import React, { createContext, useContext, useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, NavLink, Navigate, useNavigate, useParams } from 'react-router-dom';
import { MapContainer, TileLayer, Circle, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import {
  Bell,
  ClipboardPlus,
  LayoutDashboard,
  Stethoscope,
  FlaskConical,
  MapPinned,
  ShieldAlert,
  LogOut,
  ChevronRight,
  CheckCircle2,
  AlertTriangle,
  AlertCircle,
  Menu,
  Phone,
  Map,
  Search,
  Check,
  Clock,
  Send,
  Building2,
  Calendar,
  X,
  Activity
} from 'lucide-react';
import './styles.css';
import API_BASE_URL, { buildApiUrl } from './config/api.js';

export { API_BASE_URL, buildApiUrl };

const Auth = createContext();
export const useAuth = () => useContext(Auth);

export const api = async (path, o = {}) => {
  const s = JSON.parse(
    localStorage.getItem('ldews-session') || 'null'
  );

  const isFormData =
    typeof FormData !== 'undefined' &&
    o.body instanceof FormData;

  const headers = {
    ...(isFormData ? {} : {
      'Content-Type': 'application/json'
    }),
    ...(s?.token ? {
      Authorization: `Bearer ${s.token}`
    } : {}),
    ...(o.headers || {})
  };

  const url = buildApiUrl(path);

  console.log('API REQUEST:', url);

  const r = await fetch(url, {
    ...o,
    headers
  });

  const data = await r.json();

  if (!r.ok) {
    throw new Error(
      data?.message ||
      data?.error ||
      `Request failed with status ${r.status}`
    );
  }

  return data;
};

const roles = {
  farmer: 'Livestock Owner / Farmer',
  vet: 'Government Veterinary Officer',
  lab: 'Diagnostic Laboratory Officer',
  district: 'District Surveillance Officer',
  state: 'State Animal Husbandry Officer'
};

const homes = {
  farmer: '/farmer',
  vet: '/vet',
  lab: '/lab',
  district: '/district/overview',
  state: '/state/overview'
};

// Reusable components
function Load({ children, error }) {
  if (error) {
    return (
      <div className="empty" style={{ color: '#b42318' }}>
        <AlertCircle size={20} style={{ margin: '0 auto 8px', display: 'block' }} />
        {error}
      </div>
    );
  }
  return children;
}

function Badge({ children }) {
  const x = String(children || '');
  let color = 'blue';
  if (/Confirmed|Escalated|Critical|High/i.test(x)) color = 'red';
  else if (/Monitoring|Testing|Pending|Prioritized|Moderate/i.test(x)) color = 'amber';
  else if (/Verified|Closed|Negative|Approved/i.test(x)) color = 'green';
  else if (/Received|Normal/i.test(x)) color = 'slate';
  return <span className={`badge ${color}`}>{x}</span>;
}

function Modal({ open, title, onClose, children }) {
  if (!open) return null;
  return (
    <div className="modal-backdrop">
      <section className="modal">
        <div className="panel-title">
          <h2>{title}</h2>
          <button className="link" onClick={onClose} style={{ textDecoration: 'none' }}>
            <X size={18} />
          </button>
        </div>
        {children}
      </section>
    </div>
  );
}

function useLoad(url) {
  const [d, setD] = useState();
  const [e, setE] = useState('');
  useEffect(() => {
    let active = true;
    setD(undefined);
    setE('');
    api(url)
      .then(res => { if (active) setD(res); })
      .catch(err => { if (active) setE(err.message || 'Failed to load data'); });
    return () => { active = false; };
  }, [url]);
  return { d, e, setD };
}

// Global Shell
function Shell({ children }) {
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);
  const [showNotif, setShowNotif] = useState(false);
  const { d: notifs } = useLoad('/notifications');

  const n = {
    farmer: [
      ['Farmer Portal', '/farmer', LayoutDashboard],
      ['Report Animal Problem', '/farmer/report', ClipboardPlus],
      ['My Reports & Status', '/farmer/reports', MapPinned]
    ],
    vet: [
      ['Investigation Queue', '/vet', Stethoscope],
      ['Assigned Case Register', '/vet/cases', LayoutDashboard]
    ],
    lab: [
      ['Diagnostic Work Queue', '/lab', FlaskConical],
      ['Sample Register', '/lab/samples', LayoutDashboard]
    ],
    district: [
      ['Surveillance & Response', '/district/overview', LayoutDashboard],
      ['District Case Register', '/district/cases', ClipboardPlus],
      ['Active Cluster Alerts', '/district/clusters', MapPinned]
    ],
    state: [
      ['Strategic Priority Matrix', '/state/overview', LayoutDashboard],
      ['District Risk Ranking', '/state/districts', MapPinned],
      ['District Action Requests', '/state/requests', ShieldAlert]
    ]
  }[user.role] || [];

  return (
    <>
      <header>
        <div className="govline">
          <div className="govline-left">
            <span>भारत सरकार | Government of India</span>
            <span>पशुपालन और डेयरी विभाग | Department of Animal Husbandry & Dairying</span>
          </div>
          <div className="govline-right">
            <span className="lang-switch">English | हिंदी | मराठी</span>
            <span className="helpline-pill"><Phone size={11} /> Helpline: 1962</span>
          </div>
        </div>

        <div className="brand">
          <button className="mobile" onClick={() => setOpen(!open)} aria-label="Toggle navigation">
            <Menu size={22} />
          </button>
          <div className="seal">GOI</div>
          <div className="brand-text">
            <b>Livestock Disease Early Warning System (LDEWS)</b>
            <small>National Animal Disease Surveillance & Outbreak Response Portal</small>
          </div>

          <div className="header-actions">
            <button
              className="notif-btn"
              onClick={() => setShowNotif(!showNotif)}
              title="Notifications"
            >
              <Bell size={18} />
              {notifs && notifs.length > 0 && (
                <span className="notif-badge">{notifs.length}</span>
              )}
            </button>

            {showNotif && (
              <div className="notif-dropdown">
                <div className="notif-header">
                  <h4>Surveillance Notifications</h4>
                  <button className="link" onClick={() => setShowNotif(false)}>Close</button>
                </div>
                <div className="notif-list">
                  {notifs && notifs.length > 0 ? (
                    notifs.map(x => (
                      <div key={x._id} className="notif-item">
                        <b>{x.title}</b>
                        <span>{x.message}</span>
                        <small>{new Date(x.createdAt || x.deliveredAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</small>
                      </div>
                    ))
                  ) : (
                    <div className="empty">No active notifications.</div>
                  )}
                </div>
              </div>
            )}

            <div className="profile-card">
              <span className="avatar">{(user.name || 'O')[0]}</span>
              <div className="profile-info">
                <strong>{user.name}</strong>
                <small>{roles[user.role]} {user.district ? `(${user.district})` : ''}</small>
              </div>
            </div>

            <button className="logout-btn" onClick={logout} title="Sign out of portal">
              <LogOut size={15} /> Sign out
            </button>
          </div>
        </div>
      </header>

      <aside className={open ? 'open' : ''}>
        <div className="side-title">Official Workspace</div>
        {n.map(([title, to, Icon]) => (
          <NavLink
            to={to}
            end={to === homes[user.role]}
            key={to}
            onClick={() => setOpen(false)}
          >
            <Icon size={17} />
            {title}
          </NavLink>
        ))}

        <div className="side-footer">
          <ShieldAlert size={16} /> <b>National Toll-Free 1962</b>
          <span>24x7 Animal Health Emergency & Tele-Veterinary Response</span>
        </div>
      </aside>

      {open && <div className="backdrop" onClick={() => setOpen(false)} />}

      <main>
        <div className="crumb">
          Portal Home <ChevronRight size={13} /> {roles[user.role]}
        </div>
        {children}
      </main>
    </>
  );
}

function Page({ title, action, subtitle, children }) {
  return (
    <Shell>
      <div className="page-head">
        <div>
          <h1>{title}</h1>
          <p>{subtitle || 'Official Government livestock surveillance and response workspace'}</p>
        </div>
        {action}
      </div>
      {children}
    </Shell>
  );
}

function Metric({ label, value, note, riskClass }) {
  return (
    <div className="metric">
      <span>{label}</span>
      <strong className={riskClass || ''}>{value ?? '—'}</strong>
      <small>{note}</small>
    </div>
  );
}

// Visual Stepper for Farmer and Vet cases
function CaseTimeline({ status }) {
  const steps = [
    { label: 'Reported', key: 'Reported' },
    { label: 'Triage / Monitoring', key: 'Monitoring' },
    { label: 'Vet Escalated', key: 'Escalated to Vet' },
    { label: 'Vet Verified', key: 'Vet Verified' },
    { label: 'Sample Testing', key: 'Lab Testing' },
    { label: 'Confirmed / Closed', key: 'Confirmed' }
  ];

  const statusOrder = [
    'Reported',
    'Monitoring',
    'Escalated to Vet',
    'Vet Verified',
    'Sample Collected',
    'Lab Testing',
    'Confirmed',
    'Negative',
    'Closed'
  ];

  const currentIndex = statusOrder.indexOf(status);

  return (
    <div className="timeline-stepper">
      {steps.map((s, idx) => {
        const stepIdx = statusOrder.indexOf(s.key);
        const isDone = currentIndex > stepIdx;
        const isActive = currentIndex === stepIdx;
        return (
          <div
            key={s.key}
            className={`timeline-step ${isDone ? 'done' : ''} ${isActive ? 'active' : ''}`}
          >
            <div className="step-node">
              {isDone ? <Check size={14} /> : idx + 1}
            </div>
            <div className="step-label">{s.label}</div>
          </div>
        );
      })}
    </div>
  );
}

// Case List Component
function Cases({ cases = [], open, isVet = false }) {
  const [query, setQuery] = useState('');
  const list = cases.filter(c => JSON.stringify(c).toLowerCase().includes(query.toLowerCase()));

  return (
    <>
      <div className="filter">
        <Search size={16} />
        <input
          placeholder="Filter by Case ID, village, animal or disease suspicion..."
          value={query}
          onChange={e => setQuery(e.target.value)}
        />
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Case ID</th>
              <th>Location & Farmer</th>
              <th>Reported Symptoms</th>
              <th>Suspected Condition</th>
              <th>Automated Risk</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {list.map(c => {
              const isUrgent = c.localOutbreakRisk >= 70;
              return (
                <tr key={c._id} style={isUrgent && isVet ? { background: '#fffbfa' } : {}}>
                  <td>
                    <b>{c.caseId}</b>
                    <small>{new Date(c.createdAt).toLocaleDateString()} {new Date(c.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</small>
                  </td>
                  <td>
                    <strong>{c.location?.village || 'Village'}, {c.location?.taluka ? `${c.location.taluka}, ` : ''}{c.location?.district}</strong>
                    <small>{c.farmerName || 'Owner'} {c.phone ? `(${c.phone})` : ''}</small>
                  </td>
                  <td>
                    <span>{c.animalType}</span>
                    <small>{Array.isArray(c.symptoms) ? c.symptoms.join(', ') : (c.symptoms || '—')}</small>
                  </td>
                  <td>
                    <b>{c.suspectedDisease || 'General Infection'}</b>
                    <small>Automated Triage Tier: {c.triage || 'Standard'}</small>
                  </td>
                  <td>
                    <span className={`risk-pill ${isUrgent ? 'high' : (c.localOutbreakRisk >= 50 ? 'medium' : 'low')}`}>
                      {c.localOutbreakRisk}%
                    </span>
                  </td>
                  <td><Badge>{c.status}</Badge></td>
                  <td>
                    <button className="primary" style={{ padding: '6px 12px', fontSize: '12px' }} onClick={() => open(c)}>
                      Open
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {!list.length && <div className="empty">No matching operational records found.</div>}
    </>
  );
}

// ----------------------------------------------------
// 1. Farmer Experience
// ----------------------------------------------------
function FarmerHome() {
  const { d, e } = useLoad('/reports/my');
  const nav = useNavigate();
  const latest = d?.[0];

  return (
    <Page
      title="Livestock Owner Health Assistance Portal"
      subtitle="Report animal illnesses, receive official precautionary advisories, and track veterinary response"
    >
      <Load error={e}>
        {d && (
          <>
            {/* Prominent Action Banner for Farmers */}
            <div className="panel" style={{ background: 'linear-gradient(135deg, #062b51 0%, #0b4f8a 100%)', color: '#fff', padding: '24px 28px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
                <div>
                  <h2 style={{ color: '#fff', fontSize: '20px', marginBottom: '6px' }}>Is your cattle or sheep showing signs of illness?</h2>
                  <p style={{ color: '#eaf3fb', margin: 0, fontSize: '13px' }}>
                    Submit an immediate report to trigger veterinary assessment and receive approved protective measures.
                  </p>
                </div>
                <button
                  className="primary"
                  onClick={() => nav('/farmer/report')}
                  style={{ background: '#ff9933', color: '#062b51', borderColor: '#e68524', fontWeight: '700', padding: '12px 22px', fontSize: '14px' }}
                >
                  <ClipboardPlus size={18} /> Report Animal Health Problem
                </button>
              </div>
            </div>

            <div className="metrics">
              <Metric label="My Total Reports" value={d.length} note="Submitted cases" />
              <Metric label="Under Monitoring" value={d.filter(x => x.status === 'Monitoring').length} note="Precautionary observation" />
              <Metric label="Escalated to Vet" value={d.filter(x => x.status === 'Escalated to Vet' || x.status === 'Vet Verified').length} note="Assigned to Government Vet" />
              <Metric label="Confirmed / Resolved" value={d.filter(x => ['Confirmed', 'Closed', 'Negative'].includes(x.status)).length} note="Lab tested or closed" />
            </div>

            <div className="two-col">
              <section className="panel">
                <div className="panel-title">
                  <h2>Latest Government Precautionary Advisory</h2>
                  <Badge>{latest?.advisory?.disease || 'General'}</Badge>
                </div>
                {latest?.advisory ? (
                  <>
                    <b style={{ color: '#0b4f8a', fontSize: '15px' }}>{latest.advisory.title}</b>
                    <p style={{ marginTop: '8px', lineHeight: '1.6' }}>{latest.advisory.message}</p>
                    <div className="notice" style={{ marginTop: '14px' }}>
                      <b>Important Farmer Directive:</b> Separate sick livestock from healthy animals, avoid movement to village markets, and keep water troughs clean.
                    </div>
                  </>
                ) : (
                  <p className="hint">Precautionary disease guidance will be provided immediately upon submitting a health report.</p>
                )}
              </section>

              <section className="panel" style={{ borderTop: '3px solid #ff9933' }}>
                <div className="panel-title">
                  <h2><Phone size={18} color="#b42318" /> Report Through Toll-Free IVR (1962)</h2>
                </div>
                <p style={{ fontSize: '13px', color: '#486581' }}>
                  Livestock owners without internet access can dial <b>1962</b> to register disease reports via assisted phone call.
                </p>
                <ol style={{ fontSize: '12px', paddingLeft: '18px', color: '#334e68', lineHeight: '1.8' }}>
                  <li>Dial 1962 (Toll-free Animal Helpline)</li>
                  <li>Select preferred language (Hindi / Marathi)</li>
                  <li>State animal type and observed symptoms</li>
                  <li>Confirm district and village location</li>
                  <li>Receive official Case Tracking ID via SMS</li>
                </ol>
                <button className="secondary" onClick={() => nav('/farmer/report#ivr')} style={{ width: '100%', marginTop: '8px' }}>
                  Launch Interactive IVR Simulator
                </button>
              </section>
            </div>

            <section className="panel">
              <div className="panel-title">
                <h2>My Active Animal Health Reports</h2>
                <button className="link" onClick={() => nav('/farmer/reports')}>View All History</button>
              </div>
              <Cases cases={d.slice(0, 4)} open={() => nav('/farmer/reports')} />
            </section>
          </>
        )}
      </Load>
    </Page>
  );
}

function Report() {
  const nav = useNavigate();
  const { user } = useAuth();
  const [f, setF] = useState({
    animalType: 'Cattle',
    symptoms: 'Mouth blisters, excessive drooling, lameness',
    district: user.district || 'Nashik',
    taluka: user.taluka || 'Niphad',
    village: 'Pimpalgaon',
    source: 'web'
  });
  const [photo, setPhoto] = useState(null);
  const [photoPreview, setPhotoPreview] = useState(null);
  const [photoError, setPhotoError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submittedCase, setSubmittedCase] = useState(null);
  const [err, setErr] = useState('');

  const symptomPresets = [
    'Mouth blisters',
    'Excessive drooling',
    'Sudden lameness',
    'High fever',
    'Skin nodules',
    'Nasal discharge',
    'Diarrhea'
  ];

  const addPreset = p => {
    const current = f.symptoms.split(',').map(x => x.trim()).filter(Boolean);
    if (!current.includes(p)) {
      setF({ ...f, symptoms: [...current, p].join(', ') });
    }
  };

  const handlePhotoChange = (e) => {
    const file = e.target.files?.[0];
    setPhotoError('');
    if (!file) {
      setPhoto(null);
      setPhotoPreview(null);
      return;
    }
    if (!['image/jpeg', 'image/png', 'image/jpg'].includes(file.type)) {
      setPhotoError('Only JPG, JPEG, and PNG images are supported.');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      setPhotoError('Photo size exceeds 5MB limit.');
      return;
    }
    setPhoto(file);
    setPhotoPreview(URL.createObjectURL(file));
  };

  const submit = async (e, iv = false) => {
    e.preventDefault();
    setErr('');
    setSubmitting(true);
    try {
      const parsed = (f.symptoms || '')
        .split(',')
        .map(x => x.trim())
        .filter(Boolean);

      let res;
      if (photo && !iv) {
        // Send multipart form-data for photo screening
        const formData = new FormData();
        formData.append('animalType', f.animalType);
        formData.append('symptoms', JSON.stringify(parsed));
        formData.append('district', f.district);
        formData.append('taluka', f.taluka);
        formData.append('village', f.village);
        formData.append('source', f.source || 'web');
        formData.append('photo', photo);

        res = await api('/reports', {
          method: 'POST',
          body: formData
        });
      } else {
        const payload = iv
          ? {
            ...f,
            symptoms: parsed,
            farmerName: user.name,
            phone: user.phone || '9876543210',
            language: 'Hindi'
          }
          : {
            ...f,
            symptoms: parsed,
            location: { district: f.district, taluka: f.taluka, village: f.village }
          };

        res = await api(iv ? '/ivr/report' : '/reports', {
          method: 'POST',
          body: JSON.stringify(payload)
        });
      }

      setSubmittedCase(res);
    } catch (x) {
      setErr(x.message || 'Could not submit report. Please check input fields.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Page
      title="Report Animal Health Problem"
      subtitle="Register an official animal illness report to initiate triage, precautionary advisories, and veterinary escalation"
    >
      {submittedCase ? (
        <div className="panel" style={{ borderTop: '4px solid #027a48', maxWidth: '800px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', padding: '16px 0 20px' }}>
            <CheckCircle2 size={44} color="#027a48" style={{ margin: '0 auto 12px' }} />
            <h2 style={{ fontSize: '22px', color: '#062b51', marginBottom: '4px' }}>Animal Health Report Registered</h2>
            <p style={{ color: '#627d98', fontSize: '13px' }}>
              Official Tracking Reference: <strong style={{ color: '#102a43' }}>{submittedCase.case?.caseId}</strong>
            </p>
          </div>

          <div style={{ background: '#f8fafc', padding: '16px', borderRadius: '4px', marginBottom: '18px', border: '1px solid #d9e2ec' }}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '12px' }}>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Assigned Status</small>
                <Badge>{submittedCase.case?.status}</Badge>
              </div>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Automated Risk Triage</small>
                <strong>{submittedCase.case?.localOutbreakRisk}% ({submittedCase.case?.triage?.toUpperCase()})</strong>
              </div>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Suspected Condition</small>
                <strong>{submittedCase.case?.suspectedDisease}</strong>
              </div>
            </div>
          </div>

          {/* AUTOMATED SYMPTOM ANALYSIS */}
          <div style={{ background: '#f8fafc', padding: '16px', borderRadius: '4px', marginBottom: '18px', border: '1px solid #d9e2ec' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', borderBottom: '1px solid #e2e8f0', paddingBottom: '8px' }}>
              <h3 style={{ fontSize: '13px', margin: 0, color: '#062b51', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                Automated Symptom Analysis
              </h3>
              <span className={`badge ${submittedCase.case?.mlSource === 'fastapi' ? 'green' : 'amber'}`}>
                {submittedCase.case?.mlSource === 'fastapi' ? 'FastAPI Voting Ensemble' : 'Fallback Assessment'}
              </span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '12px', fontSize: '13px' }}>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Predicted Condition</small>
                <strong style={{ color: '#0b4f8a' }}>{submittedCase.case?.suspectedDisease}</strong>
              </div>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Confidence Score</small>
                <strong>
                  {submittedCase.case?.mlPrediction?.confidence
                    ? `${(submittedCase.case.mlPrediction.confidence * 100).toFixed(1)}%`
                    : `${submittedCase.case?.localOutbreakRisk}%`}
                </strong>
              </div>
              <div>
                <small style={{ color: '#627d98', display: 'block' }}>Model Source</small>
                <span>
                  {submittedCase.case?.mlSource === 'fastapi' ? 'FastAPI Voting Ensemble' : 'Fallback Assessment'}
                </span>
              </div>
            </div>
            <div style={{ fontSize: '11px', color: '#627d98', marginTop: '10px', fontStyle: 'italic' }}>
              AI screening provides preliminary risk assessment and does not replace veterinary diagnosis.
            </div>
          </div>

          {/* AI VISUAL SCREENING (IF PHOTO WAS PROCESSED) */}
          {submittedCase.case?.imageScreening && (
            <div style={{ background: '#f0f9ff', border: '1px solid #b9e6fe', padding: '16px', borderRadius: '4px', marginBottom: '18px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', borderBottom: '1px solid #d0ecfd', paddingBottom: '8px' }}>
                <h3 style={{ fontSize: '13px', margin: 0, color: '#026aa2', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  AI Visual Screening — Lumpy Skin Disease Detection
                </h3>
                <span className="badge blue">ResNet18 CNN</span>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', fontSize: '13px' }}>
                <div>
                  <small style={{ color: '#026aa2', display: 'block' }}>Visual Classification</small>
                  <strong style={{ color: '#0b4f8a', fontSize: '14px' }}>{submittedCase.case.imageScreening.prediction}</strong>
                </div>
                <div>
                  <small style={{ color: '#026aa2', display: 'block' }}>Visual Confidence</small>
                  <strong>{(submittedCase.case.imageScreening.confidence * 100).toFixed(1)}%</strong>
                </div>
              </div>
              <div style={{ fontSize: '11px', color: '#026aa2', marginTop: '10px', fontStyle: 'italic' }}>
                Disclaimer: AI visual screening is a preliminary screening tool and does not replace clinical veterinary diagnosis.
              </div>
            </div>
          )}

          <div className="notice" style={{ background: '#eff8ff', marginBottom: '18px' }}>
            <b>Immediate Precautionary Advisory:</b>
            <p style={{ margin: '6px 0 0', lineHeight: '1.6' }}>{submittedCase.advisory?.message}</p>
          </div>

          <div className="warning-banner">
            <b>What Happens Next:</b>
            {submittedCase.escalated ? (
              <p style={{ margin: '4px 0 0' }}>
                Because the automated risk assessment is 70% or higher, this case has been <strong>automatically escalated to the assigned Government Veterinarian</strong> for physical field verification. You will be contacted for an inspection visit.
              </p>
            ) : (
              <p style={{ margin: '4px 0 0' }}>
                Your report has been placed under <strong>Monitoring</strong>. Follow the precautionary measures. If additional cases are reported in your village, the system will automatically escalate this case to the veterinary officer.
              </p>
            )}
          </div>

          <div style={{ display: 'flex', gap: '12px', justifyContent: 'center', marginTop: '24px' }}>
            <button className="primary" onClick={() => nav('/farmer/reports')}>
              View My Reports & Tracking Timeline
            </button>
            <button className="secondary" onClick={() => setSubmittedCase(null)}>
              Submit Another Report
            </button>
          </div>
        </div>
      ) : (
        <div className="two-col">
          <form className="panel form" onSubmit={e => submit(e, false)}>
            <div className="panel-title">
              <h2>Livestock Information & Symptoms</h2>
              <span className="hint">Fields marked are mandatory</span>
            </div>

            <div className="form-grid">
              <label>
                Animal Type *
                <select value={f.animalType} onChange={e => setF({ ...f, animalType: e.target.value })}>
                  {['Cattle', 'Buffalo', 'Goat', 'Sheep', 'Poultry', 'Other'].map(x => (
                    <option key={x} value={x}>{x}</option>
                  ))}
                </select>
              </label>

              <label>
                Reporting Source
                <select value={f.source} onChange={e => setF({ ...f, source: e.target.value })}>
                  <option value="web">Web Portal (Direct)</option>
                  <option value="voice">Voice / Telephonic</option>
                  <option value="sms">SMS Assisted</option>
                </select>
              </label>

              <label>
                District *
                <input value={f.district} onChange={e => setF({ ...f, district: e.target.value })} required />
              </label>

              <label>
                Taluka *
                <input value={f.taluka} onChange={e => setF({ ...f, taluka: e.target.value })} required />
              </label>

              <label style={{ gridColumn: 'span 2' }}>
                Village / Locality *
                <input value={f.village} onChange={e => setF({ ...f, village: e.target.value })} required />
              </label>
            </div>

            <label style={{ marginTop: '14px' }}>
              Observed Symptoms (Comma separated or pick below) *
              <textarea
                value={f.symptoms}
                onChange={e => setF({ ...f, symptoms: e.target.value })}
                placeholder="Describe observed physical signs (e.g. mouth blisters, drooling, high fever, skin nodules)..."
                required
              />
            </label>

            <div>
              <span className="hint" style={{ fontWeight: 600 }}>Quick Select Common Symptoms:</span>
              <div className="chips">
                {symptomPresets.map(p => (
                  <button
                    type="button"
                    key={p}
                    className="chip"
                    onClick={() => addPreset(p)}
                  >
                    + {p}
                  </button>
                ))}
              </div>
            </div>

            {/* Optional Animal Photo Upload */}
            <div style={{ marginTop: '16px', borderTop: '1px dashed #d9e2ec', paddingTop: '14px' }}>
              <label style={{ fontWeight: 600, fontSize: '13px' }}>
                Upload Animal Photo (Optional)
                <span className="hint" style={{ display: 'block', fontWeight: 'normal', marginTop: '3px' }}>
                  Provide an optional photo for AI visual screening (e.g. skin nodules or lesions for Lumpy Skin Disease detection). Supported: JPG, JPEG, PNG (Max 5MB).
                </span>
                <input
                  type="file"
                  accept="image/jpeg,image/png,image/jpg"
                  onChange={handlePhotoChange}
                  style={{ marginTop: '8px' }}
                />
              </label>
              {photoError && <small style={{ color: '#b42318', display: 'block', marginTop: '4px' }}>{photoError}</small>}
              {photoPreview && (
                <div style={{ marginTop: '10px', display: 'flex', alignItems: 'center', gap: '12px', background: '#f8fafc', padding: '8px 12px', borderRadius: '4px', border: '1px solid #d9e2ec' }}>
                  <img src={photoPreview} alt="Selected livestock preview" style={{ width: '64px', height: '64px', objectFit: 'cover', borderRadius: '4px', border: '1px solid #cbd5e1' }} />
                  <div style={{ flex: 1 }}>
                    <small style={{ color: '#102a43', display: 'block', fontWeight: 600 }}>{photo?.name}</small>
                    <small style={{ color: '#627d98' }}>{photo?.size ? (photo.size / 1024).toFixed(1) + ' KB' : ''}</small>
                    <button type="button" className="link" onClick={() => { setPhoto(null); setPhotoPreview(null); }} style={{ display: 'block', padding: 0, fontSize: '11px', color: '#b42318', marginTop: '2px' }}>
                      Remove photo
                    </button>
                  </div>
                </div>
              )}
            </div>

            <div style={{ marginTop: '24px' }}>
              <button className="primary" type="submit" disabled={submitting}>
                {submitting ? 'Registering Report...' : 'Submit Animal Health Report'}
              </button>
            </div>

            {err && <div className="notice" style={{ background: '#fef3f2', borderColor: '#b42318', color: '#b42318', marginTop: '16px' }}>{err}</div>}
          </form>

          <div>
            <section className="panel" id="ivr" style={{ borderTop: '3px solid #ff9933' }}>
              <div className="panel-title">
                <h2><Phone size={18} color="#b42318" /> Interactive IVR Simulation (1962)</h2>
              </div>
              <p style={{ fontSize: '13px', color: '#486581' }}>
                Simulate the automated Interactive Voice Response journey for phone-assisted callers:
              </p>

              <div style={{ background: '#f8fafc', padding: '14px', borderRadius: '4px', border: '1px solid #d9e2ec', marginBottom: '16px' }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '12px' }}>
                  <div><b>1. Dial:</b> Toll-free 1962 (Simulated)</div>
                  <div><b>2. Language:</b> Hindi / Marathi audio menu</div>
                  <div><b>3. AI Parser:</b> Speech-to-symptom extraction</div>
                  <div><b>4. Location:</b> Verified {f.village}, {f.district}</div>
                  <div><b>5. Workflow:</b> Identical ML triage & threshold</div>
                </div>
              </div>

              <button
                className="primary"
                type="button"
                onClick={e => submit(e, true)}
                disabled={submitting}
                style={{ width: '100%', background: '#ff9933', borderColor: '#e68524', color: '#062b51', fontWeight: 700 }}
              >
                {submitting ? 'Connecting IVR...' : 'Execute IVR Report Simulation'}
              </button>
              <small style={{ color: '#627d98', display: 'block', marginTop: '8px', textAlign: 'center' }}>
                Submits real FarmerReport with source = "ivr"
              </small>
            </section>

            <section className="panel">
              <h2>Veterinary Guidance</h2>
              <p style={{ fontSize: '12px', color: '#486581', lineHeight: '1.6' }}>
                Reports submitted through this portal are processed by the National Early Warning Engine. Symptoms indicating Foot and Mouth Disease (FMD), Lumpy Skin Disease (LSD), or PPR trigger priority alerts for field veterinary investigation.
              </p>
            </section>
          </div>
        </div>
      )}
    </Page>
  );
}

function FarmerReports() {
  const { d, e } = useLoad('/reports/my');
  const [selectedCase, setSelectedCase] = useState(null);

  return (
    <Page
      title="My Submitted Health Reports"
      subtitle="Track the real-time operational status, veterinary verification, and laboratory results for your livestock"
    >
      <Load error={e}>
        {d && (
          <>
            <div className="panel">
              <div className="panel-title">
                <h2>Operational Tracking Register</h2>
                <span className="hint">{d.length} reports on record</span>
              </div>
              <Cases cases={d} open={c => setSelectedCase(c)} />
            </div>

            {selectedCase && (
              <section className="panel" style={{ borderTop: '4px solid #0b4f8a' }}>
                <div className="panel-title">
                  <h2>Case Investigation Timeline: {selectedCase.caseId}</h2>
                  <button className="link" onClick={() => setSelectedCase(null)}>Close Details</button>
                </div>

                <CaseTimeline status={selectedCase.status} />

                <div className="two-col-equal" style={{ marginTop: '16px' }}>
                  <div style={{ background: '#f8fafc', padding: '16px', borderRadius: '4px', border: '1px solid #d9e2ec' }}>
                    <h3 style={{ fontSize: '14px', margin: '0 0 10px', color: '#062b51' }}>Case Summary</h3>
                    <div style={{ display: 'grid', gridTemplateColumns: '120px 1fr', gap: '8px', fontSize: '13px' }}>
                      <span style={{ color: '#627d98' }}>Animal:</span> <b>{selectedCase.animalType}</b>
                      <span style={{ color: '#627d98' }}>Location:</span> <span>{selectedCase.location?.village}, {selectedCase.location?.district}</span>
                      <span style={{ color: '#627d98' }}>Symptoms:</span> <span>{Array.isArray(selectedCase.symptoms) ? selectedCase.symptoms.join(', ') : selectedCase.symptoms}</span>
                      <span style={{ color: '#627d98' }}>Report Source:</span> <span>{selectedCase.source?.toUpperCase()}</span>
                      <span style={{ color: '#627d98' }}>Current Status:</span> <div><Badge>{selectedCase.status}</Badge></div>
                    </div>
                  </div>

                  <div style={{ background: '#eff8ff', padding: '16px', borderRadius: '4px', border: '1px solid #b2ddff' }}>
                    <h3 style={{ fontSize: '14px', margin: '0 0 10px', color: '#0b4f8a' }}>Official Precautionary Advisory</h3>
                    <p style={{ margin: 0, fontSize: '13px', lineHeight: '1.6' }}>
                      {selectedCase.advisory?.message || 'Isolate affected animals and follow veterinary directives.'}
                    </p>
                    {selectedCase.clinicalObservations && (
                      <div style={{ marginTop: '12px', borderTop: '1px solid #b2ddff', paddingTop: '10px' }}>
                        <small style={{ color: '#0b4f8a', fontWeight: 700 }}>Veterinarian Clinical Findings:</small>
                        <p style={{ margin: '4px 0 0', fontSize: '12px' }}>{selectedCase.clinicalObservations}</p>
                      </div>
                    )}
                  </div>
                </div>
              </section>
            )}
          </>
        )}
      </Load>
    </Page>
  );
}

// ----------------------------------------------------
// 2. Government Veterinarian Experience
// ----------------------------------------------------
function VetList() {
  const { d, e } = useLoad('/vet/cases');
  const nav = useNavigate();

  return (
    <Page
      title="Field Investigation Queue"
      subtitle="Escalated livestock disease cases requiring field verification and diagnostic sample collection"
    >
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="Field Action Queue" value={d.filter(x => x.status === 'Escalated to Vet').length} note="Pending verification" />
              <Metric label="High Outbreak Risk" value={d.filter(x => x.localOutbreakRisk >= 70).length} note="Risk score ≥70%" riskClass="risk" />
              <Metric label="Sample In Testing" value={d.filter(x => x.status === 'Lab Testing').length} note="With diagnostic lab" />
              <Metric label="Total Assigned Cases" value={d.length} note="Jurisdiction cases" />
            </div>

            <section className="panel">
              <div className="panel-title">
                <h2>Field Case Register</h2>
                <span className="hint">Urgent high-risk cases sorted by outbreak risk</span>
              </div>
              <Cases cases={d} open={c => nav('/vet/cases/' + c.caseId)} isVet={true} />
            </section>
          </>
        )}
      </Load>
    </Page>
  );
}

function VetCase() {
  const { id } = useParams();
  const { d: c, e, setD } = useLoad('/vet/cases/' + id);
  const [notes, setNotes] = useState('');
  const [msg, setMsg] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  const act = async (path, body = {}) => {
    setActionLoading(true);
    try {
      const isPatch = path.includes('verify') || path.includes('status');
      const r = await api(path, {
        method: isPatch ? 'PATCH' : 'POST',
        body: JSON.stringify(body)
      });
      if (r.case) {
        setD(r.case);
        setMsg('Diagnostic sample registered and forwarded to mapped District Laboratory.');
      } else {
        setD(r);
        setMsg('Case verification completed and farmer notified.');
      }
    } catch (x) {
      setMsg(x.message || 'Action failed');
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <Page
      title={`Case Investigation: ${id}`}
      subtitle="Perform clinical assessment, record veterinary observations, and dispatch diagnostic samples"
    >
      <Load error={e}>
        {c && (
          <>
            {/* Status Timeline */}
            <div className="panel">
              <CaseTimeline status={c.status} />
            </div>

            <div className="two-col">
              <div>
                {/* INITIAL AI TRIAGE & PRELIMINARY SCREENING */}
                <section className="panel" style={{ borderTop: '3px solid #ff9933', marginBottom: '16px' }}>
                  <div className="panel-title">
                    <h2>
                      <Activity size={18} color="#b54708" />
                      Initial AI Triage & Preliminary Screening
                    </h2>
                    <span className={`badge ${c.mlSource === 'fastapi' ? 'green' : 'amber'}`}>
                      {c.mlSource === 'fastapi' ? 'FastAPI Voting Ensemble' : 'Fallback Model'}
                    </span>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px', fontSize: '13px', background: '#f8fafc', padding: '12px', borderRadius: '4px', border: '1px solid #d9e2ec' }}>
                    <div>
                      <small style={{ color: '#627d98', display: 'block' }}>Predicted Condition</small>
                      <strong style={{ color: '#0b4f8a', fontSize: '14px' }}>{c.suspectedDisease}</strong>
                    </div>
                    <div>
                      <small style={{ color: '#627d98', display: 'block' }}>Confidence / Risk</small>
                      <strong>
                        {c.mlPrediction?.confidence
                          ? `${(c.mlPrediction.confidence * 100).toFixed(1)}% (${c.localOutbreakRisk}% Risk)`
                          : `${c.localOutbreakRisk}% Risk`}
                      </strong>
                    </div>
                    <div>
                      <small style={{ color: '#627d98', display: 'block' }}>Symptom Model Source</small>
                      <span>{c.mlSource === 'fastapi' ? 'FastAPI Voting Ensemble' : 'Fallback Heuristic'}</span>
                    </div>
                  </div>

                  {/* Image screening result if available */}
                  {c.imageScreening && (
                    <div style={{ marginTop: '10px', padding: '10px 12px', background: '#f0f9ff', border: '1px solid #b9e6fe', borderRadius: '4px', fontSize: '12px' }}>
                      <b style={{ color: '#026aa2' }}>AI Visual Screening (ResNet18 CNN):</b>
                      <div style={{ marginTop: '4px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
                        <span>Classification: <strong>{c.imageScreening.prediction}</strong></span>
                        <span>Confidence: <strong>{(c.imageScreening.confidence * 100).toFixed(1)}%</strong></span>
                        <span>Source: <strong>{c.imageScreening.source === 'fastapi' ? 'FastAPI Microservice' : 'Offline Fallback'}</strong></span>
                      </div>
                    </div>
                  )}

                  <div style={{ marginTop: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '12px' }}>
                    <div>
                      <span style={{ color: '#627d98' }}>AI Recommendation: </span>
                      <strong style={{ color: c.localOutbreakRisk >= 70 || c.mlPrediction?.requiresVetReview ? '#b42318' : '#0b4f8a' }}>
                        {c.localOutbreakRisk >= 70 || c.mlPrediction?.requiresVetReview
                          ? 'Requires Immediate Physical Field Verification'
                          : 'Standard Clinical Observation Protocol'}
                      </strong>
                    </div>
                  </div>

                  <div className="notice" style={{ background: '#fffaeb', borderColor: '#fedf89', marginTop: '12px', fontSize: '11px', color: '#7a271a' }}>
                    <b>Clinical Authority Disclaimer:</b> AI triage provides preliminary screening based on reported symptoms. Field physical examination and laboratory confirmation by the licensed veterinary officer determine the final diagnosis.
                  </div>
                </section>

                <section className="panel">
                  <div className="panel-title">
                    <h2>Livestock & Location Record</h2>
                    <Badge>{c.status}</Badge>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '130px 1fr', gap: '10px', fontSize: '13px' }}>
                    <span style={{ color: '#627d98' }}>Farmer Name:</span> <strong>{c.farmerName || 'Owner'}</strong>
                    <span style={{ color: '#627d98' }}>Contact Phone:</span> <span>{c.phone || 'Not provided'}</span>
                    <span style={{ color: '#627d98' }}>Village / Taluka:</span> <span>{c.location?.village}, {c.location?.taluka}</span>
                    <span style={{ color: '#627d98' }}>District:</span> <span>{c.location?.district}</span>
                    <span style={{ color: '#627d98' }}>Animal Type:</span> <span>{c.animalType}</span>
                    <span style={{ color: '#627d98' }}>Reported Signs:</span> <span>{Array.isArray(c.symptoms) ? c.symptoms.join(', ') : c.symptoms}</span>
                    <span style={{ color: '#627d98' }}>Date Reported:</span> <span>{new Date(c.createdAt).toLocaleString()}</span>
                  </div>
                </section>
              </div>

              {/* Action Panel */}
              <section className="panel form" style={{ borderTop: '3px solid #0b4f8a' }}>
                <div className="panel-title">
                  <h2>Veterinary Clinical Actions</h2>
                </div>

                <label>
                  Field Examination & Clinical Observations *
                  <textarea
                    value={notes || c.clinicalObservations || ''}
                    onChange={x => setNotes(x.target.value)}
                    placeholder="Document oral lesions, temperature, lameness severity, herd exposure..."
                    rows={4}
                  />
                </label>

                {c.status === 'Escalated to Vet' && (
                  <div>
                    <button
                      className="primary"
                      type="button"
                      disabled={actionLoading}
                      onClick={() => act(`/vet/cases/${id}/verify`, { clinicalObservations: notes })}
                      style={{ width: '100%', marginBottom: '10px' }}
                    >
                      {actionLoading ? 'Saving...' : '1. Confirm Field Verification'}
                    </button>
                    <small className="hint">Transitions case to 'Vet Verified' and notifies the livestock owner.</small>
                  </div>
                )}

                {c.status === 'Vet Verified' && (
                  <div>
                    <button
                      className="primary"
                      type="button"
                      disabled={actionLoading}
                      onClick={() => act(`/vet/cases/${id}/sample`, { notes })}
                      style={{ width: '100%', background: '#027a48', borderColor: '#027a48' }}
                    >
                      {actionLoading ? 'Routing...' : '2. Collect & Dispatch Diagnostic Sample'}
                    </button>
                    <small className="hint">Creates official Sample record and routes directly to mapped Diagnostic Lab.</small>
                  </div>
                )}

                {c.status === 'Lab Testing' && (
                  <div className="notice" style={{ background: '#eff8ff', borderColor: '#0b4f8a' }}>
                    <b>Diagnostic Sample Dispatched:</b>
                    <p style={{ margin: '4px 0 0', fontSize: '12px' }}>
                      Sample collected from field and assigned to District Laboratory. Awaiting molecular / PCR confirmation.
                    </p>
                  </div>
                )}

                {c.status === 'Confirmed' && (
                  <div className="notice" style={{ background: '#fef3f2', borderColor: '#b42318', color: '#b42318' }}>
                    <b>Laboratory Diagnosis Confirmed:</b>
                    <p style={{ margin: '4px 0 0', fontSize: '12px' }}>
                      Pathogen verified by laboratory. District containment and ring vaccination protocols active.
                    </p>
                  </div>
                )}

                {msg && (
                  <div className="toast">
                    <CheckCircle2 size={18} />
                    <div>{msg}</div>
                  </div>
                )}
              </section>
            </div>
          </>
        )}
      </Load>
    </Page>
  );
}

// ----------------------------------------------------
// 3. Laboratory Assistant Experience
// ----------------------------------------------------
function LabList() {
  const { d, e } = useLoad('/lab/samples');
  const nav = useNavigate();

  return (
    <Page
      title="Diagnostic Sample Work Queue"
      subtitle="Process biological samples, execute diagnostic assays, and publish verified laboratory outcomes"
    >
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="Pending Testing" value={d.filter(x => x.status === 'Collected' || x.status === 'Received').length} note="Samples in queue" />
              <Metric label="In Assay / Analysis" value={d.filter(x => x.status === 'Testing').length} note="PCR/ELISA in progress" />
              <Metric label="Completed Tests" value={d.filter(x => x.status === 'Completed').length} note="Published results" />
              <Metric label="Total Laboratory Register" value={d.length} note="All samples" />
            </div>

            <section className="panel">
              <div className="panel-title">
                <h2>Incoming Diagnostic Samples</h2>
              </div>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Sample ID</th>
                      <th>Case Reference</th>
                      <th>Suspected Condition</th>
                      <th>Animal & Tissue</th>
                      <th>Collection Village</th>
                      <th>Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {d.map(s => (
                      <tr key={s._id}>
                        <td><b>{s.sampleId}</b></td>
                        <td>{s.case?.caseId || '—'}</td>
                        <td><strong>{s.case?.suspectedDisease || 'General'}</strong></td>
                        <td>{s.case?.animalType} <small>{s.notes || 'Field swab'}</small></td>
                        <td>{s.case?.location?.village}, {s.case?.location?.district}</td>
                        <td><Badge>{s.status}</Badge></td>
                        <td>
                          <button className="primary" style={{ padding: '6px 12px', fontSize: '12px' }} onClick={() => nav('/lab/samples/' + s.sampleId)}>
                            Open Assay
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {!d.length && <div className="empty">No diagnostic samples currently queued for this laboratory.</div>}
            </section>
          </>
        )}
      </Load>
    </Page>
  );
}

function LabSample() {
  const { id } = useParams();
  const { d: s, e, setD } = useLoad('/lab/samples/' + id);
  const nav = useNavigate();
  const [result, setResult] = useState('Confirmed');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState('');

  const send = async e => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await api('/lab/samples/' + id + '/result', {
        method: 'POST',
        body: JSON.stringify({
          result,
          notes: notes || 'RT-PCR assay verified positive for pathogen.',
          disease: s.case?.suspectedDisease
        })
      });
      setMsg('Laboratory result published. Notifications dispatched to Farmer, Vet, District Officer, and State HQ.');
      setD(prev => ({ ...prev, status: 'Completed' }));
    } catch (x) {
      setMsg(x.message || 'Failed to submit laboratory result');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Page
      title={`Diagnostic Assay: ${id}`}
      subtitle="Validate specimen integrity, execute confirmatory testing, and publish official diagnostic verdict"
    >
      <Load error={e}>
        {s && (
          <div className="two-col">
            <section className="panel">
              <div className="panel-title">
                <h2>Sample & Clinical Context</h2>
                <Badge>{s.status}</Badge>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '130px 1fr', gap: '10px', fontSize: '13px' }}>
                <span style={{ color: '#627d98' }}>Sample ID:</span> <b>{s.sampleId}</b>
                <span style={{ color: '#627d98' }}>Linked Case:</span> <span>{s.case?.caseId}</span>
                <span style={{ color: '#627d98' }}>Suspected Disease:</span> <strong>{s.case?.suspectedDisease}</strong>
                <span style={{ color: '#627d98' }}>Animal Type:</span> <span>{s.case?.animalType}</span>
                <span style={{ color: '#627d98' }}>Location:</span> <span>{s.case?.location?.village}, {s.case?.location?.district}</span>
                <span style={{ color: '#627d98' }}>Collection Notes:</span> <span>{s.notes || 'Standard field sample'}</span>
                <span style={{ color: '#627d98' }}>Collected Date:</span> <span>{new Date(s.collectedAt || s.createdAt).toLocaleString()}</span>
              </div>
            </section>

            <form className="panel form" onSubmit={send} style={{ borderTop: '3px solid #0b4f8a' }}>
              <div className="panel-title">
                <h2>Publish Diagnostic Result</h2>
              </div>

              {s.status === 'Completed' ? (
                <div>
                  <div className="notice" style={{ background: '#ecfdf3', borderColor: '#027a48', color: '#027a48' }}>
                    <b>Testing Completed & Results Published</b>
                    <p style={{ margin: '4px 0 0', fontSize: '12px' }}>
                      The diagnostic outcome for this sample is final and published across district surveillance dashboards.
                    </p>
                  </div>
                  <button className="secondary" type="button" onClick={() => nav('/lab/samples')} style={{ marginTop: '12px' }}>
                    Return to Diagnostic Work Queue
                  </button>
                </div>
              ) : (
                <>
                  <label>
                    Diagnostic Outcome *
                    <select value={result} onChange={e => setResult(e.target.value)}>
                      <option value="Confirmed">Confirmed (Pathogen Positive — Outbreak Confirmed)</option>
                      <option value="Negative">Negative (Non-infectious / Pathogen Negative)</option>
                      <option value="Inconclusive">Inconclusive (Requires Repeat Sample)</option>
                    </select>
                  </label>

                  <label>
                    Assay Methodology & Diagnostic Notes *
                    <textarea
                      value={notes}
                      onChange={e => setNotes(e.target.value)}
                      placeholder="Enter RT-PCR Ct value, serotype identification (e.g. FMDV Serotype O), or ELISA titers..."
                      rows={4}
                      required
                    />
                  </label>

                  <button className="primary" type="submit" disabled={submitting}>
                    {submitting ? 'Publishing Result...' : 'Publish Official Laboratory Result'}
                  </button>
                </>
              )}

              {msg && (
                <div className="toast">
                  <CheckCircle2 size={18} />
                  <div>{msg}</div>
                </div>
              )}
            </form>
          </div>
        )}
      </Load>
    </Page>
  );
}

// ----------------------------------------------------
// 4. District Surveillance Officer Experience
// ----------------------------------------------------
function DistrictHome() {
  const { user } = useAuth();
  const districtName = user.district || 'Nashik';
  const { d, e } = useLoad('/district/' + districtName + '/overview');
  const { d: trends } = useLoad('/district/' + districtName + '/trends');
  const { d: breakdown } = useLoad('/district/' + districtName + '/breakdown');
  const { d: historical } = useLoad('/district/' + districtName + '/historical');
  const [modalOpen, setModalOpen] = useState(false);
  const [reqType, setReqType] = useState('vaccination');
  const [reqReason, setReqReason] = useState('');
  const [done, setDone] = useState('');

  const submitRequest = async () => {
    try {
      await api('/district/requests', {
        method: 'POST',
        body: JSON.stringify({
          type: reqType,
          disease: 'Foot and Mouth Disease',
          district: districtName,
          taluka: 'Niphad',
          village: 'Pimpalgaon',
          reason: reqReason || 'Immediate field intervention required following cluster review.'
        })
      });
      setDone(`Official ${reqType} request submitted to State Headquarters.`);
      setReqReason('');
      setModalOpen(false);
    } catch (x) {
      setDone(x.message || 'Failed to submit request');
    }
  };

  return (
    <Page
      title={`District Animal Health Surveillance — ${districtName}`}
      subtitle="Real-time operational monitoring, active cluster signals, and emergency field action coordination"
      action={
        <button
          className="primary"
          onClick={() => setModalOpen(true)}
          style={{ background: '#062b51', borderColor: '#062b51' }}
        >
          <Send size={15} /> Raise State Action Request
        </button>
      }
    >
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="Reports Today" value={d.todayReports?.length || 0} note="Submitted since 00:00 hrs" />
              <Metric label="Active Cases" value={d.activeCases?.length || 0} note="Open operational cases" />
              <Metric label="Confirmed Outbreaks" value={d.confirmedCases?.length || 0} note="Lab verified cases" riskClass="risk" />
              <Metric label="Active Cluster Signals" value={d.clusters?.length || 0} note="Local-area hotspots" />
            </div>

            {/* LIVE SITUATION MAP */}
            <section className="panel" style={{ borderTop: '3px solid #0b4f8a' }}>
              <div className="panel-title">
                <h2>
                  <Map size={18} color="#0b4f8a" />
                  District Live Operational Situation
                </h2>
                <Badge>LIVE REPORTS & CASES ONLY</Badge>
              </div>
              <p className="hint" style={{ marginBottom: '14px' }}>
                Markers represent active cases from the real-time database. Historical disease archives and state predictive models are strictly segregated.
              </p>

              <div style={{ height: '400px', width: '100%', borderRadius: '8px', overflow: 'hidden', marginTop: '16px' }}>
                {d.clusters && d.clusters.filter(c => c.centroid?.latitude).length > 0 ? (
                  <MapContainer
                    center={[d.clusters.find(c => c.centroid?.latitude).centroid.latitude, d.clusters.find(c => c.centroid?.latitude).centroid.longitude]}
                    zoom={9}
                    style={{ height: '100%', width: '100%' }}
                  >
                    <TileLayer
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    />
                    {d.clusters.filter(c => c.centroid?.latitude).map(c => (
                      <Circle
                        key={c.clusterId}
                        center={[c.centroid.latitude, c.centroid.longitude]}
                        radius={(c.radiusKm || 15) * 1000}
                        pathOptions={{
                          color: c.risk >= 70 ? '#b42318' : '#eab308',
                          fillColor: c.risk >= 70 ? '#b42318' : '#eab308',
                          fillOpacity: 0.4
                        }}
                      >
                        <Popup>
                          <strong>{c.disease}</strong><br />
                          Location: {c.village}<br />
                          Active Cases: {c.caseCount}<br />
                          Max Risk Score: {c.risk}%
                        </Popup>
                      </Circle>
                    ))}
                  </MapContainer>
                ) : (
                  <div className="empty">No geographic hotspots available.</div>
                )}
              </div>
            </section>

            {/* ACTIVE OUTBREAK CLUSTER DETECTION */}
            <section className="panel" style={{ borderTop: '3px solid #b42318' }}>
              <div className="panel-title">
                <div>
                  <h2 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <AlertTriangle size={18} color="#b42318" />
                    Active Outbreak Cluster Detection
                  </h2>
                  <small style={{ color: '#627d98', display: 'block', marginTop: '2px' }}>
                    Powered by Spatial Analysis ({d.clusters?.some(c => c.source === 'dbscan') ? 'DBSCAN Machine Learning' : 'Density Assessment'})
                  </small>
                </div>
                <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                  <span className={`badge ${d.clusters?.some(c => c.source === 'dbscan') ? 'green' : 'amber'}`}>
                    {d.clusters?.some(c => c.source === 'dbscan') ? 'DBSCAN Active' : 'Fallback Density'}
                  </span>
                  <Badge>RADIUS: 15 KM</Badge>
                </div>
              </div>

              {d.clusters && d.clusters.length > 0 ? (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>Cluster ID & Source</th>
                        <th>Village & Taluka</th>
                        <th>Pathogen & Centroid</th>
                        <th>Linked Case IDs</th>
                        <th>Peak Risk</th>
                        <th>Recommended Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {d.clusters.map((x, idx) => (
                        <tr key={x.village + x.disease + idx} style={{ background: '#fffbfa' }}>
                          <td>
                            <b style={{ color: '#062b51' }}>Cluster #{x.clusterId ?? idx}</b>
                            <small style={{ display: 'block', marginTop: '2px' }}>
                              <span className={`badge ${x.source === 'dbscan' ? 'green' : 'amber'}`} style={{ fontSize: '10px', padding: '1px 6px' }}>
                                {x.source === 'dbscan' ? 'DBSCAN' : 'Fallback'}
                              </span>
                            </small>
                          </td>
                          <td>
                            <b>{x.village}</b>
                            <small style={{ display: 'block' }}>{x.taluka || districtName} (15 km radius)</small>
                          </td>
                          <td>
                            <strong>{x.disease}</strong>
                            <small style={{ display: 'block', color: '#627d98' }}>
                              {x.centroid?.latitude ? `${x.centroid.latitude.toFixed(4)}, ${x.centroid.longitude.toFixed(4)}` : 'Centroid calculated'}
                            </small>
                          </td>
                          <td>
                            <span style={{ fontSize: '14px', fontWeight: 800 }}>{x.caseCount}</span> active cases
                            <small style={{ display: 'block', color: '#486581', maxWidth: '220px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                              {x.caseIds?.join(', ') || 'Connected cluster'}
                            </small>
                          </td>
                          <td><span className="risk-pill high">{x.risk}%</span></td>
                          <td>
                            <button className="primary" style={{ padding: '5px 10px', fontSize: '11px', background: '#b42318', borderColor: '#b42318' }} onClick={() => setModalOpen(true)}>
                              Deploy Ring Vaccination
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="empty">No active clusters meet the multi-case density threshold.</div>
              )}
            </section>

            <div className="two-col">
              {/* DISEASE TRENDS CHART */}
              <section className="panel">
                <div className="panel-title">
                  <h2>Disease Activity Trends</h2>
                  <span className="hint">Daily Case Inflow</span>
                </div>
                {trends && trends.length > 0 ? (
                  <div>
                    <div className="trend-bars">
                      {trends.slice(-7).map((t, idx) => {
                        const maxVal = Math.max(...trends.map(x => x.cases), 1);
                        const heightPct = Math.round((t.cases / maxVal) * 90) + 10;
                        return (
                          <div key={idx} className="trend-bar-col">
                            <div className="trend-bar" style={{ height: `${heightPct}%`, background: '#0b4f8a' }} title={`${t._id.disease}: ${t.cases} cases`} />
                            <span className="trend-bar-label">{t._id.day?.slice(5)}</span>
                          </div>
                        );
                      })}
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#627d98', marginTop: '8px' }}>
                      <span>Source: District Case Database</span>
                      <span>Chronological Progression</span>
                    </div>
                  </div>
                ) : (
                  <div className="empty">Insufficient trend observations for this period.</div>
                )}
              </section>

              {/* AREA BREAKDOWN */}
              <section className="panel">
                <div className="panel-title">
                  <h2>Taluka & Village Breakdown</h2>
                </div>
                {breakdown && breakdown.length > 0 ? (
                  <div className="table-wrap">
                    <table>
                      <thead>
                        <tr>
                          <th>Taluka</th>
                          <th>Village</th>
                          <th>Cases</th>
                          <th>Max Risk</th>
                        </tr>
                      </thead>
                      <tbody>
                        {breakdown.map((b, i) => (
                          <tr key={i}>
                            <td>{b._id?.taluka || '—'}</td>
                            <td><b>{b._id?.village || '—'}</b></td>
                            <td>{b.cases}</td>
                            <td><span className="risk-pill medium">{b.risk}%</span></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <div className="empty">No village breakdown data available.</div>
                )}
              </section>
            </div>

            {/* HISTORICAL ARCHIVE LAYER (STRICTLY SEGREGATED) */}
            <section className="panel" style={{ background: '#fafbfc' }}>
              <div className="panel-title">
                <h2>Historical Disease Archive</h2>
                <Badge>PRIOR VERIFIED EPIDEMIOLOGICAL RECORDS</Badge>
              </div>
              <p className="hint">
                Maintained for multi-season baseline comparison. Historical records are strictly segregated from active operational hotspot intensity.
              </p>
              {historical && historical.length > 0 ? (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>Disease</th>
                        <th>Village</th>
                        <th>Taluka</th>
                        <th>Recorded Cases</th>
                        <th>Archive Date</th>
                      </tr>
                    </thead>
                    <tbody>
                      {historical.map(h => (
                        <tr key={h._id}>
                          <td><b>{h.disease}</b></td>
                          <td>{h.village}</td>
                          <td>{h.taluka || '—'}</td>
                          <td>{h.count} verified</td>
                          <td>{new Date(h.recordedAt).toLocaleDateString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="empty">No historical outbreak records archived for this jurisdiction.</div>
              )}
            </section>

            {/* ACTION REQUEST MODAL */}
            <Modal open={modalOpen} title="Raise State Action Request" onClose={() => setModalOpen(false)}>
              <div className="form">
                <label>
                  Intervention Type *
                  <select value={reqType} onChange={e => setReqType(e.target.value)}>
                    <option value="vaccination">Ring Vaccination Campaign</option>
                    <option value="containment">Movement Restriction / Quarantine</option>
                  </select>
                </label>

                <label>
                  Intervention Justification *
                  <textarea
                    value={reqReason}
                    onChange={e => setReqReason(e.target.value)}
                    placeholder="Specify why State allocation is necessary (e.g. cluster acceleration in Pimpalgaon, need for 2,000 vaccine units)..."
                    rows={4}
                  />
                </label>

                <div style={{ display: 'flex', gap: '10px', marginTop: '16px' }}>
                  <button className="primary" type="button" onClick={submitRequest}>
                    Submit Request to State HQ
                  </button>
                  <button className="secondary" type="button" onClick={() => setModalOpen(false)}>
                    Cancel
                  </button>
                </div>
              </div>
            </Modal>

            {done && (
              <div className="toast">
                <CheckCircle2 size={18} />
                <div>{done}</div>
              </div>
            )}
          </>
        )}
      </Load>
    </Page>
  );
}

function DistrictCases() {
  const { user } = useAuth();
  const { d, e } = useLoad('/district/' + (user.district || 'Nashik') + '/active-cases');
  return (
    <Page title={`Active Case Register — ${user.district || 'Nashik'}`} subtitle="Comprehensive listing of all non-closed reports across talukas">
      <section className="panel">
        <Load error={e}>
          {d && <Cases cases={d} open={() => { }} />}
        </Load>
      </section>
    </Page>
  );
}

function Clusters() {
  const { user } = useAuth();
  const { d, e } = useLoad('/district/' + (user.district || 'Nashik') + '/clusters');
  return (
    <Page title="Active Outbreak Cluster Warnings" subtitle="Early warning triggers generated by spatial-temporal disease density and DBSCAN spatial analysis">
      <section className="panel">
        <Load error={e}>
          {d && d.length ? (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Cluster ID</th>
                    <th>Cluster Location</th>
                    <th>Suspected Condition</th>
                    <th>Spatial Centroid</th>
                    <th>Linked Active Cases</th>
                    <th>Peak Risk</th>
                    <th>Analysis Engine</th>
                  </tr>
                </thead>
                <tbody>
                  {d.map((x, idx) => (
                    <tr key={x.village + x.disease + idx}>
                      <td><b style={{ color: '#062b51' }}>Cluster #{x.clusterId ?? idx}</b></td>
                      <td><b>{x.village}</b> <small>{x.taluka || user.district}</small></td>
                      <td><strong>{x.disease}</strong></td>
                      <td>
                        <small style={{ color: '#486581' }}>
                          {x.centroid?.latitude ? `${x.centroid.latitude.toFixed(4)}, ${x.centroid.longitude.toFixed(4)}` : 'Calculated'}
                        </small>
                      </td>
                      <td>
                        <span style={{ fontWeight: 700 }}>{x.caseCount}</span> cases
                        <small style={{ display: 'block', color: '#627d98', maxWidth: '180px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {x.caseIds?.join(', ') || 'Linked'}
                        </small>
                      </td>
                      <td><span className="risk-pill high">{x.risk}%</span></td>
                      <td>
                        <span className={`badge ${x.source === 'dbscan' ? 'green' : 'amber'}`}>
                          {x.source === 'dbscan' ? 'DBSCAN ML' : 'Density Fallback'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="empty">No active clusters meet the multi-case local threshold.</div>
          )}
        </Load>
      </section>
    </Page>
  );
}

// ----------------------------------------------------
// 5. State Officer Strategic Experience
// ----------------------------------------------------
function StateHome() {
  const { d, e } = useLoad('/state/districts');
  const { d: reqs } = useLoad('/state/requests');
  const nav = useNavigate();

  return (
    <Page
      title="State Strategic Priority Matrix — Maharashtra"
      subtitle="Epidemiological resource allocation, predicted risk ranking, and district rapid-response approval"
    >
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="High-Risk Districts" value={d.filter(x => x.currentRisk >= 70).length} note="Predicted score ≥70%" riskClass="risk" />
              <Metric label="State Outbreaks" value={d.reduce((a, x) => a + (x.confirmedCases || 0), 0)} note="PCR-confirmed foci" />
              <Metric label="Monitored Districts" value={d.length} note="Full state coverage" />
              <Metric label="Pending Action Requests" value={reqs?.length ?? 0} note="Awaiting State decision" />
            </div>

            {/* DISTRICT RISK RANKING TABLE */}
            <section className="panel" style={{ borderTop: '3px solid #062b51' }}>
              <div className="panel-title">
                <h2>
                  <Building2 size={18} color="#062b51" />
                  Maharashtra District Risk Hierarchy (Where Should the State Act First?)
                </h2>
                <Badge>PREDICTED CURRENT OPERATIONAL RISK</Badge>
              </div>
              <p className="hint" style={{ marginBottom: '14px' }}>
                Predicted risk is computed using the ML district-risk contract; it is segregated from raw report counts and historical records.
              </p>

              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Rank</th>
                      <th>District Name</th>
                      <th>Predicted Outbreak Risk</th>
                      <th>Active Cases</th>
                      <th>Confirmed Outbreaks</th>
                      <th>Active Clusters</th>
                      <th>Strategic Priority</th>
                    </tr>
                  </thead>
                  <tbody>
                    {d.map((x, i) => {
                      const isHigh = x.currentRisk >= 70;
                      return (
                        <tr key={x.district} style={isHigh ? { background: '#fffbfa' } : {}}>
                          <td><strong style={{ fontSize: '15px' }}>#{i + 1}</strong></td>
                          <td><b>{x.district}</b></td>
                          <td>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                              <div style={{ flex: 1, background: '#e5edf5', height: '8px', borderRadius: '4px', overflow: 'hidden', minWidth: '80px' }}>
                                <div style={{ width: `${x.currentRisk}%`, background: isHigh ? '#b42318' : '#0b4f8a', height: '100%' }} />
                              </div>
                              <span className={`risk-pill ${isHigh ? 'high' : 'medium'}`}>{x.currentRisk}%</span>
                            </div>
                          </td>
                          <td>{x.activeCases}</td>
                          <td><strong>{x.confirmedCases}</strong></td>
                          <td>{x.clusters}</td>
                          <td>
                            <Badge>{isHigh ? 'Critical State Attention' : 'Standard Surveillance'}</Badge>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </section>

            {/* PENDING REQUESTS PREVIEW */}
            <section className="panel">
              <div className="panel-title">
                <h2>Pending District Intervention Requests</h2>
                <button className="link" onClick={() => nav('/state/requests')}>View & Allocate All</button>
              </div>
              {reqs && reqs.length > 0 ? (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>Request ID</th>
                        <th>District</th>
                        <th>Intervention Type</th>
                        <th>Justification</th>
                        <th>Priority</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {reqs.map(r => (
                        <tr key={r._id}>
                          <td><b>{r.requestId}</b></td>
                          <td><strong>{r.district}</strong></td>
                          <td>{r.type === 'vaccination' ? 'Ring Vaccination' : 'Containment'}</td>
                          <td>{r.reason}</td>
                          <td><Badge>{r.priority}</Badge></td>
                          <td>
                            <button className="primary" style={{ padding: '6px 12px', fontSize: '12px' }} onClick={() => nav('/state/requests')}>
                              Review & Allocate
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="empty">No pending action requests awaiting State decision.</div>
              )}
            </section>
          </>
        )}
      </Load>
    </Page>
  );
}

function StateDistricts() {
  const { d, e } = useLoad('/state/districts');
  return (
    <Page title="District Risk Ranking" subtitle="State-wide operational risk ranking computed from multi-factor disease inputs">
      <section className="panel">
        <Load error={e}>
          {d && (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>District</th>
                    <th>Predicted Risk</th>
                    <th>Active Cases</th>
                    <th>Confirmed Cases</th>
                    <th>Cluster Signals</th>
                  </tr>
                </thead>
                <tbody>
                  {d.map(x => (
                    <tr key={x.district}>
                      <td><b>{x.district}</b></td>
                      <td><span className={`risk-pill ${x.currentRisk >= 70 ? 'high' : 'medium'}`}>{x.currentRisk}%</span></td>
                      <td>{x.activeCases}</td>
                      <td>{x.confirmedCases}</td>
                      <td>{x.clusters}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Load>
      </section>
    </Page>
  );
}

function StateRequests() {
  const { d, e, setD } = useLoad('/state/requests');
  const [pick, setPick] = useState(null);
  const [action, setAction] = useState('Approved');
  const [allocation, setAllocation] = useState('');
  const [msg, setMsg] = useState('');

  const sendDecision = async () => {
    if (!pick) return;
    try {
      await api('/state/requests/' + pick._id, {
        method: 'PATCH',
        body: JSON.stringify({
          status: action,
          priority: action === 'Prioritized' ? 'High' : 'Normal',
          allocation: allocation || (action === 'Allocated' ? 'State Reserve biological allocation dispatched' : '')
        })
      });
      setMsg(`State decision saved (${action}). District Officer notified.`);
      setD(d.filter(x => x._id !== pick._id));
      setPick(null);
      setAllocation('');
    } catch (x) {
      setMsg(x.message || 'Action failed');
    }
  };

  return (
    <Page title="District Action Requests" subtitle="Review district quarantine and emergency vaccination requests and allocate State reserves">
      <section className="panel">
        <Load error={e}>
          {d && (
            <>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Request Reference</th>
                      <th>District</th>
                      <th>Type</th>
                      <th>Justification</th>
                      <th>Priority</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {d.map(x => (
                      <tr key={x._id}>
                        <td><b>{x.requestId}</b></td>
                        <td><strong>{x.district}</strong></td>
                        <td>{x.type === 'vaccination' ? 'Ring Vaccination' : 'Containment'}</td>
                        <td>{x.reason}</td>
                        <td><Badge>{x.priority}</Badge></td>
                        <td>
                          <button className="primary" style={{ padding: '6px 12px', fontSize: '12px' }} onClick={() => { setPick(x); setAction('Approved'); }}>
                            Review Request
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {!d.length && <div className="empty">No pending district intervention requests.</div>}
            </>
          )}
        </Load>
      </section>

      <Modal open={!!pick} title={`State Decision: ${pick?.requestId}`} onClose={() => setPick(null)}>
        <div className="form">
          <p style={{ margin: '0 0 12px', fontSize: '13px' }}>
            <strong>District:</strong> {pick?.district} | <strong>Type:</strong> {pick?.type}
          </p>
          <div className="notice" style={{ background: '#f8fafc', marginBottom: '14px' }}>
            <b>District Justification:</b> {pick?.reason}
          </div>

          <label>
            State Executive Decision *
            <select value={action} onChange={e => setAction(e.target.value)}>
              <option value="Approved">Approve Request</option>
              <option value="Prioritized">Prioritize with High Urgency</option>
              <option value="Allocated">Allocate Vaccines / Rapid Team</option>
              <option value="Rejected">Reject Request</option>
            </select>
          </label>

          <label>
            Allocation / Directive Notes
            <input
              value={allocation}
              onChange={e => setAllocation(e.target.value)}
              placeholder="e.g. 5,000 vaccine doses dispatched from State Veterinary Reserve..."
            />
          </label>

          <div style={{ display: 'flex', gap: '10px', marginTop: '16px' }}>
            <button className="primary" type="button" onClick={sendDecision}>
              Confirm & Dispatch Decision
            </button>
            <button className="secondary" type="button" onClick={() => setPick(null)}>
              Cancel
            </button>
          </div>
        </div>
      </Modal>

      {msg && (
        <div className="toast">
          <CheckCircle2 size={18} />
          <div>{msg}</div>
        </div>
      )}
    </Page>
  );
}

// ----------------------------------------------------
// Official Login Experience
// ----------------------------------------------------
function Login() {
  const { login } = useAuth();
  const [role, setRole] = useState('farmer');
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState('');

  const demoAccounts = [
    { key: 'farmer', title: 'Livestock Owner / Farmer', name: 'Suresh Patil (9876543210)', scope: 'Village Pimpalgaon, Nashik' },
    { key: 'vet', title: 'Government Veterinarian', name: 'Dr Ananya Shah (9000000001)', scope: 'Field Investigation, Nashik' },
    { key: 'lab', title: 'Diagnostic Lab Officer', name: 'Nisha Rao (9000000002)', scope: 'District Disease Investigation Lab' },
    { key: 'district', title: 'District Surveillance Officer', name: 'Vikram Deshmukh (9000000003)', scope: 'District Headquarter, Nashik' },
    { key: 'state', title: 'State Animal Husbandry Officer', name: 'Priya Kulkarni (9000000004)', scope: 'State Command Center, Maharashtra' }
  ];

  const handleLogin = async r => {
    const selectedRole = r || role;
    setErr('');
    setLoading(true);
    try {
      await login(selectedRole);
    } catch (x) {
      setErr(x.message || 'Login failed. Please verify database seeding.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-wrap">
      <div className="login-topline" />
      <div className="govline">
        <span>Government of India | Department of Animal Husbandry & Dairying</span>
        <span>National Animal Disease Surveillance Portal</span>
      </div>

      <div className="login-body">
        <div className="login-card">
          <div className="login-seal-box">
            <div className="seal">GOI</div>
            <div>
              <b style={{ color: '#062b51', fontSize: '18px', display: 'block' }}>LDEWS Official Access</b>
              <small style={{ color: '#627d98' }}>Department of Animal Husbandry & Dairying</small>
            </div>
          </div>

          <h1>Authorized Portal Entry</h1>
          <p>Select your operational role below to enter the role-specific disease surveillance workspace:</p>

          <div className="role-cards">
            {demoAccounts.map(a => (
              <div
                key={a.key}
                className={`role-card-opt ${role === a.key ? 'selected' : ''}`}
                onClick={() => setRole(a.key)}
              >
                <div>
                  <strong>{a.title}</strong>
                  <small>{a.name} · {a.scope}</small>
                </div>
                {role === a.key && <Check size={16} color="#0b4f8a" />}
              </div>
            ))}
          </div>

          <button
            className="primary"
            style={{ width: '100%', justifyContent: 'center', padding: '12px', fontSize: '14px', background: '#0b4f8a' }}
            type="button"
            disabled={loading}
            onClick={() => handleLogin()}
          >
            {loading ? 'Authenticating Official Session...' : `Enter ${roles[role]} Workspace`}
          </button>

          {err && (
            <div className="notice" style={{ background: '#fef3f2', borderColor: '#b42318', color: '#b42318', marginTop: '14px' }}>
              {err}
            </div>
          )}

          <div style={{ borderTop: '1px solid #e5edf5', marginTop: '20px', paddingTop: '12px', textAlign: 'center', fontSize: '11px', color: '#627d98' }}>
            Demo Authentication Active · Default Demo Password: <strong>demo123</strong>
          </div>
        </div>
      </div>
    </div>
  );
}

function RoleGuard({ roles: allowedRoles, children }) {
  const { user } = useAuth();
  if (!allowedRoles.includes(user.role)) {
    return <Navigate to={homes[user.role] || '/login'} replace />;
  }
  return children;
}

function App() {
  const [session, setSession] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('ldews-session') || 'null');
    } catch {
      return null;
    }
  });

  useEffect(() => {
    const handleLogout = () => setSession(null);
    window.addEventListener('ldews-logout', handleLogout);
    return () => window.removeEventListener('ldews-logout', handleLogout);
  }, []);

  const login = async role => {
    const r = await api('/auth/demo-login', {
      method: 'POST',
      body: JSON.stringify({ role })
    });
    localStorage.setItem('ldews-session', JSON.stringify(r));
    setSession(r);
  };

  const logout = () => {
    localStorage.removeItem('ldews-session');
    setSession(null);
  };

  if (!session) {
    return (
      <Auth.Provider value={{ login }}>
        <Login />
      </Auth.Provider>
    );
  }

  return (
    <Auth.Provider value={{ ...session, login, logout }}>
      <Routes>
        {/* Farmer Routes */}
        <Route path="/farmer" element={<RoleGuard roles={['farmer']}><FarmerHome /></RoleGuard>} />
        <Route path="/farmer/report" element={<RoleGuard roles={['farmer']}><Report /></RoleGuard>} />
        <Route path="/farmer/reports" element={<RoleGuard roles={['farmer']}><FarmerReports /></RoleGuard>} />

        {/* Vet Routes */}
        <Route path="/vet" element={<RoleGuard roles={['vet']}><VetList /></RoleGuard>} />
        <Route path="/vet/cases" element={<RoleGuard roles={['vet']}><VetList /></RoleGuard>} />
        <Route path="/vet/cases/:id" element={<RoleGuard roles={['vet']}><VetCase /></RoleGuard>} />

        {/* Lab Routes */}
        <Route path="/lab" element={<RoleGuard roles={['lab']}><LabList /></RoleGuard>} />
        <Route path="/lab/samples" element={<RoleGuard roles={['lab']}><LabList /></RoleGuard>} />
        <Route path="/lab/samples/:id" element={<RoleGuard roles={['lab']}><LabSample /></RoleGuard>} />

        {/* District Routes */}
        <Route path="/district/overview" element={<RoleGuard roles={['district', 'state']}><DistrictHome /></RoleGuard>} />
        <Route path="/district/cases" element={<RoleGuard roles={['district', 'state']}><DistrictCases /></RoleGuard>} />
        <Route path="/district/clusters" element={<RoleGuard roles={['district', 'state']}><Clusters /></RoleGuard>} />

        {/* State Routes */}
        <Route path="/state/overview" element={<RoleGuard roles={['state']}><StateHome /></RoleGuard>} />
        <Route path="/state/districts" element={<RoleGuard roles={['state']}><StateDistricts /></RoleGuard>} />
        <Route path="/state/requests" element={<RoleGuard roles={['state']}><StateRequests /></RoleGuard>} />

        {/* Fallback Redirect */}
        <Route path="*" element={<Navigate to={homes[session.user?.role] || '/farmer'} replace />} />
      </Routes>
    </Auth.Provider>
  );
}

createRoot(document.getElementById('root')).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
);
