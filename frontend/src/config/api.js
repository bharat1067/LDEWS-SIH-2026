const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL ||
  'http://localhost:5000'
).replace(/\/+$/, '');

export function buildApiUrl(path = '') {
  const base = API_BASE_URL.replace(/\/api$/, '');
  const cleanPath = path.replace(/^\/+/, '').replace(/^api\//, '');

  return `${base}/api/${cleanPath}`;
}

export { API_BASE_URL };

export default API_BASE_URL;