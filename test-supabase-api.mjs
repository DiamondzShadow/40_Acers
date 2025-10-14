import { createClient } from '@supabase/supabase-js';

// These are the API credentials (NOT PostgreSQL credentials)
const supabaseUrl = 'https://kkaidegysdobcmflffey.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrYWlkZWd5c2RvYmNtZmxmZmV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Njg1ODQsImV4cCI6MjA3NjA0NDU4NH0.8OBxGWByrax-NyXGPEJCcFs-X3WTgyNcrT-RJjctwao';

async function testSupabaseAPI() {
  console.log('🔌 Testing Supabase API connection...\n');
  
  try {
    // Create Supabase client
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    console.log('✅ Supabase client created');
    console.log('URL:', supabaseUrl);
    
    // Try to query the database
    console.log('\n📊 Testing database query...');
    const { data, error } = await supabase
      .from('users')
      .select('count')
      .limit(1);
    
    if (error) {
      console.log('⚠️  Query error:', error.message);
      if (error.message.includes('relation') || error.message.includes('does not exist')) {
        console.log('\n✅ SUPABASE API IS WORKING!');
        console.log('❌ But tables dont exist yet (not migrated)');
        console.log('\n📝 This is actually GOOD NEWS!');
        console.log('It means Supabase is working, we just need to migrate tables.');
        console.log('\n🎯 The issue: We need to use drizzle-kit to push the schema');
        console.log('   But drizzle-kit needs DIRECT PostgreSQL connection');
        console.log('\n💡 Solution: Find the correct PostgreSQL connection string!');
      } else {
        console.log('Error details:', error);
      }
    } else {
      console.log('✅ Query successful!');
      console.log('Data:', data);
      console.log('\n🎉 SUPABASE IS STRONG! Tables exist and API works! 💪');
    }
    
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
  }
}

testSupabaseAPI();
