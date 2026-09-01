/**
 * ML Integration Adapter Contract
 * 
 * Replace only this adapter when the external ML inference service becomes available.
 * 
 * Contract 1: POST /api/ml/predict
 * Input:
 * {
 *   symptoms: string[],
 *   animalType: string,
 *   location?: { district: string, taluka?: string, village: string },
 *   recentLocalReports?: number,
 *   context?: Record<string, any>
 * }
 * Output:
 * {
 *   suspectedDisease: string,
 *   triage: 'low' | 'medium' | 'high',
 *   localOutbreakRisk: number (0-100)
 * }
 * 
 * Contract 2: POST /api/ml/district-risk
 * Input:
 * {
 *   district: string,
 *   recentReports?: number,
 *   confirmedCases?: number,
 *   season?: string,
 *   weather?: string,
 *   vaccinationCoverage?: number
 * }
 * Output:
 * {
 *   district: string,
 *   outbreakRisk: number (0-100)
 * }
 */

export async function predict({
  symptoms = [],
  animalType = '',
  location = {},
  recentLocalReports,
  localReportCount,
  districtRisk = 0,
  context = {}
} = {}) {
  const t = (Array.isArray(symptoms) ? symptoms.join(' ') : String(symptoms || '')).toLowerCase();
  let suspectedDisease = 'General livestock infection';
  let triage = 'low';
  let base = 28;

  if (/mouth|blister|lesion|drool|lameness/.test(t)) {
    suspectedDisease = 'Foot and Mouth Disease';
    triage = 'high';
    base = 58;
  } else if (/nodule|skin|fever/.test(t)) {
    suspectedDisease = 'Lumpy Skin Disease';
    triage = 'medium';
    base = 45;
  } else if (/cough|nasal|diarrhoea|diarrhea/.test(t)) {
    suspectedDisease = animalType.toLowerCase().includes('goat') ? 'PPR' : 'Hemorrhagic Septicemia';
    triage = 'medium';
    base = 40;
  }

  const reports = Number(recentLocalReports ?? localReportCount) || 0;
  const distRisk = Number(districtRisk) || 0;
  const localOutbreakRisk = Math.min(95, Math.max(10, base + reports * 7 + Math.round(distRisk * 0.12)));

  if (localOutbreakRisk >= 70) {
    triage = 'high';
  }

  return {
    suspectedDisease,
    triage,
    localOutbreakRisk
  };
}

export async function predictDistrictRisk({
  district = 'Nashik',
  recentReports = 0,
  confirmedCases = 0,
  season = 'Monsoon',
  weather = 'Humid',
  vaccinationCoverage = 65
} = {}) {
  const base = 25;
  const reportWeight = (Number(recentReports) || 0) * 4;
  const confirmedWeight = (Number(confirmedCases) || 0) * 8;
  const coverageOffset = Math.max(0, Math.round((100 - (Number(vaccinationCoverage) || 65)) * 0.2));

  const outbreakRisk = Math.min(98, Math.max(15, base + reportWeight + confirmedWeight + coverageOffset));

  return {
    district,
    outbreakRisk
  };
}
