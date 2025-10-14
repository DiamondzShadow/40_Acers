# 🚀 Run This SQL in Supabase to Create All Tables

## Step-by-Step Instructions:

### 1. Open Supabase SQL Editor
Go to: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/sql/new

### 2. Copy the SQL File
The migration SQL is in: `migrations/20251014201106_cuddly_robbie_robertson.sql`

### 3. Run the SQL
- Paste the entire SQL file content into the SQL Editor
- Click "Run" button at the bottom right
- Wait for it to complete (should take a few seconds)

### 4. Verify Tables Were Created
- Go to Table Editor: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/editor
- You should now see all 42 tables!

## Tables That Will Be Created (42 total):

✅ Core Tables (10):
- users, properties, investments, transactions, documents
- sessions, wallets, payment_transactions, payment_methods, user_profiles

✅ Social & Community (9):
- community_posts, post_likes, post_comments, user_follows
- user_achievements, user_activity, challenges, challenge_participants, leaderboard

✅ Investment Features (7):
- investor_tiers, tokenomics_config, investment_tiers
- user_investment_accounts, withdrawal_requests
- milestone_performance, recurring_investments

✅ Documents & Verification (4):
- document_reviews, verifiers, document_templates, property_reports

✅ External Integrations (6):
- hubspot_contacts, hubspot_deals, social_investors
- sync_sessions, listing_fees, wallet_transactions

✅ Analytics & Security (6):
- user_sessions, property_analytics, user_devices
- security_logs, api_metrics, cache_metrics

## After Running:

Your Supabase database will be fully set up with:
- ✅ All 42 tables
- ✅ All foreign key relationships
- ✅ All indexes
- ✅ All constraints

Then you can start using your application! 🎉
