const { Client } = require('pg');

const password = 'TVDIHmRcKQXnn7q0';
const projectRef = 'kkaidegysdobcmflffey';

// Try completely different connection string formats
const formats = [
  // Maybe newer format without aws-0 prefix
  `postgresql://postgres.${projectRef}:${password}@${projectRef}.pooler.supabase.com:6543/postgres`,
  
  // Maybe uses db. prefix for pooler too
  `postgresql://postgres:${password}@db.${projectRef}.pooler.supabase.com:6543/postgres`,
  
  // Maybe different hostname entirely
  `postgresql://postgres:${password}@pooler.supabase.com:6543/${projectRef}`,
  
  // Try with project as database name
  `postgresql://postgres.${projectRef}:${password}@pooler.supabase.com:6543/postgres`,
  
  // Try without postgres. prefix in username
  `postgresql://postgres:${password}@${projectRef}.supabase.com:6543/postgres`,
  
  // Try supabase.co domain
  `postgresql://postgres:${password}@${projectRef}.supabase.co:6543/postgres`,
  
  // Try with supabase.io (old domain)
  `postgresql://postgres.${projectRef}:${password}@${projectRef}.supabase.io:6543/postgres`,
];

async function testFormat(connectionString, index) {
  const client = new Client({ 
    connectionString,
    ssl: { rejectUnauthorized: false },
    connectionTimeoutMillis: 5000,
  });
  
  try {
    console.log(`\n[${index + 1}/${formats.length}] Testing format...`);
    console.log(`Host: ${connectionString.split('@')[1].split(':')[0]}`);
    
    await client.connect();
    
    console.log('\n🎉 SUCCESS! FOUND IT! 🎉\n');
    
    const res = await client.query('SELECT version()');
    console.log('✅ PostgreSQL version:', res.rows[0].version.substring(0, 50));
    
    const tables = await client.query(`
      SELECT COUNT(*) as count
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log(`✅ Tables in database: ${tables.rows[0].count}`);
    
    await client.end();
    
    console.log('\n💪 SUPABASE IS STRONG!\n');
    console.log('🔗 WORKING CONNECTION STRING:');
    console.log(connectionString);
    console.log('\n📝 I will update your .env file now!\n');
    
    return connectionString;
    
  } catch (error) {
    console.log(`   ❌ ${error.message.substring(0, 50)}`);
    try { await client.end(); } catch {}
    return null;
  }
}

async function findWorkingFormat() {
  console.log('🔍 Testing different connection string formats...');
  console.log(`Project: ${projectRef}`);
  console.log(`Password: ${password}\n`);
  
  for (let i = 0; i < formats.length; i++) {
    const workingConnection = await testFormat(formats[i], i);
    if (workingConnection) {
      return workingConnection;
    }
  }
  
  console.log('\n❌ Still no luck with these formats.');
  console.log('\n📋 I NEED THE ACTUAL CONNECTION STRING from your dashboard.');
  console.log('\nPlease go to Settings → Database');
  console.log('Look for ANY text that starts with:');
  console.log('  postgresql://');
  console.log('\nCopy the ENTIRE line and send it to me!\n');
  
  return null;
}

findWorkingFormat();
