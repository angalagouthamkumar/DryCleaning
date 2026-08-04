import { Request, Response } from 'express';
import { OrderModel } from '../models/orderModel';
import { OrderStore } from '../models/orderStore';

export const AdminController = {
  getAnalytics: async (req: Request, res: Response): Promise<void> => {
    try {
      let orders: any[] = [];
      try {
        orders = await OrderModel.find({}).lean();
      } catch (_) {
        orders = OrderStore.getAll();
      }

      const totalOrders = orders.length;

      // Filter today's orders (Asia/Kolkata or local day)
      const startOfToday = new Date();
      startOfToday.setHours(0, 0, 0, 0);

      const todayOrders = orders.filter(o => new Date(o.createdAt) >= startOfToday);
      const totalRevenue = orders.reduce((sum, o) => sum + (Number(o.grandTotal) || 0), 0);
      const todayRevenue = todayOrders.reduce((sum, o) => sum + (Number(o.grandTotal) || 0), 0);

      const activeOrders = orders.filter(o => {
        const s = (o.status || '').toLowerCase();
        return !s.includes('delivered') && !s.includes('cancel');
      }).length;

      const deliveredCount = orders.filter(o => (o.status || '').toLowerCase().includes('delivered')).length;
      const cancelledCount = orders.filter(o => (o.status || '').toLowerCase().includes('cancel')).length;

      // Service breakdown
      const serviceCounts: Record<string, number> = {};
      orders.forEach(o => {
        if (Array.isArray(o.services)) {
          o.services.forEach((s: string) => {
            serviceCounts[s] = (serviceCounts[s] || 0) + 1;
          });
        }
      });

      res.status(200).json({
        success: true,
        data: {
          totalOrders,
          todayOrdersCount: todayOrders.length,
          totalRevenue,
          todayRevenue,
          activeOrdersCount: activeOrders,
          deliveredCount,
          cancelledCount,
          serviceCounts,
        }
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  getCustomers: async (req: Request, res: Response): Promise<void> => {
    try {
      let orders: any[] = [];
      try {
        orders = await OrderModel.find({}).lean();
      } catch (_) {
        orders = OrderStore.getAll();
      }

      const customerMap: Record<string, {
        customerName: string;
        customerPhone: string;
        fullAddress: string;
        totalOrders: number;
        totalSpent: number;
        lastOrderDate: Date;
      }> = {};

      orders.forEach(o => {
        const rawPhone = o.customerPhone || 'Unknown';
        const cleanPhone = rawPhone.replace(/\D/g, '').slice(-10) || rawPhone;

        if (!customerMap[cleanPhone]) {
          customerMap[cleanPhone] = {
            customerName: o.customerName || 'Customer',
            customerPhone: rawPhone,
            fullAddress: o.fullAddress || '',
            totalOrders: 0,
            totalSpent: 0,
            lastOrderDate: new Date(o.createdAt),
          };
        }

        customerMap[cleanPhone].totalOrders += 1;
        customerMap[cleanPhone].totalSpent += Number(o.grandTotal) || 0;

        const orderDate = new Date(o.createdAt);
        if (orderDate > customerMap[cleanPhone].lastOrderDate) {
          customerMap[cleanPhone].lastOrderDate = orderDate;
          customerMap[cleanPhone].customerName = o.customerName || customerMap[cleanPhone].customerName;
          customerMap[cleanPhone].fullAddress = o.fullAddress || customerMap[cleanPhone].fullAddress;
        }
      });

      const customerList = Object.values(customerMap).sort((a, b) => b.lastOrderDate.getTime() - a.lastOrderDate.getTime());

      res.status(200).json({
        success: true,
        data: customerList
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  searchOrders: async (req: Request, res: Response): Promise<void> => {
    try {
      const { q } = req.query;
      const queryStr = typeof q === 'string' ? q.trim() : '';

      if (!queryStr) {
        res.status(400).json({ success: false, message: 'Search query string q is required' });
        return;
      }

      let orders: any[] = [];
      try {
        orders = await OrderModel.find({}).lean();
      } catch (_) {
        orders = OrderStore.getAll();
      }

      const upperQ = queryStr.toUpperCase();
      const cleanDigits = queryStr.replace(/\D/g, '');

      // 1. Exact or Partial Order ID Search
      const exactOrderIdMatches = orders.filter(o => (o.orderId || '').toUpperCase().includes(upperQ));
      if (exactOrderIdMatches.length > 0 && (upperQ.startsWith('ORD') || queryStr.length > 10)) {
        res.status(200).json({
          success: true,
          mode: 'ORDER_ID',
          data: exactOrderIdMatches
        });
        return;
      }

      // 2. Customer Phone Number Search
      if (cleanDigits.length >= 4) {
        const phoneMatches = orders.filter(o => {
          const p = (o.customerPhone || '').replace(/\D/g, '');
          return p.includes(cleanDigits);
        });

        res.status(200).json({
          success: true,
          mode: 'CUSTOMER_PHONE',
          data: phoneMatches
        });
        return;
      }

      // 3. Fallback: Search by Customer Name
      const nameMatches = orders.filter(o => (o.customerName || '').toLowerCase().includes(queryStr.toLowerCase()));

      res.status(200).json({
        success: true,
        mode: 'GENERAL',
        data: nameMatches
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  getPayments: async (req: Request, res: Response): Promise<void> => {
    try {
      let orders: any[] = [];
      try {
        orders = await OrderModel.find({}).lean();
      } catch (_) {
        orders = OrderStore.getAll();
      }

      let totalCollected = 0;
      let totalPending = 0;
      let onlineUpiTotal = 0;
      let codTotal = 0;

      const transactions = orders.map(o => {
        const isPaidOnline = (o.paymentMethod || '').toUpperCase().includes('UPI');
        const isDelivered = (o.status || '').toLowerCase().includes('delivered');
        const amount = Number(o.grandTotal) || 0;

        if (isPaidOnline || isDelivered) {
          totalCollected += amount;
        } else {
          totalPending += amount;
        }

        if (isPaidOnline) {
          onlineUpiTotal += amount;
        } else {
          codTotal += amount;
        }

        return {
          transactionId: `TXN_${o.orderId || Math.random().toString(36).substring(7)}`,
          orderId: o.orderId,
          customerName: o.customerName,
          customerPhone: o.customerPhone,
          amount,
          paymentMethod: isPaidOnline ? 'UPI / Online' : 'Cash on Delivery (COD)',
          paymentStatus: isPaidOnline || isDelivered ? 'COMPLETED' : 'PENDING COLLECTION',
          date: o.createdAt || new Date(),
        };
      });

      res.status(200).json({
        success: true,
        summary: {
          totalCollected,
          totalPending,
          onlineUpiTotal,
          codTotal,
          totalTransactions: transactions.length,
        },
        data: transactions,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }
};
