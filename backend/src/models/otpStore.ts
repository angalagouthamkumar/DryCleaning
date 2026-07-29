export interface OtpSession {
  phoneNumber: string;
  code: string;
  expiresAt: Date;
  lastSentAt: Date;
  attempts: number;
}

const otpMap = new Map<string, OtpSession>();

export const OtpStore = {
  saveSession: (phoneNumber: string, code: string): OtpSession => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    const now = new Date();
    const expiresAt = new Date(now.getTime() + 5 * 60 * 1000); // 5 minutes validity

    const session: OtpSession = {
      phoneNumber: cleanPhone,
      code,
      expiresAt,
      lastSentAt: now,
      attempts: 0,
    };

    otpMap.set(cleanPhone, session);
    return session;
  },

  getSession: (phoneNumber: string): OtpSession | undefined => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    return otpMap.get(cleanPhone);
  },

  incrementAttempts: (phoneNumber: string): number => {
    const session = OtpStore.getSession(phoneNumber);
    if (!session) return 0;
    session.attempts += 1;
    return session.attempts;
  },

  deleteSession: (phoneNumber: string): void => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    otpMap.delete(cleanPhone);
  }
};
