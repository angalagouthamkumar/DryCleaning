import { Request, Response } from 'express';
import mongoose from 'mongoose';
import { RiderModel } from '../models/riderModel';
import { OrderModel } from '../models/orderModel';

const getRiderQuery = (param: string) => {
  const isMongoId = mongoose.Types.ObjectId.isValid(param);
  return isMongoId ? { $or: [{ riderId: param }, { _id: param }] } : { riderId: param };
};

const getOrderQuery = (param: string) => {
  const isMongoId = mongoose.Types.ObjectId.isValid(param);
  return isMongoId ? { $or: [{ orderId: param }, { _id: param }] } : { orderId: param };
};

export const AdminRiderController = {
  // GET /api/v1/admin/riders
  getRiders: async (req: Request, res: Response): Promise<void> => {
    try {
      let riders = await RiderModel.find({}).lean();
      if (riders.length === 0) {
        const defaultRider = new RiderModel({
          riderId: 'RIDER_101',
          name: 'Rider Partner #101',
          phone: '+919999988888',
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          totalCompletedDeliveries: 10,
          isOnDuty: true,
          status: 'Approved',
          paidOutEarnings: 0,
        });
        await defaultRider.save();
        riders = [defaultRider.toObject() as any];
      }

      // Compute total earnings and live active orders per rider
      const enrichedRiders = await Promise.all(
        riders.map(async (r: any) => {
          const completedOrders = await OrderModel.countDocuments({
            $or: [{ assignedRiderId: r.riderId }, { assignedRiderId: r._id }],
            status: { $regex: /delivered/i },
          });

          const activeOrders = await OrderModel.countDocuments({
            $or: [{ assignedRiderId: r.riderId }, { assignedRiderId: r._id }],
            status: { $not: { $regex: /delivered|cancelled/i } },
          });

          const totalDeliveries = Math.max(r.totalCompletedDeliveries || 0, completedOrders);
          const totalEarnings = totalDeliveries * 90; // ₹65 base + ₹25 incentive per delivery

          return {
            ...r,
            totalCompletedDeliveries: totalDeliveries,
            activeOrdersCount: activeOrders,
            totalEarnings,
            pendingPayout: Math.max(0, totalEarnings - (r.paidOutEarnings || 0)),
          };
        })
      );

      res.status(200).json({
        success: true,
        count: enrichedRiders.length,
        data: enrichedRiders,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // PATCH /api/v1/admin/riders/:riderId/status
  updateRiderStatus: async (req: Request, res: Response): Promise<void> => {
    try {
      const riderIdStr = String(req.params.riderId);
      const { status, isOnDuty } = req.body;

      const updateData: any = {};
      if (status) updateData.status = status;
      if (typeof isOnDuty === 'boolean') updateData.isOnDuty = isOnDuty;

      const rider = await RiderModel.findOneAndUpdate(
        getRiderQuery(riderIdStr),
        { $set: updateData },
        { new: true }
      );

      if (!rider) {
        res.status(404).json({ success: false, message: 'Rider not found' });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Rider status updated successfully',
        data: rider,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // POST /api/v1/admin/riders/:riderId/assign-order
  assignOrder: async (req: Request, res: Response): Promise<void> => {
    try {
      const riderIdStr = String(req.params.riderId);
      const { orderId } = req.body;

      const rider = await RiderModel.findOne(getRiderQuery(riderIdStr));
      if (!rider) {
        res.status(404).json({ success: false, message: 'Rider not found' });
        return;
      }

      const order = await OrderModel.findOne(getOrderQuery(String(orderId)));
      if (!order) {
        res.status(404).json({ success: false, message: 'Order not found' });
        return;
      }

      order.assignedRiderId = rider.riderId;
      order.assignedRiderName = rider.name;
      if (order.status === 'Placed') {
        order.status = 'Pickup Assigned';
      }
      await order.save();

      res.status(200).json({
        success: true,
        message: `Order #${order.orderId} assigned to ${rider.name} successfully`,
        data: order,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // POST /api/v1/admin/riders/:riderId/payout
  processPayout: async (req: Request, res: Response): Promise<void> => {
    try {
      const riderIdStr = String(req.params.riderId);
      const { amount } = req.body;

      const rider = await RiderModel.findOne(getRiderQuery(riderIdStr));
      if (!rider) {
        res.status(404).json({ success: false, message: 'Rider not found' });
        return;
      }

      const payoutAmount = Number(amount) || 0;
      rider.paidOutEarnings = (rider.paidOutEarnings || 0) + payoutAmount;
      await rider.save();

      res.status(200).json({
        success: true,
        message: `Payout of ₹${payoutAmount} released to ${rider.name}`,
        data: {
          riderId: rider.riderId,
          paidOutEarnings: rider.paidOutEarnings,
        },
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
};
