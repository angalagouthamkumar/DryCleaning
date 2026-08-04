import React, { useEffect, useState } from 'react';
import { IndianRupee, ShoppingBag, Clock, CheckCircle2, TrendingUp, RefreshCw } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IAnalytics, IOrder } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { OrderDetailModal } from '../components/OrderDetailModal';

export const DashboardScreen: React.FC = () => {
  const [analytics, setAnalytics] = useState<IAnalytics | null>(null);
  const [recentOrders, setRecentOrders] = useState<IOrder[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedOrder, setSelectedOrder] = useState<IOrder | null>(null);

  const fetchData = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const [anaRes, orderRes] = await Promise.all([
        AdminApiService.getAnalytics(),
        AdminApiService.getOrders(),
      ]);
      if (anaRes.success) setAnalytics(anaRes.data);
      if (orderRes.success) setRecentOrders((orderRes.data || []).slice(0, 8));
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err);
    } finally {
      if (!silent) setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(() => {
      fetchData(true);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div>
      {/* Page Title & Refresh */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">Executive Overview</h1>
          <p className="text-muted">Real-time performance dashboard for your dry cleaning store</p>
        </div>
        <button onClick={() => fetchData()} className="btn btn-outline">
          <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> Refresh Data
        </button>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid-4" style={{ marginBottom: '28px' }}>
        <div className="card" style={{ borderLeft: '4px solid var(--primary-mint)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>TOTAL REVENUE</p>
              <h2 style={{ fontSize: '26px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
                ₹{analytics?.totalRevenue.toLocaleString() || '0'}
              </h2>
              <p style={{ fontSize: '12px', color: 'var(--primary-mint-dark)', fontWeight: 600, marginTop: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
                <TrendingUp size={14} /> Today: ₹{analytics?.todayRevenue.toLocaleString() || '0'}
              </p>
            </div>
            <div style={{ width: 44, height: 44, borderRadius: 12, backgroundColor: 'var(--primary-mint-light)', color: 'var(--primary-mint-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <IndianRupee size={22} />
            </div>
          </div>
        </div>

        <div className="card" style={{ borderLeft: '4px solid var(--accent-gold)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>TODAY'S ORDERS</p>
              <h2 style={{ fontSize: '26px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
                {analytics?.todayOrdersCount || 0}
              </h2>
              <p className="text-muted" style={{ fontSize: '12px', marginTop: 4 }}>
                Lifetime: {analytics?.totalOrders || 0} orders
              </p>
            </div>
            <div style={{ width: 44, height: 44, borderRadius: 12, backgroundColor: 'var(--accent-gold-light)', color: '#996e00', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ShoppingBag size={22} />
            </div>
          </div>
        </div>

        <div className="card" style={{ borderLeft: '4px solid var(--accent-orange)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>ACTIVE IN-PROGRESS</p>
              <h2 style={{ fontSize: '26px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
                {analytics?.activeOrdersCount || 0}
              </h2>
              <p style={{ fontSize: '12px', color: 'var(--accent-orange)', fontWeight: 600, marginTop: 4 }}>
                Needs pickup or cleaning
              </p>
            </div>
            <div style={{ width: 44, height: 44, borderRadius: 12, backgroundColor: 'var(--accent-orange-light)', color: 'var(--accent-orange)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Clock size={22} />
            </div>
          </div>
        </div>

        <div className="card" style={{ borderLeft: '4px solid var(--primary-mint)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <p className="text-muted" style={{ fontWeight: 700, fontSize: '12px' }}>DELIVERED ORDERS</p>
              <h2 style={{ fontSize: '26px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 4 }}>
                {analytics?.deliveredCount || 0}
              </h2>
              <p className="text-muted" style={{ fontSize: '12px', marginTop: 4 }}>
                Cancelled: {analytics?.cancelledCount || 0}
              </p>
            </div>
            <div style={{ width: 44, height: 44, borderRadius: 12, backgroundColor: 'var(--primary-mint-light)', color: 'var(--primary-mint-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <CheckCircle2 size={22} />
            </div>
          </div>
        </div>
      </div>

      {/* Main Content Layout: Live Feed + Category Demand */}
      <div className="grid-2">
        {/* Live Orders Feed */}
        <div className="card">
          <div className="card-header">
            <h3 className="heading-md">Live Customer Orders</h3>
            <span style={{ fontSize: '12px', fontWeight: 700, color: 'var(--primary-mint-dark)', backgroundColor: 'var(--primary-mint-light)', padding: '4px 10px', borderRadius: 20 }}>
              Live Ticker
            </span>
          </div>

          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Customer</th>
                  <th>Total</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {recentOrders.length > 0 ? (
                  recentOrders.map((order) => (
                    <tr
                      key={order._id || order.orderId}
                      onClick={() => setSelectedOrder(order)}
                      style={{ cursor: 'pointer' }}
                    >
                      <td style={{ fontWeight: 800, color: 'var(--dark-navy)' }}>{order.orderId}</td>
                      <td>
                        <div style={{ fontWeight: 700 }}>{order.customerName}</div>
                        <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{order.customerPhone}</div>
                      </td>
                      <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{order.grandTotal}</td>
                      <td><StatusBadge status={order.status} /></td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={4} style={{ textAlign: 'center', padding: '30px', color: 'var(--text-muted)' }}>
                      No orders placed yet.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Service Category Demand */}
        <div className="card">
          <div className="card-header">
            <h3 className="heading-md">Service Demand Breakdown</h3>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {analytics?.serviceCounts && Object.keys(analytics.serviceCounts).length > 0 ? (
              Object.entries(analytics.serviceCounts).map(([service, count]) => {
                const percentage = Math.min(100, Math.round((count / (analytics.totalOrders || 1)) * 100));
                return (
                  <div key={service}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px', fontWeight: 700, marginBottom: 6 }}>
                      <span>{service}</span>
                      <span style={{ color: 'var(--primary-mint-dark)' }}>{count} order(s) ({percentage}%)</span>
                    </div>
                    <div style={{ height: 10, width: '100%', backgroundColor: 'var(--card-fill)', borderRadius: 5, overflow: 'hidden' }}>
                      <div style={{ height: '100%', width: `${Math.max(5, percentage)}%`, backgroundColor: 'var(--primary-mint)', borderRadius: 5 }}></div>
                    </div>
                  </div>
                );
              })
            ) : (
              <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                No service analytics available yet.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Order Detail Modal */}
      {selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setSelectedOrder(null)}
          onStatusUpdated={fetchData}
        />
      )}
    </div>
  );
};
