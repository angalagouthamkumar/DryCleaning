export interface OrderItem {
  name: string;
  quantity: number;
  price: number;
  category?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string;
  fullAddress: string;
  landmark?: string;
  latitude: number;
  longitude: number;
  liveLocationUrl: string;
  services: string[];
  items: OrderItem[];
  pickupDate: string;
  pickupSlot: string;
  paymentMethod: string;
  subtotal: number;
  deliveryCharge: number;
  handlingFee: number;
  grandTotal: number;
  notes?: string;
  status: 'Placed' | 'Confirmed' | 'Picked Up' | 'In Cleaning' | 'Ready' | 'Out for Delivery' | 'Delivered';
  createdAt: Date;
  updatedAt: Date;
}

const ordersMap = new Map<string, Order>();

export const OrderStore = {
  create: (orderData: Omit<Order, 'id' | 'orderNumber' | 'status' | 'createdAt' | 'updatedAt'>): Order => {
    const timestamp = Date.now();
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const orderNumber = `ORD-${new Date().getFullYear()}-${randomSuffix}`;
    const id = `ord_${timestamp}_${randomSuffix}`;

    const newOrder: Order = {
      ...orderData,
      id,
      orderNumber,
      status: 'Placed',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    ordersMap.set(id, newOrder);
    return newOrder;
  },

  findById: (id: string): Order | undefined => {
    return ordersMap.get(id);
  },

  findByCustomerPhone: (phoneNumber: string): Order[] => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    const results: Order[] = [];
    for (const order of ordersMap.values()) {
      if (order.customerPhone.replace(/[\s\-\(\)]/g, '') === cleanPhone) {
        results.push(order);
      }
    }
    return results.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  },

  getAll: (): Order[] => {
    return Array.from(ordersMap.values()).sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  },

  updateStatus: (id: string, status: Order['status']): Order | undefined => {
    const order = ordersMap.get(id);
    if (!order) return undefined;
    const updated = {
      ...order,
      status,
      updatedAt: new Date(),
    };
    ordersMap.set(id, updated);
    return updated;
  }
};
