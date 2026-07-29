import jwt from 'jsonwebtoken';
import { UserStore, User } from '../models/userStore';
import { OtpStore } from '../models/otpStore';
import { WhatsAppService } from './whatsappService';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_drycleaning_jwt_key_2026';

export const AuthService = {
  sendOtp: async (phoneNumber: string): Promise<{ success: boolean; message: string; cooldownSeconds?: number }> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    if (!cleanPhone || cleanPhone.length < 8) {
      throw new Error('Please enter a valid phone number.');
    }

    const existingSession = await OtpStore.getSession(cleanPhone);
    if (existingSession) {
      const now = new Date();
      const elapsedSeconds = Math.floor((now.getTime() - new Date(existingSession.lastSentAt).getTime()) / 1000);
      if (elapsedSeconds < 120) {
        return {
          success: false,
          message: `Please wait ${120 - elapsedSeconds} seconds before requesting another code.`,
          cooldownSeconds: 120 - elapsedSeconds,
        };
      }
    }

    // Generate strict random 6-digit OTP code (e.g. 849201)
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    await OtpStore.saveSession(cleanPhone, code);
    await WhatsAppService.sendOtpNotification(cleanPhone, code);

    return {
      success: true,
      message: '6-digit verification code sent successfully.',
    };
  },

  resendOtp: async (phoneNumber: string): Promise<{ success: boolean; message: string }> => {
    return AuthService.sendOtp(phoneNumber);
  },

  verifyOtp: async (phoneNumber: string, code: string): Promise<{ token: string; user: User; isNewUser: boolean }> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    const session = await OtpStore.getSession(cleanPhone);

    if (!session) {
      throw new Error('OTP session expired or not found. Please request a new verification code.');
    }

    if (new Date() > new Date(session.expiresAt)) {
      await OtpStore.deleteSession(cleanPhone);
      throw new Error('Verification code has expired. Please request a new code.');
    }

    const isValidCode = session.code === code.trim();

    if (!isValidCode) {
      const attempts = await OtpStore.incrementAttempts(cleanPhone);
      if (attempts >= 5) {
        await OtpStore.deleteSession(cleanPhone);
        throw new Error('Too many invalid attempts. Please request a new code.');
      }
      throw new Error('Invalid 6-digit verification code. Please check and try again.');
    }

    await OtpStore.deleteSession(cleanPhone);

    let user = UserStore.findByPhone(cleanPhone);
    let isNewUser = false;

    if (!user) {
      user = UserStore.create(cleanPhone);
      isNewUser = true;
    }

    const token = jwt.sign(
      { userId: user.id, phoneNumber: user.phoneNumber },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    return {
      token,
      user,
      isNewUser,
    };
  },

  verifyJwt: (token: string): { userId: string; phoneNumber: string } => {
    try {
      return jwt.verify(token, JWT_SECRET) as { userId: string; phoneNumber: string };
    } catch (err) {
      throw new Error('Invalid or expired access token.');
    }
  }
};
