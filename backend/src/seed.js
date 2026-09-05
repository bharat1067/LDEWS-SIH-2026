import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import {
  User,
  District,
  Taluka,
  Village,
  FarmerReport,
  Advisory,
  VetAssignment,
  Sample,
  LabResult,
  Notification,
  ActionRequest,
  HistoricalDiseaseRecord
} from './models/index.js';

export async function seedDatabase(connection = mongoose.connection) {
  console.log('Seeding demo database...');

  // Idempotent clean-up: delete all documents in reverse dependency order
  const models = [
    Notification,
    LabResult,
    Sample,
    VetAssignment,
    Advisory,
    FarmerReport,
    ActionRequest,
    HistoricalDiseaseRecord,
    Village,
    Taluka,
    District,
    User
  ];

  for (const m of models) {
    await m.deleteMany({});
  }

  const password = await bcrypt.hash('demo123', 10);

  // 1. Users for all 5 roles
  const users = await User.insertMany([
    { name: 'Suresh Patil', phone: '9876543210', email: 'suresh@farmer.gov.in', password, role: 'farmer', district: 'Nashik', taluka: 'Niphad' },
    { name: 'Asha Kale', phone: '9876543211', email: 'asha@farmer.gov.in', password, role: 'farmer', district: 'Nashik', taluka: 'Niphad' },
    { name: 'Ramesh Wagh', phone: '9876543212', email: 'ramesh@farmer.gov.in', password, role: 'farmer', district: 'Nashik', taluka: 'Sinnar' },
    { name: 'Dr Ananya Shah', phone: '9000000001', email: 'vet@nashik.gov.in', password, role: 'vet', district: 'Nashik', taluka: 'Niphad' },
    { name: 'Nisha Rao', phone: '9000000002', email: 'lab@nashik.gov.in', password, role: 'lab', district: 'Nashik' },
    { name: 'Vikram Deshmukh', phone: '9000000003', email: 'officer@nashik.gov.in', password, role: 'district', district: 'Nashik' },
    { name: 'Priya Kulkarni', phone: '9000000004', email: 'officer@state.gov.in', password, role: 'state', district: 'Maharashtra' }
  ]);

  const [farmer, asha, ramesh, vet, lab, districtOfficer, stateOfficer] = users;

  // 2. Districts & Administrative Structure
  const [nashik, pune, ahmednagar] = await District.insertMany([
    { name: 'Nashik', state: 'Maharashtra', riskScore: 76, assignedVet: vet._id, mappedLab: lab._id },
    { name: 'Pune', state: 'Maharashtra', riskScore: 53, assignedVet: vet._id, mappedLab: lab._id },
    { name: 'Ahmednagar', state: 'Maharashtra', riskScore: 34, assignedVet: vet._id, mappedLab: lab._id }
  ]);

  const [niphad, sinnar, junnar] = await Taluka.insertMany([
    { name: 'Niphad', district: nashik._id },
    { name: 'Sinnar', district: nashik._id },
    { name: 'Junnar', district: pune._id }
  ]);

  await Village.insertMany([
    { name: 'Pimpalgaon', taluka: niphad._id, district: 'Nashik', latitude: 20.084, longitude: 74.086 },
    { name: 'Wavi', taluka: sinnar._id, district: 'Nashik', latitude: 19.989, longitude: 74.111 },
    { name: 'Alephata', taluka: junnar._id, district: 'Pune', latitude: 19.193, longitude: 74.118 }
  ]);

  const pimpalgaonLoc = { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon', latitude: 20.084, longitude: 74.086, coordinates: [74.086, 20.084] };
  const waviLoc = { district: 'Nashik', taluka: 'Sinnar', village: 'Wavi', latitude: 19.989, longitude: 74.111, coordinates: [74.111, 19.989] };
  const alephataLoc = { district: 'Pune', taluka: 'Junnar', village: 'Alephata', latitude: 19.193, longitude: 74.118, coordinates: [74.118, 19.193] };

  // 3. Multi-stage Farmer Reports
  // Case 1: Monitoring (< 70 threshold)
  const lowCase = await FarmerReport.create({
    caseId: 'CASE-260901-01',
    farmer: farmer._id,
    farmerName: farmer.name,
    phone: farmer.phone,
    animalType: 'Buffalo',
    symptoms: ['Mild fever', 'Reduced feed intake'],
    location: waviLoc,
    source: 'web',
    language: 'Marathi',
    suspectedDisease: 'Lumpy Skin Disease',
    triage: 'medium',
    localOutbreakRisk: 53,
    status: 'Monitoring',
    createdAt: new Date()
  });

  // Case 2: Escalated to Vet (>= 70 threshold, awaiting Vet verification)
  const escalatedCase = await FarmerReport.create({
    caseId: 'CASE-260901-02',
    farmer: asha._id,
    farmerName: asha.name,
    phone: asha.phone,
    animalType: 'Cattle',
    symptoms: ['Mouth blisters', 'Drooling'],
    location: pimpalgaonLoc,
    source: 'ivr',
    language: 'Hindi',
    suspectedDisease: 'Foot and Mouth Disease',
    triage: 'high',
    localOutbreakRisk: 74,
    status: 'Escalated to Vet',
    createdAt: new Date()
  });

  // Case 3: Vet Verified (ready for sample collection)
  const verifiedCase = await FarmerReport.create({
    caseId: 'CASE-260901-03',
    farmer: ramesh._id,
    farmerName: ramesh.name,
    phone: ramesh.phone,
    animalType: 'Cattle',
    symptoms: ['Mouth lesions', 'Lameness'],
    location: pimpalgaonLoc,
    source: 'sms',
    language: 'Marathi',
    suspectedDisease: 'Foot and Mouth Disease',
    triage: 'high',
    localOutbreakRisk: 79,
    status: 'Vet Verified',
    clinicalObservations: 'Vesicles on dental pad and tongue; significant lameness observed.',
    createdAt: new Date(Date.now() - 3600000)
  });

  // Case 4: Lab Testing (sample collected, currently with Lab Assistant)
  const labTestingCase = await FarmerReport.create({
    caseId: 'CASE-260901-05',
    farmer: farmer._id,
    farmerName: farmer.name,
    phone: farmer.phone,
    animalType: 'Cattle',
    symptoms: ['High fever', 'Severe salivation', 'Interdigital lesions'],
    location: pimpalgaonLoc,
    source: 'web',
    language: 'English',
    suspectedDisease: 'Foot and Mouth Disease',
    triage: 'high',
    localOutbreakRisk: 81,
    status: 'Lab Testing',
    clinicalObservations: 'Ruptured vesicles with secondary contamination.',
    createdAt: new Date(Date.now() - 7200000)
  });

  // Case 5: Confirmed (Lab positive result published, active outbreak signal)
  const confirmedCase = await FarmerReport.create({
    caseId: 'CASE-260831-04',
    farmer: farmer._id,
    farmerName: farmer.name,
    phone: farmer.phone,
    animalType: 'Cattle',
    symptoms: ['Blisters', 'Drooling', 'Lameness'],
    location: pimpalgaonLoc,
    source: 'web',
    language: 'English',
    suspectedDisease: 'Foot and Mouth Disease',
    triage: 'high',
    localOutbreakRisk: 86,
    status: 'Confirmed',
    clinicalObservations: 'Verified acute FMD clinical picture.',
    createdAt: new Date(Date.now() - 864e5)
  });

  // Case 6: Negative/Closed
  const negativeCase = await FarmerReport.create({
    caseId: 'CASE-260825-06',
    farmer: ramesh._id,
    farmerName: ramesh.name,
    phone: ramesh.phone,
    animalType: 'Goat',
    symptoms: ['Nasal discharge'],
    location: alephataLoc,
    source: 'web',
    language: 'Marathi',
    suspectedDisease: 'PPR',
    triage: 'medium',
    localOutbreakRisk: 42,
    status: 'Negative',
    clinicalObservations: 'Simple allergic rhinitis without fever.',
    createdAt: new Date(Date.now() - 1728e5)
  });

  // Case 7 & 8: Active LSD Cluster in Wavi (To show multiple hotspots on live map)
  const lsdCase1 = await FarmerReport.create({
    caseId: 'CASE-260902-07',
    farmer: farmer._id,
    farmerName: farmer.name,
    phone: farmer.phone,
    animalType: 'Buffalo',
    symptoms: ['Skin nodules', 'Fever', 'Swollen lymph nodes'],
    location: waviLoc,
    source: 'web',
    language: 'Marathi',
    suspectedDisease: 'Lumpy Skin Disease',
    triage: 'medium',
    localOutbreakRisk: 55,
    status: 'Confirmed',
    createdAt: new Date(Date.now() - 432e5) // 12 hours ago
  });

  const lsdCase2 = await FarmerReport.create({
    caseId: 'CASE-260902-08',
    farmer: asha._id,
    farmerName: asha.name,
    phone: asha.phone,
    animalType: 'Cattle',
    symptoms: ['Skin nodules', 'Fever', 'Lethargy'],
    location: { ...waviLoc, latitude: 19.991, longitude: 74.112, coordinates: [74.112, 19.991] }, // slight offset
    source: 'sms',
    language: 'Marathi',
    suspectedDisease: 'Lumpy Skin Disease',
    triage: 'medium',
    localOutbreakRisk: 58,
    status: 'Confirmed',
    createdAt: new Date(Date.now() - 216e5) // 6 hours ago
  });

  // 4. Advisories for reports
  const allCases = [lowCase, escalatedCase, verifiedCase, labTestingCase, confirmedCase, negativeCase, lsdCase1, lsdCase2];
  for (const c of allCases) {
    const advisory = await Advisory.create({
      case: c._id,
      disease: c.suspectedDisease,
      title: `Advisory: ${c.suspectedDisease}`,
      message: 'Isolate affected animals, restrict animal movement, disinfect shed premises and follow veterinary directives.',
      riskBand: c.triage,
      approved: true
    });
    c.advisory = advisory._id;
    await c.save();
  }

  // 5. Vet Assignments
  await VetAssignment.insertMany([
    { case: escalatedCase._id, vet: vet._id, status: 'Assigned', assignedAt: new Date() },
    { case: verifiedCase._id, vet: vet._id, status: 'Verified', assignedAt: new Date(Date.now() - 3600000), verifiedAt: new Date() },
    { case: labTestingCase._id, vet: vet._id, status: 'Verified', assignedAt: new Date(Date.now() - 7200000), verifiedAt: new Date(Date.now() - 3600000) },
    { case: confirmedCase._id, vet: vet._id, status: 'Verified', assignedAt: new Date(Date.now() - 864e5), verifiedAt: new Date(Date.now() - 828e5) }
  ]);

  // 6. Samples: One pending for Lab Assistant, one completed with result
  const pendingSample = await Sample.create({
    sampleId: 'SMP-260901-02',
    case: labTestingCase._id,
    collectedBy: vet._id,
    lab: lab._id,
    status: 'Collected',
    collectedAt: new Date(Date.now() - 3600000),
    notes: 'Epithelial tissue sample and vesicular fluid in sterile transport medium.'
  });

  const completedSample = await Sample.create({
    sampleId: 'SMP-260831-01',
    case: confirmedCase._id,
    collectedBy: vet._id,
    lab: lab._id,
    status: 'Completed',
    collectedAt: new Date(Date.now() - 864e5),
    receivedAt: new Date(Date.now() - 828e5),
    notes: 'Vesicular fluid collected for molecular testing.'
  });

  // 7. Lab Results
  await LabResult.create({
    sample: completedSample._id,
    result: 'Confirmed',
    disease: 'Foot and Mouth Disease',
    notes: 'RT-PCR positive for FMDV Serotype O.',
    submittedBy: lab._id,
    submittedAt: new Date(Date.now() - 792e5)
  });

  // 8. Notifications across roles
  await Notification.insertMany([
    { user: farmer._id, title: 'Health advisory available', message: 'Advisory issued for CASE-260901-01.', case: lowCase._id, type: 'advisory' },
    { user: vet._id, title: 'High-risk livestock case assigned', message: `${escalatedCase.caseId}: Foot and Mouth Disease reported in Pimpalgaon. Immediate visit recommended.`, case: escalatedCase._id, type: 'escalation' },
    { user: lab._id, title: 'New sample received for testing', message: `Sample ${pendingSample.sampleId} requires laboratory diagnostic processing.`, case: labTestingCase._id, type: 'sample' },
    { user: districtOfficer._id, title: 'Confirmed FMD cluster in Pimpalgaon', message: 'Laboratory confirmation received. High-density transmission alert.', case: confirmedCase._id, type: 'lab-result' },
    { user: stateOfficer._id, title: 'Nashik district risk level updated', message: 'Nashik operational risk increased to 76% following PCR-confirmed FMD cluster.', case: confirmedCase._id, type: 'state-alert' }
  ]);

  // 9. District Action Requests (Pending, Prioritized, Approved)
  await ActionRequest.insertMany([
    {
      requestId: 'REQ-260901-01',
      type: 'vaccination',
      district: 'Nashik',
      taluka: 'Niphad',
      village: 'Pimpalgaon',
      disease: 'Foot and Mouth Disease',
      reason: 'Ring vaccination required for 2,500 cattle around Pimpalgaon cluster.',
      createdBy: districtOfficer._id,
      status: 'Prioritized',
      priority: 'High'
    },
    {
      requestId: 'REQ-260901-02',
      type: 'containment',
      district: 'Nashik',
      taluka: 'Niphad',
      village: 'Pimpalgaon',
      disease: 'Foot and Mouth Disease',
      reason: 'Temporary animal movement and local weekly livestock market suspension.',
      createdBy: districtOfficer._id,
      status: 'Pending',
      priority: 'Normal'
    },
    {
      requestId: 'REQ-260830-03',
      type: 'vaccination',
      district: 'Pune',
      taluka: 'Junnar',
      village: 'Alephata',
      disease: 'PPR',
      reason: 'Targeted booster vaccination for small ruminants.',
      createdBy: districtOfficer._id,
      status: 'Approved',
      priority: 'High',
      allocation: '1,000 vaccine doses dispatched.',
      reviewedBy: stateOfficer._id,
      reviewedAt: new Date(Date.now() - 864e5)
    }
  ]);

  // 10. Historical Records (segregated from live data)
  await HistoricalDiseaseRecord.insertMany([
    { disease: 'Foot and Mouth Disease', district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon', count: 12, recordedAt: new Date('2026-07-20') },
    { disease: 'Foot and Mouth Disease', district: 'Nashik', taluka: 'Sinnar', village: 'Wavi', count: 5, recordedAt: new Date('2026-08-05') },
    { disease: 'Lumpy Skin Disease', district: 'Nashik', taluka: 'Sinnar', village: 'Wavi', count: 8, recordedAt: new Date('2026-07-14') },
    { disease: 'Foot and Mouth Disease', district: 'Pune', taluka: 'Junnar', village: 'Alephata', count: 4, recordedAt: new Date('2026-08-15') },
    { disease: 'PPR', district: 'Ahmednagar', taluka: 'Sangamner', village: 'Ashwi', count: 7, recordedAt: new Date('2026-07-28') }
  ]);

  console.log('Seed completed successfully.');
  console.log('Demo login password for all users: demo123');
  console.log('Farmer: 9876543210 (Suresh Patil) | 9876543211 (Asha Kale)');
  console.log('Vet: 9000000001 (Dr Ananya Shah)');
  console.log('Lab: 9000000002 (Nisha Rao)');
  console.log('District: 9000000003 (Vikram Deshmukh - Nashik)');
  console.log('State: 9000000004 (Priya Kulkarni - Maharashtra)');
}

// Standalone CLI runner
if (process.argv[1] && process.argv[1].replace(/\\/g, '/').endsWith('backend/src/seed.js')) {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  try {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 2500 });
    await seedDatabase();
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.warn(`Connecting to local MongoDB at ${uri} failed (${err.message}).`);
    console.warn('Running seed with embedded MongoDB runner...');
    try {
      const { MongoMemoryServer } = await import('mongodb-memory-server');
      const mongod = await MongoMemoryServer.create({ instance: { dbName: 'ldews' } });
      const memUri = mongod.getUri();
      await mongoose.connect(memUri);
      await seedDatabase();
      await mongoose.disconnect();
      await mongod.stop();
      console.log('Embedded seed verified successfully.');
      process.exit(0);
    } catch (memErr) {
      console.error('Seed execution error:', memErr.message);
      process.exit(1);
    }
  }
}

