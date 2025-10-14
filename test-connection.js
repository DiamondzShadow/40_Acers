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
    console.log('✅ Connected successfully!');
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', res.rows[0].version);
    
    await client.end();
    console.log('✅ Connection test passed!');
    return true;
  } catch (error) {
    console.error('❌ Connection failed!');
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    console.log('\n⚠️  This means the PostgreSQL password is incorrect.');
    console.log('📝 Please get the correct password from:');
    console.log('   https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database');
    await client.end();
    return false;
  }
}

testConnection();
