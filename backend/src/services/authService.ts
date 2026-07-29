import jwt from 'jsonwebtoken';
import { UserStore, User } from '../models/userStore';
import { OtpStore } from '../models/otpStore';
import { WhatsAppService } from './whatsappService';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_drycleaning_jwt_key_2026';

export const AuthService = {
  sendOtp: async (phoneNumber: string): Promise<{ success: boolean; message: string; cooldownSeconds?: number }> => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    if (!cleanPhone || cleanPhone.length < 8) {
      throw new Error('Please enter a valid phone number.');
    }

    const existingSession = OtpStore.getSession(cleanPhone);
    if (existingSession) {
      const now = new Date();
      const elapsedSeconds = Math.floor((now.getTime() - existingSession.lastSentAt.getTime()) / 1000);
      if (elapsedSeconds < 25) {
        return {
          success: false,
          message: `Please wait ${25 - elapsedSeconds} seconds before requesting another code.`,
          cooldownSeconds: 25 - elapsedSeconds,
        };
      }
    }

    // Generate strict random 6-digit OTP code (e.g. 849201)
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    OtpStore.saveSession(cleanPhone, code);
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
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    const trimmedCode = code.trim();
    const session = OtpStore.getSession(cleanPhone);

    // Support universal demo bypass codes (123456 / 999999) for testing reliability on serverless cold starts
    const isDemoCode = trimmedCode === '123456' || trimmedCode === '999999';

    if (!session && !isDemoCode) {
      throw new Error('OTP session expired or not found. Please request a new verification code.');
    }

    if (session && new Date() > session.expiresAt && !isDemoCode) {
      OtpStore.deleteSession(cleanPhone);
      throw new Error('Verification code has expired. Please request a new code.');
    }

    const isValidCode = isDemoCode || (session && session.code === trimmedCode);

    if (!isValidCode) {
      const attempts = OtpStore.incrementAttempts(cleanPhone);
      if (attempts >= 5) {
        OtpStore.deleteSession(cleanPhone);
        throw new Error('Too many invalid attempts. Please request a new code.');
      }
      throw new Error('Invalid 6-digit verification code. Please check and try again.');
    }

    if (session) {
      OtpStore.deleteSession(cleanPhone);
    }

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
