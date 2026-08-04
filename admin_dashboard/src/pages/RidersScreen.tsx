import React, { useEffect, useState } from 'react';
import { Bike, Search, CheckCircle, XCircle, Star, IndianRupee, ShieldAlert, UserCheck, RefreshCw, Send, DollarSign } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IRider, IOrder } from '../types';

export const RidersScreen: React.FC = () => {
  const [riders, setRiders] = useState<IRider[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterTab, setFilterTab] = useState<'ALL' | 'ONLINE' | 'ACTIVE' | 'PENDING'>('ALL');
  const [loading, setLoading] = useState(true);

  const [selectedRiderForPayout, setSelectedRiderForPayout] = useState<IRider | null>(null);
  const [payoutAmount, setPayoutAmount] = useState<number>(0);
  const [isProcessingPayout, setIsProcessingPayout] = useState(false);

  const [selectedRiderForAssign, setSelectedRiderForAssign] = useState<IRider | null>(null);
  const [unassignedOrders, setUnassignedOrders] = useState<IOrder[]>([]);
  const [selectedOrderIdToAssign, setSelectedOrderIdToAssign] = useState<string>('');
  const [isAssigning, setIsAssigning] = useState(false);

  const fetchRiders = async (showLoading = false) => {
    if (showLoading) setLoading(true);
    try {
      const res = await AdminApiService.getRiders();
      if (res.success && Array.isArray(res.data)) {
        setRiders(res.data);
      }
    } catch (err) {
      console.error('Failed to fetch riders:', err);
    } finally {
      if (showLoading) setLoading(false);
    }
  };

  const fetchUnassignedOrders = async () => {
    try {
      const res = await AdminApiService.getOrders();
      if (res.success && Array.isArray(res.data)) {
        const unassigned = res.data.filter(
          (o: IOrder) =>
            !o.status.toLowerCase().includes('delivered') &&
            !o.status.toLowerCase().includes('cancel')
        );
        setUnassignedOrders(unassigned);
        if (unassigned.length > 0) {
          setSelectedOrderIdToAssign(unassigned[0].orderId || unassigned[0]._id || '');
        }
      }
    } catch (err) {
      console.error('Failed to fetch unassigned orders:', err);
    }
  };

  useEffect(() => {
    fetchRiders(true);
    const interval = setInterval(() => {
      fetchRiders(false);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleToggleStatus = async (rider: IRider, newStatus: 'Approved' | 'Suspended') => {
    try {
      const res = await AdminApiService.updateRiderStatus(rider.riderId || rider._id || '', newStatus);
      if (res.success) {
        fetchRiders();
      }
    } catch (err) {
      alert('Failed to update rider status');
    }
  };

  const handleToggleDuty = async (rider: IRider) => {
    try {
      const res = await AdminApiService.updateRiderStatus(rider.riderId || rider._id || '', undefined, !rider.isOnDuty);
      if (res.success) {
        fetchRiders();
      }
    } catch (err) {
      alert('Failed to toggle rider duty status');
    }
  };

  const handleOpenAssignModal = (rider: IRider) => {
    setSelectedRiderForAssign(rider);
    fetchUnassignedOrders();
  };

  const handleConfirmAssign = async () => {
    if (!selectedRiderForAssign || !selectedOrderIdToAssign) return;
    setIsAssigning(true);
    try {
      const res = await AdminApiService.assignOrderToRider(
        selectedRiderForAssign.riderId || selectedRiderForAssign._id || '',
        selectedOrderIdToAssign
      );
      if (res.success) {
        alert(res.message);
        setSelectedRiderForAssign(null);
        fetchRiders();
      }
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to assign order');
    } finally {
      setIsAssigning(false);
    }
  };

  const handleOpenPayoutModal = (rider: IRider) => {
    setSelectedRiderForPayout(rider);
    setPayoutAmount(rider.pendingPayout || 0);
  };

  const handleConfirmPayout = async () => {
    if (!selectedRiderForPayout || payoutAmount <= 0) return;
    setIsProcessingPayout(true);
    try {
      const res = await AdminApiService.processRiderPayout(
        selectedRiderForPayout.riderId || selectedRiderForPayout._id || '',
        payoutAmount
      );
      if (res.success) {
        alert(res.message);
        setSelectedRiderForPayout(null);
        fetchRiders();
      }
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to process payout');
    } finally {
      setIsProcessingPayout(false);
    }
  };

  const filteredRiders = riders.filter((r) => {
    const q = searchQuery.toLowerCase();
    const matchesSearch =
      (r.name || '').toLowerCase().includes(q) ||
      (r.phone || '').includes(q) ||
      (r.riderId || '').toLowerCase().includes(q);

    if (!matchesSearch) return false;
    if (filterTab === 'ONLINE') return r.isOnDuty;
    if (filterTab === 'ACTIVE') return (r.activeOrdersCount || 0) > 0;
    if (filterTab === 'PENDING') return r.status === 'Pending';

    return true;
  });

  const onlineCount = riders.filter((r) => r.isOnDuty).length;
  const activeDeliveriesCount = riders.reduce((acc, r) => acc + (r.activeOrdersCount || 0), 0);
  const pendingApprovalsCount = riders.filter((r) => r.status === 'Pending').length;

  return (
    <div>
      {/* Title Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">Rider Management & Operations</h1>
          <p className="text-muted">Manage rider accounts, duty status, order dispatching, ratings, and payouts</p>
        </div>
        <button onClick={() => fetchRiders(true)} className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <RefreshCw size={16} /> Refresh Metrics
        </button>
      </div>

      {/* Metric KPI Cards */}
      <div className="metrics-grid" style={{ marginBottom: '24px' }}>
        <div className="metric-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span className="text-muted" style={{ fontSize: '13px', fontWeight: 600 }}>Total Fleet Riders</span>
            <Bike size={20} color="var(--primary-mint-dark)" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: 900, marginTop: '8px', color: 'var(--dark-navy)' }}>
            {riders.length}
          </div>
        </div>

        <div className="metric-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span className="text-muted" style={{ fontSize: '13px', fontWeight: 600 }}>Online On-Duty</span>
            <UserCheck size={20} color="#10B981" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: 900, marginTop: '8px', color: '#10B981' }}>
            {onlineCount}
          </div>
        </div>

        <div className="metric-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span className="text-muted" style={{ fontSize: '13px', fontWeight: 600 }}>Active Deliveries</span>
            <Send size={20} color="#3B82F6" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: 900, marginTop: '8px', color: '#3B82F6' }}>
            {activeDeliveriesCount}
          </div>
        </div>

        <div className="metric-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span className="text-muted" style={{ fontSize: '13px', fontWeight: 600 }}>Pending Approvals</span>
            <ShieldAlert size={20} color="#F59E0B" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: 900, marginTop: '8px', color: '#F59E0B' }}>
            {pendingApprovalsCount}
          </div>
        </div>
      </div>

      {/* Filter Tabs & Search Bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: 16 }}>
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            className={`btn ${filterTab === 'ALL' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterTab('ALL')}
            style={{ borderRadius: 'var(--radius-pill)', padding: '6px 16px', fontSize: '13px' }}
          >
            All Riders ({riders.length})
          </button>
          <button
            className={`btn ${filterTab === 'ONLINE' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterTab('ONLINE')}
            style={{ borderRadius: 'var(--radius-pill)', padding: '6px 16px', fontSize: '13px' }}
          >
            Online Now ({onlineCount})
          </button>
          <button
            className={`btn ${filterTab === 'ACTIVE' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterTab('ACTIVE')}
            style={{ borderRadius: 'var(--radius-pill)', padding: '6px 16px', fontSize: '13px' }}
          >
            Active Deliveries ({activeDeliveriesCount})
          </button>
          <button
            className={`btn ${filterTab === 'PENDING' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterTab('PENDING')}
            style={{ borderRadius: 'var(--radius-pill)', padding: '6px 16px', fontSize: '13px' }}
          >
            Pending ({pendingApprovalsCount})
          </button>
        </div>

        <div style={{ minWidth: '280px', position: 'relative' }}>
          <Search size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            className="form-input"
            style={{ paddingLeft: 42, borderRadius: 'var(--radius-pill)', backgroundColor: '#ffffff' }}
            placeholder="Search rider by name or phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* Riders Table */}
      <div className="card" style={{ padding: 0 }}>
        <div className="table-container" style={{ border: 'none' }}>
          <table>
            <thead>
              <tr>
                <th>Rider Partner</th>
                <th>Mobile Number</th>
                <th>Duty</th>
                <th>Status</th>
                <th>Completed Deliveries</th>
                <th>Total Earnings</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredRiders.length > 0 ? (
                filteredRiders.map((r, idx) => (
                  <tr key={idx}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <img
                          src={r.photoUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'}
                          alt={r.name}
                          style={{ width: 38, height: 38, borderRadius: '50%', objectFit: 'cover' }}
                        />
                        <div>
                          <div style={{ fontWeight: 800, color: 'var(--dark-navy)' }}>{r.name}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>ID: {r.riderId}</div>
                        </div>
                      </div>
                    </td>
                    <td style={{ fontWeight: 600 }}>{r.phone}</td>
                    <td>
                      <button
                        onClick={() => handleToggleDuty(r)}
                        className={`badge ${r.isOnDuty ? 'badge-success' : 'badge-neutral'}`}
                        style={{ border: 'none', cursor: 'pointer' }}
                      >
                        {r.isOnDuty ? 'ONLINE' : 'OFFLINE'}
                      </button>
                    </td>
                    <td>
                      <span className={`badge ${r.status === 'Approved' ? 'badge-success' : r.status === 'Pending' ? 'badge-warning' : 'badge-danger'}`}>
                        {r.status || 'Approved'}
                      </span>
                    </td>
                    <td style={{ fontWeight: 700 }}>{r.totalCompletedDeliveries || 0} orders</td>
                    <td style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>
                      ₹{r.totalEarnings || 0}
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button
                          onClick={() => handleOpenAssignModal(r)}
                          className="btn btn-outline"
                          style={{ padding: '4px 8px', fontSize: '12px' }}
                          title="Assign Order"
                        >
                          Assign
                        </button>
                        <button
                          onClick={() => handleOpenPayoutModal(r)}
                          className="btn btn-primary"
                          style={{ padding: '4px 8px', fontSize: '12px' }}
                          title="Process Payout"
                        >
                          Payout
                        </button>
                        {r.status === 'Approved' ? (
                          <button
                            onClick={() => handleToggleStatus(r, 'Suspended')}
                            className="btn btn-outline"
                            style={{ padding: '4px 8px', fontSize: '12px', color: 'red', borderColor: '#FCA5A5' }}
                          >
                            Suspend
                          </button>
                        ) : (
                          <button
                            onClick={() => handleToggleStatus(r, 'Approved')}
                            className="btn btn-outline"
                            style={{ padding: '4px 8px', fontSize: '12px', color: 'green', borderColor: '#6EE7B7' }}
                          >
                            Approve
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                    No riders found matching your search.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Assign Order Modal */}
      {selectedRiderForAssign && (
        <div className="modal-overlay" onClick={() => setSelectedRiderForAssign(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '500px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2 className="heading-lg">Assign Order to {selectedRiderForAssign.name}</h2>
              <button onClick={() => setSelectedRiderForAssign(null)} className="btn btn-outline">Close</button>
            </div>

            {unassignedOrders.length > 0 ? (
              <div>
                <label className="form-label">Select Active Order to Dispatch:</label>
                <select
                  className="form-input"
                  style={{ marginBottom: '20px' }}
                  value={selectedOrderIdToAssign}
                  onChange={(e) => setSelectedOrderIdToAssign(e.target.value)}
                >
                  {unassignedOrders.map((o) => (
                    <option key={o._id || o.orderId} value={o.orderId || o._id}>
                      Order #{o.orderId} — {o.customerName} (₹{o.grandTotal}) — {o.status}
                    </option>
                  ))}
                </select>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10 }}>
                  <button onClick={() => setSelectedRiderForAssign(null)} className="btn btn-outline">Cancel</button>
                  <button onClick={handleConfirmAssign} disabled={isAssigning} className="btn btn-primary">
                    {isAssigning ? 'Assigning...' : 'Dispatch Order to Rider'}
                  </button>
                </div>
              </div>
            ) : (
              <p className="text-muted">No unassigned active orders available to dispatch.</p>
            )}
          </div>
        </div>
      )}

      {/* Payout Modal */}
      {selectedRiderForPayout && (
        <div className="modal-overlay" onClick={() => setSelectedRiderForPayout(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '450px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2 className="heading-lg">Release Weekly Payout</h2>
              <button onClick={() => setSelectedRiderForPayout(null)} className="btn btn-outline">Close</button>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <div style={{ fontWeight: 800, color: 'var(--dark-navy)', fontSize: '16px' }}>{selectedRiderForPayout.name}</div>
              <div className="text-muted" style={{ fontSize: '13px' }}>ID: {selectedRiderForPayout.riderId} • Phone: {selectedRiderForPayout.phone}</div>
            </div>

            <div style={{ backgroundColor: 'var(--bg-light)', padding: '16px', borderRadius: '12px', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
                <span className="text-muted">Total Lifetime Earnings:</span>
                <span style={{ fontWeight: 800 }}>₹{selectedRiderForPayout.totalEarnings || 0}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span className="text-muted">Pending Payout Balance:</span>
                <span style={{ fontWeight: 800, color: 'var(--primary-mint-dark)' }}>₹{selectedRiderForPayout.pendingPayout || 0}</span>
              </div>
            </div>

            <div style={{ marginBottom: '20px' }}>
              <label className="form-label">Payout Release Amount (₹):</label>
              <input
                type="number"
                className="form-input"
                value={payoutAmount}
                onChange={(e) => setPayoutAmount(Number(e.target.value))}
              />
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10 }}>
              <button onClick={() => setSelectedRiderForPayout(null)} className="btn btn-outline">Cancel</button>
              <button onClick={handleConfirmPayout} disabled={isProcessingPayout} className="btn btn-primary">
                {isProcessingPayout ? 'Processing...' : 'Confirm & Release Payout'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
