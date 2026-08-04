import axios from 'axios';

const getBaseUrl = () => {
  if (typeof window !== 'undefined') {
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      return '/api/v1';
    }
  }
  return 'https://backend-phi-five-63.vercel.app/api/v1';
};

export const api = axios.create({
  baseURL: getBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.config && error.config.baseURL === '/api/v1') {
      error.config.baseURL = 'https://backend-phi-five-63.vercel.app/api/v1';
      return axios.request(error.config);
    }
    return Promise.reject(error);
  }
);

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const AdminApiService = {
  login: async (email: string, password: string) => {
    const res = await api.post('/auth/admin-login', { email, password });
    return res.data;
  },

  getAnalytics: async () => {
    const res = await api.get('/admin/analytics');
    return res.data;
  },

  getOrders: async (params?: { phoneNumber?: string; status?: string }) => {
    const res = await api.get('/orders', { params });
    return res.data;
  },

  updateOrderStatus: async (orderId: string, status: string) => {
    const res = await api.patch(`/orders/${orderId}/status`, { status });
    return res.data;
  },

  getCustomers: async () => {
    const res = await api.get('/admin/customers');
    return res.data;
  },

  searchOrders: async (query: string) => {
    const res = await api.get('/admin/search', { params: { q: query } });
    return res.data;
  },

  getPayments: async () => {
    const res = await api.get('/admin/payments');
    return res.data;
  },

  getRiders: async () => {
    const res = await api.get('/admin/riders');
    return res.data;
  },

  updateRiderStatus: async (riderId: string, status?: string, isOnDuty?: boolean) => {
    const res = await api.patch(`/admin/riders/${riderId}/status`, { status, isOnDuty });
    return res.data;
  },

  assignOrderToRider: async (riderId: string, orderId: string) => {
    const res = await api.post(`/admin/riders/${riderId}/assign-order`, { orderId });
    return res.data;
  },

  processRiderPayout: async (riderId: string, amount: number) => {
    const res = await api.post(`/admin/riders/${riderId}/payout`, { amount });
    return res.data;
  },

  getContent: async () => {
    const res = await api.get('/admin/content');
    return res.data;
  },

  bulkUpdateContent: async (items: Array<{ key: string; text: string }>) => {
    const res = await api.post('/admin/content/bulk-update', { items });
    return res.data;
  },

  getApkReleases: async () => {
    const res = await api.get('/apk');
    return res.data;
  },

  updateApkRelease: async (appType: string, payload: Record<string, any>) => {
    const res = await api.put(`/apk/admin/${appType}`, payload);
    return res.data;
  },

  trackApkDownload: async (appType: string) => {
    const res = await api.post(`/apk/${appType}/download`);
    return res.data;
  },
};
