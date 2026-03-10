import React, { useState, useEffect } from 'react';
import {
  Users, Handshake, Package, LayoutDashboard, Settings,
  LogOut, Search, CheckCircle, XCircle, Eye, Phone, Mail, Clock,
  ShieldCheck, AlertCircle, MapPin, Scale, IndianRupee, ZoomIn
} from 'lucide-react';
import { auth, db } from './firebase';
import { signInWithEmailAndPassword, onAuthStateChanged, signOut } from 'firebase/auth';
import { collection, query, where, onSnapshot, doc, updateDoc, orderBy, getDoc } from 'firebase/firestore';
import './index.css';

const App = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [pendingPartners, setPendingPartners] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [allPartners, setAllPartners] = useState([]);
  const [allPickups, setAllPickups] = useState([]);
  const [selectedPartner, setSelectedPartner] = useState(null);
  const [previewImage, setPreviewImage] = useState(null);
  const [stats, setStats] = useState({
    totalUsers: 0,
    activePartners: 0,
    orders: 0,
    pendingVerifications: 0
  });

  // Auth Listener
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  // Data Listeners
  useEffect(() => {
    if (!user) return;

    // Listen for Pending Partners (for dashboard notifications)
    const qPending = query(collection(db, 'partners'), where('verificationStatus', '==', 'pending'));
    const unsubscribePending = onSnapshot(qPending, (snapshot) => {
      const partners = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setPendingPartners(partners);
      setStats(prev => ({ ...prev, pendingVerifications: partners.length }));
    });

    // Listen for All Users
    const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setAllUsers(users);
      setStats(prev => ({ ...prev, totalUsers: users.length }));
    });

    // Listen for All Partners
    const unsubscribePartners = onSnapshot(collection(db, 'partners'), (snapshot) => {
      const partners = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      const activeCount = partners.filter(p => p.verificationStatus === 'verified').length;
      setAllPartners(partners);
      setStats(prev => ({ ...prev, activePartners: activeCount }));
    });

    // Listen for All Pickups
    const qPickups = query(collection(db, 'pickups'), orderBy('scheduledTime', 'desc'));
    const unsubscribePickups = onSnapshot(qPickups, (snapshot) => {
      const pickups = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setAllPickups(pickups);
      setStats(prev => ({ ...prev, orders: pickups.length }));
    });

    return () => {
      unsubscribePending();
      unsubscribeUsers();
      unsubscribePartners();
      unsubscribePickups();
    };
  }, [user]);

  const handleLogin = async (e) => {
    e.preventDefault();
    const email = e.target.email.value;
    const password = e.target.password.value;
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
      alert("Login failed: " + error.message);
    }
  };

  const handleLogout = () => signOut(auth);

  const updateVerificationStatus = async (partnerId, status) => {
    try {
      const updateData = {
        verificationStatus: status,
        verifiedAt: status === 'verified' ? new Date() : null,
        rejectedAt: status === 'rejected' ? new Date() : null,
      };

      // Sync to both collections
      await Promise.all([
        updateDoc(doc(db, 'partners', partnerId), updateData),
        updateDoc(doc(db, 'users', partnerId), updateData)
      ]);

      setSelectedPartner(null);
      alert(`Partner ${status === 'verified' ? 'Approved' : 'Rejected'} successfully!`);
    } catch (error) {
      alert("Update failed: " + error.message);
    }
  };

  // Helper to deep fetch partner data including fallback to users collection
  const openPartnerReview = async (partner) => {
    setLoading(true);
    try {
      console.log("Deep fetching documents for:", partner.id);
      // Fetch latest from both collections to ensure we have all data
      const [partnerSnap, userSnap] = await Promise.all([
        getDoc(doc(db, 'partners', partner.id)),
        getDoc(doc(db, 'users', partner.id))
      ]);

      let consolidatedData = { id: partner.id };

      if (userSnap.exists()) {
        console.log("Found data in 'users' collection");
        consolidatedData = { ...consolidatedData, ...userSnap.data() };
      }

      if (partnerSnap.exists()) {
        console.log("Found data in 'partners' collection");
        consolidatedData = { ...consolidatedData, ...partnerSnap.data() };
      }

      // Ensure all possible doc field names are covered (camelCase and snake_case)
      const finalData = {
        ...consolidatedData,
        selfieUrl: consolidatedData.selfieUrl || consolidatedData.selfie_url || consolidatedData.selfie,
        aadharFrontUrl: consolidatedData.aadharFrontUrl || consolidatedData.aadhar_front || consolidatedData.aadharFront,
        aadharBackUrl: consolidatedData.aadharBackUrl || consolidatedData.aadhar_back || consolidatedData.aadharBack,
        panFrontUrl: consolidatedData.panFrontUrl || consolidatedData.pan_front || consolidatedData.panFront,
        panBackUrl: consolidatedData.panBackUrl || consolidatedData.pan_back || consolidatedData.panBack
      };

      console.log("Final consolidated data for review:", finalData);
      setSelectedPartner(finalData);
    } catch (error) {
      console.error("Fetch error:", error);
      alert("Error fetching details: " + error.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading && !selectedPartner) return (
    <div className="login-container">
      <div className="glass-morphism" style={{ padding: '40px', borderRadius: '24px', textAlign: 'center' }}>
        <div className="logo-icon ripple" style={{ margin: '0 auto 20px' }}>E</div>
        <p>Syncing EcoSathi Data...</p>
      </div>
    </div>
  );

  if (!user) {
    return (
      <div className="login-container">
        <div className="login-card glass-morphism">
          <div className="logo-section" style={{ justifyContent: 'center', marginBottom: '40px' }}>
            <div className="logo-icon">E</div>
            <span className="logo-text">EcoSathi <span style={{ color: 'var(--primary)', fontStyle: 'italic', fontSize: '10px' }}>ADMIN</span></span>
          </div>
          <h2 style={{ textAlign: 'center', marginBottom: '32px' }}>Admin Login</h2>
          <form onSubmit={handleLogin}>
            <div className="input-group">
              <label>Email Address</label>
              <input type="email" name="email" placeholder="admin@ecosathi.com" required defaultValue="ecosathi.app.admin@gmail.com" />
            </div>
            <div className="input-group">
              <label>Password</label>
              <input type="password" name="password" placeholder="••••••••" required defaultValue="ecosathi.app.admin99@gmail.com" />
            </div>
            <button type="submit" className="btn-primary">Sign In</button>
          </form>
          <p style={{ marginTop: '24px', textAlign: 'center', fontSize: '12px', color: 'var(--text-secondary)' }}>
            Authorized access only. All actions are logged.
          </p>
        </div>
      </div>
    );
  }

  const renderDashboard = () => (
    <>
      <div className="stats-grid">
        <div className="card glass-morphism" onClick={() => setActiveTab('users')} style={{ cursor: 'pointer' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
            <div style={{ padding: '12px', background: 'rgba(16, 185, 129, 0.1)', borderRadius: '14px' }}><Users color="var(--primary)" /></div>
          </div>
          <h3 style={{ color: 'var(--text-secondary)', fontSize: '13px', marginBottom: '8px' }}>Total Platform Users</h3>
          <div style={{ fontSize: '28px', fontWeight: '800' }}>{stats.totalUsers}</div>
        </div>
        <div className="card glass-morphism" onClick={() => setActiveTab('partners')} style={{ cursor: 'pointer', border: stats.pendingVerifications > 0 ? '1px solid rgba(234, 179, 8, 0.5)' : '' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
            <div style={{ padding: '12px', background: 'rgba(59, 130, 246, 0.1)', borderRadius: '14px' }}><Handshake color="var(--accent)" /></div>
            {stats.pendingVerifications > 0 && <span className="badge badge-pending">{stats.pendingVerifications} Pending</span>}
          </div>
          <h3 style={{ color: 'var(--text-secondary)', fontSize: '13px', marginBottom: '8px' }}>Active Partners</h3>
          <div style={{ fontSize: '28px', fontWeight: '800' }}>{stats.activePartners}</div>
        </div>
        <div className="card glass-morphism" onClick={() => setActiveTab('orders')} style={{ cursor: 'pointer' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
            <div style={{ padding: '12px', background: 'rgba(234, 179, 8, 0.1)', borderRadius: '14px' }}><Package color="#EAB308" /></div>
          </div>
          <h3 style={{ color: 'var(--text-secondary)', fontSize: '13px', marginBottom: '8px' }}>Total Pickups</h3>
          <div style={{ fontSize: '28px', fontWeight: '800' }}>{stats.orders}</div>
        </div>
      </div>

      <div className="page-header">
        <h2 style={{ fontSize: '20px' }}>Recent Pending Approvals</h2>
      </div>

      <div className="table-wrapper glass-morphism">
        {pendingPartners.length === 0 ? (
          <div style={{ padding: '60px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <ShieldCheck size={48} style={{ marginBottom: '16px', opacity: 0.5 }} />
            <p>All partners are verified. No pending tasks.</p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Partner Name</th>
                <th>Phone</th>
                <th>Submission Time</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {pendingPartners.slice(0, 5).map((p) => (
                <tr key={p.id}>
                  <td style={{ fontWeight: '600' }}>{p.name}</td>
                  <td>{p.phone || 'N/A'}</td>
                  <td>{p.submittedAt?.toDate().toLocaleString() || 'Recent'}</td>
                  <td><span className="badge badge-pending">Review Required</span></td>
                  <td>
                    <button
                      onClick={() => openPartnerReview(p)}
                      className="btn-outline"
                      style={{ padding: '6px 12px', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '6px' }}
                    >
                      <Eye size={14} /> Review Documents
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );

  const renderUsers = () => (
    <div className="table-wrapper glass-morphism">
      <table>
        <thead>
          <tr>
            <th>User Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Role</th>
            <th>Join Date</th>
          </tr>
        </thead>
        <tbody>
          {allUsers.map((u) => (
            <tr key={u.id}>
              <td style={{ fontWeight: '600' }}>{u.name}</td>
              <td>{u.email}</td>
              <td>{u.phone || 'N/A'}</td>
              <td><span className={`badge ${u.role === 'admin' ? 'badge-active' : 'badge-completed'}`}>{u.role}</span></td>
              <td>{u.createdAt?.toDate().toLocaleDateString() || 'N/A'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  const renderPartners = () => {
    const activePartners = allPartners.filter(p => p.verificationStatus === 'verified');

    return (
      <div className="table-wrapper glass-morphism">
        {activePartners.length === 0 ? (
          <div style={{ padding: '60px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <Handshake size={48} style={{ marginBottom: '16px', opacity: 0.5 }} />
            <p>No active partners currently in the network.</p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Partner Name</th>
                <th>Location</th>
                <th>Earnings</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {activePartners.map((p) => (
                <tr key={p.id}>
                  <td style={{ fontWeight: '600' }}>{p.name}</td>
                  <td>{p.location ? `${p.location.latitude.toFixed(2)}, ${p.location.longitude.toFixed(2)}` : 'N/A'}</td>
                  <td style={{ color: 'var(--primary)', fontWeight: 'bold' }}>₹{p.totalEarnings?.toFixed(0) || 0}</td>
                  <td>{p.rating?.toFixed(1) || '5.0'} ⭐</td>
                  <td>
                    <span className="badge badge-completed">Verified</span>
                  </td>
                  <td>
                    <button
                      onClick={() => openPartnerReview(p)}
                      className="btn-outline"
                      style={{ padding: '6px 12px', fontSize: '12px' }}
                    >
                      View Profile
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    );
  };

  const renderVerifications = () => {
    const toVerify = allPartners.filter(p => p.verificationStatus === 'pending' || p.verificationStatus === 'rejected');

    return (
      <div className="table-wrapper glass-morphism">
        {toVerify.length === 0 ? (
          <div style={{ padding: '60px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <ShieldCheck size={48} style={{ marginBottom: '16px', opacity: 0.5 }} />
            <p>No pending verifications at the moment.</p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Partner Name</th>
                <th>Phone</th>
                <th>Status</th>
                <th>Submission</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {toVerify.map((p) => (
                <tr key={p.id}>
                  <td style={{ fontWeight: '600' }}>{p.name}</td>
                  <td>{p.phone || 'N/A'}</td>
                  <td>
                    <span className={`badge badge-${p.verificationStatus === 'pending' ? 'pending' : 'failed'}`}>
                      {p.verificationStatus === 'pending' ? 'Needs Review' : 'Rejected'}
                    </span>
                  </td>
                  <td style={{ fontSize: '12px' }}>{p.submittedAt?.toDate().toLocaleString() || 'N/A'}</td>
                  <td>
                    <button
                      onClick={() => openPartnerReview(p)}
                      className="btn-primary"
                      style={{ padding: '6px 12px', fontSize: '12px' }}
                    >
                      {p.verificationStatus === 'pending' ? 'Start Review' : 'Re-verify'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    );
  };

  const renderOrders = () => (
    <div className="table-wrapper glass-morphism">
      <table>
        <thead>
          <tr>
            <th>Pickup ID</th>
            <th>Material</th>
            <th>Weight</th>
            <th>Address</th>
            <th>Status</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {allPickups.map((o) => (
            <tr key={o.id}>
              <td style={{ fontWeight: '700', color: 'var(--accent)', fontSize: '12px' }}>#{o.id.slice(-6).toUpperCase()}</td>
              <td style={{ fontWeight: '600' }}>{o.plasticType}</td>
              <td>{o.estimatedWeight} kg</td>
              <td style={{ fontSize: '12px', maxWidth: '200px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{o.address}</td>
              <td>
                <span className={`badge badge-${o.status === 'completed' ? 'completed' : o.status === 'pending' ? 'pending' : 'active'}`}>
                  {o.status}
                </span>
              </td>
              <td style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>{o.scheduledTime?.toDate().toLocaleString() || 'N/A'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  return (
    <div className="app-container">
      {/* Sidebar */}
      <nav className="sidebar glass-morphism">
        <div className="logo-section">
          <div className="logo-icon">E</div>
          <span className="logo-text">EcoSathi <span style={{ color: 'var(--primary)', fontStyle: 'italic', fontSize: '10px' }}>ADMIN</span></span>
        </div>

        <ul className="nav-menu">
          <li className={`nav-item ${activeTab === 'dashboard' ? 'active' : ''}`} onClick={() => setActiveTab('dashboard')}>
            <LayoutDashboard size={20} /> Dashboard
          </li>
          <li className={`nav-item ${activeTab === 'users' ? 'active' : ''}`} onClick={() => setActiveTab('users')}>
            <Users size={20} /> Users
          </li>
          <li className={`nav-item ${activeTab === 'partners' ? 'active' : ''}`} onClick={() => setActiveTab('partners')}>
            <Handshake size={20} /> Partners
          </li>
          <li className={`nav-item ${activeTab === 'orders' ? 'active' : ''}`} onClick={() => setActiveTab('orders')}>
            <Package size={20} /> Orders
          </li>
          <li className={`nav-item ${activeTab === 'verifications' ? 'active' : ''}`} onClick={() => setActiveTab('verifications')}>
            <ShieldCheck size={20} /> Verifications {stats.pendingVerifications > 0 && <span style={{ marginLeft: 'auto', background: 'var(--primary)', color: 'white', padding: '2px 8px', borderRadius: '10px', fontSize: '10px' }}>{stats.pendingVerifications}</span>}
          </li>
        </ul>

        <div style={{ marginTop: 'auto', padding: '20px 12px', borderTop: '1px solid var(--glass-border)' }}>
          <div className="nav-item"><Settings size={20} /> Settings</div>
          <div className="nav-item" onClick={handleLogout} style={{ color: '#EF4444' }}><LogOut size={20} /> Logout</div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="main-content">
        <header className="page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h1 className="page-title">
              {activeTab === 'dashboard' ? 'Admin Overview' :
                activeTab === 'users' ? 'Platform Users' :
                  activeTab === 'partners' ? 'Partner Network' :
                    activeTab === 'orders' ? 'Pickup Requests' : 'Identity Verification'}
            </h1>
            <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
              <div className="glass-morphism" style={{ padding: '8px 16px', borderRadius: '40px', display: 'flex', gap: '12px', alignItems: 'center' }}>
                <Search size={18} color="var(--text-secondary)" />
                <input type="text" placeholder="Search..." style={{ background: 'none', border: 'none', color: 'white', outline: 'none' }} />
              </div>
              <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>AD</div>
            </div>
          </div>
        </header>

        {activeTab === 'dashboard' ? renderDashboard() :
          activeTab === 'users' ? renderUsers() :
            activeTab === 'partners' ? renderPartners() :
              activeTab === 'orders' ? renderOrders() :
                activeTab === 'verifications' ? renderVerifications() :
                  renderDashboard()}
      </main>

      {/* Manual Verification Modal */}
      {selectedPartner && (
        <div className="modal-overlay" onClick={() => setSelectedPartner(null)}>
          <div className="modal-content glass-morphism" onClick={e => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <h2 style={{ fontSize: '24px', marginBottom: '8px' }}>Manual Onboarding Review</h2>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '20px', color: 'var(--text-secondary)' }}>
                  <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><Users size={16} /> {selectedPartner.name}</span>
                  <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><Phone size={16} /> {selectedPartner.phone || 'N/A'}</span>
                  {selectedPartner.submittedAt && (
                    <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><Clock size={16} /> Submitted: {selectedPartner.submittedAt?.toDate().toLocaleString()}</span>
                  )}
                  <button
                    onClick={() => openPartnerReview(selectedPartner)}
                    className="btn-outline"
                    style={{ padding: '2px 8px', fontSize: '10px', marginLeft: '10px' }}
                  >
                    Sync Latest Data
                  </button>
                </div>
              </div>
              <button onClick={() => setSelectedPartner(null)} className="btn-outline" style={{ border: 'none' }}><XCircle /></button>
            </div>

            {selectedPartner.verificationStatus === 'verified' ? (
              <div style={{ marginTop: '32px', padding: '40px', textAlign: 'center', background: 'rgba(16, 185, 129, 0.05)', borderRadius: '24px' }}>
                <ShieldCheck size={48} color="var(--primary)" style={{ marginBottom: '16px' }} />
                <h3>This partner is already verified</h3>
                <p style={{ color: 'var(--text-secondary)', marginTop: '8px' }}>All identity documents have been approved.</p>
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 320px', gap: '32px', marginTop: '24px' }}>
                <div style={{ maxHeight: '70vh', overflowY: 'auto', paddingRight: '12px' }}>
                  <div className="doc-grid" style={{ margin: '0', gridTemplateColumns: 'repeat(2, 1fr)', gap: '20px' }}>
                    {[
                      { label: '1. SELFIE PHOTO', url: selectedPartner.selfieUrl },
                      { label: '2. AADHAR FRONT', url: selectedPartner.aadharFrontUrl },
                      { label: '3. AADHAR BACK', url: selectedPartner.aadharBackUrl },
                      { label: '4. PAN FRONT', url: selectedPartner.panFrontUrl },
                      { label: '5. PAN BACK', url: selectedPartner.panBackUrl }
                    ].map((docItem, index) => (
                      <div className="doc-card" key={index} style={{ background: 'rgba(255,255,255,0.02)', padding: '16px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
                        <label style={{ fontSize: '11px', fontWeight: 'bold', color: 'var(--primary)', textTransform: 'uppercase', letterSpacing: '1px' }}>{docItem.label}</label>
                        {docItem.url && docItem.url.length > 5 ? (
                          <div style={{ position: 'relative', marginTop: '12px', cursor: 'pointer', overflow: 'hidden', borderRadius: '12px' }} onClick={() => setPreviewImage(docItem.url)}>
                            <img src={docItem.url} alt={docItem.label} style={{ width: '100%', height: '180px', objectFit: 'cover', transition: '0.4s' }} className="zoom-img" />
                            <div style={{ position: 'absolute', inset: 0, background: 'rgba(16, 185, 129, 0.2)', opacity: 0, transition: '0.3s', display: 'flex', alignItems: 'center', justifyContent: 'center' }} className="img-hover-overlay">
                              <div style={{ padding: '10px', background: 'var(--primary)', borderRadius: '50%' }}><ZoomIn color="white" size={20} /></div>
                            </div>
                          </div>
                        ) : (
                          <div className="glass-morphism" style={{ height: '180px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', marginTop: '12px', color: 'var(--text-secondary)', gap: '10px' }}>
                            <AlertCircle size={32} opacity={0.3} />
                            <span style={{ fontSize: '12px' }}>Document Not Available</span>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                <div className="glass-morphism" style={{ padding: '24px', borderRadius: '24px', border: '1px solid var(--glass-border)' }}>
                  <h3 style={{ fontSize: '14px', marginBottom: '16px', color: 'var(--text-primary)' }}>Manual Checklist</h3>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    {[
                      { id: 'selfie', label: 'Selfie matches documents' },
                      { id: 'aadhar', label: 'Aadhar card is valid' },
                      { id: 'pan', label: 'PAN card details match' },
                      { id: 'clear', label: 'Photos are clear & readable' }
                    ].map(item => (
                      <label key={item.id} style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px', cursor: 'pointer' }}>
                        <input type="checkbox" style={{ accentColor: 'var(--primary)' }} defaultChecked={false} />
                        {item.label}
                      </label>
                    ))}
                  </div>

                  <div style={{ marginTop: '24px' }}>
                    <label style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Admin Review Notes</label>
                    <textarea
                      placeholder="Add manual review notes..."
                      style={{
                        width: '100%', marginTop: '8px', padding: '12px',
                        background: 'rgba(255,255,255,0.03)', border: '1px solid var(--glass-border)',
                        borderRadius: '12px', color: 'white', fontSize: '12px', height: '80px', outline: 'none'
                      }}
                    />
                  </div>

                  <div style={{ marginTop: '24px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    <button className="btn-primary btn-approve" onClick={() => updateVerificationStatus(selectedPartner.id, 'verified')}>
                      <CheckCircle size={16} style={{ marginRight: '8px' }} /> Accept Onboarding
                    </button>
                    <button className="btn-outline btn-reject" style={{ width: '100%' }} onClick={() => updateVerificationStatus(selectedPartner.id, 'rejected')}>
                      <XCircle size={16} style={{ marginRight: '8px' }} /> Reject Application
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Image Preview Modal */}
      {previewImage && (
        <div className="modal-overlay" style={{ zIndex: 2000, background: 'rgba(0,0,0,0.9)' }} onClick={() => setPreviewImage(null)}>
          <div style={{ position: 'relative', maxWidth: '90vw', maxHeight: '90vh', display: 'flex', flexDirection: 'column', alignItems: 'center' }} onClick={e => e.stopPropagation()}>
            <img src={previewImage} alt="Preview" style={{ maxWidth: '100%', maxHeight: '80vh', borderRadius: '12px', border: '2px solid var(--primary)' }} />
            <div style={{ marginTop: '20px', display: 'flex', gap: '20px' }}>
              <button onClick={() => window.open(previewImage, '_blank')} className="btn-primary" style={{ padding: '8px 24px' }}>Full Resolution</button>
              <button onClick={() => setPreviewImage(null)} className="btn-outline" style={{ padding: '8px 24px' }}>Close</button>
            </div>
          </div>
        </div>
      )}

      {/* Styles for hover effect */}
      <style>{`
        .doc-card div:hover .img-hover-overlay {
          opacity: 1 !important;
        }
        .doc-card div:hover .zoom-img {
          transform: scale(1.1);
        }
        .checklist-item:hover {
          color: var(--primary);
        }
        @keyframes ripple {
          0% { transform: scale(0.8); opacity: 0.5; }
          100% { transform: scale(1.2); opacity: 0; }
        }
        .ripple {
          position: relative;
        }
        .ripple::after {
          content: "";
          position: absolute;
          inset: -10px;
          border: 2px solid var(--primary);
          border-radius: 50%;
          animation: ripple 1.5s infinite;
        }
      `}</style>
    </div>
  );
};

export default App;
