import { OtpModel } from './otpModel';

export interface OtpSession {
  phoneNumber: string;
  code: string;
  expiresAt: Date;
  lastSentAt: Date;
  attempts: number;
}

const memoryMap = new Map<string, OtpSession>();

export const OtpStore = {
  saveSession: async (phoneNumber: string, code: string): Promise<OtpSession> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    const now = new Date();
    const expiresAt = new Date(now.getTime() + 2 * 60 * 1000); // 2 minutes validity

    const sessionData: OtpSession = {
      phoneNumber: cleanPhone,
      code,
      expiresAt,
      lastSentAt: now,
      attempts: 0,
    };

    memoryMap.set(cleanPhone, sessionData);

    try {
      await OtpModel.findOneAndUpdate(
        { phoneNumber: cleanPhone },
        { code, expiresAt, lastSentAt: now, attempts: 0 },
        { upsert: true, new: true }
      );
    } catch (err) {
      console.warn('MongoDB OtpModel save warning:', err);
    }

    return sessionData;
  },

  getSession: async (phoneNumber: string): Promise<OtpSession | undefined> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');

    try {
      const dbDoc = await OtpModel.findOne({ phoneNumber: cleanPhone });
      if (dbDoc) {
        return {
          phoneNumber: dbDoc.phoneNumber,
          code: dbDoc.code,
          expiresAt: dbDoc.expiresAt,
          lastSentAt: dbDoc.lastSentAt,
          attempts: dbDoc.attempts,
        };
      }
    } catch (_) {}

    return memoryMap.get(cleanPhone);
  },

  incrementAttempts: async (phoneNumber: string): Promise<number> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    try {
      const updated = await OtpModel.findOneAndUpdate(
        { phoneNumber: cleanPhone },
        { $inc: { attempts: 1 } },
        { new: true }
      );
      if (updated) return updated.attempts;
    } catch (_) {}

    const mem = memoryMap.get(cleanPhone);
    if (!mem) return 0;
    mem.attempts += 1;
    return mem.attempts;
  },

  deleteSession: async (phoneNumber: string): Promise<void> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    memoryMap.delete(cleanPhone);
    try {
      await OtpModel.deleteOne({ phoneNumber: cleanPhone });
    } catch (_) {}
  }
};
