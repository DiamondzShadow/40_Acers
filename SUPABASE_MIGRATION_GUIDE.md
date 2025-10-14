# 🚀 Supabase Migration Guide

## Overview
This guide will help you migrate your real estate investment platform from Neon Database to Supabase.

---

## ✅ What's Been Completed

1. ✅ **Installed Supabase Client Library** (`@supabase/supabase-js`)
2. ✅ **Updated Database Configuration** (`server/db.ts`)
3. ✅ **Updated Drizzle Config** (`drizzle.config.ts`)
4. ✅ **Created Environment Variables Templates** (`.env.example`)

---

## 🔧 Migration Steps

### Step 1: Get Your Database Connection String

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `kkaidegysdobcmflffey`
3. Navigate to: **Project Settings** → **Database**
4. Scroll down to **Connection String** section
5. Select **"URI"** tab
6. Copy the connection string (it will look like this):
   ```
   postgresql://postgres.kkaidegysdobcmflffey:[YOUR-PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres
   ```
7. **IMPORTANT:** Replace `[YOUR-PASSWORD]` with your actual database password

### Step 2: Create Your .env File

Create a `.env` file in the root directory (copy from `.env.example`):

```bash
# Required for Supabase
USE_SUPABASE=true

# Get this from Supabase Dashboard > Project Settings > Database > Connection String
DATABASE_URL=postgresql://postgres.kkaidegysdobcmflffey:[YOUR-PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# Supabase Configuration
SUPABASE_URL=https://kkaidegysdobcmflffey.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrYWlkZWd5c2RvYmNtZmxmZmV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Njg1ODQsImV4cCI6MjA3NjA0NDU4NH0.8OBxGWByrax-NyXGPEJCcFs-X3WTgyNcrT-RJjctwao
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrYWlkZWd5c2RvYmNtZmxmZmV5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDQ2ODU4NCwiZXhwIjoyMDc2MDQ0NTg0fQ.SPKLMiisxoTn__a7BybBLL6s-A7xe1gerjuB9i7Ne_A

# ... add your other environment variables (Stripe, PayPal, etc.)
```

### Step 3: Push Your Schema to Supabase

Run the following command to push your database schema to Supabase:

```bash
npm run db:push
```

This command will:
- Connect to your Supabase PostgreSQL database
- Create all 40+ tables defined in `shared/schema.ts`
- Set up all indexes and relationships

### Step 4: Verify the Migration

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to: **Table Editor**
3. You should see all your tables:
   - `users`
   - `properties`
   - `investments`
   - `transactions`
   - `community_posts`
   - `documents`
   - ... and 35+ more tables

### Step 5: Test Your Application

```bash
# Start the development server
npm run dev
```

Your application should now be running with Supabase! 🎉

---

## 🎯 Key Benefits You're Getting

### 1. **Built-in Authentication**
- Ready-to-use OAuth providers (Google, GitHub, Discord, Microsoft)
- Can replace your current Passport.js setup
- Social login with minimal configuration

### 2. **Row Level Security (RLS)**
Your schema has sensitive data that needs protection:
- Investor financial data
- Payment transactions
- Private documents
- User profiles

**Next Step:** Set up RLS policies (see `SUPABASE_RLS_POLICIES.md`)

### 3. **File Storage**
You have document management needs:
- Property images (`property_images` array in properties table)
- Property videos
- Legal documents (deeds, titles, LLC documents)
- User uploads

**Next Step:** Migrate to Supabase Storage (see `SUPABASE_STORAGE_SETUP.md`)

### 4. **Real-time Subscriptions**
Perfect for your social features:
- Live investment updates
- Community posts and comments
- Real-time notifications
- Activity feeds

**Example Usage:**
```typescript
import { supabase } from './server/db';

// Subscribe to new investments
const subscription = supabase
  .from('investments')
  .on('INSERT', payload => {
    console.log('New investment:', payload.new);
  })
  .subscribe();
```

### 5. **Better Analytics**
- Built-in analytics dashboard
- Query performance monitoring
- User session tracking
- Database health metrics

---

## 📊 Your Database Structure

### Core Tables (10)
- `users` - User accounts and profiles
- `properties` - Real estate listings
- `investments` - Investment transactions
- `transactions` - Payment transactions
- `documents` - Document management
- `sessions` - User sessions
- `wallets` - User wallets
- `payment_transactions` - Payment processing
- `payment_methods` - Saved payment methods
- `user_profiles` - User preferences

### Social & Community (8)
- `community_posts` - User posts and updates
- `post_likes` - Post engagement
- `post_comments` - Threaded comments
- `user_follows` - Social connections
- `user_achievements` - Gamification
- `user_activity` - Activity feeds
- `challenges` - Community challenges
- `leaderboard` - Rankings

### Investment Features (7)
- `investor_tiers` - Tiered investment system
- `tokenomics_config` - Token pricing
- `investment_tiers` - Investment packages
- `user_investment_accounts` - User accounts
- `withdrawal_requests` - Withdrawal processing
- `milestone_performance` - Performance tracking
- `recurring_investments` - Auto-invest feature

### Document & Verification (4)
- `document_reviews` - Review workflow
- `verifiers` - Lawyer/admin accounts
- `document_templates` - Document requirements
- `property_reports` - Property communications

### External Integrations (6)
- `hubspot_contacts` - CRM sync
- `hubspot_deals` - Sales pipeline
- `social_investors` - Social media integration
- `sync_sessions` - Cross-platform sync
- `listing_fees` - Fee management
- `wallet_transactions` - Transaction history

### Analytics & Security (8)
- `user_sessions` - Session tracking
- `property_analytics` - Property metrics
- `user_devices` - Device management
- `security_logs` - Security audit trail
- `api_metrics` - API performance
- `cache_metrics` - Cache statistics

**Total: 43 Tables** - All compatible with Supabase! ✅

---

## 🔒 Security Recommendations

### Immediate Actions:

1. **Enable Row Level Security (RLS)**
   ```sql
   -- Enable RLS on all tables
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE investments ENABLE ROW LEVEL SECURITY;
   ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
   -- ... repeat for all tables
   ```

2. **Create RLS Policies**
   ```sql
   -- Example: Users can only read their own data
   CREATE POLICY "Users can view own data"
   ON users FOR SELECT
   USING (auth.uid() = id);

   -- Example: Users can update their own profile
   CREATE POLICY "Users can update own profile"
   ON users FOR UPDATE
   USING (auth.uid() = id);
   ```

3. **Secure Document Access**
   - Set up Storage RLS for file uploads
   - Use signed URLs for temporary access
   - Implement document verification workflow

4. **Payment Security**
   - Never expose `SUPABASE_SERVICE_ROLE_KEY` to client
   - Use server-side functions for payment processing
   - Implement webhook verification

---

## 🚨 Common Issues & Solutions

### Issue: "relation does not exist"
**Solution:** Run `npm run db:push` to create tables

### Issue: "permission denied for table"
**Solution:** Check RLS policies or use service role key for admin operations

### Issue: "too many connections"
**Solution:** Use connection pooling (already configured in `DATABASE_URL`)

### Issue: "authentication failed"
**Solution:** Verify `DATABASE_URL` password is correct

---

## 📚 Next Steps

1. ✅ **Complete Schema Migration** (Run `npm run db:push`)
2. 📖 **Set Up Row Level Security** (See `SUPABASE_RLS_POLICIES.md`)
3. 📦 **Configure Storage Buckets** (See `SUPABASE_STORAGE_SETUP.md`)
4. 🔐 **Implement Supabase Auth** (Optional - can keep Passport.js)
5. 🔴 **Add Real-time Features** (Enhance user experience)
6. 📊 **Set Up Monitoring** (Use Supabase Dashboard)

---

## 🆘 Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **Drizzle ORM Docs:** https://orm.drizzle.team/docs/overview
- **Your Project Dashboard:** https://supabase.com/dashboard/project/kkaidegysdobcmflffey

---

## 🎉 You're All Set!

Your application is now configured to use Supabase. Run `npm run db:push` to complete the migration.

**Questions?** Check the troubleshooting section above or consult the Supabase documentation.
