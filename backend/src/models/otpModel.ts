import mongoose, { Schema, Document } from 'mongoose';

export interface IOtpDocument extends Document {
  phoneNumber: string;
  code: string;
  expiresAt: Date;
  lastSentAt: Date;
  attempts: number;
}

const OtpSchema: Schema = new Schema({
  phoneNumber: { type: String, required: true, unique: true },
  code: { type: String, required: true },
  expiresAt: { type: Date, required: true },
  lastSentAt: { type: Date, default: Date.now },
  attempts: { type: Number, default: 0 },
});

export const OtpModel = mongoose.model<IOtpDocument>('OtpSession', OtpSchema);
