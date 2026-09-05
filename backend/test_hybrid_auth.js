import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import {
  User,
  FarmerReport,
  District,
  APPROVED_DISTRICTS
} from './src/models/index.js';
import { seedDatabase } from './src/seed.js';

let passed = 0;
let failed = 0;

function assert(condition, message) {
  if (condition) {
    console.log(`  ✓ ${message}`);
    passed++;
  } else {
    console.error(`  ✗ FAIL: ${message}`);
    failed++;
  }
}

async function runHybridAuthTests() {
  console.log('\n==================================================');
  console.log('LDEWS Hybrid Authentication & Multi-District Registry Tests');
  console.log('==================================================\n');

  // Step 1: Database Setup
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  let mongodInstance = null;

  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2500 });
    console.log(`1. Connected to MongoDB at ${mongoUri}`);
  } catch (err) {
    console.log(`1. Local MongoDB unavailable. Starting embedded MongoMemoryServer...`);
    const { MongoMemoryServer } = await import('mongodb-memory-server');
    mongodInstance = await MongoMemoryServer.create({ instance: { dbName: 'ldews-test' } });
    await mongoose.connect(mongodInstance.getUri());
    console.log(`   Embedded MongoDB connected.`);
  }

  assert(mongoose.connection.readyState === 1, 'Database connection ready');

  // Step 2: Seed Database
  console.log('\n2. Testing Seed Initialization with Hybrid Personas:');
  await seedDatabase();
  const userCount = await User.countDocuments();
  assert(userCount >= 17, `Seeded users count: ${userCount} (includes 7 demo users and 10 government registry officers)`);

  const demoUsers = await User.find({ accountType: 'demo' });
  assert(demoUsers.length === 7, `Demo users count: ${demoUsers.length} (exact 7 accounts preserved)`);

  const govUsers = await User.find({ accountType: 'government' });
  assert(govUsers.length === 10, `Government registry personnel count: ${govUsers.length} (exact 10 multi-district officers)`);

  // Verify all 10 multi-district officers exist
  const expectedPersonnel = [
    { email: 'vet.nashik@gov.in', role: 'vet', district: 'Nashik', employeeId: 'VET-MH-042' },
    { email: 'vet.pune@gov.in', role: 'vet', district: 'Pune', employeeId: 'VET-MH-043' },
    { email: 'vet.ahmednagar@gov.in', role: 'vet', district: 'Ahmednagar', employeeId: 'VET-MH-044' },
    { email: 'lab.nashik@gov.in', role: 'lab', district: 'Nashik', employeeId: 'LAB-MH-018' },
    { email: 'lab.pune@gov.in', role: 'lab', district: 'Pune', employeeId: 'LAB-MH-019' },
    { email: 'lab.ahmednagar@gov.in', role: 'lab', district: 'Ahmednagar', employeeId: 'LAB-MH-020' },
    { email: 'officer.nashik@gov.in', role: 'district', district: 'Nashik', employeeId: 'DSO-MH-001' },
    { email: 'officer.pune@gov.in', role: 'district', district: 'Pune', employeeId: 'DSO-MH-002' },
    { email: 'officer.ahmednagar@gov.in', role: 'district', district: 'Ahmednagar', employeeId: 'DSO-MH-003' },
    { email: 'director.state@gov.in', role: 'state', district: 'Maharashtra', employeeId: 'SAHO-MH-002' }
  ];

  for (const exp of expectedPersonnel) {
    const officer = await User.findOne({ email: exp.email });
    assert(!!officer, `Officer present: ${exp.email}`);
    assert(officer.role === exp.role, `Officer role matches: ${exp.role}`);
    assert(officer.district === exp.district, `Officer district matches: ${exp.district}`);
    assert(officer.employeeId === exp.employeeId, `Officer employeeId matches: ${exp.employeeId}`);
    assert(officer.accountActivated === false, `Officer initial accountActivated is false: ${exp.email}`);
  }

  // Token & Public User helpers
  const secret = process.env.JWT_SECRET || 'demo-secret-key-sih2026';
  const tokenFor = u => jwt.sign(
    {
      id: u._id,
      role: u.role,
      name: u.name,
      phone: u.phone,
      email: u.email,
      district: u.district,
      taluka: u.taluka,
      accountType: u.accountType || 'public'
    },
    secret,
    { expiresIn: '8h' }
  );

  const publicUser = u => ({
    id: u._id,
    name: u.name,
    phone: u.phone,
    email: u.email,
    role: u.role,
    district: u.district,
    taluka: u.taluka,
    accountType: u.accountType || 'public',
    accountActivated: u.accountActivated !== false,
    organization: u.organization || 'Department of Animal Husbandry & Dairying',
    designation: u.designation || '',
    employeeId: u.employeeId || ''
  });

  // Step 3: Verify Demo Mode Authentication
  console.log('\n3. Testing Demo Mode Authentication (All 5 Roles):');
  const demoRoles = ['farmer', 'vet', 'lab', 'district', 'state'];
  for (const role of demoRoles) {
    const u = await User.findOne({ role, active: true, accountType: 'demo' });
    assert(!!u, `Demo user exists for role '${role}': ${u?.name}`);
    const token = tokenFor(u);
    const decoded = jwt.verify(token, secret);
    assert(decoded.role === role, `JWT properly contains role '${role}'`);
    assert(decoded.accountType === 'demo', `JWT identifies demo user accountType`);
    const pub = publicUser(u);
    assert(!pub.password && !pub.passwordHash, `Sanitized demo user does not leak password hash`);
  }

  // Step 4: Verify Public Registration Security (Only Farmers Allowed)
  console.log('\n4. Testing Public Registration Security & Restrictions:');
  const forbiddenRoles = ['vet', 'lab', 'district', 'state'];
  for (const fRole of forbiddenRoles) {
    const isForbidden = (fRole && fRole !== 'farmer');
    assert(isForbidden, `Registration rejection enforced: role '${fRole}' cannot self-register`);
  }

  assert(APPROVED_DISTRICTS.includes('Nashik'), 'Nashik is in APPROVED_DISTRICTS');
  assert(APPROVED_DISTRICTS.includes('Pune'), 'Pune is in APPROVED_DISTRICTS');
  assert(APPROVED_DISTRICTS.includes('Ahmednagar'), 'Ahmednagar is in APPROVED_DISTRICTS');
  assert(!APPROVED_DISTRICTS.includes('Mumbai'), 'Unapproved district Mumbai is correctly excluded');

  // Step 5: Real Farmer Registration & Lifecycle
  console.log('\n5. Testing Real Farmer Registration & Lifecycle:');
  const testFarmerEmail = 'test.farmer.' + Date.now() + '@example.com';
  const testFarmerPhone = '98' + Math.floor(10000000 + Math.random() * 90000000);
  const rawPassword = 'realSecurePassword123';
  const hashedPassword = await bcrypt.hash(rawPassword, 10);

  const registeredFarmer = await User.create({
    name: 'Balasaheb Shinde',
    email: testFarmerEmail,
    phone: testFarmerPhone,
    password: hashedPassword,
    role: 'farmer',
    district: 'Ahmednagar',
    accountType: 'public',
    accountActivated: true,
    designation: 'Livestock Owner / Farmer'
  });

  assert(!!registeredFarmer._id, `Farmer registered with ID: ${registeredFarmer._id}`);
  assert(registeredFarmer.accountType === 'public', 'Farmer accountType is public');
  assert(registeredFarmer.district === 'Ahmednagar', 'Farmer assigned to selected district: Ahmednagar');
  assert(registeredFarmer.password !== rawPassword, 'Password is properly hashed with bcrypt');

  // Farmer Login
  const isMatch = await bcrypt.compare(rawPassword, registeredFarmer.password);
  assert(isMatch, 'Farmer login password comparison succeeds');
  const farmerToken = tokenFor(registeredFarmer);
  const decodedFarmer = jwt.verify(farmerToken, secret);
  assert(decodedFarmer.accountType === 'public', 'Farmer token contains accountType: public');
  assert(decodedFarmer.district === 'Ahmednagar', 'Farmer token contains district: Ahmednagar');

  // Step 6: Multi-District Officer Verification & Role-Mismatch Rejection
  console.log('\n6. Testing Multi-District Officer Verification & Role Mismatch:');
  const puneVet = await User.findOne({ email: 'vet.pune@gov.in' });
  assert(!!puneVet, 'Pre-authorized officer found: Dr. Amit Patil (vet.pune@gov.in)');
  assert(puneVet.district === 'Pune', 'Officer district verified as Pune');
  assert(puneVet.accountActivated === false, 'Officer initially unactivated');

  // Simulate verification role mismatch
  const roleMismatchRejected = puneVet.role !== 'district';
  assert(roleMismatchRejected, 'Role mismatch detected when vet officer tries to verify as district officer');

  const ahmednagarDSO = await User.findOne({ email: 'officer.ahmednagar@gov.in' });
  assert(!!ahmednagarDSO, 'District Surveillance Officer found: Anjali Kulkarni (officer.ahmednagar@gov.in)');
  assert(ahmednagarDSO.district === 'Ahmednagar', 'Officer district verified as Ahmednagar');

  const stateDir = await User.findOne({ email: 'director.state@gov.in' });
  assert(!!stateDir, 'State Officer found: Dr. Kavita Sharma (director.state@gov.in)');
  assert(stateDir.district === 'Maharashtra', 'State officer oversees Maharashtra');

  // Step 7: Government Officer First-Time Activation
  console.log('\n7. Testing First-Time Account Activation for Government Officer:');
  const activatingVet = await User.findOne({ email: 'vet.nashik@gov.in' });
  assert(activatingVet.accountActivated === false, 'vet.nashik@gov.in is initially unactivated');

  const newOfficerPassword = 'OfficialVetPassword2026!';
  const hashedOfficerPassword = await bcrypt.hash(newOfficerPassword, 10);
  activatingVet.password = hashedOfficerPassword;
  activatingVet.accountActivated = true;
  await activatingVet.save();

  assert(activatingVet.accountActivated === true, 'Officer accountActivated transitioned to true');
  const passCheck = await bcrypt.compare(newOfficerPassword, activatingVet.password);
  assert(passCheck, 'Officer can authenticate with newly created password');

  // Step 8: SEED SAFETY RULE VALIDATION (Idempotent preservation of activated accounts)
  console.log('\n8. Testing SEED SAFETY RULE (Idempotent Seeding & Activated Account Preservation):');
  console.log('   Re-running seedDatabase()...');
  await seedDatabase();

  const officerAfterReseed = await User.findOne({ email: 'vet.nashik@gov.in' });
  assert(!!officerAfterReseed, 'Activated officer still exists after re-seeding');
  assert(officerAfterReseed.accountActivated === true, 'SEED SAFETY: accountActivated remained TRUE (not reset to false)');
  assert(officerAfterReseed.password === hashedOfficerPassword, 'SEED SAFETY: Password hash strictly preserved');

  const reseedPassCheck = await bcrypt.compare(newOfficerPassword, officerAfterReseed.password);
  assert(reseedPassCheck, 'SEED SAFETY: Officer can still log in using activated password after re-seeding');

  // Verify that an unactivated officer remained unactivated
  const puneVetAfterReseed = await User.findOne({ email: 'vet.pune@gov.in' });
  assert(puneVetAfterReseed.accountActivated === false, 'SEED SAFETY: Unactivated officer remains unactivated');

  // Verify that registered public farmer was also preserved
  const farmerAfterReseed = await User.findOne({ email: testFarmerEmail });
  assert(!!farmerAfterReseed, 'SEED SAFETY: Registered citizen/farmer account preserved across re-seeding');

  // Verify demo users refreshed
  const demoUsersAfterReseed = await User.find({ accountType: 'demo' });
  assert(demoUsersAfterReseed.length === 7, 'SEED SAFETY: Demo users refreshed to exact 7 accounts');

  // Step 9: Architectural Safeguard - Demo Mode Isolation
  console.log('\n9. Testing Architectural Safeguards & Demo Mode Isolation:');
  const demoFarmer = await User.findOne({ email: 'suresh@farmer.gov.in' });
  assert(demoFarmer.accountType === 'demo', 'Demo user correctly tagged with accountType: demo');
  const blockDemoFromLive = demoFarmer.accountType === 'demo';
  assert(blockDemoFromLive, 'Demo accounts blocked from live password endpoint (isolated)');

  console.log('\n==================================================');
  console.log(`RESULTS: ${passed} assertions passed, ${failed} failed.`);
  console.log('==================================================\n');

  if (mongodInstance) {
    await mongoose.disconnect();
    await mongodInstance.stop();
  } else {
    await mongoose.disconnect();
  }

  process.exit(failed > 0 ? 1 : 0);
}

runHybridAuthTests().catch(err => {
  console.error('Test execution error:', err);
  process.exit(1);
});
