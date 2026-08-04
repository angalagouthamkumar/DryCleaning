import mongoose, { Schema, Document } from 'mongoose';

export interface ILoginSession extends Document {
  riderId: string;
  loginTime: Date;
  logoutTime?: Date;
  onlineDurationMinutes: number;
  activeDurationMinutes: number;
  breakDurationMinutes: number;
}

const LoginSessionSchema = new Schema<ILoginSession>({
  riderId: { type: String, required: true, index: true },
  loginTime: { type: Date, default: Date.now },
  logoutTime: { type: Date },
  onlineDurationMinutes: { type: Number, default: 0 },
  activeDurationMinutes: { type: Number, default: 0 },
  breakDurationMinutes: { type: Number, default: 0 },
});

export const LoginSessionModel = mongoose.model<ILoginSession>('LoginSession', LoginSessionSchema);
