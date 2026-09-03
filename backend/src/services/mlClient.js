/**
 * LDEWS ML Client Service
 * 
 * Proxies requests from Node.js Express backend to Python FastAPI ML Microservice.
 * Configurable ML_SERVICE_URL with strict timeout handling (8-10 seconds).
 * Guarantees graceful fallback and fault tolerance: the Express backend never crashes.
 */

const getMlBaseUrl = () => process.env.ML_SERVICE_URL || 'http://localhost:8000';
const DEFAULT_TIMEOUT_MS = Number(process.env.ML_TIMEOUT_MS) || 8000;

async function requestWithTimeout(endpoint, options = {}, timeoutMs = DEFAULT_TIMEOUT_MS) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const baseUrl = getMlBaseUrl();
    const url = `${baseUrl.replace(/\/$/, '')}${endpoint}`;
    const res = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    clearTimeout(timer);

    if (!res.ok) {
      const errorText = await res.text().catch(() => '');
      return {
        success: false,
        source: 'fallback',
        status: res.status,
        error: `FastAPI responded with HTTP ${res.status}: ${errorText || res.statusText}`
      };
    }

    const data = await res.json();
    return {
      success: true,
      source: 'fastapi',
      data
    };
  } catch (err) {
    clearTimeout(timer);
    const isTimeout = err.name === 'AbortError';
    return {
      success: false,
      source: 'fallback',
      error: isTimeout ? `ML request timed out after ${timeoutMs}ms` : `ML service unavailable: ${err.message}`
    };
  }
}

/**
 * Health check querying the FastAPI /health endpoint
 */
export async function healthCheckML() {
  const result = await requestWithTimeout('/health', { method: 'GET' }, 3000);
  if (result.success) {
    return {
      status: 'online',
      fallbackAvailable: true,
      service: 'fastapi',
      details: result.data
    };
  }
  return {
    status: 'offline',
    fallbackAvailable: true,
    service: 'fallback',
    error: result.error
  };
}

/**
 * Tabular symptom prediction using VotingClassifier ensemble
 * @param {Object} params
 * @param {string} params.species - e.g. "Cattle", "Sheep", "Goat"
 * @param {number[]} params.symptoms - array of integer symptom IDs
 */
export async function predictSymptoms({ species = 'Cattle', symptoms = [] } = {}) {
  const body = JSON.stringify({
    species,
    symptoms: Array.isArray(symptoms) ? symptoms : []
  });

  const res = await requestWithTimeout('/predict', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body
  });

  if (!res.success) {
    return {
      success: false,
      source: 'fallback',
      error: res.error
    };
  }

  return {
    success: true,
    source: 'fastapi',
    predicted_disease_id: res.data.predicted_disease_id,
    confidence_score: res.data.confidence_score,
    requires_vet_review: res.data.requires_vet_review
  };
}

/**
 * Image screening using PyTorch ResNet18 trained on Lumpy Skin Disease
 * @param {Object} params
 * @param {Buffer} params.fileBuffer - raw image bytes
 * @param {string} params.filename - e.g. "lesion.jpg"
 * @param {string} params.mimetype - e.g. "image/jpeg"
 */
export async function predictImage({ fileBuffer, filename = 'animal.jpg', mimetype = 'image/jpeg' } = {}) {
  if (!fileBuffer) {
    return {
      success: false,
      source: 'fallback',
      error: 'No image buffer provided'
    };
  }

  try {
    const formData = new FormData();
    const blob = new Blob([fileBuffer], { type: mimetype });
    formData.append('file', blob, filename);

    const res = await requestWithTimeout('/predict-image', {
      method: 'POST',
      body: formData
    });

    if (!res.success) {
      return {
        success: false,
        source: 'fallback',
        error: res.error
      };
    }

    return {
      success: true,
      source: 'fastapi',
      image_prediction: res.data.image_prediction,
      confidence_score: res.data.confidence_score,
      filename: res.data.filename
    };
  } catch (err) {
    return {
      success: false,
      source: 'fallback',
      error: `Failed to construct image screening payload: ${err.message}`
    };
  }
}

/**
 * Spatial outbreak clustering using DBSCAN
 * @param {Object} params
 * @param {number} params.radiusKm - default 15
 * @param {number} params.minCases - default 3
 * @param {Array<{ report_id: number, latitude: number, longitude: number }>} params.cases
 */
export async function detectOutbreaks({ radiusKm = 15.0, minCases = 3, cases = [] } = {}) {
  if (!Array.isArray(cases) || cases.length < minCases) {
    return {
      success: true,
      source: 'dbscan',
      outbreaks: []
    };
  }

  const body = JSON.stringify({
    radius_km: Number(radiusKm) || 15.0,
    min_cases: Number(minCases) || 3,
    cases
  });

  const res = await requestWithTimeout('/detect-outbreaks', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body
  });

  if (!res.success) {
    return {
      success: false,
      source: 'fallback',
      error: res.error,
      outbreaks: []
    };
  }

  return {
    success: true,
    source: 'dbscan',
    outbreaks: res.data.outbreaks || []
  };
}
