import { Pool, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';
import ws from "ws";
import * as schema from "@shared/schema";
import { createClient } from '@supabase/supabase-js';

// Configure WebSocket for serverless PostgreSQL
neonConfig.webSocketConstructor = ws;

// Determine which database to use based on environment variables
const useSupabase = process.env.USE_SUPABASE === 'true';

// Validate required environment variables
if (!process.env.DATABASE_URL) {
  throw new Error(
    "DATABASE_URL must be set. Did you forget to provision a database?",
  );
}

if (useSupabase && (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY)) {
  throw new Error(
    "SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set when USE_SUPABASE is true",
  );
}

// Create Supabase client for additional features (auth, storage, realtime)
// This is available regardless of which database you're using
export const supabase = useSupabase && process.env.SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY
  ? createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )
  : null;

// Create database connection pool (works with both Neon and Supabase PostgreSQL)
export const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Create Drizzle ORM instance
export const db = drizzle({ client: pool, schema });