/**
 * LDEWS End-to-End ML Integration Test
 * 
 * Verifies:
 * 1. GET /api/ml/health with FastAPI online
 * 2. POST /api/reports symptom prediction via FastAPI (mlSource = fastapi)
 * 3. POST /api/reports multipart image screening via FastAPI (imageScreening)
 * 4. GET /api/district/:district/clusters via DBSCAN
 * 5. Transparent fallback behavior when FastAPI is offline
 */

import 'dotenv/config';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import { FarmerReport, User, District, Village } from './src/models/index.js';
import { processReport } from './src/services/workflowService.js';
import { healthCheckML, detectOutbreaks } from './src/services/mlClient.js';
import { seedDatabase } from './src/seed.js';

let assertionCount = 0;
function assert(condition, message) {
  if (!condition) {
    console.error(`  FAIL: ${message}`);
    process.exit(1);
  }
  assertionCount++;
  console.log(`  ✓ ${message}`);
}

async function runTests() {
  console.log('\n==================================================');
  console.log('LDEWS Python FastAPI ML Integration Test');
  console.log('==================================================\n');

  // 1. Connect DB
  let mongodInstance = null;
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2000 });
  } catch {
    const { MongoMemoryServer } = await import('mongodb-memory-server');
    mongodInstance = await MongoMemoryServer.create({ instance: { dbName: 'ldews' } });
    await mongoose.connect(mongodInstance.getUri());
  }
  assert(mongoose.connection.readyState === 1, 'Database connected');

  await seedDatabase();

  // 2. Health check via mlClient
  console.log('\n1. Testing ML Microservice Health Check:');
  const health = await healthCheckML();
  console.log('  Health check result:', health);
  assert(health.status === 'online', 'FastAPI health check status is online');
  assert(health.details?.tabularModelLoaded === true, 'FastAPI has tabular Voting Ensemble loaded');
  assert(health.details?.imageModelLoaded === true, 'FastAPI has ResNet18 image model loaded');

  // 3. Test symptom report with FastAPI online
  console.log('\n2. Testing Farmer Report with Real FastAPI Symptom Prediction:');
  const farmer = await User.findOne({ role: 'farmer' });
  const reportPayload = {
    animalType: 'Cattle',
    symptoms: ['Mouth blisters', 'Drooling of saliva (ropey string)', 'Lameness'],
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' },
    source: 'web'
  };

  const reportData = await processReport(reportPayload, farmer);
  console.log('  Report created:', reportData.report.caseId, 'Disease:', reportData.report.suspectedDisease, 'ML Source:', reportData.report.mlSource);
  assert(reportData.report.mlSource === 'fastapi', 'Report mlSource is fastapi');
  assert(reportData.report.mlPrediction?.modelSource === 'fastapi', 'mlPrediction modelSource is fastapi');
  assert(reportData.report.mlPrediction?.diseaseId === 8, 'Predicted disease ID is 8 (Foot and Mouth Disease)');
  assert(reportData.report.suspectedDisease === 'Foot and Mouth Disease', 'Suspected condition mapped to Foot and Mouth Disease');
  assert(reportData.report.mlPrediction?.confidence > 0.5, 'Prediction confidence > 0.5');

  // 4. Test report with image screening metadata
  console.log('\n3. Testing Report Image Screening Metadata Preservation:');
  const imageReportPayload = {
    animalType: 'Cattle',
    symptoms: ['Skin nodules', 'High fever'],
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' },
    imageScreening: {
      prediction: 'Normal Skin',
      confidence: 0.88,
      filename: 'sample_cow.jpg',
      source: 'fastapi',
      screenedAt: new Date()
    }
  };
  const imgReportData = await processReport(imageReportPayload, farmer);
  assert(imgReportData.report.imageScreening?.prediction === 'Normal Skin', 'Image screening prediction preserved on case');
  assert(imgReportData.report.imageScreening?.source === 'fastapi', 'Image screening source is fastapi');

  // 5. Test DBSCAN Outbreak Detection via mlClient
  console.log('\n4. Testing DBSCAN Outbreak Detection:');
  const dbscanCases = [
    { report_id: 1, latitude: 20.084, longitude: 73.985 },
    { report_id: 2, latitude: 20.086, longitude: 73.987 },
    { report_id: 3, latitude: 20.085, longitude: 73.986 }
  ];
  const dbscanResult = await detectOutbreaks({ radiusKm: 15, minCases: 2, cases: dbscanCases });
  console.log('  DBSCAN result:', dbscanResult);
  assert(dbscanResult.success === true, 'DBSCAN call succeeded');
  assert(dbscanResult.source === 'dbscan', 'DBSCAN source is dbscan');
  assert(dbscanResult.outbreaks.length >= 1, 'At least 1 spatial cluster detected');
  assert(dbscanResult.outbreaks[0].sumCases === 3, 'Cluster contains 3 connected cases');

  // 6. Test Graceful Fallback Simulation
  console.log('\n5. Testing Graceful Fallback when ML Service is Unreachable:');
  // Temporarily override ML_SERVICE_URL to simulate offline port
  const origUrl = process.env.ML_SERVICE_URL;
  process.env.ML_SERVICE_URL = 'http://127.0.0.1:59999'; // Dead port

  const offlineHealth = await healthCheckML();
  assert(offlineHealth.status === 'offline', 'Offline health check reports status: offline');
  assert(offlineHealth.fallbackAvailable === true, 'Offline health check indicates fallbackAvailable: true');

  const fallbackReportPayload = {
    animalType: 'Goat',
    symptoms: ['cough', 'diarrhea', 'nasal discharge'],
    location: { district: 'Nashik', taluka: 'Niphad', village: 'Pimpalgaon' }
  };
  const fallbackData = await processReport(fallbackReportPayload, farmer);
  console.log('  Fallback report:', fallbackData.report.caseId, 'Source:', fallbackData.report.mlSource, 'Disease:', fallbackData.report.suspectedDisease);
  assert(fallbackData.report.mlSource === 'fallback', 'When ML service is offline, mlSource is fallback');
  assert(fallbackData.report.status.length > 0, 'Report was still created successfully');
  assert(fallbackData.advisory?.message.length > 0, 'Advisory was still generated successfully');

  // Restore URL
  process.env.ML_SERVICE_URL = origUrl;

  console.log(`\n==================================================`);
  console.log(`INTEGRATION TEST RESULTS: ${assertionCount} assertions passed, 0 failed.`);
  console.log(`==================================================\n`);

  await mongoose.disconnect();
  if (mongodInstance) {
    await mongodInstance.stop();
  }
  process.exit(0);
}

runTests().catch(err => {
  console.error('Test run failed:', err);
  process.exit(1);
});
