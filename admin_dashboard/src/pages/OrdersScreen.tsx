import React, { useEffect, useState } from 'react';
import { RefreshCw, Filter, Eye } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IOrder } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { OrderDetailModal } from '../components/OrderDetailModal';

const FILTER_TABS = [
  'All',
  'Placed',
  'Pickup Assigned',
  'In Washing',
  'Quality Check',
  'Out for Delivery',
  'Delivered',
  'Cancelled'
];

const ALL_STATUSES = [
  'Placed',
  'Pickup Assigned',
  'Rider On the Way',
  'Pickup Completed',
  'Received at Store',
  'Inspection Started',
  'Cleaning Started',
  'Dry Cleaning Completed',
  'Ironing Started',
  'Quality Check',
  'Ready for Delivery',
  'Delivery Partner Assigned',
  'Out for Delivery',
  'Delivered',
  'Cancelled'
];

export const OrdersScreen: React.FC = () => {
  const [orders, setOrders] = useState<IOrder[]>([]);
  const [filteredOrders, setFilteredOrders] = useState<IOrder[]>([]);
  const [activeTab, setActiveTab] = useState('All');
  const [loading, setLoading] = useState(true);
  const [selectedOrder, setSelectedOrder] = useState<IOrder | null>(null);

  const fetchOrders = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const res = await AdminApiService.getOrders();
      if (res.success && Array.isArray(res.data)) {
        setOrders(res.data);
      }
    } catch (err) {
      console.error('Failed to fetch orders:', err);
    } finally {
      if (!silent) setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
    const interval = setInterval(() => {
      fetchOrders(true);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (activeTab === 'All') {
      setFilteredOrders(orders);
    } else {
      setFilteredOrders(
        orders.filter((o) => (o.status || '').toLowerCase().includes(activeTab.toLowerCase()))
      );
    }
  }, [activeTab, orders]);

  const handleQuickStatusChange = async (orderId: string, newStatus: string, e: React.ChangeEvent<HTMLSelectElement>) => {
    e.stopPropagation();
    try {
      await AdminApiService.updateOrderStatus(orderId, newStatus);
      fetchOrders();
    } catch (err) {
      console.error('Quick status update failed:', err);
    }
  };

  return (
    <div>
      {/* Title Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">Order Command Center</h1>
          <p className="text-muted">Manage active customer orders, update progress, and inspect instructions</p>
        </div>
        <button onClick={() => fetchOrders()} className="btn btn-outline">
          <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> Refresh Orders
        </button>
      </div>

      {/* Filter Tabs */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '12px', marginBottom: '20px' }}>
        {FILTER_TABS.map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            style={{
              padding: '8px 18px',
              borderRadius: 'var(--radius-pill)',
              fontSize: '13px',
              fontWeight: 700,
              whiteSpace: 'nowrap',
              backgroundColor: activeTab === tab ? 'var(--dark-navy)' : '#ffffff',
              color: activeTab === tab ? '#ffffff' : 'var(--text-primary)',
              border: '1px solid',
              borderColor: activeTab === tab ? 'var(--dark-navy)' : 'var(--border-light)',
              transition: 'all 0.15s ease',
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* Orders Table */}
      <div className="card" style={{ padding: 0 }}>
        <div className="table-container" style={{ border: 'none' }}>
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer Info</th>
                <th>Pickup Slot</th>
                <th>Items Count</th>
                <th>Total</th>
                <th>Status</th>
                <th>Quick Update</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.length > 0 ? (
                filteredOrders.map((order) => (
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
                    <td>
                      <div style={{ fontSize: '13px', fontWeight: 600 }}>{order.pickupDate}</div>
                      <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{order.pickupSlot}</div>
                    </td>
                    <td style={{ fontWeight: 700 }}>{(order.items || []).length} item(s)</td>
                    <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{order.grandTotal}</td>
                    <td><StatusBadge status={order.status} /></td>
                    <td onClick={(e) => e.stopPropagation()}>
                      <select
                        className="form-select"
                        style={{ padding: '4px 8px', fontSize: '12px', fontWeight: 700, height: 32, width: 140 }}
                        value={order.status || 'Placed'}
                        onChange={(e) => handleQuickStatusChange(order._id || order.id || order.orderId, e.target.value, e)}
                      >
                        {ALL_STATUSES.map((st) => (
                          <option key={st} value={st}>{st}</option>
                        ))}
                      </select>
                    </td>
                    <td>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedOrder(order);
                        }}
                        className="btn btn-outline"
                        style={{ padding: '6px 12px', fontSize: '12px' }}
                      >
                        <Eye size={14} /> View
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={8} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                    No orders found matching status tab "{activeTab}".
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detailed Modal */}
      {selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setSelectedOrder(null)}
          onStatusUpdated={fetchOrders}
        />
      )}
    </div>
  );
};
