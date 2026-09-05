import {
  FarmerReport,
  Advisory,
  Notification,
  User,
  District,
  Village,
  VetAssignment,
  Sample
} from '../models/index.js';
import { predict } from './mlService.js';
import { predictSymptoms } from './mlClient.js';
import { normalizeSpecies, mapSymptomsToIds, mapDiseaseIdToName } from './mlMappingService.js';

// Single backend-controlled escalation decision
export const getRiskThreshold = () => Number(process.env.RISK_THRESHOLD || 70);

const advice = {
  'Foot and Mouth Disease': 'Isolate affected animals, avoid animal movement, disinfect sheds, and await veterinary guidance.',
  'Lumpy Skin Disease': 'Isolate affected animals, control insects and vectors, provide fluids, and contact veterinary officer.',
  'African Swine Fever': 'Strict quarantine of pig pens, restrict farm visitors, and alert veterinary authorities immediately.',
  'Anthrax': 'Do not move or open carcass if death occurs, isolate herd, and notify veterinary authority urgently.',
  'Avian Influenza': 'Quarantine flock, prevent wild bird contact, wear protective gear, and report to veterinary dispensary.',
  'Babesiosis': 'Apply anti-tick treatments to livestock, isolate febrile animals, and seek veterinary administration of antiparasitics.',
  'Black Quarter': 'Isolate animal, administer prescribed antibiotics promptly under veterinary supervision, and vaccinate herd.',
  'Bluetongue': 'Protect ruminants from midge vectors using netting and repellents, provide shade and soft fodder.',
  'Trypanosomosis': 'Control biting fly population, isolate weak livestock, and consult veterinarian for trypanocidal treatment.',
  'Swine Fever': 'Isolate sick pigs immediately, disinfect pens, and observe biosecurity protocols.',
  'Fasciolosis': 'Keep animals away from snail-infested stagnant water bodies and treat with recommended flukicides.',
  'Sheep and Goat Pox': 'Isolate affected sheep/goats, treat skin lesions, and restrict flock movement.',
  'PPR': 'Separate sick goats/sheep, avoid animal movement and maintain clean feed and water.',
  'Hemorrhagic Septicemia': 'Isolate animal immediately, prevent exposure to cold/damp areas, and contact veterinarian urgently.'
};

export const notify = async (user, title, message, caseId = null, type = 'workflow') => {
  const userId = user?._id || user;
  if (!userId) return null;
  return Notification.create({
    user: userId,
    title,
    message,
    case: caseId,
    type,
    deliveredAt: new Date()
  });
};

export async function processReport(payload, farmer = null) {
  const loc = payload.location || {
    district: payload.district,
    taluka: payload.taluka,
    village: payload.village,
    latitude: payload.latitude,
    longitude: payload.longitude
  };

  // If coordinates are missing, attempt to enrich from the Village collection
  if (!loc.latitude || !loc.longitude) {
    const vMatch = await Village.findOne({
      name: new RegExp(`^${loc.village}$`, 'i'),
      district: new RegExp(`^${loc.district}$`, 'i')
    });
    if (vMatch) {
      loc.latitude = vMatch.latitude;
      loc.longitude = vMatch.longitude;
      if (!loc.taluka && vMatch.taluka) {
        loc.taluka = vMatch.taluka;
      }
    }
  }

  // Populate GeoJSON coordinates array if we have lat/lng
  if (typeof loc.longitude === 'number' && typeof loc.latitude === 'number') {
    loc.coordinates = [loc.longitude, loc.latitude];
  }

  // Count recent reports in the same village over the last 7 days
  const recent = await FarmerReport.countDocuments({
    'location.village': loc.village,
    createdAt: { $gte: new Date(Date.now() - 7 * 864e5) }
  });

  const district = await District.findOne({ name: loc.district });

  // 1. Normalize species and symptoms for ML microservice
  const normSpecies = normalizeSpecies(payload.animalType);
  const symptomIds = mapSymptomsToIds(payload.symptoms);

  // 2. Attempt Real ML Prediction via FastAPI
  let result = null;
  const mlAttempt = await predictSymptoms({ species: normSpecies, symptoms: symptomIds });

  if (mlAttempt.success) {
    const disName = mapDiseaseIdToName(mlAttempt.predicted_disease_id);
    const conf = mlAttempt.confidence_score;
    const reqVet = Boolean(mlAttempt.requires_vet_review);

    // Calculate risk score based on confidence and local density (Epidemiological Model)
    const baseRisk = conf * 65; // Continuous scaling of confidence
    const clusteringPenalty = (1 - Math.exp(-0.4 * recent)) * 25; // Logistic saturation for outbreaks
    const endemicityPrior = (district?.riskScore || 0) * 0.10; // Bayesian prior from district history
    
    let localOutbreakRisk = Math.round(baseRisk + clusteringPenalty + endemicityPrior);
    localOutbreakRisk = Math.min(100, Math.max(0, localOutbreakRisk)); // Clamp between 0 and 100

    const triage = (localOutbreakRisk >= 70 || reqVet || conf < 0.6) ? 'high' : (localOutbreakRisk >= 45 ? 'medium' : 'low');

    result = {
      suspectedDisease: disName,
      triage,
      localOutbreakRisk,
      requiresVetReview: reqVet,
      mlSource: 'fastapi',
      mlPrediction: {
        diseaseId: mlAttempt.predicted_disease_id,
        diseaseName: disName,
        confidence: conf,
        requiresVetReview: reqVet,
        modelSource: 'fastapi',
        predictedAt: new Date()
      }
    };
  } else {
    // 3. Transparent Fallback to existing heuristic ML logic
    const fallbackRes = await predict({
      symptoms: payload.symptoms,
      animalType: payload.animalType,
      location: loc,
      recentLocalReports: recent,
      districtRisk: district?.riskScore || 0,
      context: payload.context
    });

    result = {
      ...fallbackRes,
      requiresVetReview: fallbackRes.triage === 'high',
      mlSource: 'fallback',
      mlPrediction: {
        diseaseName: fallbackRes.suspectedDisease,
        confidence: fallbackRes.triage === 'high' ? 0.75 : 0.60,
        requiresVetReview: fallbackRes.triage === 'high',
        modelSource: 'fallback',
        predictedAt: new Date()
      }
    };
  }

  // Single backend-controlled escalation evaluation:
  // RISK >= 70 -> escalate
  // RISK < 70 -> monitoring
  const isEscalated = result.localOutbreakRisk >= getRiskThreshold();
  const status = isEscalated ? 'Escalated to Vet' : 'Monitoring';

  const report = await FarmerReport.create({
    caseId: `CASE-${Date.now().toString().slice(-8)}-${Math.floor(Math.random() * 90 + 10)}`,
    farmer: farmer?._id || null,
    farmerName: payload.farmerName || farmer?.name || 'Local Livestock Owner',
    phone: payload.phone || farmer?.phone || '',
    animalType: payload.animalType,
    symptoms: Array.isArray(payload.symptoms) ? payload.symptoms : (payload.symptoms ? [payload.symptoms] : []),
    location: loc,
    source: payload.source || 'web',
    language: payload.language || 'English',
    suspectedDisease: result.suspectedDisease,
    triage: result.triage,
    localOutbreakRisk: result.localOutbreakRisk,
    status,
    mlPrediction: result.mlPrediction,
    mlSource: result.mlSource,
    imageScreening: payload.imageScreening || null,
    photoUrl: payload.photoUrl || ''
  });

  // Generate automated advisory
  const advisory = await Advisory.create({
    case: report._id,
    disease: result.suspectedDisease,
    title: `Advisory: ${result.suspectedDisease}`,
    message: advice[result.suspectedDisease] || 'Observe the animal, keep it separated, and contact veterinary services if symptoms worsen.',
    riskBand: result.triage,
    approved: true
  });

  report.advisory = advisory._id;
  await report.save();

  // Notify farmer if user account is linked
  if (farmer) {
    await notify(farmer, 'Animal health advisory generated', advisory.message, report._id, 'advisory');
  }

  // Handle escalation to Vet
  if (isEscalated) {
    // Resolve assigned vet: handles populated object or raw ObjectId reference
    const vetId = district?.assignedVet?._id || district?.assignedVet || (await User.findOne({ role: 'vet', district: loc.district, active: true }))?._id;
    if (vetId) {
      await VetAssignment.create({
        case: report._id,
        vet: vetId,
        status: 'Assigned',
        assignedAt: new Date()
      });
      await notify(
        vetId,
        'High-risk livestock case assigned',
        `${report.caseId}: ${result.suspectedDisease} reported in ${loc.village} (Risk: ${result.localOutbreakRisk}%).`,
        report._id,
        'escalation'
      );
    }
  }

  return {
    report,
    advisory,
    escalated: isEscalated
  };
}

export async function collectSample(report, vet, notes = '') {
  const district = await District.findOne({ name: report.location?.district });
  
  // Resolve mapped lab: handles populated object or raw ObjectId reference
  const labId = district?.mappedLab?._id || district?.mappedLab || (await User.findOne({ role: 'lab', district: report.location?.district, active: true }))?._id;

  const sample = await Sample.create({
    sampleId: `SMP-${Date.now().toString().slice(-8)}`,
    case: report._id,
    collectedBy: vet._id || vet,
    lab: labId || null,
    status: 'Collected',
    collectedAt: new Date(),
    notes: notes || 'Field sample collected during veterinary visit.'
  });

  report.status = 'Lab Testing';
  if (notes) {
    report.clinicalObservations = notes;
  }
  await report.save();

  if (labId) {
    await notify(
      labId,
      'Sample assigned for testing',
      `Sample ${sample.sampleId} from case ${report.caseId} requires laboratory testing.`,
      report._id,
      'sample'
    );
  }

  return {
    sample,
    case: report
  };
}
