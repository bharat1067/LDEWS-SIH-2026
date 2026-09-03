import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

import {
  User,
  FarmerReport,
  Sample,
  LabResult,
  Notification,
  VetAssignment,
  ActionRequest,
  HistoricalDiseaseRecord,
  District,
  Village
} from './models/index.js';
import multer from 'multer';
import { predict, predictDistrictRisk } from './services/mlService.js';
import { healthCheckML, predictImage, detectOutbreaks } from './services/mlClient.js';
import { processReport, collectSample, notify } from './services/workflowService.js';
import { seedDatabase } from './seed.js';

const app = express();
const port = process.env.PORT || 5000;
const secret = process.env.JWT_SECRET || 'demo-secret-key-sih2026';

// Multer in-memory storage for optional animal photo uploads (5MB max)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }
});

app.use(cors({ origin: process.env.FRONTEND_ORIGIN || 'http://localhost:5173' }));
app.use(express.json());

// Token helpers
const tokenFor = u => jwt.sign(
  { id: u._id, role: u.role, name: u.name, phone: u.phone, district: u.district, taluka: u.taluka },
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
  taluka: u.taluka
});

// Authentication middleware
const auth = (roles = []) => async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authentication required' });
    }
    const token = authHeader.slice(7);
    const decoded = jwt.verify(token, secret);
    req.user = decoded;
    if (roles.length && !roles.includes(decoded.role)) {
      return res.status(403).json({ message: 'Insufficient role permission' });
    }
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired authentication token' });
  }
};

// Robust entity lookup helpers supporting both ObjectId and custom identifiers
const findCase = id => {
  const isObjId = mongoose.isValidObjectId(id);
  return FarmerReport.findOne({
    $or: [
      ...(isObjId ? [{ _id: id }] : []),
      { caseId: id }
    ]
  });
};

const findSample = (id, labId = null) => {
  const isObjId = mongoose.isValidObjectId(id);
  const query = {
    $or: [
      ...(isObjId ? [{ _id: id }] : []),
      { sampleId: id }
    ]
  };
  if (labId) query.lab = labId;
  return Sample.findOne(query);
};

const findRequest = id => {
  const isObjId = mongoose.isValidObjectId(id);
  return ActionRequest.findOne({
    $or: [
      ...(isObjId ? [{ _id: id }] : []),
      { requestId: id }
    ]
  });
};

// --- System & Health ---
app.get('/api/health', (_, res) => {
  res.json({
    status: 'ok',
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    host: mongoose.connection.host || 'none',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/ml/health', async (_, res) => {
  try {
    const health = await healthCheckML();
    res.json(health);
  } catch (err) {
    res.json({
      status: 'offline',
      fallbackAvailable: true,
      service: 'fallback',
      error: err.message
    });
  }
});

// --- Authentication Routes ---
app.post('/api/auth/login', async (req, res, next) => {
  try {
    const { identifier, password } = req.body;
    if (!identifier || !password) {
      return res.status(400).json({ message: 'Phone/email and password are required' });
    }
    const u = await User.findOne({
      $or: [{ phone: identifier }, { email: identifier }],
      active: true
    });
    if (!u || !u.password || !await bcrypt.compare(password, u.password)) {
      return res.status(401).json({ message: 'Invalid phone, email or password' });
    }
    res.json({ token: tokenFor(u), user: publicUser(u) });
  } catch (err) {
    next(err);
  }
});

app.post('/api/auth/demo-login', async (req, res, next) => {
  try {
    const role = req.body.role || 'farmer';
    const u = await User.findOne({ role, active: true });
    if (!u) {
      return res.status(503).json({ message: `No demo user found for role '${role}'. Please run 'npm run seed' first.` });
    }
    res.json({ token: tokenFor(u), user: publicUser(u) });
  } catch (err) {
    next(err);
  }
});

app.get('/api/notifications', auth(), async (req, res, next) => {
  try {
    const list = await Notification.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .populate('case', 'caseId status suspectedDisease');
    res.json(list);
  } catch (err) {
    next(err);
  }
});

// --- ML Contract Routes ---
app.post('/api/ml/predict', auth(), async (req, res, next) => {
  try {
    const result = await predict(req.body);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

app.post('/api/ml/district-risk', auth(), async (req, res, next) => {
  try {
    const result = await predictDistrictRisk(req.body);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// --- Farmer Reporting & Case Access ---
app.post('/api/reports', auth(['farmer']), (req, res, next) => {
  upload.single('photo')(req, res, err => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ message: 'Photo size exceeds the maximum limit of 5MB.' });
      }
      return res.status(400).json({ message: `Photo upload error: ${err.message}` });
    }
    next();
  });
}, async (req, res, next) => {
  try {
    let { animalType, symptoms, location, district, taluka, village } = req.body;

    // Support parsed or stringified inputs from multipart FormData
    if (typeof symptoms === 'string' && (symptoms.startsWith('[') || symptoms.startsWith('{'))) {
      try { symptoms = JSON.parse(symptoms); } catch {}
    }
    if (typeof location === 'string') {
      try { location = JSON.parse(location); } catch {}
    }

    if (!animalType) {
      return res.status(400).json({ message: 'Animal type is required' });
    }
    const loc = location || { district, taluka, village };
    if (!loc.district || !loc.village) {
      return res.status(400).json({ message: 'District and village are required' });
    }

    let imageScreening = null;
    let photoUrl = '';

    // Handle optional animal photo
    if (req.file) {
      const mime = req.file.mimetype;
      if (!['image/jpeg', 'image/png', 'image/jpg'].includes(mime)) {
        return res.status(400).json({ message: 'Only JPG, JPEG, and PNG images are supported.' });
      }

      // Perform AI visual screening using FastAPI ResNet18 model
      try {
        const imgRes = await predictImage({
          fileBuffer: req.file.buffer,
          filename: req.file.originalname,
          mimetype: mime
        });

        if (imgRes.success) {
          imageScreening = {
            prediction: imgRes.image_prediction,
            confidence: imgRes.confidence_score,
            filename: imgRes.filename,
            source: 'fastapi',
            screenedAt: new Date()
          };
        } else {
          imageScreening = {
            prediction: 'Visual Screening Unavailable',
            confidence: 0,
            filename: req.file.originalname,
            source: 'fallback',
            screenedAt: new Date(),
            error: imgRes.error
          };
        }
      } catch (imgErr) {
        imageScreening = {
          prediction: 'Visual Screening Unavailable',
          confidence: 0,
          filename: req.file.originalname,
          source: 'fallback',
          screenedAt: new Date()
        };
      }

      photoUrl = `data:${mime};base64,${req.file.buffer.toString('base64').slice(0, 120)}...`;
    }

    const farmer = await User.findById(req.user.id);
    const data = await processReport({
      ...req.body,
      symptoms,
      location: loc,
      source: req.body.source || 'web',
      imageScreening,
      photoUrl
    }, farmer);

    res.status(201).json({
      case: data.report,
      advisory: data.advisory,
      escalated: data.escalated
    });
  } catch (err) {
    next(err);
  }
});

app.get('/api/reports/my', auth(['farmer']), async (req, res, next) => {
  try {
    const reports = await FarmerReport.find({ farmer: req.user.id })
      .sort({ createdAt: -1 })
      .populate('advisory');
    res.json(reports);
  } catch (err) {
    next(err);
  }
});

app.get('/api/reports/:id', auth(['farmer', 'vet', 'lab', 'district', 'state']), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id).populate('advisory');
    if (!c) return res.status(404).json({ message: 'Case not found' });
    if (req.user.role === 'farmer' && String(c.farmer) !== req.user.id) {
      return res.status(403).json({ message: 'Unauthorized to view this report' });
    }
    res.json(c);
  } catch (err) {
    next(err);
  }
});

// --- IVR Integration Simulation Endpoint ---
app.post('/api/ivr/report', async (req, res, next) => {
  try {
    const b = req.body;
    if (!b.phone || !b.animalType || !b.district || !b.village) {
      return res.status(400).json({
        message: 'phone, animalType, district and village are required for IVR reports'
      });
    }

    let farmer = await User.findOne({ phone: b.phone });
    if (!farmer) {
      farmer = await User.create({
        name: b.farmerName || 'IVR Caller',
        phone: b.phone,
        role: 'farmer',
        district: b.district,
        taluka: b.taluka || ''
      });
    }

    const data = await processReport({
      ...b,
      source: 'ivr',
      location: {
        district: b.district,
        taluka: b.taluka || '',
        village: b.village
      }
    }, farmer);

    res.status(201).json({
      callReference: `IVR-${Date.now()}`,
      captured: true,
      case: data.report,
      advisory: data.advisory,
      escalated: data.escalated
    });
  } catch (err) {
    next(err);
  }
});

// --- Shared Case Query ---
app.get('/api/cases', auth(), async (req, res, next) => {
  try {
    let query = {};
    if (req.user.role === 'farmer') {
      query = { farmer: req.user.id };
    } else if (req.user.role === 'vet') {
      const assigned = await VetAssignment.find({ vet: req.user.id }).select('case');
      query = {
        $or: [
          { _id: { $in: assigned.map(x => x.case) } },
          { 'location.district': req.user.district, status: { $in: ['Escalated to Vet', 'Vet Verified', 'Lab Testing'] } }
        ]
      };
    }
    const list = await FarmerReport.find(query).sort({ createdAt: -1 });
    res.json(list);
  } catch (err) {
    next(err);
  }
});

app.get('/api/cases/:id', auth(), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id);
    if (!c) return res.status(404).json({ message: 'Case not found' });
    res.json(c);
  } catch (err) {
    next(err);
  }
});

// --- Veterinary Workflow Routes ---
app.get('/api/vet/cases', auth(['vet']), async (req, res, next) => {
  try {
    const assigned = await VetAssignment.find({ vet: req.user.id }).select('case');
    const cases = await FarmerReport.find({
      $or: [
        { _id: { $in: assigned.map(x => x.case) } },
        { 'location.district': req.user.district, status: { $in: ['Escalated to Vet', 'Vet Verified', 'Lab Testing'] } }
      ]
    }).sort({ createdAt: -1 });
    res.json(cases);
  } catch (err) {
    next(err);
  }
});

app.get('/api/vet/cases/:id', auth(['vet']), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id);
    if (!c) return res.status(404).json({ message: 'Case not found' });
    const isAssigned = await VetAssignment.findOne({ case: c._id, vet: req.user.id });
    if (!isAssigned && c.location?.district !== req.user.district) {
      return res.status(403).json({ message: 'Case outside assigned veterinary jurisdiction' });
    }
    res.json(c);
  } catch (err) {
    next(err);
  }
});

app.patch('/api/vet/cases/:id/verify', auth(['vet']), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id);
    if (!c) return res.status(404).json({ message: 'Case not found' });

    let a = await VetAssignment.findOne({ case: c._id, vet: req.user.id });
    if (!a) {
      a = await VetAssignment.create({ case: c._id, vet: req.user.id, status: 'Assigned' });
    }

    c.status = 'Vet Verified';
    c.clinicalObservations = req.body.clinicalObservations || c.clinicalObservations || 'Clinical examination completed.';
    await c.save();

    a.status = 'Verified';
    a.verifiedAt = new Date();
    await a.save();

    if (c.farmer) {
      await notify(c.farmer, 'Veterinary verification complete', `${c.caseId} has been verified by the veterinary officer.`, c._id, 'vet-verification');
    }

    res.json(c);
  } catch (err) {
    next(err);
  }
});

app.patch('/api/vet/cases/:id/status', auth(['vet']), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id);
    if (!c) return res.status(404).json({ message: 'Case not found' });

    const validStatuses = ['Vet Verified', 'Sample Collected', 'Lab Testing', 'Closed'];
    if (!validStatuses.includes(req.body.status)) {
      return res.status(400).json({ message: 'Invalid vet status' });
    }

    c.status = req.body.status;
    if (req.body.clinicalObservations) {
      c.clinicalObservations = req.body.clinicalObservations;
    }
    await c.save();
    res.json(c);
  } catch (err) {
    next(err);
  }
});

app.post('/api/vet/cases/:id/sample', auth(['vet']), async (req, res, next) => {
  try {
    const c = await findCase(req.params.id);
    if (!c) return res.status(404).json({ message: 'Case not found' });

    if (c.status !== 'Vet Verified') {
      return res.status(409).json({ message: 'Please verify the case before collecting a sample.' });
    }

    const vetUser = await User.findById(req.user.id);
    const result = await collectSample(c, vetUser, req.body.notes);

    // Returns both sample and updated case for clean frontend state update
    res.status(201).json({
      sample: result.sample,
      case: result.case
    });
  } catch (err) {
    next(err);
  }
});

// --- Laboratory Workflow Routes ---
app.get('/api/lab/samples', auth(['lab']), async (req, res, next) => {
  try {
    const samples = await Sample.find({ lab: req.user.id })
      .populate('case')
      .sort({ createdAt: -1 });
    res.json(samples);
  } catch (err) {
    next(err);
  }
});

app.get('/api/lab/samples/:id', auth(['lab']), async (req, res, next) => {
  try {
    const s = await findSample(req.params.id, req.user.id).populate('case');
    if (!s) return res.status(404).json({ message: 'Sample not found' });
    res.json(s);
  } catch (err) {
    next(err);
  }
});

app.patch('/api/lab/samples/:id/status', auth(['lab']), async (req, res, next) => {
  try {
    const s = await findSample(req.params.id, req.user.id);
    if (!s) return res.status(404).json({ message: 'Sample not found' });

    const validStatuses = ['Received', 'Testing', 'Completed'];
    if (!validStatuses.includes(req.body.status)) {
      return res.status(400).json({ message: 'Invalid laboratory sample status' });
    }

    s.status = req.body.status;
    if (req.body.status === 'Received') s.receivedAt = new Date();
    await s.save();
    res.json(s);
  } catch (err) {
    next(err);
  }
});

app.post('/api/lab/samples/:id/result', auth(['lab']), async (req, res, next) => {
  try {
    const s = await findSample(req.params.id, req.user.id).populate('case');
    if (!s) return res.status(404).json({ message: 'Sample not found' });

    const { result, notes, disease } = req.body;
    if (!['Confirmed', 'Negative', 'Inconclusive'].includes(result)) {
      return res.status(400).json({ message: 'Result must be Confirmed, Negative, or Inconclusive' });
    }

    const labResult = await LabResult.create({
      sample: s._id,
      result,
      disease: disease || s.case?.suspectedDisease || 'General livestock infection',
      notes: notes || 'Laboratory diagnosis submitted.',
      submittedBy: req.user.id,
      submittedAt: new Date()
    });

    s.status = 'Completed';
    await s.save();

    if (s.case) {
      s.case.status = result === 'Confirmed' ? 'Confirmed' : (result === 'Negative' ? 'Negative' : 'Closed');
      await s.case.save();

      // Notify farmer, district officers, state officers, and assigned vet
      const officers = await User.find({ role: { $in: ['district', 'state'] }, active: true });
      const notifications = [
        ...officers.map(o => notify(o, 'Laboratory result published', `${s.case.caseId}: ${s.case.status} for ${labResult.disease}.`, s.case._id, 'lab-result'))
      ];

      if (s.case.farmer) {
        notifications.push(notify(s.case.farmer, 'Laboratory test result available', `${s.case.caseId}: ${s.case.status}.`, s.case._id, 'lab-result'));
      }
      if (s.collectedBy) {
        notifications.push(notify(s.collectedBy, 'Sample result confirmed', `${s.sampleId} (${s.case.caseId}): ${result}.`, s.case._id, 'lab-result'));
      }

      await Promise.all(notifications);
    }

    res.status(201).json(labResult);
  } catch (err) {
    next(err);
  }
});

// --- District Statistics & Monitoring ---
async function districtStats(district) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const reports = await FarmerReport.find({ 'location.district': district });
  const active = reports.filter(x => !['Negative', 'Closed'].includes(x.status));
  const confirmed = reports.filter(x => x.status === 'Confirmed');

  const stageList = ['Monitoring', 'Escalated to Vet', 'Vet Verified', 'Lab Testing', 'Confirmed', 'Negative', 'Closed'];
  const stageSummary = Object.fromEntries(stageList.map(s => [s, reports.filter(x => x.status === s).length]));

  const minCases = Number(process.env.CLUSTER_MIN_CASES || 2);

  // Attempt real spatial clustering via FastAPI DBSCAN endpoint
  let clusters = [];
  const validCoordCases = active.filter(
    c => typeof c.location?.latitude === 'number' && typeof c.location?.longitude === 'number'
  );

  if (validCoordCases.length >= minCases) {
    const numToCase = new Map();
    const casesCoords = validCoordCases.map((c, idx) => {
      const numId = idx + 1;
      numToCase.set(numId, c);
      return {
        report_id: numId,
        latitude: c.location.latitude,
        longitude: c.location.longitude
      };
    });

    try {
      const dbscanRes = await detectOutbreaks({
        radiusKm: 15.0,
        minCases,
        cases: casesCoords
      });

      if (dbscanRes.success && dbscanRes.outbreaks && dbscanRes.outbreaks.length > 0) {
        clusters = dbscanRes.outbreaks.map(ob => {
          const casesInCluster = ob.affected_report_ids.map(id => numToCase.get(id)).filter(Boolean);
          const first = casesInCluster[0];
          const maxRisk = Math.max(...casesInCluster.map(c => c.localOutbreakRisk || 0), 0);
          return {
            clusterId: ob.cluster_id,
            centroid: {
              latitude: ob.centroid_latitude,
              longitude: ob.centroid_longitude
            },
            radiusKm: 15,
            caseCount: ob.sumCases,
            caseIds: casesInCluster.map(c => c.caseId),
            village: first?.location?.village || `Cluster-${ob.cluster_id + 1}`,
            taluka: first?.location?.taluka || '',
            disease: first?.suspectedDisease || 'Livestock Outbreak',
            risk: maxRisk,
            source: 'dbscan'
          };
        });
      }
    } catch {
      // Graceful fallback to village-density grouping
    }
  }

  // Fallback to village-density grouping if DBSCAN returned no clusters or was unavailable
  if (!clusters.length) {
    const clusterMap = active.reduce((acc, c) => {
      const key = `${c.location.village}|${c.suspectedDisease}`;
      acc[key] = acc[key] || {
        clusterId: Object.keys(acc).length,
        village: c.location.village,
        taluka: c.location.taluka || '',
        disease: c.suspectedDisease,
        caseCount: 0,
        risk: 0,
        caseIds: [],
        source: 'fallback'
      };
      acc[key].caseCount += 1;
      acc[key].risk = Math.max(acc[key].risk, c.localOutbreakRisk);
      acc[key].caseIds.push(c.caseId);
      return acc;
    }, {});
    clusters = Object.values(clusterMap).filter(x => x.caseCount >= minCases);
  }

  const mapData = active.map(c => ({
    caseId: c.caseId,
    lat: c.location.latitude,
    lng: c.location.longitude,
    village: c.location.village,
    disease: c.suspectedDisease,
    risk: c.localOutbreakRisk,
    status: c.status
  }));

  return {
    todayReports: reports.filter(x => x.createdAt >= today),
    activeCases: active,
    confirmedCases: confirmed,
    clusters,
    stageSummary,
    mapData
  };
}

app.get('/api/district/:district/overview', auth(['district', 'state']), async (req, res, next) => {
  try {
    res.json(await districtStats(req.params.district));
  } catch (err) {
    next(err);
  }
});

app.get('/api/district/:district/historical', auth(['district', 'state']), async (req, res, next) => {
  try {
    const records = await HistoricalDiseaseRecord.find({ district: req.params.district }).sort({ recordedAt: -1 });
    res.json(records);
  } catch (err) {
    next(err);
  }
});

app.get('/api/district/:district/trends', auth(['district', 'state']), async (req, res, next) => {
  try {
    const trends = await FarmerReport.aggregate([
      { $match: { 'location.district': req.params.district } },
      {
        $group: {
          _id: {
            disease: '$suspectedDisease',
            day: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }
          },
          cases: { $sum: 1 }
        }
      },
      { $sort: { '_id.day': 1 } }
    ]);
    res.json(trends);
  } catch (err) {
    next(err);
  }
});

app.get('/api/district/:district/breakdown', auth(['district', 'state']), async (req, res, next) => {
  try {
    const breakdown = await FarmerReport.aggregate([
      { $match: { 'location.district': req.params.district } },
      {
        $group: {
          _id: {
            taluka: '$location.taluka',
            village: '$location.village'
          },
          cases: { $sum: 1 },
          risk: { $max: '$localOutbreakRisk' }
        }
      },
      { $sort: { cases: -1 } }
    ]);
    res.json(breakdown);
  } catch (err) {
    next(err);
  }
});

// Specific sub-endpoints for district metrics
for (const [path, key] of [
  ['today-reports', 'todayReports'],
  ['active-cases', 'activeCases'],
  ['confirmed-cases', 'confirmedCases'],
  ['clusters', 'clusters'],
  ['map', 'mapData'],
  ['stage-summary', 'stageSummary']
]) {
  app.get(`/api/district/:district/${path}`, auth(['district', 'state']), async (req, res, next) => {
    try {
      const stats = await districtStats(req.params.district);
      res.json(stats[key]);
    } catch (err) {
      next(err);
    }
  });
}

// District action requests
app.post('/api/district/requests', auth(['district']), async (req, res, next) => {
  try {
    const r = await ActionRequest.create({
      requestId: `REQ-${Date.now().toString().slice(-8)}`,
      type: req.body.type,
      district: req.user.district || req.body.district || 'Nashik',
      taluka: req.body.taluka || '',
      village: req.body.village || '',
      disease: req.body.disease || 'Foot and Mouth Disease',
      reason: req.body.reason || 'District rapid-response required.',
      createdBy: req.user.id
    });

    const states = await User.find({ role: 'state' });
    await Promise.all(
      states.map(s => notify(s, 'New district action request', `${r.type} request ${r.requestId} from ${r.district}.`, null, 'request'))
    );

    res.status(201).json(r);
  } catch (err) {
    next(err);
  }
});

app.get('/api/district/requests', auth(['district', 'state']), async (req, res, next) => {
  try {
    const query = req.user.role === 'district' ? { district: req.user.district } : {};
    const requests = await ActionRequest.find(query).sort({ createdAt: -1 });
    res.json(requests);
  } catch (err) {
    next(err);
  }
});

// --- State Monitoring & Allocation ---
app.get('/api/state/districts', auth(['state']), async (req, res, next) => {
  try {
    const ds = await District.find();
    const out = [];
    for (const d of ds) {
      const stats = await districtStats(d.name);
      const prediction = await predict({
        recentLocalReports: stats.activeCases.length,
        districtRisk: d.riskScore
      });
      out.push({
        district: d.name,
        currentRisk: prediction.localOutbreakRisk,
        activeCases: stats.activeCases.length,
        confirmedCases: stats.confirmedCases.length,
        clusters: stats.clusters.length,
        prediction
      });
    }
    out.sort((a, b) => b.currentRisk - a.currentRisk);
    res.json(out);
  } catch (err) {
    next(err);
  }
});

app.get('/api/state/map', auth(['state']), async (req, res, next) => {
  try {
    const list = await District.find().select('name riskScore state');
    res.json(list);
  } catch (err) {
    next(err);
  }
});

app.get('/api/state/outbreaks', auth(['state']), async (req, res, next) => {
  try {
    const confirmed = await FarmerReport.find({ status: 'Confirmed' }).sort({ updatedAt: -1 });
    res.json(confirmed);
  } catch (err) {
    next(err);
  }
});

app.get('/api/state/requests', auth(['state']), async (req, res, next) => {
  try {
    const requests = await ActionRequest.find({ status: { $in: ['Pending', 'Prioritized'] } }).sort({ createdAt: -1 });
    res.json(requests);
  } catch (err) {
    next(err);
  }
});

app.patch('/api/state/requests/:id', auth(['state']), async (req, res, next) => {
  try {
    const r = await findRequest(req.params.id);
    if (!r) return res.status(404).json({ message: 'Action request not found' });

    const validDecisions = ['Approved', 'Rejected', 'Prioritized', 'Allocated'];
    if (!validDecisions.includes(req.body.status)) {
      return res.status(400).json({ message: 'Invalid request decision status' });
    }

    r.status = req.body.status;
    if (req.body.priority) r.priority = req.body.priority;
    if (req.body.allocation) r.allocation = req.body.allocation;
    r.reviewedBy = req.user.id;
    r.reviewedAt = new Date();
    await r.save();

    if (r.createdBy) {
      await notify(r.createdBy, 'State decision on request', `${r.requestId} has been marked as ${r.status}.`, null, 'request');
    }

    res.json(r);
  } catch (err) {
    next(err);
  }
});

// Express Error Handler Middleware
app.use((err, req, res, next) => {
  console.error('API Error:', err.message);
  res.status(err.status || 500).json({
    message: err.message || 'Internal server error'
  });
});

// --- Server & Database Initialization ---
async function start() {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ldews';
  let connected = false;

  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2500 });
    console.log('MongoDB connected successfully at', mongoUri);
    connected = true;
  } catch (err) {
    console.warn(`Local MongoDB connection failed at ${mongoUri} (${err.message}).`);
    console.warn('Attempting embedded in-memory MongoDB runner fallback...');

    try {
      const { MongoMemoryServer } = await import('mongodb-memory-server');
      const mongod = await MongoMemoryServer.create({ instance: { dbName: 'ldews' } });
      const memUri = mongod.getUri();
      await mongoose.connect(memUri);
      console.log('Embedded in-memory MongoDB initialized at', memUri);
      connected = true;

      // Automatically seed if the database is newly created
      const userCount = await User.countDocuments();
      if (userCount === 0) {
        await seedDatabase();
      }
    } catch (fallbackErr) {
      console.error('Could not initialize embedded MongoDB fallback:', fallbackErr.message);
      console.error('To run with local MongoDB, please start your local mongod service.');
    }
  }

  app.listen(port, () => {
    console.log(`LDEWS Backend API running on http://localhost:${port} [DB: ${connected ? 'Active' : 'Offline'}]`);
  });
}

start();
