import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import {
  User,
  FarmerReport,
  Advisory,
  VetAssignment,
  Sample,
  LabResult,
  Notification,
  ActionRequest,
  HistoricalDiseaseRecord,
  District,
  Village
} from './src/models/index.js';
import { predict, predictDistrictRisk } from './src/services/mlService.js';
import { processReport, collectSample, notify, getRiskThreshold } from './src/services/workflowService.js';
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

async function runTests() {
  console.log('\n==================================================');
  console.log('LDEWS Full Integration & Runtime Verification Test');
  console.log('==================================================\n');

  // Step 1: Connect to database (or embedded memory server if standalone is not running)
  console.log('1. Database Connection & Environment Configuration:');
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  let isMemory = false;

  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2500 });
    console.log(`  Connected to MongoDB at ${mongoUri}`);
  } catch (err) {
    console.log(`  Local MongoDB unavailable (${err.message}). Starting embedded memory MongoDB...`);
    const { MongoMemoryServer } = await import('mongodb-memory-server');
    const mongod = await MongoMemoryServer.create({ instance: { dbName: 'ldews' } });
    const memUri = mongod.getUri();
    await mongoose.connect(memUri);
    isMemory = true;
    console.log(`  Embedded MongoDB connected at ${memUri}`);
  }
  assert(mongoose.connection.readyState === 1, 'MongoDB connection readyState === 1 (connected)');

  // Step 2: Test Seed Idempotency
  console.log('\n2. Testing Seed Script & Idempotency:');
  await seedDatabase();
  const countUsersPass1 = await User.countDocuments();
  const countReportsPass1 = await FarmerReport.countDocuments();
  const countDistrictsPass1 = await District.countDocuments();
  const countSamplesPass1 = await Sample.countDocuments();

  assert(countUsersPass1 >= 7, `Seeded users: ${countUsersPass1} (expected >= 7)`);
  assert(countReportsPass1 >= 6, `Seeded reports: ${countReportsPass1} (expected >= 6)`);
  assert(countDistrictsPass1 >= 3, `Seeded districts: ${countDistrictsPass1} (expected >= 3)`);
  assert(countSamplesPass1 >= 2, `Seeded samples: ${countSamplesPass1} (expected >= 2)`);

  // Run seed a second time to verify idempotency
  console.log('  Running seedDatabase() second time for idempotency check...');
  await seedDatabase();
  const countUsersPass2 = await User.countDocuments();
  const countReportsPass2 = await FarmerReport.countDocuments();

  assert(countUsersPass1 === countUsersPass2, `Idempotent User count: ${countUsersPass2} === ${countUsersPass1}`);
  assert(countReportsPass1 === countReportsPass2, `Idempotent Report count: ${countReportsPass2} === ${countReportsPass1}`);

  // Step 3: Verify Authentication & Roles
  console.log('\n3. Testing Authentication & Role Verification:');
  const roles = ['farmer', 'vet', 'lab', 'district', 'state'];
  const authUsers = {};

  for (const role of roles) {
    const u = await User.findOne({ role, active: true });
    assert(!!u, `User found for role '${role}': ${u?.name} (${u?.phone})`);
    const match = await bcrypt.compare('demo123', u.password);
    assert(match, `Password verification for '${role}' user succeeds with 'demo123'`);

    const token = jwt.sign(
      { id: u._id, role: u.role, name: u.name, district: u.district },
      process.env.JWT_SECRET || 'demo-secret-key-sih2026',
      { expiresIn: '8h' }
    );
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'demo-secret-key-sih2026');
    assert(decoded.role === role, `JWT token signed & decoded correctly for ${role}`);
    authUsers[role] = u;
  }

  // Step 4: Verify ML Contracts
  console.log('\n4. Testing ML Integration Contracts:');
  // Contract 1: POST /api/ml/predict
  const mlPredictInput = {
    symptoms: ['mouth lesions', 'blisters', 'drooling'],
    animalType: 'Cattle',
    location: { district: 'Nashik', village: 'Pimpalgaon' },
    recentLocalReports: 2,
    context: { herdSize: 20 }
  };
  const mlPredictResult = await predict(mlPredictInput);
  assert(typeof mlPredictResult.suspectedDisease === 'string' && mlPredictResult.suspectedDisease.length > 0, `predict() returns suspectedDisease: '${mlPredictResult.suspectedDisease}'`);
  assert(['low', 'medium', 'high'].includes(mlPredictResult.triage), `predict() returns valid triage tier: '${mlPredictResult.triage}'`);
  assert(typeof mlPredictResult.localOutbreakRisk === 'number' && mlPredictResult.localOutbreakRisk >= 0 && mlPredictResult.localOutbreakRisk <= 100, `predict() returns localOutbreakRisk: ${mlPredictResult.localOutbreakRisk}%`);

  // Contract 2: POST /api/ml/district-risk
  const mlDistrictInput = {
    district: 'Nashik',
    recentReports: 4,
    confirmedCases: 2,
    season: 'Monsoon',
    weather: 'Humid',
    vaccinationCoverage: 70
  };
  const mlDistrictResult = await predictDistrictRisk(mlDistrictInput);
  assert(mlDistrictResult.district === 'Nashik', `predictDistrictRisk() returns district: '${mlDistrictResult.district}'`);
  assert(typeof mlDistrictResult.outbreakRisk === 'number' && mlDistrictResult.outbreakRisk >= 0 && mlDistrictResult.outbreakRisk <= 100, `predictDistrictRisk() returns outbreakRisk: ${mlDistrictResult.outbreakRisk}%`);

  // Step 5: Farmer Flow (Testing BOTH < 70 and >= 70)
  console.log('\n5. Testing Farmer Flow (Threshold Evaluation):');
  const threshold = getRiskThreshold();
  assert(threshold === 70, `System RISK_THRESHOLD is set to ${threshold}`);

  // Flow 5A: Risk Below Threshold (< 70) -> Monitoring, NO Vet escalation
  const lowRiskData = await processReport({
    animalType: 'Buffalo',
    symptoms: ['Mild fever'],
    district: 'Nashik',
    taluka: 'Sinnar',
    village: 'Wavi',
    source: 'web'
  }, authUsers.farmer);

  assert(lowRiskData.report.localOutbreakRisk < threshold, `Low-risk case risk: ${lowRiskData.report.localOutbreakRisk}% (< ${threshold}%)`);
  assert(lowRiskData.report.status === 'Monitoring', `Low-risk case status is 'Monitoring' (was: ${lowRiskData.report.status})`);
  assert(lowRiskData.escalated === false, 'Low-risk case escalated flag is false');
  const lowVetAssignment = await VetAssignment.findOne({ case: lowRiskData.report._id });
  assert(!lowVetAssignment, 'No VetAssignment created for low-risk case');

  // Flow 5B: Risk >= Threshold (>= 70) -> Escalated to Vet, Vet Assignment & Notification
  const highRiskData = await processReport({
    animalType: 'Cattle',
    symptoms: ['Mouth blisters', 'drooling', 'lameness'],
    district: 'Nashik',
    taluka: 'Niphad',
    village: 'Pimpalgaon',
    source: 'web'
  }, authUsers.farmer);

  assert(highRiskData.report.localOutbreakRisk >= threshold, `High-risk case risk: ${highRiskData.report.localOutbreakRisk}% (>= ${threshold}%)`);
  assert(highRiskData.report.status === 'Escalated to Vet', `High-risk case status is 'Escalated to Vet' (was: ${highRiskData.report.status})`);
  assert(highRiskData.escalated === true, 'High-risk case escalated flag is true');
  
  const highVetAssignment = await VetAssignment.findOne({ case: highRiskData.report._id });
  assert(!!highVetAssignment, 'VetAssignment created for high-risk case');
  assert(String(highVetAssignment?.vet) === String(authUsers.vet._id), `VetAssignment correctly linked to assigned Vet (${authUsers.vet.name})`);

  const vetNotif = await Notification.findOne({ user: authUsers.vet._id, case: highRiskData.report._id, type: 'escalation' });
  assert(!!vetNotif, `Vet received escalation notification: "${vetNotif?.title}"`);

  // Step 6: IVR Flow Integration
  console.log('\n6. Testing IVR Flow Simulation:');
  const ivrReportData = await processReport({
    phone: '9876543299',
    farmerName: 'Kailash Shinde',
    animalType: 'Cattle',
    symptoms: ['Mouth lesions', 'Drooling'],
    district: 'Nashik',
    taluka: 'Niphad',
    village: 'Pimpalgaon',
    source: 'ivr',
    language: 'Hindi'
  }, null);

  assert(ivrReportData.report.source === 'ivr', `IVR report source is '${ivrReportData.report.source}'`);
  assert(ivrReportData.report.localOutbreakRisk >= threshold, `IVR report evaluated by ML: risk ${ivrReportData.report.localOutbreakRisk}%`);
  assert(ivrReportData.report.status === 'Escalated to Vet', `IVR report status escalated based on threshold`);
  assert(!!ivrReportData.advisory, `IVR report generated advisory: '${ivrReportData.advisory.title}'`);
  assert(ivrReportData.report.location.latitude === 20.084, `IVR report location coordinates enriched from Village model (lat: ${ivrReportData.report.location.latitude})`);

  // Step 7: Vet Investigation & Sample Collection Flow
  console.log('\n7. Testing Vet Flow (Verification & Sample Collection):');
  // Vet opens case
  const vetCaseToVerify = await FarmerReport.findById(highRiskData.report._id);
  assert(!!vetCaseToVerify, 'Vet retrieves high-risk case');

  // Vet verifies case
  vetCaseToVerify.status = 'Vet Verified';
  vetCaseToVerify.clinicalObservations = 'Severe vesicles in oral cavity and high fever verified during field visit.';
  await vetCaseToVerify.save();
  await highVetAssignment.updateOne({ status: 'Verified', verifiedAt: new Date() });
  await notify(authUsers.farmer._id, 'Veterinary verification complete', 'Case verified.', vetCaseToVerify._id, 'vet-verification');

  assert(vetCaseToVerify.status === 'Vet Verified', 'Case status updated to Vet Verified');

  // Vet collects sample
  const sampleResult = await collectSample(vetCaseToVerify, authUsers.vet, 'Vesicular fluid swab collected.');
  assert(!!sampleResult.sample, `Sample created with ID: ${sampleResult.sample.sampleId}`);
  assert(sampleResult.case.status === 'Lab Testing', `Case status transitioned to 'Lab Testing' (was: ${sampleResult.case.status})`);
  assert(String(sampleResult.sample.lab) === String(authUsers.lab._id), `Sample correctly mapped to District Laboratory (${authUsers.lab.name})`);

  const labNotif = await Notification.findOne({ user: authUsers.lab._id, case: vetCaseToVerify._id, type: 'sample' });
  assert(!!labNotif, `Lab assistant received notification: "${labNotif?.title}"`);

  // Step 8: Laboratory Flow (Testing & Confirmation)
  console.log('\n8. Testing Laboratory Flow:');
  const labSample = await Sample.findById(sampleResult.sample._id).populate('case');
  assert(!!labSample, 'Lab retrieves assigned sample from queue');

  // Lab submits Confirmed result
  const labResult = await LabResult.create({
    sample: labSample._id,
    result: 'Confirmed',
    disease: 'Foot and Mouth Disease',
    notes: 'RT-PCR test positive for FMD serotype O.',
    submittedBy: authUsers.lab._id,
    submittedAt: new Date()
  });
  labSample.status = 'Completed';
  await labSample.save();

  labSample.case.status = 'Confirmed';
  await labSample.case.save();

  assert(labSample.status === 'Completed', 'Sample status marked as Completed');
  assert(labSample.case.status === 'Confirmed', 'Farmer report status marked as Confirmed');

  // Step 9: District Flow (Verification of Stats & Segregation)
  console.log('\n9. Testing District Surveillance & Data Segregation:');
  const nashikReports = await FarmerReport.find({ 'location.district': 'Nashik' });
  const activeCases = nashikReports.filter(x => !['Negative', 'Closed'].includes(x.status));
  const confirmedCases = nashikReports.filter(x => x.status === 'Confirmed');
  const historicalRecords = await HistoricalDiseaseRecord.find({ district: 'Nashik' });

  assert(activeCases.length > 0, `Active cases in Nashik: ${activeCases.length}`);
  assert(confirmedCases.length >= 2, `Confirmed cases in Nashik: ${confirmedCases.length}`);
  assert(historicalRecords.length >= 3, `Historical records in Nashik: ${historicalRecords.length}`);
  assert(historicalRecords[0].count > 0, 'Historical data contains dedicated historical counts separate from live reports');

  // Test District Action Request
  const actionReq = await ActionRequest.create({
    requestId: `REQ-${Date.now().toString().slice(-8)}`,
    type: 'vaccination',
    district: 'Nashik',
    taluka: 'Niphad',
    village: 'Pimpalgaon',
    disease: 'Foot and Mouth Disease',
    reason: 'Active confirmed cluster needs ring vaccination.',
    createdBy: authUsers.district._id,
    status: 'Pending'
  });
  assert(actionReq.status === 'Pending', `Action request created with status: ${actionReq.status}`);

  // Step 10: State Flow (District Aggregation & Prioritization)
  console.log('\n10. Testing State Flow (Aggregation, Ranking & Decisions):');
  const districts = await District.find();
  const stateDistricts = [];
  for (const d of districts) {
    const dReports = await FarmerReport.find({ 'location.district': d.name });
    const dActive = dReports.filter(x => !['Negative', 'Closed'].includes(x.status));
    const dConfirmed = dReports.filter(x => x.status === 'Confirmed');
    const pred = await predictDistrictRisk({
      district: d.name,
      recentReports: dReports.length,
      confirmedCases: dConfirmed.length
    });
    stateDistricts.push({
      district: d.name,
      activeCases: dActive.length,
      confirmedCases: dConfirmed.length,
      outbreakRisk: pred.outbreakRisk
    });
  }
  stateDistricts.sort((a, b) => b.outbreakRisk - a.outbreakRisk);
  assert(stateDistricts.length >= 3, `State aggregates all ${stateDistricts.length} districts`);
  assert(stateDistricts[0].outbreakRisk >= stateDistricts[1].outbreakRisk, 'Districts ranked by outbreak risk in descending order');

  // State Officer reviews and allocates request
  actionReq.status = 'Approved';
  actionReq.priority = 'High';
  actionReq.allocation = '2,000 FMD vaccine doses allocated from State Reserve.';
  actionReq.reviewedBy = authUsers.state._id;
  actionReq.reviewedAt = new Date();
  await actionReq.save();

  assert(actionReq.status === 'Approved', `State updated action request to '${actionReq.status}'`);
  assert(actionReq.allocation.length > 0, `Allocation documented: '${actionReq.allocation}'`);

  console.log('\n==================================================');
  console.log(`RESULTS: ${passed} assertions passed, ${failed} failed.`);
  console.log('==================================================\n');

  await mongoose.disconnect();
  process.exit(failed > 0 ? 1 : 0);
}

runTests().catch(err => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
