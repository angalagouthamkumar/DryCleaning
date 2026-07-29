import { Request, Response } from 'express';
import mongoose from 'mongoose';
import { OrderStore } from '../models/orderStore';
import { OrderModel } from '../models/orderModel';
import { WhatsAppService } from '../services/whatsappService';
import { SemPayService } from '../services/semPayService';

const ADMIN_WHATSAPP_NUMBER = '918341726226';

export const OrderController = {
  createOrder: async (req: Request, res: Response): Promise<void> => {
    try {
      const {
        customerName,
        customerPhone,
        fullAddress,
        landmark,
        latitude,
        longitude,
        liveLocationUrl: incomingLiveLocationUrl,
        services,
        items,
        pickupDate,
        pickupSlot,
        paymentMethod,
        upiVpa,
        subtotal,
        deliveryCharge,
        handlingFee,
        grandTotal,
        notes,
        hasVoiceInstruction,
        voiceNoteUrl,
        photoUrls,
      } = req.body;

      const liveLocationUrl = incomingLiveLocationUrl || (latitude && longitude ? `https://maps.google.com/?q=${latitude},${longitude}` : '');
      const orderId = `ORD-${Date.now()}`;

      // Initialize SemPay UPI Intent transaction payload
      const semPayTxn = await SemPayService.createUpiPaymentIntent({
        orderId,
        amount: grandTotal || 0,
        customerName: customerName || 'Customer',
        customerPhone: customerPhone || '',
        vpa: upiVpa || 'angala@fam',
      });

      const orderPayload = {
        orderId,
        customerName: customerName || 'Customer',
        customerPhone: customerPhone || '',
        fullAddress: fullAddress || '',
        landmark: landmark || '',
        latitude: latitude,
        longitude: longitude,
        liveLocationUrl,
        services: services || [],
        items: items || [],
        pickupDate: pickupDate || '',
        pickupSlot: pickupSlot || '',
        paymentMethod: paymentMethod || 'COD',
        upiVpa: upiVpa || 'angala@fam',
        subtotal: subtotal || 0,
        deliveryCharge: deliveryCharge || 0,
        handlingFee: handlingFee || 0,
        grandTotal: grandTotal || 0,
        notes: notes || '',
        hasVoiceInstruction: hasVoiceInstruction || false,
        voiceNoteUrl: voiceNoteUrl || '',
        photoUrls: photoUrls || [],
        status: 'Placed',
        createdAt: new Date(),
      };

      let savedOrder: any = null;

      // 1. Direct save to MongoDB Atlas Database
      try {
        savedOrder = await OrderModel.create(orderPayload);
        console.log(`✅ Order ${orderId} saved to MongoDB Atlas database successfully! ID: ${savedOrder._id}`);
      } catch (dbErr: any) {
        console.error('❌ MongoDB Atlas save error:', dbErr);
        // Fallback to memory store if DB creation fails
        savedOrder = OrderStore.create(orderPayload as any);
      }

      // 2. Also keep OrderStore updated as secondary cache
      if (savedOrder && savedOrder._id) {
        try {
          OrderStore.create({
            ...orderPayload,
            id: savedOrder._id.toString(),
            orderNumber: orderId,
            updatedAt: new Date(),
          } as any);
        } catch (_) {}
      }

      // 3. Server-side WhatsApp notification to Owner ONLY (+918341726226)
      await WhatsAppService.sendOrderNotification(ADMIN_WHATSAPP_NUMBER, orderPayload);

      res.status(201).json({
        success: true,
        message: 'Order placed successfully & saved to MongoDB Atlas',
        data: {
          order: savedOrder,
          adminPhone: ADMIN_WHATSAPP_NUMBER,
          upiVpa: 'angala@fam',
          semPay: semPayTxn,
        },
      });
    } catch (err: any) {
      console.error('❌ createOrder endpoint exception:', err);
      res.status(500).json({ success: false, message: err.message });
    }
  },

  getOrders: async (req: Request, res: Response): Promise<void> => {
    try {
      const { phoneNumber } = req.query;
      const phoneStr = typeof phoneNumber === 'string' ? phoneNumber.trim() : undefined;

      // If phone number is specified, strictly isolate and return ONLY this customer's orders
      if (phoneStr && phoneStr.length > 0) {
        const cleanPhone = phoneStr.replace(/\D/g, '');
        const last10Digits = cleanPhone.slice(-10);

        try {
          const customerOrders = await OrderModel.find({
            $or: [
              { customerPhone: phoneStr },
              { customerPhone: cleanPhone },
              { customerPhone: { $regex: last10Digits, $options: 'i' } }
            ]
          }).sort({ createdAt: -1 });

          // Return ONLY matching orders for this customer (empty list [] if new customer with 0 orders)
          res.status(200).json({ success: true, data: customerOrders || [] });
          return;
        } catch (dbErr) {
          console.warn('⚠️ OrderModel.find warning, falling back to OrderStore:', dbErr);
          const allLocal = OrderStore.getAll();
          const filtered = allLocal.filter(o => {
            const p = (o.customerPhone || '').replace(/\D/g, '');
            return p.includes(last10Digits);
          });
          res.status(200).json({ success: true, data: filtered });
          return;
        }
      }

      // If no phone number parameter is passed (e.g. admin dashboard), return all orders
      try {
        const allDbOrders = await OrderModel.find({}).sort({ createdAt: -1 });
        res.status(200).json({ success: true, data: allDbOrders });
      } catch (_) {
        res.status(200).json({ success: true, data: OrderStore.getAll() });
      }
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  updateStatus: async (req: Request, res: Response): Promise<void> => {
    try {
      const idStr = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { status } = req.body;
      if (!status) {
        res.status(400).json({ success: false, message: 'status is required' });
        return;
      }

      let updatedOrder: any = null;
      try {
        if (mongoose.Types.ObjectId.isValid(idStr)) {
          updatedOrder = await OrderModel.findByIdAndUpdate(idStr, { status }, { new: true });
        }
        if (!updatedOrder) {
          updatedOrder = await OrderModel.findOneAndUpdate({ orderId: idStr }, { status }, { new: true });
        }
      } catch (_) {}

      if (!updatedOrder) {
        updatedOrder = OrderStore.updateStatus(idStr, status as any);
      }

      res.status(200).json({
        success: true,
        message: `Order status updated to ${status}`,
        data: updatedOrder,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  getSemPayConfig: async (req: Request, res: Response): Promise<void> => {
    const creds = SemPayService.getClientCredentials();
    res.status(200).json({
      success: true,
      service: 'SemPay Payment Gateway Integration',
      clientId: creds.clientId,
      environment: creds.env,
      supportedMethods: ['UPI_INTENT', 'UPI_QR', 'COLLECT'],
    });
  }
};
