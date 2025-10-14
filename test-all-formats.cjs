const { Client } = require('pg');

const password = 'TVDIHmRcKQXnn7q0';
const projectRef = 'kkaidegysdobcmflffey';

// Try all possible connection formats
const connectionStrings = [
  // Format 1: Pooler with postgres.projectRef
  `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres`,
  
  // Format 2: Pooler with postgres user
  `postgresql://postgres:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres`,
  
  // Format 3: Session pooler (port 5432)
  `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:5432/postgres`,
  
  // Format 4: Direct connection
  `postgresql://postgres:${password}@db.${projectRef}.supabase.co:5432/postgres`,
  
  // Format 5: Pooler IPv4
  `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres?sslmode=require`,
  
  // Format 6: Transaction pooler
  `postgresql://postgres.${projectRef}:${password}@aws-0-us-west-1.pooler.supabase.com:6543/postgres?pgbouncer=true`,
];

async function testConnection(url, index) {
  const client = new Client({ connectionString: url });
  
  try {
    console.log(`\n[${index + 1}/${connectionStrings.length}] Testing connection...`);
    
    await client.connect();
    console.log('✅ SUCCESS! Connected to PostgreSQL!');
    
    const res = await client.query('SELECT version()');
    console.log('📊 Version:', res.rows[0].version.substring(0, 40) + '...');
    
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`📋 Tables: ${tables.rows.length}`);
    
    await client.end();
    console.log('\n🎉 WORKING CONNECTION STRING:');
    console.log(url);
    return true;
    
  } catch (error) {
    console.log(`❌ Failed: ${error.message.substring(0, 50)}`);
    try { await client.end(); } catch {}
    return false;
  }
}

async function findWorkingConnection() {
  console.log('🔍 Testing all possible Supabase connection formats...');
  console.log(`Project: ${projectRef}`);
  console.log(`Password: ${password.substring(0, 4)}...${password.substring(password.length - 4)}\n`);
  
  for (let i = 0; i < connectionStrings.length; i++) {
    const success = await testConnection(connectionStrings[i], i);
    if (success) {
      console.log('\n✅ SUPABASE IS STRONG! 💪');
      console.log('\nNext: Run migration to create tables');
      console.log('   npm run db:push\n');
      return;
    }
  }
  
  console.log('\n❌ None of the connection formats worked!');
  console.log('\n⚠️  Possible issues:');
  console.log('1. Database is paused (check Supabase Dashboard)');
  console.log('2. Project is in a different region');
  console.log('3. Network/firewall blocking connection');
  console.log('\nCheck: https://supabase.com/dashboard/project/kkaidegysdobcmflffey\n');
}

findWorkingConnection();
