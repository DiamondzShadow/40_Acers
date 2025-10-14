CREATE TABLE "api_metrics" (
	"id" serial PRIMARY KEY NOT NULL,
	"endpoint" text NOT NULL,
	"method" text NOT NULL,
	"response_time" integer,
	"status_code" integer NOT NULL,
	"user_id" text,
	"ip_address" text,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	"error_message" text
);
--> statement-breakpoint
CREATE TABLE "cache_metrics" (
	"id" serial PRIMARY KEY NOT NULL,
	"cache_key" text NOT NULL,
	"hit_rate" numeric(5, 2),
	"miss_rate" numeric(5, 2),
	"avg_response_time" integer,
	"total_requests" integer DEFAULT 0,
	"date" date NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "challenge_participants" (
	"id" serial PRIMARY KEY NOT NULL,
	"challenge_id" integer NOT NULL,
	"user_id" text NOT NULL,
	"progress" integer DEFAULT 0,
	"completed" boolean DEFAULT false,
	"joined_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "challenges" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"type" text NOT NULL,
	"rules" jsonb,
	"rewards" jsonb,
	"start_date" timestamp NOT NULL,
	"end_date" timestamp NOT NULL,
	"is_active" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "community_posts" (
	"id" serial PRIMARY KEY NOT NULL,
	"author_id" varchar NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"content" text NOT NULL,
	"property_id" integer,
	"image_url" text,
	"likes_count" integer DEFAULT 0,
	"comments_count" integer DEFAULT 0,
	"shares_count" integer DEFAULT 0,
	"is_public" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "document_reviews" (
	"id" serial PRIMARY KEY NOT NULL,
	"document_id" integer NOT NULL,
	"reviewer_id" varchar NOT NULL,
	"status" text NOT NULL,
	"comments" text,
	"checklist" jsonb,
	"reviewed_at" timestamp DEFAULT now(),
	"estimated_review_time" integer
);
--> statement-breakpoint
CREATE TABLE "document_templates" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"document_type" text NOT NULL,
	"description" text,
	"requirements" jsonb,
	"template_url" text,
	"is_required" boolean DEFAULT false,
	"order_index" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "documents" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"property_id" integer,
	"filename" text NOT NULL,
	"original_name" text NOT NULL,
	"file_url" text NOT NULL,
	"file_size" integer NOT NULL,
	"mime_type" text NOT NULL,
	"document_type" text NOT NULL,
	"category" text,
	"status" text DEFAULT 'pending' NOT NULL,
	"verification_notes" text,
	"verified_by" varchar,
	"verified_at" timestamp,
	"rejection_reason" text,
	"tags" text[],
	"is_public" boolean DEFAULT false,
	"expires_at" timestamp,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "hubspot_contacts" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"hubspot_contact_id" text NOT NULL,
	"email" text NOT NULL,
	"first_name" text,
	"last_name" text,
	"phone" text,
	"company" text,
	"job_title" text,
	"lead_source" text,
	"lifecycle_stage" text,
	"last_activity_date" timestamp,
	"total_investments" numeric(12, 2) DEFAULT '0',
	"sync_status" text DEFAULT 'active',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "hubspot_contacts_hubspot_contact_id_unique" UNIQUE("hubspot_contact_id")
);
--> statement-breakpoint
CREATE TABLE "hubspot_deals" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"property_id" integer,
	"hubspot_deal_id" text NOT NULL,
	"deal_name" text NOT NULL,
	"amount" numeric(12, 2) NOT NULL,
	"stage" text NOT NULL,
	"pipeline" text NOT NULL,
	"close_date" timestamp,
	"probability" integer DEFAULT 0,
	"deal_type" text,
	"source" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "hubspot_deals_hubspot_deal_id_unique" UNIQUE("hubspot_deal_id")
);
--> statement-breakpoint
CREATE TABLE "investment_tiers" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"min_investment" text NOT NULL,
	"max_investment" text,
	"lockup_period_months" integer NOT NULL,
	"withdrawal_frequency_days" integer NOT NULL,
	"early_withdrawal_penalty" numeric(5, 2),
	"benefits" text[],
	"description" text,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "investments" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"property_id" integer NOT NULL,
	"shares_purchased" integer NOT NULL,
	"investment_amount" numeric(12, 2) NOT NULL,
	"purchase_price" numeric(10, 2) NOT NULL,
	"payment_transaction_id" integer,
	"investor_tier" text DEFAULT 'dao' NOT NULL,
	"tier_benefits_active" boolean DEFAULT true,
	"lockup_end_date" timestamp,
	"is_early_investor" boolean DEFAULT false,
	"bonus_tokens_earned" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "investor_tiers" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"property_id" integer NOT NULL,
	"current_tier" text DEFAULT 'dao' NOT NULL,
	"total_tokens_owned" integer DEFAULT 0,
	"tier_achieved_at" timestamp DEFAULT now(),
	"nft_certificate_issued" boolean DEFAULT false,
	"lifetime_yield_bonus" numeric(5, 2) DEFAULT '0',
	"voting_rights" boolean DEFAULT false,
	"exclusive_access" boolean DEFAULT false,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "leaderboard" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"category" text NOT NULL,
	"score" integer DEFAULT 0,
	"rank" integer DEFAULT 0,
	"achievements" text[] DEFAULT '{}',
	"last_updated" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "listing_fees" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"user_id" text NOT NULL,
	"property_value" text NOT NULL,
	"fee_percentage" numeric(5, 2) NOT NULL,
	"calculated_fee" text NOT NULL,
	"payment_transaction_id" integer,
	"status" text DEFAULT 'pending' NOT NULL,
	"paid_at" timestamp,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "milestone_performance" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"milestone_type" text NOT NULL,
	"target_date" timestamp NOT NULL,
	"actual_date" timestamp,
	"target_return" numeric(10, 2),
	"actual_return" numeric(10, 2),
	"performance_score" numeric(5, 2),
	"distribution_amount" text,
	"distribution_date" timestamp,
	"status" text DEFAULT 'pending' NOT NULL,
	"notes" text,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "payment_methods" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"stripe_payment_method_id" text NOT NULL,
	"type" text NOT NULL,
	"last4" text,
	"brand" text,
	"expiry_month" integer,
	"expiry_year" integer,
	"is_default" boolean DEFAULT false,
	"is_verified" boolean DEFAULT false,
	"metadata" json,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "payment_methods_stripe_payment_method_id_unique" UNIQUE("stripe_payment_method_id")
);
--> statement-breakpoint
CREATE TABLE "payment_transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"property_id" integer,
	"stripe_payment_intent_id" text,
	"paypal_order_id" text,
	"transaction_type" text NOT NULL,
	"amount" text NOT NULL,
	"currency" text DEFAULT 'USD' NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"payment_method" text NOT NULL,
	"receipt_url" text,
	"receipt_number" text,
	"metadata" jsonb,
	"created_at" timestamp DEFAULT now(),
	"completed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "post_comments" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"post_id" integer NOT NULL,
	"content" text NOT NULL,
	"parent_id" integer,
	"likes_count" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "post_likes" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"post_id" integer NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "properties" (
	"id" serial PRIMARY KEY NOT NULL,
	"owner_id" varchar NOT NULL,
	"address" text NOT NULL,
	"city" text NOT NULL,
	"state" text NOT NULL,
	"zipcode" text NOT NULL,
	"latitude" numeric(10, 8),
	"longitude" numeric(11, 8),
	"property_value" numeric(12, 2) NOT NULL,
	"square_footage" integer NOT NULL,
	"max_shares" integer NOT NULL,
	"share_price" numeric(10, 2) NOT NULL,
	"current_shares" integer DEFAULT 0 NOT NULL,
	"thumbnail_url" text,
	"property_type" text DEFAULT 'Townhouse' NOT NULL,
	"description" text,
	"bedrooms" integer,
	"bathrooms" numeric(3, 1),
	"year_built" integer,
	"lot_size" numeric(10, 2),
	"parking" text,
	"amenities" text[],
	"nearby_schools" text[],
	"walk_score" integer,
	"crime_rating" text,
	"market_trends" text,
	"rental_yield" numeric(5, 2),
	"appreciation_rate" numeric(5, 2),
	"status" text DEFAULT 'pending' NOT NULL,
	"deed_documents" text[],
	"title_documents" text[],
	"llc_documents" text[],
	"property_images" text[],
	"property_videos" text[],
	"zoom_meeting_url" text,
	"zoom_meeting_id" text,
	"zoom_password" text,
	"verification_status" text DEFAULT 'pending' NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "property_analytics" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"date" date NOT NULL,
	"views" integer DEFAULT 0,
	"unique_views" integer DEFAULT 0,
	"inquiries" integer DEFAULT 0,
	"investments" integer DEFAULT 0,
	"total_investment_amount" numeric(12, 2) DEFAULT '0',
	"average_time_on_page" integer DEFAULT 0,
	"bounce_rate" numeric(5, 2) DEFAULT '0',
	"conversion_rate" numeric(5, 2) DEFAULT '0',
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "property_reports" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"sender_id" varchar NOT NULL,
	"title" text NOT NULL,
	"content" text NOT NULL,
	"report_type" text DEFAULT 'update' NOT NULL,
	"attachments" text[] DEFAULT '{}',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "recurring_investments" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"property_id" integer,
	"payment_method_id" integer NOT NULL,
	"amount" numeric(12, 2) NOT NULL,
	"frequency" text NOT NULL,
	"next_payment_date" timestamp NOT NULL,
	"is_active" boolean DEFAULT true,
	"total_payments" integer DEFAULT 0,
	"failed_payments" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "security_logs" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text,
	"action" text NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"location" text,
	"risk_level" text DEFAULT 'low',
	"blocked" boolean DEFAULT false,
	"reason" text,
	"metadata" json,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"sid" varchar PRIMARY KEY NOT NULL,
	"sess" jsonb NOT NULL,
	"expire" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "social_investors" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"property_id" integer NOT NULL,
	"platform" text NOT NULL,
	"profile_url" text NOT NULL,
	"profile_image_url" text,
	"display_name" text NOT NULL,
	"username" text NOT NULL,
	"investment_amount" text NOT NULL,
	"shares_owned" integer NOT NULL,
	"investment_date" timestamp DEFAULT now() NOT NULL,
	"is_public" boolean DEFAULT true NOT NULL,
	"follower_count" integer,
	"verified_account" boolean DEFAULT false,
	"location" text
);
--> statement-breakpoint
CREATE TABLE "sync_sessions" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"session_id" varchar NOT NULL,
	"device_type" text NOT NULL,
	"device_id" varchar,
	"last_sync_at" timestamp DEFAULT now(),
	"is_active" boolean DEFAULT true,
	"app_version" text,
	"platform" text,
	CONSTRAINT "sync_sessions_session_id_unique" UNIQUE("session_id")
);
--> statement-breakpoint
CREATE TABLE "tokenomics_config" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"max_tokenized_value" numeric(12, 2) NOT NULL,
	"base_token_price" numeric(10, 2) NOT NULL,
	"platform_fee_percentage" numeric(5, 2) DEFAULT '5.00',
	"final_token_price" numeric(10, 2) NOT NULL,
	"max_token_supply" integer NOT NULL,
	"current_tokens_sold" integer DEFAULT 0,
	"scarcity_model" boolean DEFAULT false,
	"founder_tier_cap" integer NOT NULL,
	"community_tier_cap" integer NOT NULL,
	"soft_cap_percentage" numeric(5, 2) DEFAULT '60.00',
	"lockup_period_months" integer DEFAULT 12,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"property_id" integer,
	"type" text NOT NULL,
	"amount" numeric(10, 2) NOT NULL,
	"shares" integer,
	"status" text DEFAULT 'pending' NOT NULL,
	"email" varchar,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "user_achievements" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"earned_at" timestamp DEFAULT now(),
	"is_public" boolean DEFAULT true
);
--> statement-breakpoint
CREATE TABLE "user_activity" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"metadata" jsonb,
	"is_public" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "user_devices" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"device_id" text NOT NULL,
	"device_name" text,
	"device_type" text,
	"browser" text,
	"os" text,
	"ip_address" text,
	"is_verified" boolean DEFAULT false,
	"is_trusted" boolean DEFAULT false,
	"last_used" timestamp DEFAULT now() NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "user_devices_device_id_unique" UNIQUE("device_id")
);
--> statement-breakpoint
CREATE TABLE "user_follows" (
	"id" serial PRIMARY KEY NOT NULL,
	"follower_id" varchar NOT NULL,
	"following_id" varchar NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "user_investment_accounts" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"tier_id" integer NOT NULL,
	"total_invested" text NOT NULL,
	"available_balance" text NOT NULL,
	"locked_balance" text NOT NULL,
	"last_withdrawal_date" timestamp,
	"next_eligible_withdrawal" timestamp,
	"account_status" text DEFAULT 'active' NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "user_profiles" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"risk_tolerance" text DEFAULT 'moderate' NOT NULL,
	"investment_goals" text[] DEFAULT '{}',
	"budget_min" integer DEFAULT 0,
	"budget_max" integer DEFAULT 10000,
	"preferred_locations" text[] DEFAULT '{}',
	"property_types" text[] DEFAULT '{}',
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "user_sessions" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text,
	"session_id" text NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"referrer" text,
	"landing_page" text,
	"exit_page" text,
	"duration" integer,
	"page_views" integer DEFAULT 1,
	"bounced" boolean DEFAULT false,
	"converted" boolean DEFAULT false,
	"conversion_type" text,
	"device_type" text,
	"browser" text,
	"country" text,
	"city" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "user_sessions_session_id_unique" UNIQUE("session_id")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" varchar PRIMARY KEY NOT NULL,
	"email" varchar,
	"first_name" varchar,
	"last_name" varchar,
	"profile_image_url" varchar,
	"user_type" text DEFAULT 'investor' NOT NULL,
	"business_name" text,
	"business_verified" boolean DEFAULT false NOT NULL,
	"stripe_customer_id" text,
	"bio" text,
	"location" text,
	"investment_style" text,
	"total_investments" numeric(12, 2) DEFAULT '0',
	"total_earnings" numeric(12, 2) DEFAULT '0',
	"community_rank" integer DEFAULT 0,
	"followers_count" integer DEFAULT 0,
	"following_count" integer DEFAULT 0,
	"is_online" boolean DEFAULT false,
	"last_seen" timestamp,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now(),
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "verifiers" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar NOT NULL,
	"role" text NOT NULL,
	"specializations" text[],
	"license_number" text,
	"bar_association" text,
	"is_active" boolean DEFAULT true,
	"review_count" integer DEFAULT 0,
	"average_review_time" numeric(5, 2),
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "wallet_transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"wallet_id" integer NOT NULL,
	"payment_transaction_id" integer,
	"transaction_type" text NOT NULL,
	"amount" text NOT NULL,
	"balance_before" text NOT NULL,
	"balance_after" text NOT NULL,
	"description" text,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "wallets" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"balance" text DEFAULT '0' NOT NULL,
	"currency" text DEFAULT 'USD' NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "withdrawal_requests" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"account_id" integer NOT NULL,
	"property_id" integer,
	"requested_amount" text NOT NULL,
	"available_amount" text NOT NULL,
	"withdrawal_type" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"processing_fee" text,
	"penalty_amount" text,
	"net_amount" text,
	"reason" text,
	"approved_by" text,
	"approved_at" timestamp,
	"processed_at" timestamp,
	"bank_details" jsonb,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "api_metrics" ADD CONSTRAINT "api_metrics_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "challenge_participants" ADD CONSTRAINT "challenge_participants_challenge_id_challenges_id_fk" FOREIGN KEY ("challenge_id") REFERENCES "public"."challenges"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "challenge_participants" ADD CONSTRAINT "challenge_participants_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hubspot_contacts" ADD CONSTRAINT "hubspot_contacts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hubspot_deals" ADD CONSTRAINT "hubspot_deals_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hubspot_deals" ADD CONSTRAINT "hubspot_deals_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "leaderboard" ADD CONSTRAINT "leaderboard_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "listing_fees" ADD CONSTRAINT "listing_fees_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "listing_fees" ADD CONSTRAINT "listing_fees_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "listing_fees" ADD CONSTRAINT "listing_fees_payment_transaction_id_payment_transactions_id_fk" FOREIGN KEY ("payment_transaction_id") REFERENCES "public"."payment_transactions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "milestone_performance" ADD CONSTRAINT "milestone_performance_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_methods" ADD CONSTRAINT "payment_methods_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_transactions" ADD CONSTRAINT "payment_transactions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_transactions" ADD CONSTRAINT "payment_transactions_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "property_analytics" ADD CONSTRAINT "property_analytics_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "property_reports" ADD CONSTRAINT "property_reports_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "property_reports" ADD CONSTRAINT "property_reports_sender_id_users_id_fk" FOREIGN KEY ("sender_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_investments" ADD CONSTRAINT "recurring_investments_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_investments" ADD CONSTRAINT "recurring_investments_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_investments" ADD CONSTRAINT "recurring_investments_payment_method_id_payment_methods_id_fk" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_methods"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "security_logs" ADD CONSTRAINT "security_logs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "social_investors" ADD CONSTRAINT "social_investors_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_devices" ADD CONSTRAINT "user_devices_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_investment_accounts" ADD CONSTRAINT "user_investment_accounts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_investment_accounts" ADD CONSTRAINT "user_investment_accounts_tier_id_investment_tiers_id_fk" FOREIGN KEY ("tier_id") REFERENCES "public"."investment_tiers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_wallet_id_wallets_id_fk" FOREIGN KEY ("wallet_id") REFERENCES "public"."wallets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_payment_transaction_id_payment_transactions_id_fk" FOREIGN KEY ("payment_transaction_id") REFERENCES "public"."payment_transactions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_account_id_user_investment_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."user_investment_accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_property_id_properties_id_fk" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "IDX_session_expire" ON "sessions" USING btree ("expire");