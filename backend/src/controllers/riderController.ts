import { Request, Response } from 'express';
import { OrderModel } from '../models/orderModel';
import { OrderStore } from '../models/orderStore';
import { WhatsAppService } from '../services/whatsappService';
import { NotificationService } from '../services/notificationService';

const STORE_LOCATION = {
  latitude: 17.4482,
  longitude: 78.3811
};

export const RiderController = {
  getRiderTasks: async (req: Request, res: Response): Promise<void> => {
    try {
      let orders: any[] = [];
      try {
        orders = await OrderModel.find({}).lean();
      } catch (_) {}

      if (!orders || orders.length === 0) {
        orders = OrderStore.getAll();
      }

      const activeTasks = orders.filter(o => {
        const status = (o.status || '').toLowerCase();
        return !status.includes('delivered') && !status.includes('cancel');
      });

      res.status(200).json({
        success: true,
        storeLocation: STORE_LOCATION,
        data: activeTasks
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  acceptTask: async (req: Request, res: Response): Promise<void> => {
    try {
      const idStr = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { flowType, riderId, riderName } = req.body;

      const newStatus = flowType === 'delivery' ? 'Delivery Partner Assigned' : 'Pickup Assigned';
      const assignedRiderId = riderId || (req as any).user?.userId || 'RIDER_101';
      const assignedRiderName = riderName || (req as any).user?.name || 'Rider Partner #101';

      const updateData = {
        status: newStatus,
        assignedRiderId,
        assignedRiderName,
      };

      let updatedOrder: any = null;
      try {
        updatedOrder = await OrderModel.findOneAndUpdate({ orderId: idStr }, updateData, { new: true });
        if (!updatedOrder) {
          updatedOrder = await OrderModel.findByIdAndUpdate(idStr, updateData, { new: true });
        }
      } catch (_) {}

      if (!updatedOrder) {
        updatedOrder = OrderStore.updateStatus(idStr, newStatus as any);
      }

      if (updatedOrder) {
        try {
          await NotificationService.sendOrderStatusNotification(updatedOrder.fcmToken, updatedOrder, newStatus);
        } catch (_) {}
      }

      res.status(200).json({
        success: true,
        message: `Task accepted as ${newStatus}`,
        data: updatedOrder
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  updateTaskStep: async (req: Request, res: Response): Promise<void> => {
    try {
      const idStr = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { status } = req.body;

      if (!status) {
        res.status(400).json({ success: false, message: 'Status is required' });
        return;
      }

      let updatedOrder: any = null;
      try {
        updatedOrder = await OrderModel.findOneAndUpdate({ orderId: idStr }, { status }, { new: true });
        if (!updatedOrder) {
          updatedOrder = await OrderModel.findByIdAndUpdate(idStr, { status }, { new: true });
        }
      } catch (_) {}

      if (!updatedOrder) {
        updatedOrder = OrderStore.updateStatus(idStr, status as any);
      }

      if (updatedOrder) {
        try {
          await WhatsAppService.sendOrderStatusUpdateNotification('918341726226', updatedOrder, status);
          await NotificationService.sendOrderStatusNotification(updatedOrder.fcmToken, updatedOrder, status);
        } catch (_) {}
      }

      res.status(200).json({
        success: true,
        message: `Task step updated to ${status}`,
        data: updatedOrder
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }
};
