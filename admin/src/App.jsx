import React, { useState } from 'react';
import './index.css';

const App = () => {
  const [activeTab, setActiveTab] = useState('dashboard');

  const stats = [
    { label: 'Total Users', value: '4,203', icon: '👤', color: '#10B981', diff: '+12%' },
    { label: 'Partners', value: '184', icon: '🤝', color: '#3B82F6', diff: '+4%' },
    { label: 'Total Orders', value: '28,491', icon: '📦', color: '#F59E0B', diff: '+18%' },
    { label: 'Revenue', value: '₹4,12,021', icon: '💰', color: '#EF4444', diff: '+9%' },
  ];

  const orders = [
    { id: '#ORD-9284', user: 'Amit Sharma', partner: 'Rajesh Kumar', status: 'completed', type: 'Plastic', weight: '12kg', date: '2 Mins Ago' },
    { id: '#ORD-9211', user: 'Priya Patel', partner: 'Sunil Singh', status: 'active', type: 'Cardboard', weight: '5.2kg', date: '12 Mins Ago' },
    { id: '#ORD-9104', user: 'Rahul Varma', partner: 'Unassigned', status: 'pending', type: 'Metal', weight: '22kg', date: '34 Mins Ago' },
    { id: '#ORD-8992', user: 'Sita Ram', partner: 'Karan Mehra', status: 'completed', type: 'Glass', weight: '8kg', date: '1 Hr Ago' },
    { id: '#ORD-8742', user: 'Vikram Joy', partner: 'Rajesh Kumar', status: 'active', type: 'Plastic', weight: '14.5kg', date: '2 Hr Ago' },
  ];

  const users = [
    { name: 'Amit Sharma', email: 'amit@gmail.com', phone: '+91 9876543210', joined: 'Oct 2025', status: 'active' },
    { name: 'Priya Patel', email: 'priya@outlook.com', phone: '+91 9123456789', joined: 'Nov 2025', status: 'active' },
    { name: 'Rahul Varma', email: 'rahul.v@dev.io', phone: '+91 8877665544', joined: 'Jan 2026', status: 'active' },
  ];

  const partners = [
    { name: 'Rajesh Kumar', area: 'HSR Layout', vehicle: 'KA 01 EK 1234', rating: '4.9 ⭐', status: 'active' },
    { name: 'Sunil Singh', area: 'Indiranagar', vehicle: 'KA 51 ML 5678', rating: '4.7 ⭐', status: 'active' },
    { name: 'Karan Mehra', area: 'Whitefield', vehicle: 'KA 03 GH 9012', rating: '4.5 ⭐', status: 'pending' },
  ];

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return (
          <>
            <div className="stats-grid">
              {stats.map((stat, i) => (
                <div key={i} className="card glass-morphism" style={{ animationDelay: `${i * 0.1}s` }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
                    <div style={{ padding: '12px', background: `${stat.color}15`, borderRadius: '14px', fontSize: '24px' }}>{stat.icon}</div>
                    <span style={{ color: '#10B981', fontSize: '12px', fontWeight: 'bold' }}>{stat.diff}</span>
                  </div>
                  <h3 style={{ color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '500', marginBottom: '8px' }}>{stat.label}</h3>
                  <div style={{ fontSize: '24px', fontWeight: '800' }}>{stat.value}</div>
                </div>
              ))}
            </div>

            <div className="page-header" style={{ animationDelay: '0.4s' }}>
              <h2 className="page-title" style={{ fontSize: '20px' }}>Recent Orders</h2>
            </div>

            <div className="table-wrapper glass-morphism" style={{ animationDelay: '0.5s' }}>
              <table>
                <thead>
                  <tr>
                    <th>Order ID</th>
                    <th>User</th>
                    <th>Partner</th>
                    <th>Type</th>
                    <th>Weight</th>
                    <th>Status</th>
                    <th>Timeline</th>
                  </tr>
                </thead>
                <tbody>
                  {orders.map((order, i) => (
                    <tr key={i}>
                      <td style={{ fontWeight: '700', color: 'var(--accent)' }}>{order.id}</td>
                      <td>{order.user}</td>
                      <td>{order.partner}</td>
                      <td>{order.type}</td>
                      <td>{order.weight}</td>
                      <td>
                        <span className={`badge badge-${order.status}`}>{order.status}</span>
                      </td>
                      <td style={{ color: 'var(--text-secondary)' }}>{order.date}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        );
      case 'users':
        return (
          <div className="table-wrapper glass-morphism">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Contact</th>
                  <th>Joined</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {users.map((u, i) => (
                  <tr key={i}>
                    <td style={{ fontWeight: '600' }}>{u.name}</td>
                    <td>
                      <div>{u.email}</div>
                      <div style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>{u.phone}</div>
                    </td>
                    <td>{u.joined}</td>
                    <td><span className="badge badge-completed">{u.status}</span></td>
                    <td><button style={{ background: 'none', border: 'none', color: 'var(--accent)', cursor: 'pointer' }}>Edit</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      case 'partners':
        return (
          <div className="table-wrapper glass-morphism">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Working Area</th>
                  <th>Vehicle</th>
                  <th>Rating</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {partners.map((p, i) => (
                  <tr key={i}>
                    <td style={{ fontWeight: '600' }}>{p.name}</td>
                    <td>{p.area}</td>
                    <td>{p.vehicle}</td>
                    <td>{p.rating}</td>
                    <td><span className={`badge badge-${p.status === 'active' ? 'completed' : 'pending'}`}>{p.status}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      case 'orders':
        return (
          <div className="table-wrapper glass-morphism">
            <table>
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Type</th>
                  <th>Weight</th>
                  <th>Partner</th>
                  <th>Status</th>
                  <th>Timeline</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order, i) => (
                  <tr key={i}>
                    <td style={{ fontWeight: '700', color: 'var(--accent)' }}>{order.id}</td>
                    <td>{order.type}</td>
                    <td>{order.weight}</td>
                    <td>{order.partner}</td>
                    <td>
                      <select style={{ background: 'rgba(255,255,255,0.05)', color: 'white', border: 'none', padding: '4px', borderRadius: '4px' }} defaultValue={order.status}>
                        <option value="pending">Pending</option>
                        <option value="active">Assigned</option>
                        <option value="completed">Completed</option>
                      </select>
                    </td>
                    <td>{order.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      default:
        return null;
    }
  };

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
            <span>📊</span> Dashboard
          </li>
          <li className={`nav-item ${activeTab === 'users' ? 'active' : ''}`} onClick={() => setActiveTab('users')}>
            <span>👤</span> User Management
          </li>
          <li className={`nav-item ${activeTab === 'partners' ? 'active' : ''}`} onClick={() => setActiveTab('partners')}>
            <span>🤝</span> Partner Portal
          </li>
          <li className={`nav-item ${activeTab === 'orders' ? 'active' : ''}`} onClick={() => setActiveTab('orders')}>
            <span>📦</span> Order Tracker
          </li>
        </ul>

        <div style={{ marginTop: 'auto', padding: '20px 12px', borderTop: '1px solid var(--glass-border)' }}>
          <div className="nav-item">
            <span>⚙️</span> Settings
          </div>
          <div className="nav-item" style={{ color: '#EF4444' }}>
            <span>🚪</span> Logout
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="main-content">
        <header className="page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h1 className="page-title">
              {activeTab === 'dashboard' ? 'Admin Overview' :
                activeTab === 'users' ? 'Registered Users' :
                  activeTab === 'partners' ? 'Active Partners' : 'Manage Orders'}
            </h1>
            <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
              <div className="glass-morphism" style={{ padding: '10px 20px', borderRadius: '40px', display: 'flex', gap: '12px' }}>
                <input type="text" placeholder="Search anything..." style={{ background: 'none', border: 'none', color: 'white', outline: 'none', width: '180px' }} />
                <span>🔍</span>
              </div>
              <div style={{ width: '42px', height: '42px', borderRadius: '50%', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>AD</div>
            </div>
          </div>
        </header>

        {renderContent()}
      </main>
    </div>
  );
};

export default App;
