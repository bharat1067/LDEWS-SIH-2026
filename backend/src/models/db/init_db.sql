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
