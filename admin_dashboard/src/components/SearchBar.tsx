import React, { useState } from 'react';
import { Search, Loader2 } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IOrder } from '../types';

interface SearchBarProps {
  onSelectOrder?: (order: IOrder) => void;
  onCustomerFound?: (phone: string, orders: IOrder[]) => void;
}

export const SearchBar: React.FC<SearchBarProps> = ({ onSelectOrder, onCustomerFound }) => {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<IOrder[] | null>(null);
  const [searchMode, setSearchMode] = useState<string | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setLoading(true);
    try {
      const res = await AdminApiService.searchOrders(query.trim());
      if (res.success) {
        setResults(res.data || []);
        setSearchMode(res.mode);
        if (res.mode === 'CUSTOMER_PHONE' && onCustomerFound) {
          onCustomerFound(query.trim(), res.data || []);
        } else if (res.mode === 'ORDER_ID' && res.data && res.data.length > 0 && onSelectOrder) {
          onSelectOrder(res.data[0]);
        }
      }
    } catch (err) {
      console.error('Search failed:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ position: 'relative', width: '100%', maxWidth: '480px' }}>
      <form onSubmit={handleSearch} style={{ display: 'flex', alignItems: 'center' }}>
        <div style={{ position: 'relative', width: '100%' }}>
          <Search size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            className="form-input"
            style={{
              paddingLeft: 42,
              paddingRight: 40,
              borderRadius: 'var(--radius-pill)',
              backgroundColor: '#ffffff',
              borderColor: 'var(--border-light)',
              boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
            }}
            placeholder="Search Order ID (ORD-...) or Mobile Number..."
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              if (!e.target.value) {
                setResults(null);
                setSearchMode(null);
              }
            }}
          />
          {loading && (
            <Loader2 size={18} className="animate-spin" style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--primary-mint)' }} />
          )}
        </div>
      </form>

      {/* Instant Search Results Dropdown */}
      {results && results.length > 0 && (
        <div style={{
          position: 'absolute',
          top: '110%',
          left: 0,
          right: 0,
          backgroundColor: '#ffffff',
          borderRadius: 'var(--radius-md)',
          boxShadow: 'var(--shadow-lg)',
          border: '1px solid var(--border-light)',
          zIndex: 900,
          maxHeight: '360px',
          overflowY: 'auto',
          padding: '8px 0',
        }}>
          <div style={{ padding: '8px 16px', fontSize: '11px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', borderBottom: '1px solid var(--border-light)' }}>
            Found {results.length} result(s) for "{query}"
          </div>
          {results.map((order) => (
            <div
              key={order._id || order.orderId}
              onClick={() => {
                if (onSelectOrder) onSelectOrder(order);
                setResults(null);
              }}
              style={{
                padding: '12px 16px',
                borderBottom: '1px solid #f0f0f0',
                cursor: 'pointer',
                transition: 'background 0.15s ease',
              }}
              onMouseEnter={(e) => e.currentTarget.style.backgroundColor = 'var(--primary-mint-light)'}
              onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontWeight: 700, color: 'var(--dark-navy)', fontSize: '14px' }}>{order.orderId}</span>
                <span style={{ fontSize: '12px', color: 'var(--primary-mint)', fontWeight: 700 }}>₹{order.grandTotal}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', color: 'var(--text-muted)', marginTop: 2 }}>
                <span>{order.customerName} ({order.customerPhone})</span>
                <span>{order.status}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
