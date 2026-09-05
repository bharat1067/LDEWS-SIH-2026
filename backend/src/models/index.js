import mongoose from 'mongoose';

const { Schema, model } = mongoose;
const ref = name => ({ type: Schema.Types.ObjectId, ref: name });

const locationSchema = new Schema({
  district: { type: String, required: true },
  taluka: { type: String },
  village: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number },
  coordinates: { type: [Number], index: '2d' } // [longitude, latitude] for geo queries
}, { _id: false });

export const User = model('User', new Schema({
  name: { type: String, required: true },
  phone: { type: String, unique: true, sparse: true, index: true },
  email: { type: String, unique: true, sparse: true, index: true },
  password: { type: String },
  role: {
    type: String,
    enum: ['farmer', 'vet', 'lab', 'district', 'state'],
    required: true,
    index: true
  },
  district: { type: String },
  taluka: { type: String },
  active: { type: Boolean, default: true }
}, { timestamps: true }));

export const District = model('District', new Schema({
  name: { type: String, required: true, unique: true, index: true },
  state: { type: String, default: 'Maharashtra' },
  riskScore: { type: Number, default: 0 },
  mappedLab: ref('User'),
  assignedVet: ref('User')
}, { timestamps: true }));

export const Taluka = model('Taluka', new Schema({
  name: { type: String, required: true },
  district: ref('District')
}, { timestamps: true }));

export const Village = model('Village', new Schema({
  name: { type: String, required: true },
  taluka: ref('Taluka'),
  district: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number }
}, { timestamps: true }));

export const FarmerReport = model('FarmerReport', new Schema({
  caseId: { type: String, unique: true, index: true, required: true },
  farmer: ref('User'),
  farmerName: { type: String },
  phone: { type: String },
  animalType: { type: String, required: true },
  symptoms: [{ type: String }],
  location: { type: locationSchema, required: true },
  source: { type: String, enum: ['web', 'ivr', 'voice', 'sms'], default: 'web' },
  language: { type: String, default: 'English' },
  suspectedDisease: { type: String },
  triage: { type: String },
  localOutbreakRisk: { type: Number, default: 0 },
  status: {
    type: String,
    enum: [
      'Reported',
      'Monitoring',
      'Escalated to Vet',
      'Vet Verified',
      'Sample Collected',
      'Lab Testing',
      'Confirmed',
      'Negative',
      'Closed'
    ],
    default: 'Monitoring',
    index: true
  },
  clinicalObservations: { type: String },
  advisory: ref('Advisory'),
  mlPrediction: {
    diseaseId: { type: Number },
    diseaseName: { type: String },
    confidence: { type: Number },
    requiresVetReview: { type: Boolean },
    modelSource: { type: String, enum: ['fastapi', 'fallback'] },
    predictedAt: { type: Date }
  },
  mlSource: { type: String, enum: ['fastapi', 'fallback'], default: 'fallback' },
  imageScreening: {
    prediction: { type: String },
    confidence: { type: Number },
    filename: { type: String },
    source: { type: String, default: 'fastapi' },
    screenedAt: { type: Date }
  },
  photoUrl: { type: String }
}, { timestamps: true }));

export const Advisory = model('Advisory', new Schema({
  case: ref('FarmerReport'),
  disease: { type: String },
  title: { type: String },
  message: { type: String },
  riskBand: { type: String },
  approved: { type: Boolean, default: true },
  sentAt: { type: Date, default: Date.now }
}, { timestamps: true }));

export const VetAssignment = model('VetAssignment', new Schema({
  case: ref('FarmerReport'),
  vet: ref('User'),
  status: { type: String, default: 'Assigned' },
  assignedAt: { type: Date, default: Date.now },
  verifiedAt: { type: Date }
}, { timestamps: true }));

export const Sample = model('Sample', new Schema({
  sampleId: { type: String, unique: true, index: true, required: true },
  case: ref('FarmerReport'),
  collectedBy: ref('User'),
  lab: ref('User'),
  status: {
    type: String,
    enum: ['Collected', 'Received', 'Testing', 'Completed'],
    default: 'Collected',
    index: true
  },
  collectedAt: { type: Date, default: Date.now },
  receivedAt: { type: Date },
  notes: { type: String }
}, { timestamps: true }));

export const LabResult = model('LabResult', new Schema({
  sample: ref('Sample'),
  result: {
    type: String,
    enum: ['Confirmed', 'Negative', 'Inconclusive'],
    required: true
  },
  disease: { type: String },
  notes: { type: String },
  submittedBy: ref('User'),
  submittedAt: { type: Date, default: Date.now }
}, { timestamps: true }));

export const Notification = model('Notification', new Schema({
  user: ref('User'),
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, default: 'workflow' },
  case: ref('FarmerReport'),
  delivery: { type: String, default: 'simulated' },
  deliveredAt: { type: Date, default: Date.now },
  read: { type: Boolean, default: false }
}, { timestamps: true }));

export const ActionRequest = model('ActionRequest', new Schema({
  requestId: { type: String, unique: true, index: true, required: true },
  type: { type: String, enum: ['vaccination', 'containment'], required: true },
  district: { type: String, required: true },
  taluka: { type: String },
  village: { type: String },
  disease: { type: String },
  reason: { type: String },
  createdBy: ref('User'),
  status: {
    type: String,
    enum: ['Pending', 'Approved', 'Rejected', 'Prioritized', 'Allocated'],
    default: 'Pending',
    index: true
  },
  priority: { type: String, default: 'Normal' },
  allocation: { type: String, default: '' },
  reviewedBy: ref('User'),
  reviewedAt: { type: Date }
}, { timestamps: true }));

export const VaccinationRequest = ActionRequest;

export const HistoricalDiseaseRecord = model('HistoricalDiseaseRecord', new Schema({
  disease: { type: String, required: true },
  district: { type: String, required: true, index: true },
  taluka: { type: String },
  village: { type: String },
  count: { type: Number, default: 1 },
  recordedAt: { type: Date, default: Date.now }
}, { timestamps: true }));
