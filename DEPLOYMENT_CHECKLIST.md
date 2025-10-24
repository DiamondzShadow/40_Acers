# 🚀 Live Deployment Checklist

## Current Status: **NOT PRODUCTION READY** ⚠️

Your application is configured for Supabase but missing critical production setup.

---

## ❌ BLOCKING ISSUES (Must Fix Before Going Live)

### 1. 🔴 **CRITICAL: No .env File**
**Status:** Missing  
**Risk:** Application cannot connect to database

**Action Required:**
```bash
# Create .env file in root directory
cp .env.example .env
```

Then edit `.env` and add:
1. **Database Password** - Get from [Supabase Dashboard](https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database)
   - Replace `[YOUR-PASSWORD]` in `DATABASE_URL`
2. **Session Secret** - Generate a strong random string
3. **API Keys** - See section below

---

### 2. 🔴 **CRITICAL: Row Level Security (RLS) Not Enabled**
**Status:** ⚠️ Database is EXPOSED without RLS  
**Risk:** Anyone with database credentials can access ALL user data

**Why This is Critical:**
Your platform handles:
- 💰 Investment amounts and transactions
- 🏦 Bank account information
- 📄 Legal documents (deeds, titles)
- 🔐 Personal user information

**Action Required:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/kkaidegysdobcmflffey)
2. Navigate to: **SQL Editor**
3. Run the RLS enable script from `SUPABASE_RLS_POLICIES.md` (lines 14-57)
4. Then create basic policies (see `SUPABASE_RLS_POLICIES.md` for templates)

**Estimated Time:** 30 minutes

---

### 3. 🟡 **HIGH PRIORITY: File Storage Not Configured**
**Status:** Using local filesystem (won't work in production)  
**Risk:** Uploaded files will be lost on deployment

**Files That Need Storage:**
- Property images
- Property videos  
- Legal documents (deeds, titles, LLC docs)
- User profile images
- Document uploads

**Action Required:**
See `SUPABASE_STORAGE_SETUP.md` for detailed instructions

**Estimated Time:** 20 minutes

---

## 🔑 Required API Keys & Credentials

### Database (CRITICAL)
- [ ] `DATABASE_URL` - Get password from Supabase Dashboard
- [ ] `SUPABASE_URL` - Already configured ✅
- [ ] `SUPABASE_ANON_KEY` - Already configured ✅
- [ ] `SUPABASE_SERVICE_ROLE_KEY` - Already configured ✅

### Payment Providers (CRITICAL for transactions)
- [ ] `STRIPE_SECRET_KEY` - Production key from [Stripe Dashboard](https://dashboard.stripe.com)
- [ ] `STRIPE_PUBLISHABLE_KEY` - Production key
- [ ] `VITE_STRIPE_PUBLISHABLE_KEY` - Same as above (for client)
- [ ] `PAYPAL_CLIENT_ID` - Production credentials
- [ ] `PAYPAL_CLIENT_SECRET` - Production credentials
- [ ] Change `PAYPAL_MODE` to `production`

### OAuth Providers (For user login)
- [ ] `GOOGLE_CLIENT_ID` - From [Google Cloud Console](https://console.cloud.google.com)
- [ ] `GOOGLE_CLIENT_SECRET`
- [ ] `GITHUB_CLIENT_ID` - From [GitHub Settings](https://github.com/settings/developers)
- [ ] `GITHUB_CLIENT_SECRET`
- [ ] `DISCORD_CLIENT_ID` - From [Discord Developer Portal](https://discord.com/developers)
- [ ] `DISCORD_CLIENT_SECRET`
- [ ] `MICROSOFT_CLIENT_ID` - From [Azure Portal](https://portal.azure.com)
- [ ] `MICROSOFT_CLIENT_SECRET`

### External Services
- [ ] `HUBSPOT_API_KEY` - For CRM integration (optional)
- [ ] `OPENAI_API_KEY` - If using AI features (optional)
- [ ] `GOOGLE_MAPS_API_KEY` - For property maps

### Security
- [ ] `SESSION_SECRET` - Generate: `openssl rand -base64 32`
- [ ] `NODE_ENV=production`
- [ ] `APP_URL` - Your production domain (e.g., `https://yourdomain.com`)

---

## 📋 Pre-Deployment Checklist

### Local Testing
- [ ] Create `.env` file with all credentials
- [ ] Run `npm install` to ensure dependencies are installed
- [ ] Run `npm run db:push` to sync schema to Supabase
- [ ] Run `npm run dev` and verify application starts
- [ ] Test user registration/login
- [ ] Test property listing creation
- [ ] Test investment transaction flow
- [ ] Test file uploads
- [ ] Test payment processing (use Stripe test mode first)

### Security Hardening
- [ ] Enable RLS on all 42 tables (**CRITICAL**)
- [ ] Create RLS policies for each table
- [ ] Set up Supabase Storage RLS policies
- [ ] Verify `SUPABASE_SERVICE_ROLE_KEY` is server-only (never exposed to client)
- [ ] Add rate limiting (already configured in `performanceMiddleware.ts` ✅)
- [ ] Review security logs setup

### Database
- [ ] Verify all 42 tables exist in Supabase
- [ ] Check foreign key relationships
- [ ] Set up database backups in Supabase
- [ ] Configure database monitoring/alerts

### File Storage
- [ ] Create 5 storage buckets in Supabase:
  - `property-images` (public)
  - `property-videos` (public)
  - `legal-documents` (private)
  - `user-uploads` (private)
  - `profile-images` (public)
- [ ] Configure bucket policies
- [ ] Migrate existing uploads from `uploads/` directory
- [ ] Update file upload code to use Supabase Storage

---

## 🚀 Deployment Steps

### Option 1: Deploy to Railway (Recommended)

1. **Install Railway CLI:**
```bash
npm i -g @railway/cli
railway login
```

2. **Create Railway Project:**
```bash
railway init
```

3. **Add Environment Variables:**
```bash
railway variables set DATABASE_URL="postgresql://postgres.kkaidegysdobcmflffey:[PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
railway variables set USE_SUPABASE="true"
railway variables set SUPABASE_URL="https://kkaidegysdobcmflffey.supabase.co"
# ... add all other env vars from .env file
```

4. **Deploy:**
```bash
railway up
```

Your `railway.json` is already configured ✅

---

### Option 2: Deploy to Vercel

1. **Install Vercel CLI:**
```bash
npm i -g vercel
vercel login
```

2. **Deploy:**
```bash
vercel
```

3. **Add Environment Variables:**
Go to Vercel Dashboard → Your Project → Settings → Environment Variables
Add all variables from `.env.example`

**Note:** Your `vercel.json` needs updating - it has incomplete env var references

---

## 🔍 Post-Deployment Verification

### Smoke Tests
- [ ] Application loads without errors
- [ ] User can register/login
- [ ] Property listings display correctly
- [ ] Investment flow works end-to-end
- [ ] File uploads work
- [ ] Payment processing works
- [ ] OAuth login works for all providers
- [ ] Database queries execute successfully

### Monitoring Setup
- [ ] Set up Supabase monitoring dashboard
- [ ] Configure error tracking (Sentry recommended)
- [ ] Set up uptime monitoring
- [ ] Configure database backup schedule
- [ ] Set up alerts for critical errors

### Performance
- [ ] Test page load times
- [ ] Verify API response times
- [ ] Check database query performance
- [ ] Test under load (optional but recommended)

---

## 🆘 Common Issues & Solutions

### "Cannot connect to database"
**Solution:** Verify `DATABASE_URL` password is correct in `.env`

### "Permission denied for table"
**Solution:** RLS policies are blocking access - review policies or use service role key

### "File upload fails"
**Solution:** Supabase Storage not configured - see `SUPABASE_STORAGE_SETUP.md`

### "OAuth login fails"
**Solution:** Update redirect URLs in OAuth provider settings to match production domain

### "Payment processing fails"
**Solution:** Verify Stripe/PayPal keys are production keys (not test keys)

---

## 📊 Deployment Timeline

### Immediate (Today)
1. ✅ Create `.env` file with credentials (15 min)
2. ✅ Enable RLS on database (30 min)
3. ✅ Test locally (30 min)

### Short Term (This Week)
4. ✅ Set up Supabase Storage (20 min)
5. ✅ Deploy to Railway/Vercel (30 min)
6. ✅ Configure custom domain (15 min)
7. ✅ Run post-deployment tests (1 hour)

### Medium Term (Next Week)
8. ✅ Migrate existing files to Supabase Storage
9. ✅ Set up monitoring and alerts
10. ✅ Configure backups
11. ✅ Load testing (optional)

---

## 🎯 Next Immediate Actions

**Start here (in order):**

1. **Get Database Password:**
   - Go to: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database
   - Copy the password (or reset it)

2. **Create .env file:**
   ```bash
   cp .env.example .env
   # Edit .env and add the database password
   ```

3. **Test Locally:**
   ```bash
   npm install
   npm run db:push
   npm run dev
   ```

4. **Enable RLS (CRITICAL):**
   - Open Supabase SQL Editor
   - Run script from `SUPABASE_RLS_POLICIES.md`

5. **Deploy:**
   - Choose Railway or Vercel
   - Follow deployment steps above

---

## 📞 Support Resources

- **Supabase Dashboard:** https://supabase.com/dashboard/project/kkaidegysdobcmflffey
- **Supabase Docs:** https://supabase.com/docs
- **Railway Docs:** https://docs.railway.app
- **Vercel Docs:** https://vercel.com/docs

---

## ✅ Quick Summary

**What Works:**
- ✅ Code is production-ready
- ✅ Database schema configured (42 tables)
- ✅ No linter errors
- ✅ Deployment configs exist
- ✅ Payment providers configured
- ✅ OAuth providers configured

**What's Missing:**
- ❌ No `.env` file (blocking)
- ❌ RLS not enabled (security critical)
- ⚠️ File storage not configured
- ⚠️ No production API keys
- ⚠️ Not deployed

**Estimated Time to Go Live:** 2-3 hours for MVP deployment

---

**Last Updated:** 2025-10-24  
**Status:** Configured but Not Production Ready
