const { Client } = require('pg');

const DATABASE_URL = "postgresql://postgres.kkaidegysdobcmflffey:10tenThousand100@aws-0-us-west-1.pooler.supabase.com:6543/postgres";

async function testSupabase() {
  const client = new Client({ connectionString: DATABASE_URL });
  
  try {
    console.log('🔌 Testing PostgreSQL connection to Supabase...\n');
    
    await client.connect();
    console.log('✅ Connected successfully to PostgreSQL!\n');
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', res.rows[0].version.substring(0, 40) + '...\n');
    
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`📋 Current tables in database: ${tables.rows.length}`);
    if (tables.rows.length > 0) {
      console.log('Tables found:');
      tables.rows.forEach(row => console.log('   -', row.table_name));
    } else {
      console.log('   ⚠️  No tables yet - need to run migration!\n');
    }
    
    await client.end();
    console.log('\n✅ SUPABASE IS STRONG AND WORKING! 💪');
    console.log('\nNext step: Run migration to create tables');
    console.log('   npm run db:push\n');
    
  } catch (error) {
    console.error('\n❌ CONNECTION FAILED!');
    console.error('Error:', error.message);
    console.log('\n⚠️  The password "10tenThousand$$" is INCORRECT for this PostgreSQL database');
    console.log('\n📝 To fix this:');
    console.log('1. Go to: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database');
    console.log('2. Find "Database Password" section');
    console.log('3. Reset the password and copy it');
    console.log('4. Update line 21 in .env file with the correct password\n');
    
    try { await client.end(); } catch {}
    process.exit(1);
  }
}

testSupabase();
