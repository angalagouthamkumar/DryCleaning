import mongoose, { Schema, Document } from 'mongoose';

export interface IRider extends Document {
  riderId: string;
  name: string;
  phone: string;
  photoUrl: string;
  totalCompletedDeliveries: number;
  isOnDuty: boolean;
  status: 'Approved' | 'Pending' | 'Suspended';
  paidOutEarnings: number;
}

const RiderSchema = new Schema<IRider>({
  riderId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  photoUrl: { type: String, default: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150' },
  totalCompletedDeliveries: { type: Number, default: 0 },
  isOnDuty: { type: Boolean, default: true },
  status: { type: String, enum: ['Approved', 'Pending', 'Suspended'], default: 'Approved' },
  paidOutEarnings: { type: Number, default: 0 },
});

export const RiderModel = mongoose.model<IRider>('Rider', RiderSchema);
