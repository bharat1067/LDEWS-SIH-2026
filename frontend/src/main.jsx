import React, { createContext, useContext, useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, NavLink, Navigate, useNavigate, useParams } from 'react-router-dom';
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
  AlertCircle,
  Menu,
  Phone,
  Map,
  Search
} from 'lucide-react';
import './styles.css';

const API = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
const Auth = createContext();
export const useAuth = () => useContext(Auth);

export const api = async (path, o = {}) => {
  const s = JSON.parse(localStorage.getItem('ldews-session') || 'null');
  const r = await fetch(API + path, {
    headers: {
      'Content-Type': 'application/json',
      ...(s?.token ? { Authorization: `Bearer ${s.token}` } : {})
    },
    ...o
  });
  const d = await r.json().catch(() => ({}));
  if (r.status === 401) {
    localStorage.removeItem('ldews-session');
    if (s?.token) {
      window.dispatchEvent(new Event('ldews-logout'));
    }
    throw Error(d.message || 'Session expired. Please log in again.');
  }
  if (!r.ok) {
    throw Error(d.message || 'Request failed');
  }
  return d;
};

const roles = {
  farmer: 'Farmer',
  vet: 'Government Veterinarian',
  lab: 'Lab Assistant',
  district: 'District Officer',
  state: 'State Officer'
};

const homes = {
  farmer: '/farmer',
  vet: '/vet',
  lab: '/lab',
  district: '/district/overview',
  state: '/state/overview'
};

function Load({ children, error }) {
  return error ? <div className="empty" style={{ color: '#b42318' }}>{error}</div> : children;
}

function Badge({ children }) {
  const x = String(children || '');
  const colorClass = /Confirmed|Escalated|High/i.test(x)
    ? 'red'
    : /Monitoring|Testing|Pending|Prioritized/i.test(x)
      ? 'amber'
      : 'blue';
  return <span className={`badge ${colorClass}`}>{x}</span>;
}

function Modal({ open, title, onClose, children }) {
  if (!open) return null;
  return (
    <div className="modal-backdrop">
      <section className="modal">
        <div className="panel-title">
          <h2>{title}</h2>
          <button className="link" onClick={onClose}>Close</button>
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

function Shell({ children }) {
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);

  const n = {
    farmer: [
      ['Home', '/farmer', LayoutDashboard],
      ['Report animal problem', '/farmer/report', ClipboardPlus],
      ['My reports', '/farmer/reports', MapPinned]
    ],
    vet: [
      ['Investigation queue', '/vet', Stethoscope],
      ['All assigned cases', '/vet/cases', LayoutDashboard]
    ],
    lab: [
      ['Incoming samples', '/lab', FlaskConical],
      ['Sample register', '/lab/samples', LayoutDashboard]
    ],
    district: [
      ['Monitor & respond', '/district/overview', LayoutDashboard],
      ['Case register', '/district/cases', ClipboardPlus],
      ['Cluster alerts', '/district/clusters', MapPinned]
    ],
    state: [
      ['Predict & prioritize', '/state/overview', LayoutDashboard],
      ['District risk ranking', '/state/districts', MapPinned],
      ['Action requests', '/state/requests', ShieldAlert]
    ]
  }[user.role] || [];

  return (
    <>
      <header>
        <div className="govline">
          <span>Government of India</span>
          <span>Department of Animal Husbandry & Dairying</span>
        </div>
        <div className="brand">
          <button className="mobile" onClick={() => setOpen(!open)}><Menu /></button>
          <div className="seal">A</div>
          <div>
            <b>Livestock Disease Early Warning System</b>
            <small>National Animal Disease Surveillance Portal</small>
          </div>
          <div className="profile">
            <Bell size={18} />
            <span className="avatar">{(user.name || 'U')[0]}</span>
            <div>
              <strong>{user.name}</strong>
              <small>{roles[user.role]} {user.district ? `(${user.district})` : ''}</small>
            </div>
            <button onClick={logout} title="Sign Out"><LogOut size={17} /></button>
          </div>
        </div>
      </header>

      <aside className={open ? 'open' : ''}>
        <div className="side-title">{roles[user.role]} workspace</div>
        {n.map(([title, to, Icon]) => (
          <NavLink
            to={to}
            end={to === homes[user.role]}
            key={to}
            onClick={() => setOpen(false)}
          >
            <Icon size={18} />
            {title}
          </NavLink>
        ))}
        <div className="side-footer">
          <ShieldAlert size={17} /> Animal health helpline<br />
          <b>1962</b>
        </div>
      </aside>

      {open && <div className="backdrop" onClick={() => setOpen(false)} />}
      <main>
        <div className="crumb">Home <ChevronRight size={14} /> {roles[user.role]}</div>
        {children}
      </main>
    </>
  );
}

function Page({ title, action, children }) {
  return (
    <Shell>
      <div className="page-head">
        <div>
          <h1>{title}</h1>
          <p>Operational disease surveillance and response</p>
        </div>
        {action}
      </div>
      {children}
    </Shell>
  );
}

function Metric({ label, value, note }) {
  return (
    <div className="metric">
      <span>{label}</span>
      <strong>{value ?? '—'}</strong>
      <small>{note}</small>
    </div>
  );
}

function Cases({ cases = [], open }) {
  const [query, setQuery] = useState('');
  const list = cases.filter(c => JSON.stringify(c).toLowerCase().includes(query.toLowerCase()));

  return (
    <>
      <div className="filter">
        <Search size={16} />
        <input
          placeholder="Search case, farmer, village or disease"
          value={query}
          onChange={e => setQuery(e.target.value)}
        />
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Case</th>
              <th>Farmer / location</th>
              <th>Initial suspicion</th>
              <th>Local outbreak risk</th>
              <th>Status</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {list.map(c => (
              <tr key={c._id}>
                <td>
                  <b>{c.caseId}</b>
                  <small>{new Date(c.createdAt).toLocaleString()}</small>
                </td>
                <td>
                  {c.farmerName || 'Farmer'}
                  <small>{c.location?.village || 'Village'}, {c.location?.district || 'District'}</small>
                </td>
                <td>
                  {c.suspectedDisease || 'General Infection'}
                  <small>{c.animalType}</small>
                </td>
                <td className="risk">{c.localOutbreakRisk}%</td>
                <td><Badge>{c.status}</Badge></td>
                <td><button className="link" onClick={() => open(c)}>Open</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {!list.length && <div className="empty">No records match this filter.</div>}
    </>
  );
}

function FarmerHome() {
  const { d, e } = useLoad('/reports/my');
  const nav = useNavigate();
  const latest = d?.[0];

  return (
    <Page
      title="My animal health reports"
      action={<button className="primary" onClick={() => nav('/farmer/report')}>Report animal problem</button>}
    >
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="My active reports" value={d.filter(x => !['Closed', 'Negative'].includes(x.status)).length} note="Current cases" />
              <Metric label="Vet escalated" value={d.filter(x => x.status === 'Escalated to Vet').length} note="Veterinary visit arranged" />
              <Metric label="Sample testing" value={d.filter(x => x.status === 'Lab Testing').length} note="Awaiting lab result" />
              <Metric label="Closed" value={d.filter(x => ['Closed', 'Negative'].includes(x.status)).length} note="Resolved reports" />
            </div>
            <div className="two-col">
              <section className="panel">
                <h2>Latest advisory</h2>
                {latest?.advisory ? (
                  <>
                    <b>{latest.advisory.title}</b>
                    <p>{latest.advisory.message}</p>
                  </>
                ) : (
                  <p className="hint">An approved advisory will appear after you submit a report.</p>
                )}
              </section>
              <section className="panel">
                <h2><Phone size={18} /> Report through IVR</h2>
                <p>Call → Language → Animal → Symptoms → Location → Report ID</p>
                <button className="link" onClick={() => nav('/farmer/report#ivr')}>Open IVR simulator</button>
              </section>
            </div>
            <section className="panel">
              <div className="panel-title">
                <h2>My reports</h2>
                <button className="link" onClick={() => nav('/farmer/reports')}>View all</button>
              </div>
              <Cases cases={d.slice(0, 5)} open={() => nav('/farmer/reports')} />
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
    symptoms: 'Mouth lesions, drooling',
    district: user.district || 'Nashik',
    taluka: 'Niphad',
    village: 'Pimpalgaon',
    source: 'web'
  });
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');

  const submit = async (e, iv = false) => {
    e.preventDefault();
    setErr('');
    setMsg('');
    try {
      const parsedSymptoms = (f.symptoms || '')
        .split(',')
        .map(x => x.trim())
        .filter(Boolean);

      const r = await api(iv ? '/ivr/report' : '/reports', {
        method: 'POST',
        body: JSON.stringify(
          iv
            ? {
                ...f,
                symptoms: parsedSymptoms,
                farmerName: user.name,
                phone: user.phone || '9876543210',
                language: 'Hindi'
              }
            : {
                ...f,
                symptoms: parsedSymptoms,
                location: { district: f.district, taluka: f.taluka, village: f.village }
              }
        )
      });

      const outcome = r.escalated
        ? 'High-risk case detected (Risk >= 70%). Escalated to Vet; notification sent.'
        : 'Case recorded for Monitoring (Risk < 70%). Health advisory generated.';

      setMsg(`${r.case.caseId}: ${outcome}`);
    } catch (x) {
      setErr(x.message || 'Submission failed');
    }
  };

  return (
    <Page title="Report animal problem">
      <div className="two-col">
        <form className="panel form" onSubmit={e => submit(e, false)}>
          <h2>Animal and location</h2>
          <div className="form-grid">
            {[
              ['animalType', 'Animal type'],
              ['district', 'District'],
              ['taluka', 'Taluka'],
              ['village', 'Village']
            ].map(([k, l]) => (
              <label key={k}>
                {l}
                <input value={f[k]} onChange={e => setF({ ...f, [k]: e.target.value })} required />
              </label>
            ))}
            <label>
              Reporting source
              <select value={f.source} onChange={e => setF({ ...f, source: e.target.value })}>
                {['web', 'voice', 'sms'].map(x => <option key={x}>{x}</option>)}
              </select>
            </label>
          </div>
          <label>
            Symptoms observed (comma-separated)
            <textarea value={f.symptoms} onChange={e => setF({ ...f, symptoms: e.target.value })} required />
          </label>
          <button className="primary" type="submit">Submit report</button>
        </form>

        <section className="panel" id="ivr">
          <h2>Report through IVR</h2>
          <p>Simulate the assisted call flow and send the same report through the IVR API.</p>
          <ol>
            <li>Call 1962</li>
            <li>Select Hindi</li>
            <li>Choose animal and symptoms</li>
            <li>Confirm location</li>
            <li>Receive report ID</li>
          </ol>
          <button className="primary" type="button" onClick={e => submit(e, true)}>Run IVR simulation</button>
        </section>
      </div>

      {(msg || err) && (
        <div className={'toast ' + (err ? 'error' : '')}>
          {err ? <AlertCircle color="#b42318" /> : <CheckCircle2 />}
          <div>
            <b>{err ? 'Submission error' : 'Report recorded'}</b><br />
            {err || msg}
          </div>
          {msg && <button onClick={() => nav('/farmer/reports')}>View reports</button>}
        </div>
      )}
    </Page>
  );
}

function FarmerReports() {
  const { d, e } = useLoad('/reports/my');
  return (
    <Page title="My reports">
      <section className="panel">
        <Load error={e}>
          {d && <Cases cases={d} open={() => {}} />}
        </Load>
      </section>
    </Page>
  );
}

function VetList() {
  const { d, e } = useLoad('/vet/cases');
  const nav = useNavigate();
  return (
    <Page title="Investigate escalated cases">
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="New escalations" value={d.filter(x => x.status === 'Escalated to Vet').length} note="Needs verification" />
              <Metric label="High priority" value={d.filter(x => x.localOutbreakRisk >= 70).length} note="Local outbreak risk 70%+" />
              <Metric label="Sample testing" value={d.filter(x => x.status === 'Lab Testing').length} note="In laboratory" />
              <Metric label="Total assigned" value={d.length} note="In jurisdiction" />
            </div>
            <section className="panel">
              <h2>Field investigation queue</h2>
              <Cases cases={d} open={c => nav('/vet/cases/' + c.caseId)} />
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

  const act = async (path, body = {}) => {
    try {
      const isPatch = path.includes('verify') || path.includes('status');
      const r = await api(path, {
        method: isPatch ? 'PATCH' : 'POST',
        body: JSON.stringify(body)
      });
      // If sample was collected, server returns { sample, case }
      if (r.case) {
        setD(r.case);
        setMsg('Sample collected successfully and forwarded to the district laboratory.');
      } else {
        setD(r);
        setMsg('Workflow updated successfully.');
      }
    } catch (x) {
      setMsg(x.message || 'Action failed');
    }
  };

  return (
    <Page title="Case investigation workspace">
      <Load error={e}>
        {c && (
          <>
            <div className="two-col">
              <section className="panel">
                <div className="panel-title">
                  <h2>{c.caseId}</h2>
                  <Badge>{c.status}</Badge>
                </div>
                <p className="notice">
                  <b>Initial ML Triage — Not Final Diagnosis</b><br />
                  Suspected disease: {c.suspectedDisease || 'General Infection'} · Local Outbreak Risk: {c.localOutbreakRisk}% · Escalation Threshold: 70%
                </p>
                <dl>
                  <dt>Farmer</dt><dd>{c.farmerName || 'Farmer'}</dd>
                  <dt>Phone</dt><dd>{c.phone || 'Not recorded'}</dd>
                  <dt>Location</dt><dd>{c.location?.village}, {c.location?.taluka ? c.location.taluka + ', ' : ''}{c.location?.district}</dd>
                  <dt>Reported</dt><dd>{new Date(c.createdAt).toLocaleString()}</dd>
                  <dt>Symptoms</dt><dd>{Array.isArray(c.symptoms) ? c.symptoms.join(', ') : (c.symptoms || 'None')}</dd>
                </dl>
              </section>

              <section className="panel form">
                <h2>Clinical action</h2>
                <label>
                  Clinical observations
                  <textarea
                    value={notes || c.clinicalObservations || ''}
                    onChange={x => setNotes(x.target.value)}
                    placeholder="Document clinical signs and observations..."
                  />
                </label>
                {c.status === 'Escalated to Vet' && (
                  <button className="primary" type="button" onClick={() => act(`/vet/cases/${id}/verify`, { clinicalObservations: notes })}>
                    Verify case
                  </button>
                )}
                {c.status === 'Vet Verified' && (
                  <button className="primary" type="button" onClick={() => act(`/vet/cases/${id}/sample`, { notes })}>
                    Collect sample
                  </button>
                )}
                {c.status === 'Lab Testing' && (
                  <p className="success">Sample has been routed to the mapped laboratory for molecular testing.</p>
                )}
                {c.status === 'Confirmed' && (
                  <p className="success" style={{ color: '#b42318' }}>Diagnosis confirmed by laboratory. Response containment in progress.</p>
                )}
              </section>
            </div>
            {msg && (
              <div className="toast">
                <CheckCircle2 />
                <div>{msg}</div>
              </div>
            )}
          </>
        )}
      </Load>
    </Page>
  );
}

function LabList() {
  const { d, e } = useLoad('/lab/samples');
  const nav = useNavigate();
  return (
    <Page title="Confirm laboratory samples">
      <Load error={e}>
        {d && (
          <section className="panel">
            <h2>Incoming sample register</h2>
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Sample</th>
                    <th>Case</th>
                    <th>Suspected disease</th>
                    <th>Animal</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {d.map(s => (
                    <tr key={s._id}>
                      <td><b>{s.sampleId}</b></td>
                      <td>{s.case?.caseId || '—'}</td>
                      <td>{s.case?.suspectedDisease || 'General Infection'}</td>
                      <td>{s.case?.animalType || '—'}</td>
                      <td>{s.case?.location?.village || '—'}</td>
                      <td><Badge>{s.status}</Badge></td>
                      <td><button className="link" onClick={() => nav('/lab/samples/' + s.sampleId)}>Open</button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {!d.length && <div className="empty">No incoming samples assigned to this laboratory.</div>}
          </section>
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
  const [msg, setMsg] = useState('');

  const send = async e => {
    e.preventDefault();
    try {
      await api('/lab/samples/' + id + '/result', {
        method: 'POST',
        body: JSON.stringify({ result, notes, disease: s.case?.suspectedDisease })
      });
      setMsg('Laboratory result submitted and stakeholders notified.');
      setD(prev => ({ ...prev, status: 'Completed' }));
    } catch (x) {
      setMsg(x.message || 'Submission failed');
    }
  };

  return (
    <Page title="Sample testing workspace">
      <Load error={e}>
        {s && (
          <div className="two-col">
            <section className="panel">
              <h2>{s.sampleId}</h2>
              <dl>
                <dt>Case</dt><dd>{s.case?.caseId || '—'}</dd>
                <dt>Suspected disease</dt><dd>{s.case?.suspectedDisease || '—'}</dd>
                <dt>Animal</dt><dd>{s.case?.animalType || '—'}</dd>
                <dt>Location</dt><dd>{s.case?.location?.village}, {s.case?.location?.district}</dd>
                <dt>Testing status</dt><dd><Badge>{s.status}</Badge></dd>
                <dt>Notes</dt><dd>{s.notes || 'None'}</dd>
              </dl>
            </section>

            <form className="panel form" onSubmit={send}>
              <h2>Publish laboratory result</h2>
              {s.status === 'Completed' ? (
                <div className="success">
                  <p>Testing completed for this sample.</p>
                  <button className="primary" type="button" onClick={() => nav('/lab/samples')}>
                    Back to sample register
                  </button>
                </div>
              ) : (
                <>
                  <label>
                    Result
                    <select value={result} onChange={e => setResult(e.target.value)}>
                      {['Confirmed', 'Negative', 'Inconclusive'].map(x => <option key={x}>{x}</option>)}
                    </select>
                  </label>
                  <label>
                    Testing notes & assay details
                    <textarea
                      value={notes}
                      onChange={e => setNotes(e.target.value)}
                      placeholder="Enter PCR/ELISA assay observations..."
                    />
                  </label>
                  <button className="primary" type="submit">Submit result</button>
                </>
              )}
              {msg && <p className="success">{msg}</p>}
            </form>
          </div>
        )}
      </Load>
    </Page>
  );
}

function DistrictHome() {
  const { user } = useAuth();
  const districtName = user.district || 'Nashik';
  const { d, e } = useLoad('/district/' + districtName + '/overview');
  const { d: breakdown } = useLoad('/district/' + districtName + '/breakdown');
  const [request, setRequest] = useState('');
  const [done, setDone] = useState('');

  const raise = async type => {
    try {
      await api('/district/requests', {
        method: 'POST',
        body: JSON.stringify({
          type,
          disease: 'Foot and Mouth Disease',
          district: districtName,
          taluka: 'Niphad',
          village: 'Pimpalgaon',
          reason: request || 'Required after review of active cluster signal.'
        })
      });
      setDone(`${type === 'vaccination' ? 'Vaccination' : 'Containment'} request sent to State.`);
      setRequest('');
    } catch (x) {
      setDone(x.message || 'Failed to submit request');
    }
  };

  return (
    <Page title={`District surveillance & response (${districtName})`}>
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="Reports today" value={d.todayReports?.length || 0} note="Submitted since midnight" />
              <Metric label="Active cases" value={d.activeCases?.length || 0} note="Open operational cases" />
              <Metric label="Confirmed cases" value={d.confirmedCases?.length || 0} note="Laboratory confirmed" />
              <Metric label="Active clusters" value={d.clusters?.length || 0} note="Recent local-area signals" />
            </div>

            <div className="two-col">
              <section className="panel">
                <h2><Map size={18} /> Live district map data</h2>
                <p className="hint">Live markers use verified current reports only. Historical records and state predictions are segregated.</p>
                <div className="map-list">
                  {d.mapData && d.mapData.length > 0 ? (
                    d.mapData.map(x => (
                      <div key={x.caseId}>
                        <b>{x.village}</b>
                        <span>{x.disease} · Risk: {x.risk}% · Status: {x.status}</span>
                      </div>
                    ))
                  ) : (
                    <p>No active markers in this district.</p>
                  )}
                </div>
              </section>

              <section className="panel">
                <h2>Operational case stages</h2>
                <p className="hint">Real-time status breakdown from active database records.</p>
                <h3>Case stage summary</h3>
                {d.stageSummary && Object.entries(d.stageSummary).map(([k, v]) => (
                  <p key={k}>
                    {k}
                    <b className="right">{v}</b>
                  </p>
                ))}
              </section>
            </div>

            <section className="panel">
              <h2>Cluster alerts</h2>
              {d.clusters && d.clusters.length ? (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>Village</th>
                        <th>Taluka</th>
                        <th>Disease</th>
                        <th>Cases</th>
                        <th>Operational risk</th>
                      </tr>
                    </thead>
                    <tbody>
                      {d.clusters.map(x => (
                        <tr key={x.village + x.disease}>
                          <td>{x.village}</td>
                          <td>{x.taluka || '—'}</td>
                          <td>{x.disease}</td>
                          <td>{x.caseCount}</td>
                          <td className="risk">{x.risk}%</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="empty">No active clusters meet the configured local-area threshold.</div>
              )}
            </section>

            <div className="two-col">
              <section className="panel form">
                <h2>Raise response request</h2>
                <label>
                  Justification
                  <textarea
                    value={request}
                    onChange={e => setRequest(e.target.value)}
                    placeholder="Specify why field action is required (e.g. ring vaccination, movement containment)..."
                  />
                </label>
                <button className="primary" type="button" onClick={() => raise('vaccination')}>
                  Raise vaccination request
                </button>{' '}
                <button className="link" type="button" onClick={() => raise('containment')}>
                  Raise containment request
                </button>
                {done && <p className="success">{done}</p>}
              </section>

              <section className="panel">
                <h2>Taluka / village breakdown</h2>
                {breakdown && breakdown.length ? (
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
                            <td className="risk">{b.risk}%</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <p className="hint">No village cases recorded yet for this district.</p>
                )}
              </section>
            </div>
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
    <Page title="District case register">
      <section className="panel">
        <Load error={e}>
          {d && <Cases cases={d} open={() => {}} />}
        </Load>
      </section>
    </Page>
  );
}

function Clusters() {
  const { user } = useAuth();
  const { d, e } = useLoad('/district/' + (user.district || 'Nashik') + '/clusters');
  return (
    <Page title="Active cluster alerts">
      <section className="panel">
        <Load error={e}>
          {d && d.length ? (
            <div className="cluster-list">
              {d.map(x => (
                <div key={x.village + x.disease}>
                  <b>{x.village} ({x.taluka || 'Taluka'}) — {x.disease}</b>
                  <span>{x.caseCount} linked active cases · risk {x.risk}%</span>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty">No active clusters need a response at this time.</div>
          )}
        </Load>
      </section>
    </Page>
  );
}

function StateHome() {
  const { d, e } = useLoad('/state/districts');
  const { d: reqs } = useLoad('/state/requests');

  return (
    <Page title="Predict, prioritize and allocate">
      <Load error={e}>
        {d && (
          <>
            <div className="metrics">
              <Metric label="High-risk districts" value={d.filter(x => x.currentRisk >= 70).length} note="Predicted operational risk" />
              <Metric label="Active outbreaks" value={d.reduce((a, x) => a + (x.confirmedCases || 0), 0)} note="Confirmed cases" />
              <Metric label="Monitored districts" value={d.length} note="State-wide surveillance" />
              <Metric label="Pending action requests" value={reqs?.length ?? '—'} note="Awaiting state decision" />
            </div>

            <section className="panel">
              <h2>State district risk ranking (Dynamic Backend Computation)</h2>
              <p className="hint">Predicted risk is computed via backend ML contract; it is segregated from raw live map layers.</p>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Rank</th>
                      <th>District</th>
                      <th>Predicted risk</th>
                      <th>Active cases</th>
                      <th>Confirmed</th>
                      <th>Clusters</th>
                    </tr>
                  </thead>
                  <tbody>
                    {d.map((x, i) => (
                      <tr key={x.district}>
                        <td>{i + 1}</td>
                        <td><b>{x.district}</b></td>
                        <td className="risk">{x.currentRisk}%</td>
                        <td>{x.activeCases}</td>
                        <td>{x.confirmedCases}</td>
                        <td>{x.clusters}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
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
    <Page title="District risk ranking">
      <section className="panel">
        <Load error={e}>
          {d && (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>District</th>
                    <th>Predicted risk</th>
                    <th>Current cases</th>
                    <th>Confirmed</th>
                    <th>Active clusters</th>
                  </tr>
                </thead>
                <tbody>
                  {d.map(x => (
                    <tr key={x.district}>
                      <td><b>{x.district}</b></td>
                      <td className="risk">{x.currentRisk}%</td>
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
  const [msg, setMsg] = useState('');

  const send = async () => {
    if (!pick) return;
    try {
      await api('/state/requests/' + pick._id, {
        method: 'PATCH',
        body: JSON.stringify({
          status: action,
          priority: action === 'Prioritized' ? 'High' : 'Normal',
          allocation: action === 'Allocated' ? 'District rapid-response allocation approved' : ''
        })
      });
      setMsg(`State decision recorded (${action}) and district notified.`);
      setD(d.filter(x => x._id !== pick._id));
      setPick(null);
    } catch (x) {
      setMsg(x.message || 'Action failed');
    }
  };

  return (
    <Page title="District action requests">
      <section className="panel">
        <Load error={e}>
          {d && (
            <>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Request</th>
                      <th>District</th>
                      <th>Type</th>
                      <th>Reason</th>
                      <th>Priority</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {d.map(x => (
                      <tr key={x._id}>
                        <td><b>{x.requestId}</b></td>
                        <td>{x.district}</td>
                        <td>{x.type}</td>
                        <td>{x.reason}</td>
                        <td><Badge>{x.priority}</Badge></td>
                        <td><button className="link" onClick={() => setPick(x)}>Review</button></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {!d.length && <div className="empty">No pending action requests.</div>}
            </>
          )}
        </Load>
      </section>

      <Modal open={!!pick} title="Decide action request" onClose={() => setPick(null)}>
        <p><b>{pick?.requestId}</b>: {pick?.reason}</p>
        <label>
          Decision
          <select value={action} onChange={e => setAction(e.target.value)}>
            {['Approved', 'Rejected', 'Prioritized', 'Allocated'].map(x => <option key={x}>{x}</option>)}
          </select>
        </label>
        <button className="primary" type="button" onClick={send}>Confirm decision</button>
      </Modal>

      {msg && (
        <div className="toast">
          <CheckCircle2 />
          <div>{msg}</div>
        </div>
      )}
    </Page>
  );
}

function Login() {
  const { login } = useAuth();
  const [role, setRole] = useState('farmer');
  const [err, setErr] = useState('');

  return (
    <div className="login">
      <div className="login-brand">
        <div className="seal">A</div>
        <div>
          <b>Livestock Disease Early Warning System</b>
          <small>Department of Animal Husbandry & Dairying</small>
        </div>
      </div>
      <form
        onSubmit={async e => {
          e.preventDefault();
          setErr('');
          try {
            await login(role);
          } catch (x) {
            setErr(x.message || 'Login failed');
          }
        }}
      >
        <h1>Prototype access</h1>
        <p>Select a role to enter the role-specific demonstration workspace.</p>
        <label>
          Demo role
          <select value={role} onChange={e => setRole(e.target.value)}>
            {Object.entries(roles).map(([k, v]) => (
              <option value={k} key={k}>{v}</option>
            ))}
          </select>
        </label>
        <button className="primary" type="submit">Enter secure portal</button>
        {err && <p className="error-text" style={{ color: '#b42318', marginTop: '10px' }}>{err}</p>}
        <small>Demo data must be seeded before login (npm run seed).</small>
      </form>
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

        {/* Fallback redirect */}
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
