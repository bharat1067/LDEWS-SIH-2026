/**
 * LDEWS Frontend Centralized API Configuration & URL Normalizer
 * 
 * Supports configurable VITE_API_BASE_URL (defaults to http://localhost:5000 in dev)
 * Guarantees that `/api` is prepended exactly once.
 */

const metaEnv = (typeof import.meta !== 'undefined' && import.meta.env) ? import.meta.env : {};

export const API_BASE_URL = (
  metaEnv.VITE_API_BASE_URL ||
  (metaEnv.VITE_API_URL ? metaEnv.VITE_API_URL.replace(/\/api\/?$/, '') : '') ||
  'http://localhost:5000'
).replace(/\/+$/, '').replace(/\/api$/, '');

/**
 * Builds a fully qualified API endpoint URL guaranteeing exactly one `/api` prefix.
 * 
 * Handles all input variants:
 * - buildApiUrl('/auth/demo-login')    => `${API_BASE_URL}/api/auth/demo-login`
 * - buildApiUrl('/api/auth/demo-login') => `${API_BASE_URL}/api/auth/demo-login`
 * - buildApiUrl('auth/demo-login')     => `${API_BASE_URL}/api/auth/demo-login`
 * 
 * @param {string} path - relative or absolute endpoint path
 * @param {string} [baseUrl] - optional override for base URL
 * @returns {string} Fully qualified API URL
 */
export function buildApiUrl(path, baseUrl = API_BASE_URL) {
  const cleanBase = (baseUrl || '').replace(/\/+$/, '').replace(/\/api$/, '');
  const cleanPath = '/' + (path || '').replace(/^\/+/, '');
  const relativePath = cleanPath.startsWith('/api/') ? cleanPath.slice(4) : cleanPath;
  return `${cleanBase}/api${relativePath}`;
}

export default API_BASE_URL;
