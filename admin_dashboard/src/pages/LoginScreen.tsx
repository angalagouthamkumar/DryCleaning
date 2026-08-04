import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shirt, Lock, Mail, AlertCircle, Loader2 } from 'lucide-react';
import { AdminApiService } from '../services/api';

export const LoginScreen: React.FC = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('admin@drycleaning.com');
  const [password, setPassword] = useState('admin123456');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!email || !password) {
      setError('Please enter both admin email and password');
      return;
    }

    setLoading(true);
    try {
      const res = await AdminApiService.login(email, password);
      if (res.success && res.data?.token) {
        localStorage.setItem('admin_token', res.data.token);
        localStorage.setItem('admin_user', JSON.stringify(res.data.user || { name: 'Admin Owner', email }));
        navigate('/');
      } else {
        setError(res.message || 'Login failed');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Invalid email or password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: 'var(--dark-navy)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
    }}>
      <div style={{
        backgroundColor: '#ffffff',
        borderRadius: 'var(--radius-lg)',
        boxShadow: 'var(--shadow-lg)',
        width: '100%',
        maxWidth: '440px',
        padding: '36px 32px',
      }}>
        {/* Logo & Header */}
        <div style={{ textAlign: 'center', marginBottom: '28px' }}>
          <div style={{
            width: 60,
            height: 60,
            borderRadius: '16px',
            backgroundColor: 'var(--primary-mint)',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px auto',
            boxShadow: '0 8px 20px rgba(78, 204, 163, 0.3)',
          }}>
            <Shirt size={34} />
          </div>
          <h1 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--dark-navy)' }}>Admin Dashboard Login</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: 4 }}>
            Dry Cleaning & Laundry Quick-Commerce
          </p>
        </div>

        {/* Error Alert */}
        {error && (
          <div style={{
            backgroundColor: 'var(--accent-coral-light)',
            border: '1px solid var(--accent-coral)',
            color: 'var(--accent-coral)',
            borderRadius: 'var(--radius-sm)',
            padding: '12px 14px',
            marginBottom: '20px',
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            fontSize: '13px',
            fontWeight: 600,
          }}>
            <AlertCircle size={18} />
            <span>{error}</span>
          </div>
        )}

        {/* Login Form */}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Admin Email Address</label>
            <div style={{ position: 'relative' }}>
              <Mail size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input
                type="email"
                className="form-input"
                style={{ paddingLeft: 42 }}
                placeholder="admin@drycleaning.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="form-group" style={{ marginBottom: '24px' }}>
            <label className="form-label">Password</label>
            <div style={{ position: 'relative' }}>
              <Lock size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input
                type="password"
                className="form-input"
                style={{ paddingLeft: 42 }}
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-navy"
            disabled={loading}
            style={{ width: '100%', height: '48px', fontSize: '15px', borderRadius: 'var(--radius-pill)' }}
          >
            {loading ? <Loader2 size={20} className="animate-spin" /> : 'SIGN IN TO DASHBOARD'}
          </button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '24px', fontSize: '12px', color: 'var(--text-muted)' }}>
          Default Credentials: <b>admin@drycleaning.com</b> / <b>admin123456</b>
        </div>
      </div>
    </div>
  );
};
