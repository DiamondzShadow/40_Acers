const { Client } = require('pg');

const password = 'TVDIHmRcKQXnn7q0';
const projectRef = 'kkaidegysdobcmflffey';

// Connection configurations with SSL options
const configs = [
  {
    name: 'Pooler with SSL disabled',
    connectionString: `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres`,
    ssl: false
  },
  {
    name: 'Pooler with SSL reject unauthorized false',
    connectionString: `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres`,
    ssl: { rejectUnauthorized: false }
  },
  {
    name: 'Session pooler with SSL reject unauthorized false',
    connectionString: `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:5432/postgres`,
    ssl: { rejectUnauthorized: false }
  },
  {
    name: 'Direct connection with SSL reject unauthorized false',
    connectionString: `postgresql://postgres:${password}@db.${projectRef}.supabase.co:5432/postgres`,
    ssl: { rejectUnauthorized: false }
  },
];

async function testConnection(config, index) {
  const client = new Client({
    connectionString: config.connectionString,
    ssl: config.ssl
  });
  
  try {
    console.log(`\n[${index + 1}/${configs.length}] Testing: ${config.name}`);
    
    await client.connect();
    console.log('✅ CONNECTED SUCCESSFULLY!');
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL:', res.rows[0].version.substring(0, 50) + '...');
    
    const tables = await client.query(`
      SELECT COUNT(*) as count
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`📋 Tables in database: ${tables.rows[0].count}`);
    
    await client.end();
    
    console.log('\n🎉 SUPABASE IS STRONG! 💪');
    console.log('\n✅ WORKING CONFIGURATION:');
    console.log('Connection:', config.connectionString);
    console.log('SSL:', JSON.stringify(config.ssl));
    return true;
    
  } catch (error) {
    console.log(`❌ Failed: ${error.message}`);
    try { await client.end(); } catch {}
    return false;
  }
}

async function findWorkingConnection() {
  console.log('🔍 Testing Supabase connections with SSL configurations...');
  console.log(`Project: ${projectRef}`);
  console.log(`Password: ${password.substring(0, 4)}***${password.substring(password.length - 4)}\n`);
  
  for (let i = 0; i < configs.length; i++) {
    const success = await testConnection(configs[i], i);
    if (success) {
      console.log('\n📝 Update your .env file to use this connection');
      console.log('\n🚀 Next step: Migrate tables');
      console.log('   npm run db:push\n');
      return;
    }
  }
  
  console.log('\n❌ All connection attempts failed!');
  console.log('\n⚠️  Please check in Supabase Dashboard:');
  console.log('1. Is the database "Active" (not paused)?');
  console.log('2. Is the project in the correct region?');
  console.log('3. Copy the exact connection string from Dashboard\n');
  console.log('Check: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database\n');
}

findWorkingConnection();
