/**
 * LDEWS Backend Localization Service
 * 
 * Provides presentation and response localization around the existing core services.
 * 
 * STRICT ARCHITECTURAL RULE:
 * The Python FastAPI ML microservice, Voting Ensemble models, ResNet18 screening,
 * and DBSCAN outbreak detection remain 100% UNCHANGED.
 * All internal database records (FarmerReport.suspectedDisease, Village, District, Status)
 * remain canonical English.
 */

// Ground-truth Disease Translations
export const DISEASE_TRANSLATIONS = {
  'Foot and Mouth Disease': {
    en: 'Foot and Mouth Disease',
    hi: 'खुरपका और मुंहपका रोग (FMD)'
  },
  'Lumpy Skin Disease': {
    en: 'Lumpy Skin Disease',
    hi: 'लंपी स्किन रोग (LSD)'
  },
  'African Swine Fever': {
    en: 'African Swine Fever',
    hi: 'अफ्रीकन स्वाइन फीवर'
  },
  Anthrax: {
    en: 'Anthrax',
    hi: 'एंथ्रेक्स (गिलटी रोग)'
  },
  'Avian Influenza': {
    en: 'Avian Influenza',
    hi: 'एवियन इन्फ्लुएंजा (बर्ड फ्लू)'
  },
  Babesiosis: {
    en: 'Babesiosis',
    hi: 'बेबेसियोसिस (चिचड़ी बुखार)'
  },
  'Black Quarter': {
    en: 'Black Quarter',
    hi: 'ब्लैक क्वार्टर (लंगड़ा बुखार / BQ)'
  },
  Bluetongue: {
    en: 'Bluetongue',
    hi: 'ब्लूटंग (नीली जीभ रोग)'
  },
  Trypanosomosis: {
    en: 'Trypanosomosis',
    hi: 'ट्रिपैनोसोमियासिस (सर्रा रोग)'
  },
  'Swine Fever': {
    en: 'Swine Fever',
    hi: 'स्वाइन फीवर (क्लासिकल स्वाइन फीवर)'
  },
  Fasciolosis: {
    en: 'Fasciolosis',
    hi: 'फैसिओलोसिस (लीवर फ्लूक रोग)'
  },
  'Sheep and Goat Pox': {
    en: 'Sheep and Goat Pox',
    hi: 'भेड़ एवं बकरी चेचक (Pox)'
  },
  PPR: {
    en: 'PPR',
    hi: 'पीपीआर (बकरी प्लेग / PPR)'
  },
  'Hemorrhagic Septicemia': {
    en: 'Hemorrhagic Septicemia',
    hi: 'गलघोंटू (HS)'
  },
  'General livestock infection': {
    en: 'General livestock infection',
    hi: 'सामान्य पशु संक्रमण'
  }
};

// Official Hindi Health Advisories matching Central Animal Husbandry guidelines
export const ADVISORIES = {
  'Foot and Mouth Disease': {
    en: 'Isolate affected animals, avoid animal movement, disinfect sheds, and await veterinary guidance.',
    hi: 'प्रभावित पशुओं को तुरंत स्वस्थ पशुओं से अलग करें, पशुओं का आवागमन रोकें, बाड़े को जीवाणुरहित करें एवं पशु चिकित्सक के निर्देशों की प्रतीक्षा करें।'
  },
  'Lumpy Skin Disease': {
    en: 'Isolate affected animals, control insects and vectors, provide fluids, and contact veterinary officer.',
    hi: 'प्रभावित पशु को अलग रखें, मक्खी-मच्छर व चीचड़ नियंत्रण हेतु कीटनाशक का छिड़काव करें, पर्याप्त तरल आहार दें और पशु चिकित्सक से संपर्क करें।'
  },
  'African Swine Fever': {
    en: 'Strict quarantine of pig pens, restrict farm visitors, and alert veterinary authorities immediately.',
    hi: 'सूअर बाड़ों में सख्त क्वारंटाइन लागू करें, बाहरी व्यक्तियों का प्रवेश रोकें एवं तत्काल पशु चिकित्सा अधिकारियों को सूचित करें।'
  },
  Anthrax: {
    en: 'Do not move or open carcass if death occurs, isolate herd, and notify veterinary authority urgently.',
    hi: 'मृत्यु की स्थिति में शव को बिल्कुल न खोलें और न हटाएं, पूरे झुंड को अलग करें और तुरंत पशु चिकित्सा दल को आपातकालीन सूचना दें।'
  },
  'Avian Influenza': {
    en: 'Quarantine flock, prevent wild bird contact, wear protective gear, and report to veterinary dispensary.',
    hi: 'मुर्गियों के बाड़े को अलग रखें, जंगली पक्षियों से संपर्क रोकें, सुरक्षात्मक दस्ताने/मास्क पहनें एवं नजदीकी पशु औषधालय को रिपोर्ट करें।'
  },
  Babesiosis: {
    en: 'Apply anti-tick treatments to livestock, isolate febrile animals, and seek veterinary administration of antiparasitics.',
    hi: 'पशुओं पर चीचड़ रोधी दवा का प्रयोग करें, बुखार वाले पशुओं को अलग रखें और पशु चिकित्सक से परजीवी रोधी उपचार कराएं।'
  },
  'Black Quarter': {
    en: 'Isolate animal, administer prescribed antibiotics promptly under veterinary supervision, and vaccinate herd.',
    hi: 'बीमार पशु को अलग करें, पशु चिकित्सक की देखरेख में तत्काल निर्धारित एंटीबायोटिक दें और शेष पशुओं का टीकाकरण कराएं।'
  },
  Bluetongue: {
    en: 'Protect ruminants from midge vectors using netting and repellents, provide shade and soft fodder.',
    hi: 'कीट-मच्छर रोधी जाली और दवा का उपयोग कर पशुओं को बचाएं, छायादार स्थान और सुपाच्य हरा चारा उपलब्ध कराएं।'
  },
  Trypanosomosis: {
    en: 'Control biting fly population, isolate weak livestock, and consult veterinarian for trypanocidal treatment.',
    hi: 'काटने वाली मक्खियों पर नियंत्रण करें, कमजोर पशुओं को अलग रखें और ट्रिपैनोसाइडल उपचार हेतु पशु चिकित्सक से परामर्श लें।'
  },
  'Swine Fever': {
    en: 'Isolate sick pigs immediately, disinfect pens, and observe biosecurity protocols.',
    hi: 'बीमार सूअरों को तुरंत अलग करें, बाड़ों को कीटाणुनाशक से साफ करें और जैव-सुरक्षा नियमों का पालन करें।'
  },
  Fasciolosis: {
    en: 'Keep animals away from snail-infested stagnant water bodies and treat with recommended flukicides.',
    hi: 'पशुओं को घोंघा-प्रभावित दूषित जलाशयों व दलदली क्षेत्रों से दूर रखें और अनुशंसित कृमिनाशक दवा दें।'
  },
  'Sheep and Goat Pox': {
    en: 'Isolate affected sheep/goats, treat skin lesions, and restrict flock movement.',
    hi: 'संक्रमित भेड़-बकरियों को अलग करें, त्वचा के घावों पर एंटीसेप्टिक लेप लगाएं और झुंड की आवाजाही को प्रतिबंधित करें।'
  },
  PPR: {
    en: 'Separate sick goats/sheep, avoid animal movement and maintain clean feed and water.',
    hi: 'बीमार बकरियों/भेड़ों को स्वस्थ पशुओं से अलग रखें, पशुओं की बिक्री या आवागमन रोकें और स्वच्छ पेयजल व आहार दें।'
  },
  'Hemorrhagic Septicemia': {
    en: 'Isolate animal immediately, prevent exposure to cold/damp areas, and contact veterinarian urgently.',
    hi: 'पशु को तुरंत अलग करें, ठंड व गीले स्थान से बचाएं और बिना देर किए आपातकालीन पशु चिकित्सा सहायता लें।'
  }
};

/**
 * Resolves requested language from payload, custom header, or Accept-Language.
 * Priority: payload.language > X-LDEWS-Language > Accept-Language > 'en'
 */
export function getRequestLanguage(req = {}, payload = {}) {
  const safeReq = req || {};
  const safePayload = payload || {};
  const bodyLang = (safePayload.language || safeReq.body?.language || '').trim().toLowerCase();
  if (['hi', 'hindi'].includes(bodyLang)) return 'hi';
  if (['mr', 'marathi'].includes(bodyLang)) return 'mr';
  if (['en', 'english'].includes(bodyLang)) return 'en';

  const queryLang = (safeReq.query?.lang || safeReq.query?.language || '').trim().toLowerCase();
  if (['hi', 'hindi'].includes(queryLang)) return 'hi';
  if (['mr', 'marathi'].includes(queryLang)) return 'mr';
  if (['en', 'english'].includes(queryLang)) return 'en';

  const headerLang = (safeReq.headers?.['x-ldews-language'] || '').trim().toLowerCase();
  if (['hi', 'hindi'].includes(headerLang)) return 'hi';
  if (['mr', 'marathi'].includes(headerLang)) return 'mr';
  if (['en', 'english'].includes(headerLang)) return 'en';

  const acceptLang = (safeReq.headers?.['accept-language'] || '').toLowerCase();
  if (acceptLang.startsWith('hi')) return 'hi';
  if (acceptLang.startsWith('mr')) return 'mr';

  return 'en';
}

/**
 * Localizes canonical disease name for user-facing API response
 */
export function localizeDisease(diseaseName, language = 'en') {
  if (!diseaseName) return '';
  const langKey = language === 'hi' ? 'hi' : 'en';
  return DISEASE_TRANSLATIONS[diseaseName]?.[langKey] || diseaseName;
}

/**
 * Localizes disease advisory title and message
 */
export function getLocalizedAdvisory(diseaseName, language = 'en') {
  const langKey = language === 'hi' ? 'hi' : 'en';
  const localizedDisease = localizeDisease(diseaseName, language);
  const defaultAdvice = langKey === 'hi'
    ? 'पशु की स्थिति पर नजर रखें, उसे अलग रखें और लक्षण बढ़ने पर तुरंत पशु चिकित्सा सेवा से संपर्क करें।'
    : 'Observe the animal, keep it separated, and contact veterinary services if symptoms worsen.';

  const title = langKey === 'hi'
    ? `पशु स्वास्थ्य सलाह: ${localizedDisease}`
    : `Advisory: ${diseaseName}`;

  const message = ADVISORIES[diseaseName]?.[langKey] || defaultAdvice;

  return { title, message, diseaseDisplay: localizedDisease };
}

/**
 * Localizes notification titles and messages
 */
export function getLocalizedNotification(type, data = {}, language = 'en') {
  const langKey = language === 'hi' ? 'hi' : 'en';
  const diseaseName = data.disease || '';
  const diseaseDisplay = localizeDisease(diseaseName, language);
  const caseId = data.caseId || '';

  if (type === 'REPORT_REGISTERED') {
    return {
      title: langKey === 'hi' ? 'पशु स्वास्थ्य रिपोर्ट दर्ज हुई' : 'Animal Health Report Registered',
      message: langKey === 'hi'
        ? `केस संदर्भ संख्या ${caseId} (${diseaseDisplay}) सफलतापूर्वक दर्ज की गई है।`
        : `Case reference ${caseId} (${diseaseName}) registered successfully.`
    };
  }

  if (type === 'ADVISORY_ISSUED') {
    return {
      title: langKey === 'hi' ? 'पशु स्वास्थ्य सलाह जारी की गई' : 'Animal Health Advisory Generated',
      message: langKey === 'hi'
        ? `केस ${caseId} के लिए सुरक्षात्मक निर्देश जारी किए गए हैं।`
        : `Protective directives issued for Case ${caseId}.`
    };
  }

  return {
    title: langKey === 'hi' ? 'सूचना' : 'Notification',
    message: data.message || ''
  };
}

/**
 * Normalizes Hindi species names to canonical English for ML pipeline
 */
export function normalizeHindiSpecies(speciesInput = '') {
  const s = String(speciesInput || '').trim().toLowerCase();
  if (/गाय|मवेशी|बैल|बछड़ा|बछिया/.test(s)) return 'Cattle';
  if (/भैंस|भैंसा/.test(s)) return 'Buffalo';
  if (/बकरी|बकरा/.test(s)) return 'Goat';
  if (/भेड़|मेमना/.test(s)) return 'Sheep';
  if (/सूअर|सुअर/.test(s)) return 'Pig';
  if (/मुर्गी|मुर्गा|पोल्ट्री|पक्षी/.test(s)) return 'Poultry';
  return speciesInput;
}

/**
 * Normalizes Hindi symptom phrases to canonical English symptom keywords
 */
export function normalizeHindiSymptoms(symptomsInput) {
  if (!symptomsInput) return symptomsInput;

  const rawList = Array.isArray(symptomsInput)
    ? symptomsInput
    : String(symptomsInput).split(/[,;]+/).map(s => s.trim()).filter(Boolean);

  const hindiToEnglishMap = [
    { match: /मुंह में छाले|छाले|घाव.*मुंह|मुख घाव/i, canonical: 'Mouth blisters' },
    { match: /लार|अत्यधिक लार|राल गिरना/i, canonical: 'Excessive drooling' },
    { match: /लंगड़ा|लंगड़ापन|पैर में दर्द/i, canonical: 'Sudden lameness' },
    { match: /तेज़ बुखार|बुखार|तापमान/i, canonical: 'High fever' },
    { match: /गांठ|गांठें|त्वचा पर गांठ/i, canonical: 'Skin nodules' },
    { match: /नाक से पानी|नाक से स्राव|छींक/i, canonical: 'Nasal discharge' },
    { match: /दस्त|पेचिश|पतला गोबर/i, canonical: 'Diarrhea' },
    { match: /भूख न लगना|चारा न खाना|चारा छोड़ना/i, canonical: 'Loss of appetite' },
    { match: /दूध में कमी|दूध गिरना/i, canonical: 'Drop in milk production' },
    { match: /अचानक मृत्यु|मृत्यु/i, canonical: 'Sudden death' },
    { match: /सांस लेने में तकलीफ|सांस फूलना/i, canonical: 'Respiratory distress' },
    { match: /कमजोरी|सुस्ती/i, canonical: 'Weakness in movement' }
  ];

  return rawList.map(item => {
    const trimmed = String(item).trim();
    for (const rule of hindiToEnglishMap) {
      if (rule.match.test(trimmed)) {
        return rule.canonical;
      }
    }
    return trimmed;
  });
}
