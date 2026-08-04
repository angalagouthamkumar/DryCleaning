import mongoose, { Schema, Document } from 'mongoose';

export interface IEarningTransaction extends Document {
  riderId: string;
  orderId: string;
  customerId?: string;
  customerName?: string;
  pickupTime?: Date;
  deliveryTime: Date;
  distanceKm: number;
  baseDeliveryEarnings: number;
  pickupEarnings: number;
  distanceEarnings: number;
  waitingCharges: number;
  extraStopCharges: number;
  peakBonus: number;
  rainBonus: number;
  nightBonus: number;
  tips: number;
  incentiveAmount: number;
  platformFee: number;
  taxes: number;
  penalties: number;
  netEarnings: number;
  settlementStatus: 'Pending' | 'Settled';
  createdAt: Date;
}

const EarningTransactionSchema = new Schema<IEarningTransaction>({
  riderId: { type: String, required: true, index: true },
  orderId: { type: String, required: true, index: true },
  customerId: { type: String },
  customerName: { type: String },
  pickupTime: { type: Date },
  deliveryTime: { type: Date, default: Date.now },
  distanceKm: { type: Number, default: 2.5 },
  baseDeliveryEarnings: { type: Number, default: 50 },
  pickupEarnings: { type: Number, default: 15 },
  distanceEarnings: { type: Number, default: 0 },
  waitingCharges: { type: Number, default: 0 },
  extraStopCharges: { type: Number, default: 0 },
  peakBonus: { type: Number, default: 0 },
  rainBonus: { type: Number, default: 0 },
  nightBonus: { type: Number, default: 0 },
  tips: { type: Number, default: 0 },
  incentiveAmount: { type: Number, default: 0 },
  platformFee: { type: Number, default: 0 },
  taxes: { type: Number, default: 0 },
  penalties: { type: Number, default: 0 },
  netEarnings: { type: Number, required: true, default: 65 },
  settlementStatus: { type: String, enum: ['Pending', 'Settled'], default: 'Pending' },
  createdAt: { type: Date, default: Date.now, index: true },
});

export const EarningTransactionModel = mongoose.model<IEarningTransaction>('EarningTransaction', EarningTransactionSchema);
