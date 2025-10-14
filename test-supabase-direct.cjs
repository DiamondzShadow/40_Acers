const { Client } = require('pg');

// Try both pooler and direct connection
const POOLER_URL = "postgresql://postgres.kkaidegysdobcmflffey:10tenThousand100@aws-0-us-west-1.pooler.supabase.com:6543/postgres";
const DIRECT_URL = "postgresql://postgres:10tenThousand100@db.kkaidegysdobcmflffey.supabase.co:5432/postgres";

async function testConnection(url, name) {
  const client = new Client({ connectionString: url });
  
  try {
    console.log(`\n🔌 Testing ${name}...`);
    console.log(`Connection: ${url.replace(/:[^:]*@/, ':***@')}`);
    
    await client.connect();
    console.log('✅ Connected successfully!');
    
    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL:', res.rows[0].version.substring(0, 40) + '...');
    
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`📋 Tables in database: ${tables.rows.length}`);
    if (tables.rows.length > 0) {
      console.log('Tables:', tables.rows.slice(0, 10).map(r => r.table_name).join(', '));
    } else {
      console.log('   ⚠️  No tables yet - need to run migration!');
    }
    
    await client.end();
    console.log(`\n✅ ${name} IS STRONG! 💪`);
    return url;
    
  } catch (error) {
    console.error(`❌ ${name} failed:`, error.message);
    try { await client.end(); } catch {}
    return null;
  }
}

async function findWorkingConnection() {
  console.log('🔍 Testing Supabase PostgreSQL connections...\n');
  
  let workingUrl = await testConnection(POOLER_URL, 'Pooler Connection');
  
  if (!workingUrl) {
    workingUrl = await testConnection(DIRECT_URL, 'Direct Connection');
  }
  
  if (workingUrl) {
    console.log('\n✅ SUPABASE IS STRONG AND WORKING! 💪');
    console.log('\n📝 Use this connection string in .env:');
    console.log(workingUrl);
    console.log('\nNext step: Run migration to create tables');
    console.log('   npm run db:push\n');
  } else {
    console.log('\n❌ Both connection methods failed!');
    console.log('\n⚠️  Please verify:');
    console.log('1. Password is correct: 10tenThousand100');
    console.log('2. Project ID is correct: kkaidegysdobcmflffey');
    console.log('3. Database is active in Supabase Dashboard');
    console.log('\nGo to: https://supabase.com/dashboard/project/kkaidegysdobcmflffey/settings/database\n');
  }
}

findWorkingConnection();
