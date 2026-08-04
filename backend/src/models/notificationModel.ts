import mongoose, { Schema, Document } from 'mongoose';

export interface INotification extends Document {
  notificationId: string;
  recipientId: string; // Customer phone or Rider ID
  recipientType: 'customer' | 'rider';
  orderId?: string;
  taskId?: string;
  title: string;
  body: string;
  type: string;
  readStatus: boolean;
  createdAt: Date;
}

const NotificationSchema = new Schema<INotification>({
  notificationId: { type: String, required: true, unique: true },
  recipientId: { type: String, required: true, index: true },
  recipientType: { type: String, enum: ['customer', 'rider'], required: true },
  orderId: { type: String },
  taskId: { type: String },
  title: { type: String, required: true },
  body: { type: String, required: true },
  type: { type: String, default: 'order_status' },
  readStatus: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

export const NotificationModel = mongoose.model<INotification>('Notification', NotificationSchema);
