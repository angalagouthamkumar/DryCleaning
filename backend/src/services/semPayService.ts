import crypto from 'crypto';

export interface SemPayPaymentRequest {
  orderId: string;
  amount: number;
  customerName: string;
  customerPhone: string;
  vpa?: string;
}

export interface SemPayPaymentResponse {
  success: boolean;
  transactionId: string;
  clientId: string;
  upiIntentUrl: string;
  qrCodeData: string;
  amount: number;
  currency: string;
  status: 'PENDING' | 'SUCCESS' | 'FAILED';
  signature: string;
}

export const SemPayService = {
  getClientCredentials: () => {
    const clientId = process.env.SEMPAY_CLIENT_ID || 'fe362a4cA64890E9';
    const clientSecret = process.env.SEMPAY_CLIENT_SECRET || '27f0258fd5bc4a880726993365b3a2b93599f9fcc39440603a8f1caae5fd2c05';
    const env = process.env.SEMPAY_ENV || 'test';
    return { clientId, clientSecret, env };
  },

  /**
   * Create SemPay UPI Payment Intent & Transaction payload for order
   */
  createUpiPaymentIntent: async (req: SemPayPaymentRequest): Promise<SemPayPaymentResponse> => {
    const { clientId, clientSecret, env } = SemPayService.getClientCredentials();
    const transactionId = `TXN_SEMPAY_${Date.now()}_${Math.floor(1000 + Math.random() * 9000)}`;
    const recipientVpa = req.vpa || 'angala@fam';

    // Signature payload for secure verification
    const payloadStr = `${clientId}|${req.orderId}|${req.amount}|${transactionId}`;
    const signature = crypto.createHmac('sha256', clientSecret).update(payloadStr).digest('hex');

    // Generate Standard UPI Deep Link for GPay, PhonePe, Paytm & BHIM
    const encodedNotes = encodeURIComponent(`Dry Cleaning Order ${req.orderId}`);
    const upiIntentUrl = `upi://pay?pa=${recipientVpa}&pn=${encodeURIComponent('DryCleaningApp')}&tr=${transactionId}&tn=${encodedNotes}&am=${req.amount.toFixed(2)}&cu=INR`;

    console.log(`\n==================================================`);
    console.log(`💳 [SEMPAY UPI GATEWAY INITIATE - ENV: ${env.toUpperCase()}]`);
    console.log(`🔑 Client ID: ${clientId}`);
    console.log(`🆔 Order ID: ${req.orderId} | Txn ID: ${transactionId}`);
    console.log(`👤 Customer: ${req.customerName} (${req.customerPhone})`);
    console.log(`💰 Amount: ₹${req.amount}`);
    console.log(`📲 UPI Intent: ${upiIntentUrl}`);
    console.log(`🔏 HMAC Signature: ${signature.substring(0, 16)}...`);
    console.log(`==================================================\n`);

    return {
      success: true,
      transactionId,
      clientId,
      upiIntentUrl,
      qrCodeData: upiIntentUrl,
      amount: req.amount,
      currency: 'INR',
      status: 'PENDING',
      signature,
    };
  },

  /**
   * Verify SemPay webhook / payment signature callback
   */
  verifyPaymentSignature: (transactionId: string, orderId: string, amount: number, receivedSignature: string): boolean => {
    const { clientId, clientSecret } = SemPayService.getClientCredentials();
    const payloadStr = `${clientId}|${orderId}|${amount}|${transactionId}`;
    const expectedSignature = crypto.createHmac('sha256', clientSecret).update(payloadStr).digest('hex');
    return expectedSignature === receivedSignature;
  }
};
