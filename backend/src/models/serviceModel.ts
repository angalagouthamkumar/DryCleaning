import mongoose, { Schema, Document } from 'mongoose';

export interface IServiceItem extends Document {
  serviceId: string;
  category: string;
  title: string;
  price: string;
  priceValue: number;
  originalPrice?: string;
  isPack?: boolean;
  subtitle?: string;
}

const ServiceSchema = new Schema<IServiceItem>({
  serviceId: { type: String, required: true, unique: true },
  category: { type: String, required: true },
  title: { type: String, required: true },
  price: { type: String, required: true },
  priceValue: { type: Number, required: true },
  originalPrice: { type: String },
  isPack: { type: Boolean, default: false },
  subtitle: { type: String },
});

export const ServiceModel = mongoose.model<IServiceItem>('Service', ServiceSchema);
