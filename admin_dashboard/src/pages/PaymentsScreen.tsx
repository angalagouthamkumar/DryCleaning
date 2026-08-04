import React, { useEffect, useState } from 'react';
import { CreditCard, CheckCircle, RefreshCw } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IOrder } from '../types';

export const PaymentsScreen: React.FC = () => {
  const [transactions, setTransactions] = useState<any[]>([]);
  const [summary, setSummary] = useState({
    totalCollected: 0,
    totalPending: 0,
    onlineUpiTotal: 0,
    codTotal: 0,
  });
  const [loading, setLoading] = useState(true);

  const fetchPayments = async () => {
    setLoading(true);
    try {
      const res = await AdminApiService.getPayments();
      if (res.success) {
        setTransactions(res.data || []);
        if (res.summary) {
          setSummary(res.summary);
        }
      }
    } catch (err) {
      console.error('Failed to fetch payments:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, []);

  return (
    <div>
      {/* Title Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">Payment Ledger & Gateway Log</h1>
          <p className="text-muted">SemPay UPI Intent transaction log, VPA verification, and Cash on Delivery summary</p>
        </div>
        <button onClick={fetchPayments} className="btn btn-outline">
          <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> Refresh Ledger
        </button>
      </div>

      {/* Summary Cards */}
      <div className="grid-2" style={{ marginBottom: '24px' }}>
        <div className="card" style={{ borderLeft: '4px solid var(--primary-mint)' }}>
          <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>SEMPAY UPI INTENT REVENUE</p>
          <h2 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
            ₹{summary.onlineUpiTotal.toLocaleString()}
          </h2>
          <p style={{ fontSize: '12px', color: 'var(--primary-mint-dark)', fontWeight: 600, marginTop: 4 }}>
            VPA Gateway Target: angala@fam
          </p>
        </div>

        <div className="card" style={{ borderLeft: '4px solid var(--dark-navy)' }}>
          <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>CASH ON DELIVERY (COD)</p>
          <h2 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
            ₹{summary.codTotal.toLocaleString()}
          </h2>
          <p className="text-muted" style={{ fontSize: '12px', marginTop: 4 }}>
            Collected upon garment delivery
          </p>
        </div>
      </div>

      {/* Payment Ledger Table */}
      <div className="card" style={{ padding: 0 }}>
        <div className="table-container" style={{ border: 'none' }}>
          <table>
            <thead>
              <tr>
                <th>Transaction ID</th>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Payment Method</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Verification Status</th>
              </tr>
            </thead>
            <tbody>
              {transactions.length > 0 ? (
                transactions.map((t) => {
                  const isCompleted = t.paymentStatus === 'COMPLETED';
                  return (
                    <tr key={t.transactionId}>
                      <td style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)' }}>{t.transactionId}</td>
                      <td style={{ fontWeight: 800, color: 'var(--dark-navy)' }}>{t.orderId}</td>
                      <td>
                        <div style={{ fontWeight: 700 }}>{t.customerName}</div>
                        <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t.customerPhone}</div>
                      </td>
                      <td style={{ fontWeight: 700, color: t.paymentMethod.includes('UPI') ? 'var(--primary-mint-dark)' : 'var(--dark-navy)' }}>
                        {t.paymentMethod}
                      </td>
                      <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{t.amount}</td>
                      <td style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                        {new Date(t.date).toLocaleString()}
                      </td>
                      <td>
                        <span className={`badge ${isCompleted ? 'badge-success' : 'badge-warning'}`}>
                          {isCompleted ? <CheckCircle size={12} /> : null} {t.paymentStatus}
                        </span>
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={7} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                    No payment logs recorded yet.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
