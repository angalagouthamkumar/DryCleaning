import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, ShoppingBag, Users, CreditCard, LogOut, Shirt, X, Bike, FileText, Download } from 'lucide-react';

interface SidebarProps {
  isOpen?: boolean;
  onClose?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    if (onClose) onClose();
    navigate('/login');
  };

  const navItems = [
    { path: '/', label: 'Overview', icon: LayoutDashboard },
    { path: '/orders', label: 'Order Command', icon: ShoppingBag },
    { path: '/riders', label: 'Riders Fleet', icon: Bike },
    { path: '/customers', label: 'Customer Directory', icon: Users },
    { path: '/payments', label: 'Payment Ledger', icon: CreditCard },
    { path: '/content', label: 'Customer Content', icon: FileText },
    { path: '/downloads', label: 'System Downloads', icon: Download },
  ];

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && <div className="mobile-drawer-backdrop" onClick={onClose} />}

      <aside
        className={`app-sidebar ${isOpen ? 'open' : ''}`}
        style={{
          width: '260px',
          backgroundColor: 'var(--dark-navy)',
          color: '#ffffff',
          display: 'flex',
          flexDirection: 'column',
          padding: '24px 16px',
          borderRight: '1px solid rgba(255, 255, 255, 0.05)',
          flexShrink: 0,
        }}
      >
        {/* Brand Header & Mobile Close */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 8px 24px 8px', borderBottom: '1px solid rgba(255, 255, 255, 0.1)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: 40, height: 40, borderRadius: '12px', backgroundColor: 'var(--primary-mint)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#ffffff' }}>
              <Shirt size={22} />
            </div>
            <div>
              <h2 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', letterSpacing: '-0.3px' }}>Dry Cleaning</h2>
              <p style={{ fontSize: '11px', color: 'var(--primary-mint)', fontWeight: 600 }}>Web Admin Command</p>
            </div>
          </div>
          {onClose && (
            <button className="mobile-menu-btn" onClick={onClose} style={{ color: '#A0AEC0', padding: 4 }}>
              <X size={20} />
            </button>
          )}
        </div>

        {/* Navigation Menu */}
        <nav style={{ marginTop: '24px', flex: 1, display: 'flex', flexDirection: 'column', gap: '6px' }}>
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.path}
                to={item.path}
                end={item.path === '/'}
                onClick={() => {
                  if (onClose) onClose();
                }}
                style={({ isActive }) => ({
                  display: 'flex',
                  alignItems: 'center',
                  gap: '14px',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  fontSize: '14px',
                  fontWeight: isActive ? 700 : 500,
                  color: isActive ? '#ffffff' : '#A0AEC0',
                  backgroundColor: isActive ? 'rgba(78, 204, 163, 0.2)' : 'transparent',
                  borderLeft: isActive ? '4px solid var(--primary-mint)' : '4px solid transparent',
                  transition: 'all 0.2s ease',
                })}
              >
                {({ isActive }) => (
                  <>
                    <Icon size={20} color={isActive ? 'var(--primary-mint)' : '#A0AEC0'} />
                    <span>{item.label}</span>
                  </>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* Footer / Logout */}
        <div style={{ paddingTop: '16px', borderTop: '1px solid rgba(255, 255, 255, 0.1)' }}>
          <button
            onClick={handleLogout}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              width: '100%',
              padding: '12px 16px',
              borderRadius: '10px',
              color: '#FF6B6B',
              fontSize: '14px',
              fontWeight: 600,
            }}
          >
            <LogOut size={18} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>
    </>
  );
};
