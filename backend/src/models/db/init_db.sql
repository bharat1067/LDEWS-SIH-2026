DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50)
);

CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    species_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE diseases (
    disease_id SERIAL PRIMARY KEY,
    disease_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE symptoms (
    symptom_id SERIAL PRIMARY KEY,
    symptom_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE predefined_symptom_map (
    map_id SERIAL PRIMARY KEY,
    symptom_id INT REFERENCES symptoms(symptom_id) ON DELETE CASCADE,
    disease_id INT REFERENCES diseases(disease_id) ON DELETE CASCADE,
    species_id INT REFERENCES species(species_id) ON DELETE CASCADE,
    symptom_weight DECIMAL(3,2) DEFAULT 1.0,
    is_pathognomonic BOOLEAN DEFAULT FALSE,
    UNIQUE (symptom_id, disease_id, species_id)
);

CREATE TABLE field_reports (
    report_id SERIAL PRIMARY KEY,
    farmer_id INT,                  -- Who reported it
    animal_species VARCHAR(50),     -- e.g., 'Cow', 'Sheep'
    photo_url VARCHAR(255),         -- THE IMAGE INPUT: Link to Object Storage
    symptom_ids INT[],              -- Array of symptom IDs reported
    latitude DECIMAL(9,6),          -- Where it happened
    longitude DECIMAL(9,6),
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE model_versions (
    model_version_id SERIAL PRIMARY KEY,
    model_type VARCHAR(30) NOT NULL
        CHECK (model_type IN (
            'symptom_tabular',
            'image',
            'multimodal',
            'clustering'
        )),
    version_name VARCHAR(100) NOT NULL UNIQUE,
    model_path TEXT,
    dataset_version VARCHAR(100),
    accuracy DECIMAL(6,4),
    precision_score DECIMAL(6,4),
    recall_score DECIMAL(6,4),
    f1_score DECIMAL(6,4),
    trained_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deployed_at TIMESTAMP,
    is_active BOOLEAN DEFAULT FALSE
);

CREATE TABLE triage_results (
    triage_id SERIAL PRIMARY KEY,
    report_id INT NOT NULL REFERENCES field_reports(report_id) ON DELETE CASCADE,
    symptom_model_version_id INT REFERENCES model_versions(model_version_id),
    image_model_version_id INT REFERENCES model_versions(model_version_id),
    multimodal_model_version_id INT REFERENCES model_versions(model_version_id),
    symptom_prediction_id INT REFERENCES diseases(disease_id),
    symptom_confidence DECIMAL(5,4),
    image_prediction_id INT REFERENCES diseases(disease_id),
    image_confidence DECIMAL(5,4),
    final_prediction_id INT REFERENCES diseases(disease_id),
    final_confidence DECIMAL(5,4),
    risk_score DECIMAL(5,4),
    risk_level VARCHAR(20),
    processing_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vet_verifications (
    verification_id SERIAL PRIMARY KEY,
    report_id INT NOT NULL REFERENCES field_reports(report_id) ON DELETE CASCADE,
    vet_id INT NOT NULL REFERENCES users(user_id),
    confirmed_disease_id INT REFERENCES diseases(disease_id),
    is_confirmed BOOLEAN DEFAULT FALSE,
    clinical_notes TEXT,
    internal_hemorrhage BOOLEAN,
    used_in_training BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lab_reports (
    lab_report_id SERIAL PRIMARY KEY,
    report_id INT NOT NULL REFERENCES field_reports(report_id) ON DELETE CASCADE,
    lab_technician_id INT,
    confirmed_disease_id INT REFERENCES diseases(disease_id),
    test_method VARCHAR(100),
    test_results TEXT,
    is_final_truth BOOLEAN DEFAULT TRUE,
    used_in_training BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vaccination_records (
    vaccination_id       SERIAL PRIMARY KEY,
    farmer_id            INT REFERENCES users(user_id),
    animal_tag_id        VARCHAR(50) NOT NULL,
    animal_species       VARCHAR(50) NOT NULL,
    disease_protected_id INT REFERENCES diseases(disease_id),
    vaccine_name         VARCHAR(100) NOT NULL,
    vaccinated_on        DATE NOT NULL,
    next_due_date        DATE,
    administered_by      VARCHAR(100),
    is_current           BOOLEAN DEFAULT TRUE,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 1. SPECIES
-- ============================================================
INSERT INTO species (species_name) VALUES
('Cattle'), ('Sheep'), ('Goats'), ('Pigs'), ('Dogs'), ('Cats'),
('Horses'), ('Buffalo'), ('Wild Boars'), ('Warthogs'), ('Bush Pigs'),
('Giant Forest Hogs'), ('Chickens'), ('Turkeys'), ('Ducks'), ('Geese'),
('Wild Aquatic Birds'), ('Humans'), ('Donkeys'), ('Camels'), ('Giraffes')
ON CONFLICT (species_name) DO NOTHING;

-- ============================================================
-- 2. DISEASES
-- ============================================================
INSERT INTO diseases (disease_name, description) VALUES
('African Swine Fever', 'Highly contagious viral hemorrhagic disease caused by ASFV (Asfarviridae).'),
('Anthrax', 'Bacterial disease caused by Bacillus anthracis.'),
('Avian Influenza', 'Viral disease caused by Influenza A virus (Orthomyxoviridae); HPAI/LPAI forms.'),
('Babesiosis', 'Tick-borne blood parasite disease, zoonotic.'),
('Black Quarter', 'Bacterial disease causing severe muscle inflammation.'),
('Bluetongue', 'Viral disease of ruminants caused by BTV, transmitted by midges.'),
('Trypanosomosis', 'Parasitic disease caused by Trypanosoma protozoa.'),
('Foot and Mouth Disease', 'Highly contagious viral disease caused by FMDV (Picornaviridae).'),
('Swine Fever', 'Viral disease of pigs with high mortality.'),
('Fasciolosis', 'Parasitic disease caused by Fasciola spp. (liver flukes).'),
('Lumpy Skin Disease', 'Viral disease caused by LSDV (Capripoxvirus, Poxviridae).'),
('Sheep and Goat Pox', 'Viral disease caused by poxvirus affecting sheep and goats.')
ON CONFLICT (disease_name) DO NOTHING;

-- ============================================================
-- 3. SYMPTOMS
-- ============================================================
INSERT INTO symptoms (symptom_name) VALUES
('High fever'), ('Loss of appetite'), ('Skin discoloration'), ('Respiratory distress'),
('Vomiting'), ('Diarrhea'), ('Internal hemorrhages'), ('Weight loss'), ('Skin ulcers'),
('Joint swelling'), ('Respiratory issues'), ('Sudden death'),
('Blood around nose, mouth, and anus'), ('Oedema in throat and shoulder'),
('Severe respiratory distress'), ('Swelling of head, comb, wattles, and legs'),
('Cyanosis of comb and wattles'), ('Decreased feed/water intake'),
('Drop in egg production'), ('Nervous signs (tremors, incoordination, torticollis)'),
('Mild respiratory signs'), ('Reduced egg production'), ('High temperature'),
('Jaundice-like symptoms'), ('Yellowish mucosal membrane'), ('Coffee-colour urine'),
('Lameness'), ('Swelling in neck, shoulder, lumbar, gluteal, sacral regions'),
('Dark and crepitant skin'), ('Loss of feed intake'), ('Colic'),
('Lateral recumbency'), ('Dyspnoea'), ('Death'), ('Fever'),
('Swelling of face, neck, and eyelids'), ('Nasal discharge'), ('Salivation'),
('Necrotic ulcers on tongue, dental pad, gum, lips'), ('Hyperaemia of muzzle'),
('Bleeding at muco-cutaneous junction'), ('Swollen, cyanotic, purple-blue tongue'),
('Fluctuating high fever'), ('Swollen lymph glands'),
('Chronic emaciation and weakness'), ('Gradual loss of production'),
('Drop in milk production'), ('Drooling of saliva (ropey string)'),
('Vesicles on tongue, lips, gums, palate'),
('Vesicles in interdigital skin and coronary band'),
('Smacking sound due to mouth pain'), ('Snout and feet lesions'),
('Conjunctivitis'), ('Purplish discolouration of snout, ears, abdomen, legs'),
('Staggering gait'), ('Progressive anaemia'), ('Pale mucous membrane'),
('Sub-mandibular oedema (bottle jaw)'), ('Weakness in movement'),
('Isolation from flock'), ('Loss in production'), ('Skin nodules'),
('Edema and swelling of limbs, brisket, genitalia'),
('Nasal and ocular discharge'), ('Excessive salivation'),
('Enlarged lymph nodes'), ('Infertility and abortion'), ('Reduced weight gain'),
('Pock lesions on non-hairy parts')
ON CONFLICT (symptom_name) DO NOTHING;

-- ============================================================
-- 4. PREDEFINED SYMPTOM MAP
-- ============================================================
INSERT INTO predefined_symptom_map (symptom_id, disease_id, species_id, symptom_weight, is_pathognomonic)
SELECT s.symptom_id, d.disease_id, sp.species_id, v.weight, v.patho
FROM (VALUES
    ('High fever','African Swine Fever','ALL',0.8,FALSE),
    ('Loss of appetite','African Swine Fever','ALL',0.6,FALSE),
    ('Skin discoloration','African Swine Fever','ALL',0.8,FALSE),
    ('Respiratory distress','African Swine Fever','ALL',0.6,FALSE),
    ('Vomiting','African Swine Fever','ALL',0.6,FALSE),
    ('Diarrhea','African Swine Fever','ALL',0.6,FALSE),
    ('Internal hemorrhages','African Swine Fever','ALL',0.9,TRUE),
    ('Weight loss','African Swine Fever','ALL',0.5,FALSE),
    ('Skin ulcers','African Swine Fever','ALL',0.6,FALSE),
    ('Joint swelling','African Swine Fever','ALL',0.5,FALSE),
    ('Respiratory issues','African Swine Fever','ALL',0.5,FALSE),
    ('Sudden death','Anthrax','Cattle',0.9,TRUE),
    ('Sudden death','Anthrax','Sheep',0.9,TRUE),
    ('High fever','Anthrax','ALL',0.6,FALSE),
    ('Blood around nose, mouth, and anus','Anthrax','ALL',0.9,TRUE),
    ('Oedema in throat and shoulder','Anthrax','ALL',0.7,FALSE),
    ('Sudden death','Avian Influenza','Chickens',0.9,FALSE),
    ('Sudden death','Avian Influenza','Turkeys',0.9,FALSE),
    ('Severe respiratory distress','Avian Influenza','ALL',0.8,FALSE),
    ('Swelling of head, comb, wattles, and legs','Avian Influenza','Chickens',0.8,FALSE),
    ('Cyanosis of comb and wattles','Avian Influenza','Chickens',0.85,TRUE),
    ('Diarrhea','Avian Influenza','ALL',0.5,FALSE),
    ('Decreased feed/water intake','Avian Influenza','ALL',0.5,FALSE),
    ('Drop in egg production','Avian Influenza','ALL',0.6,FALSE),
    ('Nervous signs (tremors, incoordination, torticollis)','Avian Influenza','ALL',0.7,FALSE),
    ('Mild respiratory signs','Avian Influenza','ALL',0.4,FALSE),
    ('Reduced egg production','Avian Influenza','ALL',0.5,FALSE),
    ('High temperature','Babesiosis','Cattle',0.7,FALSE),
    ('Jaundice-like symptoms','Babesiosis','Cattle',0.8,FALSE),
    ('Yellowish mucosal membrane','Babesiosis','Cattle',0.8,FALSE),
    ('Coffee-colour urine','Babesiosis','Cattle',0.9,TRUE),
    ('High fever','Black Quarter','ALL',0.6,FALSE),
    ('Lameness','Black Quarter','ALL',0.7,FALSE),
    ('Swelling in neck, shoulder, lumbar, gluteal, sacral regions','Black Quarter','ALL',0.8,FALSE),
    ('Dark and crepitant skin','Black Quarter','ALL',0.9,TRUE),
    ('Loss of feed intake','Black Quarter','ALL',0.5,FALSE),
    ('Colic','Black Quarter','ALL',0.5,FALSE),
    ('Lateral recumbency','Black Quarter','ALL',0.6,FALSE),
    ('Dyspnoea','Black Quarter','ALL',0.6,FALSE),
    ('Death','Black Quarter','ALL',0.7,FALSE),
    ('Fever','Bluetongue','ALL',0.6,FALSE),
    ('Swelling of face, neck, and eyelids','Bluetongue','ALL',0.7,FALSE),
    ('Respiratory distress','Bluetongue','ALL',0.5,FALSE),
    ('Nasal discharge','Bluetongue','ALL',0.5,FALSE),
    ('Salivation','Bluetongue','ALL',0.5,FALSE),
    ('Necrotic ulcers on tongue, dental pad, gum, lips','Bluetongue','ALL',0.8,FALSE),
    ('Hyperaemia of muzzle','Bluetongue','ALL',0.6,FALSE),
    ('Bleeding at muco-cutaneous junction','Bluetongue','ALL',0.7,FALSE),
    ('Swollen, cyanotic, purple-blue tongue','Bluetongue','ALL',0.95,TRUE),
    ('Fluctuating high fever','Trypanosomosis','ALL',0.7,FALSE),
    ('Swollen lymph glands','Trypanosomosis','ALL',0.6,FALSE),
    ('Chronic emaciation and weakness','Trypanosomosis','ALL',0.6,FALSE),
    ('Loss of appetite','Trypanosomosis','ALL',0.5,FALSE),
    ('Gradual loss of production','Trypanosomosis','ALL',0.5,FALSE),
    ('Fever','Foot and Mouth Disease','ALL',0.6,FALSE),
    ('Loss of feed intake','Foot and Mouth Disease','ALL',0.5,FALSE),
    ('Drop in milk production','Foot and Mouth Disease','Cattle',0.6,FALSE),
    ('Drooling of saliva (ropey string)','Foot and Mouth Disease','ALL',0.8,FALSE),
    ('Vesicles on tongue, lips, gums, palate','Foot and Mouth Disease','ALL',0.9,TRUE),
    ('Vesicles in interdigital skin and coronary band','Foot and Mouth Disease','ALL',0.9,TRUE),
    ('Smacking sound due to mouth pain','Foot and Mouth Disease','ALL',0.6,FALSE),
    ('Lameness','Foot and Mouth Disease','Sheep',0.6,FALSE),
    ('Lameness','Foot and Mouth Disease','Goats',0.6,FALSE),
    ('Snout and feet lesions','Foot and Mouth Disease','Pigs',0.8,FALSE),
    ('Fever','Swine Fever','Pigs',0.6,FALSE),
    ('Conjunctivitis','Swine Fever','Pigs',0.6,FALSE),
    ('Purplish discolouration of snout, ears, abdomen, legs','Swine Fever','Pigs',0.9,TRUE),
    ('Staggering gait','Swine Fever','Pigs',0.6,FALSE),
    ('Progressive anaemia','Fasciolosis','ALL',0.7,FALSE),
    ('Pale mucous membrane','Fasciolosis','ALL',0.6,FALSE),
    ('Sub-mandibular oedema (bottle jaw)','Fasciolosis','ALL',0.85,TRUE),
    ('Loss of appetite','Fasciolosis','ALL',0.5,FALSE),
    ('Weakness in movement','Fasciolosis','ALL',0.5,FALSE),
    ('Isolation from flock','Fasciolosis','ALL',0.4,FALSE),
    ('Loss in production','Fasciolosis','ALL',0.4,FALSE),
    ('Fever','Lumpy Skin Disease','Cattle',0.7,FALSE),
    ('Skin nodules','Lumpy Skin Disease','Cattle',0.9,TRUE),
    ('Edema and swelling of limbs, brisket, genitalia','Lumpy Skin Disease','Cattle',0.7,FALSE),
    ('Nasal and ocular discharge','Lumpy Skin Disease','Cattle',0.5,FALSE),
    ('Excessive salivation','Lumpy Skin Disease','Cattle',0.5,FALSE),
    ('Enlarged lymph nodes','Lumpy Skin Disease','Cattle',0.6,FALSE),
    ('Drop in milk production','Lumpy Skin Disease','Cattle',0.6,FALSE),
    ('Infertility and abortion','Lumpy Skin Disease','Cattle',0.6,FALSE),
    ('Reduced weight gain','Lumpy Skin Disease','Cattle',0.5,FALSE),
    ('Respiratory distress','Sheep and Goat Pox','ALL',0.5,FALSE),
    ('Pock lesions on non-hairy parts','Sheep and Goat Pox','ALL',0.9,TRUE)
) AS v(symptom_name, disease_name, species_name, weight, patho)
JOIN symptoms s ON s.symptom_name = v.symptom_name
JOIN diseases d ON d.disease_name = v.disease_name
LEFT JOIN species sp ON sp.species_name = v.species_name AND v.species_name <> 'ALL'
ON CONFLICT (symptom_id, disease_id, species_id) DO NOTHING;

-- Users (for vet verifications)
INSERT INTO users (username, role) VALUES
    ('vet_sharma', 'vet'),
    ('vet_patel',  'vet'),
    ('lab_tech1',  'lab_tech');
