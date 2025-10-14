const { Client } = require('pg');
require('dotenv').config();

async function testConnection() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL
  });
  
  try {
    console.log('🔌 Testing PostgreSQL connection to Supabase...');
    console.log('Connection string:', process.env.DATABASE_URL.replace(/:[^@]*@/, ':***@'));
    await client.connect();
    console.log('✅ Connected successfully to PostgreSQL!');
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', res.rows[0].version);
    
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    console.log(`📋 Current tables in database: ${tables.rows.length}`);
    if (tables.rows.length > 0) {
      tables.rows.forEach(row => console.log('   -', row.table_name));
    } else {
      console.log('   (no tables yet - need to run migration)');
    }
    
    await client.end();
    console.log('\n✅ Connection test PASSED! Supabase PostgreSQL is working!');
    return true;
  } catch (error) {
    console.error('\n❌ Connection FAILED!');
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    console.log('\n⚠️  This means the PostgreSQL password is INCORRECT.');
    console.log('\n📝 To fix this:');
    console.log('1. Go to: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database');
    console.log('2. Scroll to "Database Password" section');
    console.log('3. Either use your existing password OR click "Reset Database Password"');
    console.log('4. Update the password in .env file (line 21)');
    try { await client.end(); } catch {}
    return false;
  }
}

testConnection();
