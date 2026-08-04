import mongoose, { Schema, Document } from 'mongoose';

export interface IAdjustment extends Document {
  riderId: string;
  type: 'Incentive' | 'Penalty' | 'Bonus' | 'OtherEarnings' | 'Deduction';
  category: string;
  amount: number;
  description: string;
  adminId?: string;
  createdAt: Date;
}

const AdjustmentSchema = new Schema<IAdjustment>({
  riderId: { type: String, required: true, index: true },
  type: {
    type: String,
    enum: ['Incentive', 'Penalty', 'Bonus', 'OtherEarnings', 'Deduction'],
    required: true,
  },
  category: { type: String, required: true },
  amount: { type: Number, required: true },
  description: { type: String, default: '' },
  adminId: { type: String },
  createdAt: { type: Date, default: Date.now, index: true },
});

export const AdjustmentModel = mongoose.model<IAdjustment>('Adjustment', AdjustmentSchema);
