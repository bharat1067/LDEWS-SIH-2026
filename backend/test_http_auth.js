// Using global fetch available natively in Node 18+

let passed = 0;
let failed = 0;

function assert(condition, msg) {
  if (condition) {
    console.log(`  ✓ ${msg}`);
    passed++;
  } else {
    console.error(`  ✗ FAIL: ${msg}`);
    failed++;
  }
}

async function testHttpAuth() {
  console.log('\n==================================================');
  console.log('Testing Live HTTP Authentication Endpoints on Port 5000');
  console.log('==================================================\n');

  const BASE = 'http://localhost:5000/api';

  // 1. Health check
  const healthRes = await fetch(`${BASE}/health`);
  const health = await healthRes.json();
  assert(healthRes.status === 200, 'GET /api/health returned HTTP 200');
  assert(health.status === 'healthy', 'Health check status is healthy');

  // 2. Demo Login
  const demoRes = await fetch(`${BASE}/auth/demo-login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ role: 'vet' })
  });
  const demoData = await demoRes.json();
  assert(demoRes.status === 200, 'POST /api/auth/demo-login (vet) returned 200');
  assert(!!demoData.token, 'Demo login returns JWT token');
  assert(demoData.user?.role === 'vet', 'Demo user role is vet');
  assert(demoData.authMode === 'demo', 'Demo login returns authMode: demo');

  // 3. Reject Public Registration of Government Officer (role: 'vet')
  const badRegRes = await fetch(`${BASE}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fullName: 'Hacker Vet',
      email: 'hacker@vet.gov',
      role: 'vet',
      password: 'password123',
      district: 'Nashik'
    })
  });
  assert(badRegRes.status === 403, 'POST /api/auth/register with role=vet rejected with HTTP 403');

  // 4. Reject Public Registration with unapproved district
  const badDistRes = await fetch(`${BASE}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fullName: 'Valid Farmer',
      email: `valid${Date.now()}@farmer.org`,
      role: 'farmer',
      password: 'password123',
      district: 'Nagpur'
    })
  });
  assert(badDistRes.status === 400, 'POST /api/auth/register with unapproved district (Nagpur) rejected with HTTP 400');

  // 5. Successful Farmer Registration
  const farmerEmail = `farmer_${Date.now()}@real.in`;
  const regRes = await fetch(`${BASE}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fullName: 'Kisan Ramesh Patil',
      email: farmerEmail,
      phone: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
      district: 'Nashik',
      password: 'farmerPassword123'
    })
  });
  const regData = await regRes.json();
  assert(regRes.status === 201, 'POST /api/auth/register returned HTTP 201 Created');
  assert(!!regData.token, 'Registration returns JWT token');
  assert(regData.user?.name === 'Kisan Ramesh Patil', 'User name saved');
  assert(regData.user?.district === 'Nashik', 'District saved as Nashik');
  assert(regData.authMode === 'real', 'Registered user has authMode: real');

  // 6. Farmer Login
  const loginRes = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      identifier: farmerEmail,
      password: 'farmerPassword123',
      role: 'farmer'
    })
  });
  const loginData = await loginRes.json();
  assert(loginRes.status === 200, 'POST /api/auth/login returned HTTP 200');
  assert(!!loginData.token, 'Login returns JWT');
  assert(!loginData.user.password && !loginData.user.passwordHash, 'No password hash returned');

  // 7. Verify Official Email for Government Officer (Unactivated)
  const verifyRes = await fetch(`${BASE}/auth/verify-official-email`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'lab.nashik@gov.in',
      role: 'lab'
    })
  });
  const verifyData = await verifyRes.json();
  assert(verifyRes.status === 200, 'POST /api/auth/verify-official-email returned HTTP 200');
  assert(verifyData.verified === true, 'Identity verified: true');
  assert(verifyData.name === 'Dr Snehal Patil', 'Pre-registered officer name: Dr Snehal Patil');
  assert(verifyData.district === 'Nashik', 'Pre-assigned district: Nashik');
  assert(verifyData.employeeId === 'LAB-MH-018', 'Pre-assigned employee ID: LAB-MH-018');

  // 8. Verify Official Email with Wrong Role Rejected
  const wrongRoleRes = await fetch(`${BASE}/auth/verify-official-email`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'lab.nashik@gov.in',
      role: 'district'
    })
  });
  assert(wrongRoleRes.status === 403, 'POST /api/auth/verify-official-email with role mismatch rejected with HTTP 403');

  // 9. First-Time Account Activation
  const actRes = await fetch(`${BASE}/auth/activate-official-account`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'lab.nashik@gov.in',
      role: 'lab',
      password: 'NewLabPassword2026'
    })
  });
  const actData = await actRes.json();
  assert(actRes.status === 200, 'POST /api/auth/activate-official-account returned HTTP 200');
  assert(!!actData.token, 'Activation returns JWT');
  assert(actData.user?.role === 'lab', 'Activated user role is lab');

  // 10. Activated Official Login
  const labLoginRes = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      identifier: 'lab.nashik@gov.in',
      password: 'NewLabPassword2026',
      role: 'lab'
    })
  });
  assert(labLoginRes.status === 200, 'POST /api/auth/login for newly activated lab officer returned HTTP 200');

  // 11. Profile Endpoint GET /api/auth/me
  const meRes = await fetch(`${BASE}/auth/me`, {
    headers: { Authorization: `Bearer ${actData.token}` }
  });
  const meData = await meRes.json();
  assert(meRes.status === 200, 'GET /api/auth/me returned HTTP 200');
  assert(meData.name === 'Dr Snehal Patil', 'GET /api/auth/me profile name matches');
  assert(!meData.password && !meData.passwordHash, 'Profile does not contain password');

  // 12. Reject Demo User via Real Login Endpoint (Safeguard 3)
  const rejectDemoRes = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      identifier: 'suresh@farmer.gov.in',
      password: 'demo123',
      role: 'farmer'
    })
  });
  assert(rejectDemoRes.status === 403, 'Demo user rejected from live login with HTTP 403 (directed to Demo Access)');

  console.log('\n==================================================');
  console.log(`HTTP RESULTS: ${passed} assertions passed, ${failed} failed.`);
  console.log('==================================================\n');

  process.exit(failed > 0 ? 1 : 0);
}

testHttpAuth().catch(err => {
  console.error('HTTP Test error:', err);
  process.exit(1);
});
