import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { Sidebar } from './components/Sidebar';
import { Navbar } from './components/Navbar';
import { LoginScreen } from './pages/LoginScreen';
import { DashboardScreen } from './pages/DashboardScreen';
import { OrdersScreen } from './pages/OrdersScreen';
import { RidersScreen } from './pages/RidersScreen';
import { CustomersScreen } from './pages/CustomersScreen';
import { PaymentsScreen } from './pages/PaymentsScreen';
import { ContentManagementScreen } from './pages/ContentManagementScreen';
import { SystemDownloadsScreen } from './pages/SystemDownloadsScreen';
import { OrderDetailModal } from './components/OrderDetailModal';
import { IOrder } from './types';

// Protected Route Guard
const ProtectedLayout: React.FC = () => {
  const token = localStorage.getItem('admin_token');
  const [selectedOrder, setSelectedOrder] = useState<IOrder | null>(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="app-container">
      <Sidebar isOpen={isMobileMenuOpen} onClose={() => setIsMobileMenuOpen(false)} />
      <div className="main-content">
        <Navbar
          onSelectOrder={(order) => setSelectedOrder(order)}
          onToggleMobileMenu={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        />
        <main className="page-wrapper">
          <Outlet />
        </main>
      </div>

      {/* Universal Search Modal Trigger */}
      {selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setSelectedOrder(null)}
        />
      )}
    </div>
  );
};

export const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginScreen />} />
        
        <Route path="/" element={<ProtectedLayout />}>
          <Route index element={<DashboardScreen />} />
          <Route path="orders" element={<OrdersScreen />} />
          <Route path="riders" element={<RidersScreen />} />
          <Route path="customers" element={<CustomersScreen />} />
          <Route path="payments" element={<PaymentsScreen />} />
          <Route path="content" element={<ContentManagementScreen />} />
          <Route path="downloads" element={<SystemDownloadsScreen />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
