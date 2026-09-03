/**
 * LDEWS ML Mapping Service
 * 
 * Maps frontend/backend clinical entities to the ground-truth numeric IDs
 * defined in PostgreSQL / sih_db_dump.sql and expected by the trained models.
 */

// Ground-truth Diseases (IDs 1-12)
export const DISEASES = {
  1: 'African Swine Fever',
  2: 'Anthrax',
  3: 'Avian Influenza',
  4: 'Babesiosis',
  5: 'Black Quarter',
  6: 'Bluetongue',
  7: 'Trypanosomosis',
  8: 'Foot and Mouth Disease',
  9: 'Swine Fever',
  10: 'Fasciolosis',
  11: 'Lumpy Skin Disease',
  12: 'Sheep and Goat Pox'
};

export const DISEASE_NAME_TO_ID = Object.entries(DISEASES).reduce((acc, [id, name]) => {
  acc[name.toLowerCase()] = Number(id);
  return acc;
}, {});

// Ground-truth Symptoms (IDs 1-69)
export const SYMPTOMS = {
  1: 'High fever',
  2: 'Loss of appetite',
  3: 'Skin discoloration',
  4: 'Respiratory distress',
  5: 'Vomiting',
  6: 'Diarrhea',
  7: 'Internal hemorrhages',
  8: 'Weight loss',
  9: 'Skin ulcers',
  10: 'Joint swelling',
  11: 'Respiratory issues',
  12: 'Sudden death',
  13: 'Blood around nose, mouth, and anus',
  14: 'Oedema in throat and shoulder',
  15: 'Severe respiratory distress',
  16: 'Swelling of head, comb, wattles, and legs',
  17: 'Cyanosis of comb and wattles',
  18: 'Decreased feed/water intake',
  19: 'Drop in egg production',
  20: 'Nervous signs (tremors, incoordination, torticollis)',
  21: 'Mild respiratory signs',
  22: 'Reduced egg production',
  23: 'High temperature',
  24: 'Jaundice-like symptoms',
  25: 'Yellowish mucosal membrane',
  26: 'Coffee-colour urine',
  27: 'Lameness',
  28: 'Swelling in neck, shoulder, lumbar, gluteal, sacral regions',
  29: 'Dark and crepitant skin',
  30: 'Loss of feed intake',
  31: 'Colic',
  32: 'Lateral recumbency',
  33: 'Dyspnoea',
  34: 'Death',
  35: 'Fever',
  36: 'Swelling of face, neck, and eyelids',
  37: 'Nasal discharge',
  38: 'Salivation',
  39: 'Necrotic ulcers on tongue, dental pad, gum, lips',
  40: 'Hyperaemia of muzzle',
  41: 'Bleeding at muco-cutaneous junction',
  42: 'Swollen, cyanotic, purple-blue tongue',
  43: 'Fluctuating high fever',
  44: 'Swollen lymph glands',
  45: 'Chronic emaciation and weakness',
  46: 'Gradual loss of production',
  47: 'Drop in milk production',
  48: 'Drooling of saliva (ropey string)',
  49: 'Vesicles on tongue, lips, gums, palate',
  50: 'Vesicles in interdigital skin and coronary band',
  51: 'Smacking sound due to mouth pain',
  52: 'Snout and feet lesions',
  53: 'Conjunctivitis',
  54: 'Purplish discolouration of snout, ears, abdomen, legs',
  55: 'Staggering gait',
  56: 'Progressive anaemia',
  57: 'Pale mucous membrane',
  58: 'Sub-mandibular oedema (bottle jaw)',
  59: 'Weakness in movement',
  60: 'Isolation from flock',
  61: 'Loss in production',
  62: 'Skin nodules',
  63: 'Edema and swelling of limbs, brisket, genitalia',
  64: 'Nasal and ocular discharge',
  65: 'Excessive salivation',
  66: 'Enlarged lymph nodes',
  67: 'Infertility and abortion',
  68: 'Reduced weight gain',
  69: 'Pock lesions on non-hairy parts'
};

// Keyword mapping for free-text or farmer symptom presets
const KEYWORD_SYMPTOM_MAP = [
  { match: /drool|ropey|string.*saliv/i, id: 48 },
  { match: /excessive.*saliv|salivation/i, id: 65 },
  { match: /saliv/i, id: 38 },
  { match: /blister|vesicle|ulcer.*tongue|ulcer.*lip|mouth lesion/i, id: 49 },
  { match: /coronary|interdigital|foot vesicle|feet lesion/i, id: 50 },
  { match: /smack|mouth pain/i, id: 51 },
  { match: /nodule|lump/i, id: 62 },
  { match: /lame|limp|hoof/i, id: 27 },
  { match: /high.*fever/i, id: 1 },
  { match: /fever|temperature/i, id: 35 },
  { match: /nasal.*discharge|runny nose/i, id: 37 },
  { match: /diarrh/i, id: 6 },
  { match: /appetite|loss of feed/i, id: 2 },
  { match: /weight.*loss/i, id: 8 },
  { match: /milk.*drop|milk.*loss/i, id: 47 },
  { match: /egg.*drop|egg.*loss/i, id: 19 },
  { match: /lymph.*node|lymph.*gland|swollen gland/i, id: 66 },
  { match: /respiratory|cough|breath/i, id: 4 },
  { match: /sudden death/i, id: 12 },
  { match: /death/i, id: 34 },
  { match: /jaundice|yellow/i, id: 24 },
  { match: /pock/i, id: 69 }
];

/**
 * Normalizes input animalType to canonical species used in training:
 * 'Cattle', 'Sheep', 'Goat', 'Pig', 'Poultry', 'Buffalo'
 */
export function normalizeSpecies(animalType = '') {
  const s = String(animalType || '').trim().toLowerCase();
  if (/cattle|cow|bull|calf|heifer|bovine/.test(s)) return 'Cattle';
  if (/buffalo/.test(s)) return 'Cattle'; // Model features use species_Cattle for large ruminants
  if (/goat|caprine/.test(s)) return 'Goat';
  if (/sheep|ovine|ram|ewe|lamb/.test(s)) return 'Sheep';
  if (/pig|swine|boar|hog|porcine/.test(s)) return 'Pig';
  if (/poultry|chicken|hen|rooster|duck|turkey|bird/.test(s)) return 'Poultry';
  return 'Cattle';
}

/**
 * Maps raw symptom inputs (strings, numeric IDs, or phrases) into unique valid symptom IDs [1..69]
 */
export function mapSymptomsToIds(symptoms) {
  if (!symptoms) return [];

  const rawList = Array.isArray(symptoms)
    ? symptoms
    : String(symptoms).split(/[,;]+/).map(s => s.trim()).filter(Boolean);

  const matchedIds = new Set();

  for (const item of rawList) {
    // If already a valid number
    const num = Number(item);
    if (!Number.isNaN(num) && num >= 1 && num <= 69) {
      matchedIds.add(num);
      continue;
    }

    const str = String(item).toLowerCase().trim();
    if (!str) continue;

    // Check exact name match
    let foundExact = false;
    for (const [idStr, name] of Object.entries(SYMPTOMS)) {
      if (name.toLowerCase() === str) {
        matchedIds.add(Number(idStr));
        foundExact = true;
        break;
      }
    }
    if (foundExact) continue;

    // Check keyword rules
    for (const rule of KEYWORD_SYMPTOM_MAP) {
      if (rule.match.test(str)) {
        matchedIds.add(rule.id);
      }
    }
  }

  return Array.from(matchedIds);
}

/**
 * Maps numeric predicted disease ID back to canonical disease name
 */
export function mapDiseaseIdToName(diseaseId) {
  const id = Number(diseaseId);
  return DISEASES[id] || 'General livestock infection';
}
