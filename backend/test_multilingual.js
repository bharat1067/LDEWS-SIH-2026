import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

import {
  getRequestLanguage,
  localizeDisease,
  getLocalizedAdvisory,
  getLocalizedNotification,
  normalizeHindiSpecies,
  normalizeHindiSymptoms,
  DISEASE_TRANSLATIONS
} from './src/services/localizationService.js';
import { processReport } from './src/services/workflowService.js';
import { FarmerReport, Advisory, Notification } from './src/models/index.js';

let mongodInstance = null;

function assert(condition, message) {
  if (!condition) {
    console.error(`❌ ASSERTION FAILED: ${message}`);
    throw new Error(`Assertion failed: ${message}`);
  }
  console.log(`  ✓ ${message}`);
}

async function runMultilingualTests() {
  console.log('====================================================');
  console.log('LDEWS Multilingual (Hindi) Architecture Verification');
  console.log('====================================================\n');

  // ----------------------------------------------------
  // UNIT TEST 1: Language Detection & Fallbacks
  // ----------------------------------------------------
  console.log('[Test 1] Testing getRequestLanguage() priority resolution...');

  // Case A: X-LDEWS-Language header
  assert(getRequestLanguage({ headers: { 'x-ldews-language': 'hi' } }) === 'hi', 'Detects X-LDEWS-Language: hi');
  assert(getRequestLanguage({ headers: { 'x-ldews-language': 'en' } }) === 'en', 'Detects X-LDEWS-Language: en');

  // Case B: Query parameter
  assert(getRequestLanguage({ headers: {}, query: { lang: 'hi' } }) === 'hi', 'Detects ?lang=hi query param');

  // Case C: Body language property ('Hindi' or 'hi')
  assert(getRequestLanguage({ headers: {}, body: { language: 'Hindi' } }) === 'hi', 'Detects body.language = "Hindi" as "hi"');
  assert(getRequestLanguage({ headers: {}, body: { language: 'hi' } }) === 'hi', 'Detects body.language = "hi"');

  // Case D: Accept-Language header
  assert(getRequestLanguage({ headers: { 'accept-language': 'hi-IN,hi;q=0.9,en;q=0.8' } }) === 'hi', 'Detects Accept-Language: hi-IN');

  // Case E: Default fallback
  assert(getRequestLanguage({ headers: {} }) === 'en', 'Defaults to "en" when no language specified');
  assert(getRequestLanguage(null) === 'en', 'Handles null request object safely by defaulting to "en"');

  // ----------------------------------------------------
  // UNIT TEST 2: Hindi Species Normalization
  // ----------------------------------------------------
  console.log('\n[Test 2] Testing normalizeHindiSpecies() presentation decoupling...');
  assert(normalizeHindiSpecies('गाय') === 'Cattle', 'Normalizes "गाय" to canonical "Cattle"');
  assert(normalizeHindiSpecies('भैंस') === 'Buffalo', 'Normalizes "भैंस" to canonical "Buffalo"');
  assert(normalizeHindiSpecies('बकरी') === 'Goat', 'Normalizes "बकरी" to canonical "Goat"');
  assert(normalizeHindiSpecies('भेड़') === 'Sheep', 'Normalizes "भेड़" to canonical "Sheep"');
  assert(normalizeHindiSpecies('मुर्गी') === 'Poultry', 'Normalizes "मुर्गी" to canonical "Poultry"');
  assert(normalizeHindiSpecies('Cattle') === 'Cattle', 'Preserves canonical English "Cattle" unchanged');

  // ----------------------------------------------------
  // UNIT TEST 3: Hindi Symptoms Normalization
  // ----------------------------------------------------
  console.log('\n[Test 3] Testing normalizeHindiSymptoms() presentation decoupling...');
  const hindiSymptoms = ['मुंह में छाले', 'अत्यधिक लार गिरना', 'अचानक लंगड़ापन'];
  const normalized = normalizeHindiSymptoms(hindiSymptoms);
  assert(normalized.includes('Mouth blisters'), 'Maps "मुंह में छाले" to canonical "Mouth blisters"');
  assert(normalized.includes('Excessive drooling'), 'Maps "अत्यधिक लार गिरना" to canonical "Excessive drooling"');
  assert(normalized.includes('Sudden lameness'), 'Maps "अचानक लंगड़ापन" to canonical "Sudden lameness"');

  // Preserves existing English symptoms
  const englishSymptoms = ['High fever', 'Skin nodules'];
  const preserved = normalizeHindiSymptoms(englishSymptoms);
  assert(preserved[0] === 'High fever' && preserved[1] === 'Skin nodules', 'Preserves canonical English symptoms unchanged');

  // ----------------------------------------------------
  // UNIT TEST 4: Disease Translation & Advisories
  // ----------------------------------------------------
  console.log('\n[Test 4] Testing localizeDisease() and getLocalizedAdvisory()...');
  assert(localizeDisease('Foot and Mouth Disease', 'hi') === 'खुरपका और मुंहपका रोग (FMD)', 'Localizes FMD to Hindi');
  assert(localizeDisease('Lumpy Skin Disease', 'hi') === 'लंपी स्किन रोग (LSD)', 'Localizes LSD to Hindi');
  assert(localizeDisease('Foot and Mouth Disease', 'en') === 'Foot and Mouth Disease', 'Preserves FMD in English mode');

  const hindiAdvisory = getLocalizedAdvisory('Foot and Mouth Disease', 'hi');
  assert(hindiAdvisory.title.includes('खुरपका और मुंहपका'), 'Advisory title is in Hindi');
  assert(hindiAdvisory.message.includes('अलगाव') || hindiAdvisory.message.includes('स्वस्थ पशुओं से अलग'), 'Advisory message contains protective Hindi guidance');

  const englishAdvisory = getLocalizedAdvisory('Foot and Mouth Disease', 'en');
  assert(englishAdvisory.title.includes('Foot and Mouth Disease'), 'Advisory title is in English when lang is "en"');

  // ----------------------------------------------------
  // UNIT TEST 5: Localized Notifications
  // ----------------------------------------------------
  console.log('\n[Test 5] Testing getLocalizedNotification()...');
  const hiNotif = getLocalizedNotification('REPORT_REGISTERED', { caseId: 'CASE-TEST-1', disease: 'Foot and Mouth Disease' }, 'hi');
  assert(hiNotif.title.includes('पशु स्वास्थ्य रिपोर्ट दर्ज'), 'Notification title is localized in Hindi');
  assert(hiNotif.message.includes('CASE-TEST-1'), 'Notification message contains caseId');
  assert(hiNotif.message.includes('खुरपका और मुंहपका रोग (FMD)'), 'Notification message contains localized disease name');

  // ----------------------------------------------------
  // INTEGRATION TEST: Full processReport() with MongoDB
  // ----------------------------------------------------
  console.log('\n[Test 6] Connecting to MongoDB to test end-to-end processReport() workflow...');
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2000 });
    console.log('Connected to local MongoDB database at', mongoUri);
  } catch (err) {
    console.log(`Local MongoDB unavailable (${err.message}). Starting embedded memory MongoDB...`);
    const { MongoMemoryServer } = await import('mongodb-memory-server');
    mongodInstance = await MongoMemoryServer.create({ instance: { dbName: 'ldews' } });
    const memUri = mongodInstance.getUri();
    await mongoose.connect(memUri);
    console.log('Connected to embedded in-memory MongoDB at', memUri);
  }

  // Flow A: English Report Submission
  console.log('\n--- Flow A: Submitting Report in English (Canonical) ---');
  const enResult = await processReport({
    farmerName: 'Ramesh English Test',
    phone: '9876500001',
    animalType: 'Cattle',
    symptoms: ['Mouth blisters', 'Excessive drooling', 'Sudden lameness'],
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' },
    source: 'web',
    language: 'en'
  });

  assert(enResult.report._id, 'Report created with Mongo ObjectId');
  assert(enResult.report.suspectedDisease === 'Foot and Mouth Disease', 'Canonical database field suspectedDisease is "Foot and Mouth Disease" (English)');
  assert(enResult.report.suspectedDiseaseDisplay === 'Foot and Mouth Disease', 'English mode suspectedDiseaseDisplay is English');
  assert(enResult.advisory.title.includes('Foot and Mouth Disease'), 'Advisory title is in English');

  // Flow B: Hindi Report Submission (Presentation localized, ML Canonical)
  console.log('\n--- Flow B: Submitting Report in Hindi (Localization Presentation Layer) ---');
  const hiResult = await processReport({
    farmerName: 'सुरेश पाटिल (Hindi Test)',
    phone: '9876500002',
    animalType: 'Cattle', // Presentation was "गाय", canonical value sent to API is "Cattle"
    symptoms: ['Mouth blisters', 'Excessive drooling'],
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' },
    source: 'web',
    language: 'Hindi' // User preferred language is Hindi
  });

  assert(hiResult.report._id, 'Hindi report created successfully');
  // CRITICAL ARCHITECTURAL CHECK:
  // Internal MongoDB stored canonical English:
  const savedCase = await FarmerReport.findById(hiResult.report._id);
  assert(savedCase.suspectedDisease === 'Foot and Mouth Disease', 'CRITICAL: Database stored canonical English disease name "Foot and Mouth Disease" for ML pipeline');
  assert(savedCase.location.district === 'Nashik', 'Database stored canonical English district');
  
  // Outer enriched presentation layer:
  assert(hiResult.report.suspectedDiseaseDisplay === 'खुरपका और मुंहपका रोग (FMD)', 'API response returns localized suspectedDiseaseDisplay in Hindi');
  assert(hiResult.advisory.title.includes('खुरपका और मुंहपका'), 'API response returns localized Hindi advisory title');
  assert(hiResult.advisory.message.includes('अलगाव') || hiResult.advisory.message.includes('अलग करें'), 'API response returns localized Hindi advisory directive');

  // Check stored Advisory in MongoDB
  const savedAdvisory = await Advisory.findOne({ case: hiResult.report._id });
  assert(savedAdvisory !== null, 'Advisory record saved in MongoDB');
  assert(savedAdvisory.message.includes('अलगाव') || savedAdvisory.message.includes('अलग करें'), 'Advisory record contains official Hindi message');

  // Check stored Notification in MongoDB
  const savedNotif = await Notification.findOne({ case: hiResult.report._id }).sort({ deliveredAt: -1 });
  if (savedNotif) {
    assert(savedNotif.title.includes('पशु स्वास्थ्य') || savedNotif.title.includes('चेतावनी') || savedNotif.title.includes('advisory'), 'Farmer received localized notification');
  }

  // Flow C: Defensive Hindi Input Normalization
  console.log('\n--- Flow C: Submitting Report with Raw Devanagari Species & Symptoms ---');
  const devanagariResult = await processReport({
    farmerName: 'देवनागरी इनपुट टेस्ट',
    phone: '9876500003',
    animalType: 'गाय', // Raw Hindi species
    symptoms: ['मुंह में छाले', 'अत्यधिक लार गिरना'], // Raw Hindi symptoms
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' },
    source: 'ivr',
    language: 'hi'
  });

  assert(devanagariResult.report.animalType === 'Cattle', 'Defensively normalized raw Devanagari "गाय" to canonical "Cattle" before saving');
  assert(devanagariResult.report.suspectedDisease === 'Foot and Mouth Disease', 'Triage executed successfully with canonical English disease');
  assert(devanagariResult.report.suspectedDiseaseDisplay === 'खुरपका और मुंहपका रोग (FMD)', 'Response displays Hindi translation');

  // Cleanup test documents
  await FarmerReport.deleteMany({ phone: { $in: ['9876500001', '9876500002', '9876500003'] } });
  await Advisory.deleteMany({ case: { $in: [enResult.report._id, hiResult.report._id, devanagariResult.report._id] } });

  await mongoose.disconnect();
  if (mongodInstance) {
    await mongodInstance.stop();
  }
  console.log('\n====================================================');
  console.log('✅ ALL MULTILINGUAL ARCHITECTURE TESTS PASSED 100%!');
  console.log('====================================================');
}

runMultilingualTests().catch(err => {
  console.error('Test suite failed:', err);
  process.exit(1);
});
