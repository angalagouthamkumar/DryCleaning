import mongoose, { Schema, Document } from 'mongoose';

export interface IOrderItem {
  name: string;
  quantity: number;
  price: number;
}

export interface IOrder extends Document {
  orderId: string;
  customerName: string;
  customerPhone: string;
  fullAddress: string;
  landmark?: string;
  latitude?: number;
  longitude?: number;
  liveLocationUrl?: string;
  services: string[];
  items: IOrderItem[];
  pickupDate: string;
  pickupSlot: string;
  paymentMethod: string;
  upiVpa?: string;
  subtotal: number;
  deliveryCharge: number;
  handlingFee: number;
  grandTotal: number;
  notes?: string;
  hasVoiceInstruction?: boolean;
  voiceNoteUrl?: string;
  photoUrls?: string[];
  status: string;
  createdAt: Date;
}

const OrderItemSchema = new Schema<IOrderItem>({
  name: { type: String, required: true },
  quantity: { type: Number, required: true, default: 1 },
  price: { type: Number, required: true, default: 0 },
});

const OrderSchema = new Schema<IOrder>({
  orderId: { type: String, required: true, unique: true },
  customerName: { type: String, required: true },
  customerPhone: { type: String, required: true },
  fullAddress: { type: String, required: true },
  landmark: { type: String },
  latitude: { type: Number },
  longitude: { type: Number },
  liveLocationUrl: { type: String },
  services: [{ type: String }],
  items: [OrderItemSchema],
  pickupDate: { type: String, required: true },
  pickupSlot: { type: String, required: true },
  paymentMethod: { type: String, required: true, default: 'COD' },
  upiVpa: { type: String, default: 'angala@fam' },
  subtotal: { type: Number, required: true },
  deliveryCharge: { type: Number, default: 0 },
  handlingFee: { type: Number, default: 0 },
  grandTotal: { type: Number, required: true },
  notes: { type: String },
  hasVoiceInstruction: { type: Boolean, default: false },
  voiceNoteUrl: { type: String },
  photoUrls: [{ type: String }],
  status: { type: String, default: 'Placed' },
  createdAt: { type: Date, default: Date.now },
});

export const OrderModel = mongoose.model<IOrder>('Order', OrderSchema);
