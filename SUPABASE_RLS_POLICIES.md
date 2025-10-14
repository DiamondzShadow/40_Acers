# 🔒 Supabase Row Level Security (RLS) Policies

## Overview
Row Level Security (RLS) ensures that users can only access data they're authorized to see. This is critical for your investment platform with sensitive financial data.

---

## Quick Start: Enable RLS

### Step 1: Enable RLS on All Tables

Go to Supabase Dashboard → SQL Editor and run:

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE investor_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tokenomics_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_investment_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestone_performance ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_investors ENABLE ROW LEVEL SECURITY;
ALTER TABLE investment_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;
ALTER TABLE hubspot_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE hubspot_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE cache_metrics ENABLE ROW LEVEL SECURITY;
```

---

## Essential RLS Policies

### 1. Users Table

```sql
-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Public profiles visible to everyone (for social features)
CREATE POLICY "Public profiles are viewable by everyone"
ON users FOR SELECT
USING (true);

-- Only authenticated users can insert (handled by auth.users)
CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);
```

### 2. Properties Table

```sql
-- Everyone can view active properties
CREATE POLICY "Anyone can view active properties"
ON properties FOR SELECT
USING (is_active = true AND status = 'active');

-- Property owners can view their own properties
CREATE POLICY "Owners can view own properties"
ON properties FOR SELECT
USING (auth.uid() = owner_id);

-- Property owners can update their own properties
CREATE POLICY "Owners can update own properties"
ON properties FOR UPDATE
USING (auth.uid() = owner_id);

-- Business users can create properties
CREATE POLICY "Business users can create properties"
ON properties FOR INSERT
WITH CHECK (
  auth.uid() = owner_id AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type = 'business'
  )
);
```

### 3. Investments Table

```sql
-- Users can view their own investments
CREATE POLICY "Users can view own investments"
ON investments FOR SELECT
USING (auth.uid() = user_id);

-- Property owners can view investments in their properties
CREATE POLICY "Property owners can view property investments"
ON investments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM properties
    WHERE id = investments.property_id
    AND owner_id = auth.uid()
  )
);

-- Users can create their own investments
CREATE POLICY "Users can create own investments"
ON investments FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

### 4. Transactions Table

```sql
-- Users can view their own transactions
CREATE POLICY "Users can view own transactions"
ON transactions FOR SELECT
USING (auth.uid() = user_id);

-- Users can create their own transactions
CREATE POLICY "Users can create own transactions"
ON transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Only service role can update transaction status
CREATE POLICY "Service can update transaction status"
ON transactions FOR UPDATE
USING (auth.jwt() ->> 'role' = 'service_role');
```

### 5. Documents Table

```sql
-- Users can view their own documents
CREATE POLICY "Users can view own documents"
ON documents FOR SELECT
USING (auth.uid() = user_id);

-- Users can view public documents
CREATE POLICY "Anyone can view public documents"
ON documents FOR SELECT
USING (is_public = true);

-- Property owners can view property documents
CREATE POLICY "Property owners can view property documents"
ON documents FOR SELECT
USING (
  property_id IS NOT NULL AND
  EXISTS (
    SELECT 1 FROM properties
    WHERE id = documents.property_id
    AND owner_id = auth.uid()
  )
);

-- Users can upload their own documents
CREATE POLICY "Users can upload own documents"
ON documents FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Verifiers can view all documents for review
CREATE POLICY "Verifiers can view all documents"
ON documents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM verifiers
    WHERE user_id = auth.uid() AND is_active = true
  )
);

-- Verifiers can update document status
CREATE POLICY "Verifiers can update document status"
ON documents FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM verifiers
    WHERE user_id = auth.uid() AND is_active = true
  )
);
```

### 6. Community Posts Table

```sql
-- Users can view public posts
CREATE POLICY "Anyone can view public posts"
ON community_posts FOR SELECT
USING (is_public = true);

-- Users can view their own posts
CREATE POLICY "Users can view own posts"
ON community_posts FOR SELECT
USING (auth.uid() = author_id);

-- Users can create posts
CREATE POLICY "Users can create posts"
ON community_posts FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
ON community_posts FOR UPDATE
USING (auth.uid() = author_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts"
ON community_posts FOR DELETE
USING (auth.uid() = author_id);
```

### 7. Wallets Table

```sql
-- Users can view their own wallet
CREATE POLICY "Users can view own wallet"
ON wallets FOR SELECT
USING (auth.uid() = user_id);

-- Users can create their own wallet
CREATE POLICY "Users can create own wallet"
ON wallets FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Only service role can update wallet balance
CREATE POLICY "Service can update wallet balance"
ON wallets FOR UPDATE
USING (auth.jwt() ->> 'role' = 'service_role');
```

### 8. Payment Transactions Table

```sql
-- Users can view their own payment transactions
CREATE POLICY "Users can view own payment transactions"
ON payment_transactions FOR SELECT
USING (auth.uid() = user_id);

-- Users can create payment transactions
CREATE POLICY "Users can create payment transactions"
ON payment_transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Only service role can update payment status
CREATE POLICY "Service can update payment status"
ON payment_transactions FOR UPDATE
USING (auth.jwt() ->> 'role' = 'service_role');
```

### 9. Withdrawal Requests Table

```sql
-- Users can view their own withdrawal requests
CREATE POLICY "Users can view own withdrawal requests"
ON withdrawal_requests FOR SELECT
USING (auth.uid() = user_id);

-- Users can create withdrawal requests
CREATE POLICY "Users can create withdrawal requests"
ON withdrawal_requests FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Admins can approve withdrawal requests
CREATE POLICY "Admins can update withdrawal requests"
ON withdrawal_requests FOR UPDATE
USING (
  auth.jwt() ->> 'role' = 'service_role' OR
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type = 'admin'
  )
);
```

### 10. Security Logs Table

```sql
-- Users can view their own security logs
CREATE POLICY "Users can view own security logs"
ON security_logs FOR SELECT
USING (auth.uid() = user_id);

-- System can insert security logs
CREATE POLICY "Service can insert security logs"
ON security_logs FOR INSERT
WITH CHECK (auth.jwt() ->> 'role' = 'service_role');
```

---

## Admin/Service Role Policies

For tables that need admin-only access:

```sql
-- Example: Only service role can manage investor tiers
CREATE POLICY "Service role full access to investor_tiers"
ON investor_tiers
USING (auth.jwt() ->> 'role' = 'service_role');

-- Example: Only service role can manage tokenomics
CREATE POLICY "Service role full access to tokenomics"
ON tokenomics_config
USING (auth.jwt() ->> 'role' = 'service_role');
```

---

## Testing RLS Policies

### Test as User

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://kkaidegysdobcmflffey.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' // anon key
);

// This should only return the user's own investments
const { data, error } = await supabase
  .from('investments')
  .select('*');
```

### Test as Service Role

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseAdmin = createClient(
  'https://kkaidegysdobcmflffey.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' // service_role key
);

// This should return ALL investments (bypasses RLS)
const { data, error } = await supabaseAdmin
  .from('investments')
  .select('*');
```

---

## Best Practices

1. **Always enable RLS** on tables with user data
2. **Test policies thoroughly** before going to production
3. **Use service role key server-side only** for admin operations
4. **Never expose service role key** to client-side code
5. **Audit policies regularly** for security vulnerabilities
6. **Use least privilege principle** - only grant necessary permissions

---

## Apply All Policies

Run all the SQL statements above in Supabase Dashboard → SQL Editor to secure your database.

**Note:** Adjust policies based on your specific business requirements.
