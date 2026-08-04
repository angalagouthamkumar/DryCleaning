import React, { useEffect, useState } from 'react';
import { Users, Search, Phone, ShoppingBag, IndianRupee, Calendar } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { ICustomer, IOrder } from '../types';
import { OrderDetailModal } from '../components/OrderDetailModal';

export const CustomersScreen: React.FC = () => {
  const [customers, setCustomers] = useState<ICustomer[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [selectedCustomerOrders, setSelectedCustomerOrders] = useState<IOrder[] | null>(null);
  const [selectedCustomerName, setSelectedCustomerName] = useState<string>('');
  const [selectedOrder, setSelectedOrder] = useState<IOrder | null>(null);

  const fetchCustomers = async () => {
    setLoading(true);
    try {
      const res = await AdminApiService.getCustomers();
      if (res.success && Array.isArray(res.data)) {
        setCustomers(res.data);
      }
    } catch (err) {
      console.error('Failed to fetch customers:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  const handleCustomerClick = async (cust: ICustomer) => {
    setLoading(true);
    setSelectedCustomerName(cust.customerName);
    try {
      const res = await AdminApiService.getOrders({ phoneNumber: cust.customerPhone });
      if (res.success && Array.isArray(res.data)) {
        setSelectedCustomerOrders(res.data);
      }
    } catch (err) {
      console.error('Failed to fetch customer orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredCustomers = customers.filter((c) => {
    const q = searchQuery.toLowerCase();
    return (
      (c.customerName || '').toLowerCase().includes(q) ||
      (c.customerPhone || '').includes(q)
    );
  });

  return (
    <div>
      {/* Title Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">Customer Directory</h1>
          <p className="text-muted">Aggregated lifetime customer spend, order history, and contact details</p>
        </div>
      </div>

      {/* Search Input */}
      <div style={{ marginBottom: '20px', maxWidth: '400px', position: 'relative' }}>
        <Search size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
        <input
          type="text"
          className="form-input"
          style={{ paddingLeft: 42, borderRadius: 'var(--radius-pill)', backgroundColor: '#ffffff' }}
          placeholder="Filter customers by name or phone..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      {/* Customer Directory Table */}
      <div className="card" style={{ padding: 0 }}>
        <div className="table-container" style={{ border: 'none' }}>
          <table>
            <thead>
              <tr>
                <th>Customer Name</th>
                <th>Mobile Number</th>
                <th>Primary Delivery Address</th>
                <th>Total Orders</th>
                <th>Lifetime Spend (LTV)</th>
                <th>Last Order Date</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredCustomers.length > 0 ? (
                filteredCustomers.map((cust, idx) => (
                  <tr key={idx} onClick={() => handleCustomerClick(cust)} style={{ cursor: 'pointer' }}>
                    <td style={{ fontWeight: 800, color: 'var(--dark-navy)' }}>{cust.customerName}</td>
                    <td style={{ fontWeight: 600 }}>{cust.customerPhone}</td>
                    <td style={{ fontSize: '13px', color: 'var(--text-primary)', maxWidth: 280, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {cust.fullAddress}
                    </td>
                    <td style={{ fontWeight: 700 }}>{cust.totalOrders} order(s)</td>
                    <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{cust.totalSpent}</td>
                    <td style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                      {new Date(cust.lastOrderDate).toLocaleDateString()}
                    </td>
                    <td>
                      <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '12px' }}>
                        History
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                    No customers found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Customer Orders History Modal */}
      {selectedCustomerOrders && (
        <div className="modal-overlay" onClick={() => setSelectedCustomerOrders(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '850px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid var(--border-light)', paddingBottom: '14px' }}>
              <div>
                <h2 className="heading-lg">Order History for {selectedCustomerName}</h2>
                <p className="text-muted">All lifetime orders placed by this customer</p>
              </div>
              <button onClick={() => setSelectedCustomerOrders(null)} className="btn btn-outline">Close</button>
            </div>

            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Slot</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {selectedCustomerOrders.map((o) => (
                    <tr key={o._id || o.orderId}>
                      <td style={{ fontWeight: 800 }}>{o.orderId}</td>
                      <td>{new Date(o.createdAt).toLocaleDateString()}</td>
                      <td>{o.pickupSlot}</td>
                      <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{o.grandTotal}</td>
                      <td>{o.status}</td>
                      <td>
                        <button onClick={() => setSelectedOrder(o)} className="btn btn-primary" style={{ padding: '4px 10px', fontSize: '12px' }}>
                          View
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Individual Order Detail Modal */}
      {selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setSelectedOrder(null)}
          onStatusUpdated={fetchCustomers}
        />
      )}
    </div>
  );
};
