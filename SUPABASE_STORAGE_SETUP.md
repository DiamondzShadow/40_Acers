# 📦 Supabase Storage Setup Guide

## Overview
Migrate your file uploads (property images, documents, videos) from local filesystem to Supabase Storage for better scalability and CDN support.

---

## Current File Storage in Your App

Based on your schema, you're storing files in:

1. **Property Media:**
   - `property_images` (array of URLs)
   - `property_videos` (array of URLs)
   - `thumbnail_url`

2. **Legal Documents:**
   - `deed_documents` (array of URLs)
   - `title_documents` (array of URLs)
   - `llc_documents` (array of URLs)

3. **Document Management:**
   - `documents` table with `file_url` field
   - Currently stored in `uploads/` directory

4. **User Profiles:**
   - `profile_image_url`

---

## Step 1: Create Storage Buckets

Go to Supabase Dashboard → Storage and create these buckets:

### 1. Property Images Bucket
```javascript
// Bucket name: property-images
// Public: Yes (so images can be displayed)
// File size limit: 10MB
// Allowed MIME types: image/jpeg, image/png, image/webp
```

### 2. Property Videos Bucket
```javascript
// Bucket name: property-videos
// Public: Yes
// File size limit: 100MB
// Allowed MIME types: video/mp4, video/quicktime
```

### 3. Documents Bucket
```javascript
// Bucket name: documents
// Public: No (sensitive documents)
// File size limit: 20MB
// Allowed MIME types: application/pdf, image/jpeg, image/png
```

### 4. Profile Images Bucket
```javascript
// Bucket name: avatars
// Public: Yes
// File size limit: 5MB
// Allowed MIME types: image/jpeg, image/png, image/webp
```

---

## Step 2: Set Up Storage Policies

### Property Images (Public Access)

```sql
-- Anyone can view property images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'property-images');

-- Property owners can upload images for their properties
CREATE POLICY "Property owners can upload images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'property-images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Property owners can delete their images
CREATE POLICY "Property owners can delete images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'property-images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

### Documents (Private Access with Signed URLs)

```sql
-- Users can view their own documents
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can upload their own documents
CREATE POLICY "Users can upload own documents"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Verifiers can view all documents
CREATE POLICY "Verifiers can view documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  EXISTS (
    SELECT 1 FROM verifiers
    WHERE user_id = auth.uid() AND is_active = true
  )
);
```

### Profile Images (Public)

```sql
-- Anyone can view avatars
CREATE POLICY "Public Access to avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Users can upload their own avatar
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own avatar
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## Step 3: Create Upload Utility

Create `server/storage.ts` (or update existing):

```typescript
import { supabase } from './db';

export async function uploadPropertyImage(
  userId: string,
  propertyId: number,
  file: File | Buffer,
  filename: string
): Promise<string> {
  const path = `${userId}/properties/${propertyId}/${Date.now()}-${filename}`;
  
  const { data, error } = await supabase.storage
    .from('property-images')
    .upload(path, file, {
      cacheControl: '3600',
      upsert: false
    });

  if (error) throw error;

  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('property-images')
    .getPublicUrl(path);

  return publicUrl;
}

export async function uploadDocument(
  userId: string,
  file: File | Buffer,
  filename: string,
  documentType: string
): Promise<{ path: string; url: string }> {
  const path = `${userId}/${documentType}/${Date.now()}-${filename}`;
  
  const { data, error } = await supabase.storage
    .from('documents')
    .upload(path, file);

  if (error) throw error;

  // Get signed URL (valid for 1 hour)
  const { data: { signedUrl } } = await supabase.storage
    .from('documents')
    .createSignedUrl(path, 3600);

  return { path, url: signedUrl };
}

export async function uploadProfileImage(
  userId: string,
  file: File | Buffer,
  filename: string
): Promise<string> {
  const path = `${userId}/${Date.now()}-${filename}`;
  
  const { data, error } = await supabase.storage
    .from('avatars')
    .upload(path, file, {
      cacheControl: '3600',
      upsert: true // Replace existing avatar
    });

  if (error) throw error;

  const { data: { publicUrl } } = supabase.storage
    .from('avatars')
    .getPublicUrl(path);

  return publicUrl;
}

export async function deleteFile(bucket: string, path: string) {
  const { error } = await supabase.storage
    .from(bucket)
    .remove([path]);

  if (error) throw error;
}

export async function getSignedUrl(bucket: string, path: string, expiresIn = 3600) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, expiresIn);

  if (error) throw error;
  return data.signedUrl;
}
```

---

## Step 4: Update Your Routes

### Example: Update Property Image Upload Route

```typescript
import express from 'express';
import multer from 'multer';
import { uploadPropertyImage } from './storage';

const upload = multer({ storage: multer.memoryStorage() });

app.post('/api/properties/:id/images', 
  upload.single('image'),
  async (req, res) => {
    try {
      const propertyId = parseInt(req.params.id);
      const userId = req.user.id; // from session
      const file = req.file.buffer;
      const filename = req.file.originalname;

      const imageUrl = await uploadPropertyImage(
        userId,
        propertyId,
        file,
        filename
      );

      // Update property in database
      await db.update(properties)
        .set({
          propertyImages: sql`array_append(property_images, ${imageUrl})`
        })
        .where(eq(properties.id, propertyId));

      res.json({ success: true, url: imageUrl });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);
```

### Example: Document Upload with Verification

```typescript
app.post('/api/documents/upload',
  upload.single('document'),
  async (req, res) => {
    try {
      const userId = req.user.id;
      const { documentType, propertyId } = req.body;
      const file = req.file.buffer;
      const filename = req.file.originalname;

      // Upload to Supabase Storage
      const { path, url } = await uploadDocument(
        userId,
        file,
        filename,
        documentType
      );

      // Save to database
      const [document] = await db.insert(documents).values({
        userId,
        propertyId: propertyId ? parseInt(propertyId) : null,
        filename: path,
        originalName: filename,
        fileUrl: path, // Store path, not URL
        fileSize: req.file.size,
        mimeType: req.file.mimetype,
        documentType,
        status: 'pending'
      }).returning();

      res.json({ 
        success: true, 
        document,
        signedUrl: url // Temporary access URL
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);
```

### Example: Get Document with Signed URL

```typescript
app.get('/api/documents/:id', async (req, res) => {
  try {
    const userId = req.user.id;
    const documentId = parseInt(req.params.id);

    // Get document from database
    const [document] = await db.select()
      .from(documents)
      .where(eq(documents.id, documentId))
      .limit(1);

    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }

    // Check permissions
    if (document.userId !== userId && !req.user.isVerifier) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Generate signed URL
    const signedUrl = await getSignedUrl('documents', document.fileUrl);

    res.json({
      ...document,
      downloadUrl: signedUrl
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## Step 5: Migrate Existing Files

Create a migration script:

```typescript
// scripts/migrate-files-to-supabase.ts
import { db } from '../server/db';
import { uploadPropertyImage, uploadDocument } from '../server/storage';
import fs from 'fs/promises';
import path from 'path';

async function migrateFiles() {
  // Get all properties with local images
  const propertiesWithImages = await db.select()
    .from(properties)
    .where(sql`array_length(property_images, 1) > 0`);

  for (const property of propertiesWithImages) {
    const newImageUrls = [];

    for (const imagePath of property.propertyImages || []) {
      // Check if it's a local path
      if (imagePath.startsWith('/uploads/') || imagePath.startsWith('uploads/')) {
        const localPath = path.join(process.cwd(), imagePath);
        
        try {
          const fileBuffer = await fs.readFile(localPath);
          const filename = path.basename(imagePath);
          
          // Upload to Supabase
          const newUrl = await uploadPropertyImage(
            property.ownerId,
            property.id,
            fileBuffer,
            filename
          );
          
          newImageUrls.push(newUrl);
          console.log(`Migrated: ${imagePath} -> ${newUrl}`);
        } catch (error) {
          console.error(`Failed to migrate ${imagePath}:`, error);
          newImageUrls.push(imagePath); // Keep old path if migration fails
        }
      } else {
        newImageUrls.push(imagePath); // Already migrated or external URL
      }
    }

    // Update property with new URLs
    await db.update(properties)
      .set({ propertyImages: newImageUrls })
      .where(eq(properties.id, property.id));
  }

  console.log('Migration complete!');
}

migrateFiles().catch(console.error);
```

Run the migration:
```bash
tsx scripts/migrate-files-to-supabase.ts
```

---

## Benefits of Supabase Storage

1. **CDN Integration** - Faster image loading worldwide
2. **Image Transformations** - Resize, crop, optimize on-the-fly
3. **Better Security** - Fine-grained access control with RLS
4. **Scalability** - No disk space limits
5. **Signed URLs** - Temporary access to private files
6. **Automatic Backups** - Files are backed up with database

---

## Image Optimization Example

```typescript
// Get optimized image URL
const { data: { publicUrl } } = supabase.storage
  .from('property-images')
  .getPublicUrl('path/to/image.jpg', {
    transform: {
      width: 800,
      height: 600,
      resize: 'cover',
      quality: 80
    }
  });
```

---

## Best Practices

1. **Use descriptive folder structure:** `userId/propertyId/timestamp-filename.jpg`
2. **Validate file types** before upload
3. **Limit file sizes** to prevent abuse
4. **Use signed URLs** for sensitive documents
5. **Clean up old files** when data is deleted
6. **Implement rate limiting** on upload endpoints

---

## Next Steps

1. Create storage buckets in Supabase Dashboard
2. Apply storage policies
3. Update upload routes to use Supabase Storage
4. Run migration script for existing files
5. Test thoroughly before deploying to production

Your file storage is now cloud-ready! 🚀
