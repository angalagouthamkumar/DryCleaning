import React from 'react';
import { SearchBar } from './SearchBar';
import { IOrder } from '../types';
import { Bell, User, Menu } from 'lucide-react';

interface NavbarProps {
  onSelectOrder?: (order: IOrder) => void;
  onCustomerFound?: (phone: string, orders: IOrder[]) => void;
  onToggleMobileMenu?: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onSelectOrder, onCustomerFound, onToggleMobileMenu }) => {
  const adminUserRaw = localStorage.getItem('admin_user');
  const adminUser = adminUserRaw ? JSON.parse(adminUserRaw) : { name: 'Admin Owner', email: 'admin@drycleaning.com' };

  return (
    <header
      className="navbar-header"
      style={{
        height: '72px',
        backgroundColor: '#ffffff',
        borderBottom: '1px solid var(--border-light)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 28px',
        position: 'sticky',
        top: 0,
        zIndex: 100,
        gap: '12px',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flex: 1 }}>
        {onToggleMobileMenu && (
          <button className="mobile-menu-btn" onClick={onToggleMobileMenu} style={{ color: 'var(--dark-navy)', padding: '6px' }}>
            <Menu size={24} />
          </button>
        )}
        {/* Universal Search Bar */}
        <div style={{ flex: 1, maxWidth: '400px' }}>
          <SearchBar onSelectOrder={onSelectOrder} onCustomerFound={onCustomerFound} />
        </div>
      </div>

      {/* Right Header Actions */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <button style={{
          width: 38,
          height: 38,
          borderRadius: '50%',
          backgroundColor: 'var(--card-fill)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'var(--dark-navy)',
          position: 'relative',
        }}>
          <Bell size={18} />
          <span style={{
            position: 'absolute',
            top: 7,
            right: 7,
            width: 7,
            height: 7,
            borderRadius: '50%',
            backgroundColor: 'var(--primary-mint)',
          }}></span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{
            width: 38,
            height: 38,
            borderRadius: '50%',
            backgroundColor: 'var(--primary-mint-light)',
            color: 'var(--primary-mint-dark)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 800,
          }}>
            <User size={18} />
          </div>
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--dark-navy)', lineHeight: 1.2 }}>{adminUser.name || 'Store Owner'}</div>
            <div className="user-email-text" style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{adminUser.email || 'admin@drycleaning.com'}</div>
          </div>
        </div>
      </div>
    </header>
  );
};
