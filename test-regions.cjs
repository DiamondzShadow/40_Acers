const { Client } = require('pg');

const password = 'TVDIHmRcKQXnn7q0';
const projectRef = 'kkaidegysdobcmflffey';

// Try all possible AWS regions Supabase uses
const regions = [
  'us-east-1',
  'us-west-1', 
  'us-west-2',
  'ap-northeast-1',
  'ap-southeast-1',
  'ap-southeast-2',
  'eu-central-1',
  'eu-west-1',
  'eu-west-2',
  'sa-east-1',
];

async function testRegion(region, index) {
  const connectionString = `postgresql://postgres.${projectRef}:${password}@aws-0-${region}.pooler.supabase.com:6543/postgres`;
  const client = new Client({ 
    connectionString,
    ssl: { rejectUnauthorized: false }
  });
  
  try {
    console.log(`[${index + 1}/${regions.length}] Testing region: ${region}...`);
    
    await client.connect();
    console.log(`\n✅ SUCCESS! Found the correct region: ${region}\n`);
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', res.rows[0].version.substring(0, 50));
    
    const tables = await client.query(`
      SELECT COUNT(*) as count
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`📋 Tables in database: ${tables.rows[0].count}\n`);
    
    await client.end();
    
    console.log('🎉 SUPABASE IS STRONG! 💪\n');
    console.log('✅ CORRECT CONNECTION STRING:');
    console.log(connectionString);
    console.log('\n📝 Update .env file with this connection string');
    console.log('\n🚀 Then run: npm run db:push\n');
    return true;
    
  } catch (error) {
    console.log(`   ❌ ${error.message.substring(0, 40)}`);
    try { await client.end(); } catch {}
    return false;
  }
}

async function findRegion() {
  console.log('🔍 Scanning all AWS regions for your Supabase database...');
  console.log(`Project: ${projectRef}`);
  console.log(`Password: ${password.substring(0, 4)}***${password.substring(password.length - 4)}\n`);
  
  for (let i = 0; i < regions.length; i++) {
    const success = await testRegion(regions[i], i);
    if (success) {
      return;
    }
  }
  
  console.log('\n❌ Could not find the correct region!');
  console.log('\n⚠️  This means:');
  console.log('1. Database might be paused or inactive');
  console.log('2. Database might use a different connection format');
  console.log('3. Need to check Supabase Dashboard for connection info\n');
}

findRegion();
