export interface IOrderItem {
  name: string;
  quantity: number;
  price: number;
}

export interface IOrder {
  _id?: string;
  id?: string;
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
  createdAt: string;
}

export interface ICustomer {
  customerName: string;
  customerPhone: string;
  fullAddress: string;
  totalOrders: number;
  totalSpent: number;
  lastOrderDate: string;
}

export interface IAnalytics {
  totalOrders: number;
  todayOrdersCount: number;
  totalRevenue: number;
  todayRevenue: number;
  activeOrdersCount: number;
  deliveredCount: number;
  cancelledCount: number;
  serviceCounts: Record<string, number>;
}

export interface IRider {
  _id?: string;
  riderId: string;
  name: string;
  phone: string;
  photoUrl: string;
  totalCompletedDeliveries: number;
  isOnDuty: boolean;
  status: 'Approved' | 'Pending' | 'Suspended';
  activeOrdersCount?: number;
  totalEarnings?: number;
  pendingPayout?: number;
}

export interface IContentItem {
  _id?: string;
  key: string;
  text: string;
  screen: string;
  category: string;
  component?: string;
  maxLength?: number;
  updatedAt?: string;
}

export interface IApkRelease {
  _id?: string;
  appType: 'customer' | 'rider';
  appName: string;
  subtitle: string;
  version: string;
  buildDate: string;
  apkSize: string;
  releaseNotes: string;
  status: string;
  downloadCount: number;
  apkUrl: string;
  updatedAt?: string;
}
