import admin from 'firebase-admin';
import { NotificationModel } from '../models/notificationModel';

// Map all 15 Order Progress Stages to FCM Push Notifications
const STAGE_NOTIFICATIONS: Record<string, { title: string; bodyTemplate: (orderId: string) => string }> = {
  'placed': {
    title: 'Order Confirmed',
    bodyTemplate: (id) => `Order ${id} has been placed successfully. We will assign a pickup rider shortly.`,
  },
  'pickup assigned': {
    title: 'Pickup Partner Assigned',
    bodyTemplate: (id) => `Rider assigned for your Order ${id} garment pickup.`,
  },
  'on the way': {
    title: 'Rider On The Way',
    bodyTemplate: (id) => `Rider is heading to your location for Order ${id} pickup.`,
  },
  'pickup completed': {
    title: 'Clothes Picked Up',
    bodyTemplate: (id) => `Garments for Order ${id} picked up and heading to store.`,
  },
  'received at store': {
    title: 'Garments Received at Hub',
    bodyTemplate: (id) => `Garments for Order ${id} arrived at our central cleaning hub.`,
  },
  'sorting': {
    title: 'Garment Sorting & Inspection',
    bodyTemplate: (id) => `Order ${id} garments are being sorted and inspected for stain treatment.`,
  },
  'washing': {
    title: 'Cleaning In Progress',
    bodyTemplate: (id) => `Order ${id} garments are undergoing eco-friendly washing process.`,
  },
  'drying': {
    title: 'Steam Pressing & Finishing',
    bodyTemplate: (id) => `Order ${id} garments are being steam pressed for a crisp finish.`,
  },
  'quality check': {
    title: 'Quality Check Passed',
    bodyTemplate: (id) => `Order ${id} garments passed final quality inspection.`,
  },
  'ready': {
    title: 'Ready for Delivery',
    bodyTemplate: (id) => `Order ${id} is packed and ready for dispatch.`,
  },
  'delivery partner assigned': {
    title: 'Delivery Partner Assigned',
    bodyTemplate: (id) => `Rider assigned for your Order ${id} delivery.`,
  },
  'out for delivery': {
    title: 'Out for Delivery',
    bodyTemplate: (id) => `Rider is out for delivery with your Order ${id} garments.`,
  },
  'reached': {
    title: 'Rider at Doorstep',
    bodyTemplate: (id) => `Rider has arrived at your delivery address for Order ${id}.`,
  },
  'delivered': {
    title: 'Order Delivered',
    bodyTemplate: (id) => `Order ${id} delivered successfully. Thank you for choosing DryCleaning!`,
  },
  'cancel': {
    title: 'Order Cancelled',
    bodyTemplate: (id) => `Order ${id} has been cancelled.`,
  },
};

export const NotificationService = {
  sendOrderStatusNotification: async (fcmToken: string | undefined, order: any, newStatus: string): Promise<boolean> => {
    try {
      const lowerStatus = newStatus.toLowerCase();
      let matchedConfig = STAGE_NOTIFICATIONS['placed'];

      for (const key of Object.keys(STAGE_NOTIFICATIONS)) {
        if (lowerStatus.includes(key)) {
          matchedConfig = STAGE_NOTIFICATIONS[key];
          break;
        }
      }

      const title = matchedConfig.title;
      const body = matchedConfig.bodyTemplate(order.orderId || 'Order');

      console.log(`[FCM Notification] Sending status update for ${order.orderId}: "${title}" - "${body}"`);

      // 1. Save Notification Record to Database History
      try {
        await NotificationModel.create({
          notificationId: `NOTIF-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
          recipientId: order.customerPhone || 'customer',
          recipientType: 'customer',
          orderId: order.orderId || '',
          title,
          body,
          type: 'order_status',
          readStatus: false,
          createdAt: new Date(),
        });
      } catch (dbErr) {
        console.error('Failed to save customer notification to DB history:', dbErr);
      }

      // 2. Dispatch FCM Push Notification
      if (fcmToken && admin.apps.length > 0) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title,
            body,
          },
          data: {
            orderId: order.orderId || '',
            status: newStatus,
            type: 'customer_order',
          },
        });
      }

      return true;
    } catch (err: any) {
      console.error(`FCM notification error: ${err.message}`);
      return false;
    }
  },

  sendRiderTaskNotification: async (
    fcmToken: string | undefined,
    riderId: string,
    order: any,
    taskType: 'pickup' | 'delivery' | 'cancel' | 'reassign'
  ): Promise<boolean> => {
    try {
      let title = 'New Pickup Task Assigned';
      let body = `New pickup order ${order.orderId} assigned to you. Address: ${order.fullAddress}`;

      if (taskType === 'delivery') {
        title = 'New Delivery Task Assigned';
        body = `New delivery order ${order.orderId} assigned to you. Address: ${order.fullAddress}`;
      } else if (taskType === 'cancel') {
        title = 'Order Cancelled';
        body = `Order ${order.orderId} has been cancelled by the customer.`;
      } else if (taskType === 'reassign') {
        title = 'Order Reassigned';
        body = `Order ${order.orderId} has been reassigned to another rider partner.`;
      }

      console.log(`[FCM Rider Notification] Sending ${taskType} alert for Rider ${riderId} on ${order.orderId}: "${title}"`);

      // 1. Save Notification Record to Database History
      try {
        await NotificationModel.create({
          notificationId: `NOTIF-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
          recipientId: riderId,
          recipientType: 'rider',
          orderId: order.orderId || '',
          taskId: order.orderId || '',
          title,
          body,
          type: 'rider_task',
          readStatus: false,
          createdAt: new Date(),
        });
      } catch (dbErr) {
        console.error('Failed to save rider notification to DB history:', dbErr);
      }

      // 2. Dispatch FCM Push Notification to Rider
      if (fcmToken && admin.apps.length > 0) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title,
            body,
          },
          data: {
            orderId: order.orderId || '',
            taskId: order.orderId || '',
            type: 'rider_task',
          },
        });
      }

      return true;
    } catch (err: any) {
      console.error(`FCM rider notification error: ${err.message}`);
      return false;
    }
  },
};
