import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { AuthService } from '../services/authService';
import { UserStore } from '../models/userStore';
import { FirebaseAdminService } from '../services/firebaseAdminService';

const sendOtpSchema = z.object({
  phoneNumber: z.string().min(8, 'Phone number must be at least 8 digits'),
});

const verifyOtpSchema = z.object({
  phoneNumber: z.string().min(8, 'Phone number must be at least 8 digits'),
  otp: z.string().min(4, 'OTP must be at least 4 digits').max(6, 'OTP must be at most 6 digits'),
});

export const AuthController = {
  sendOtp: async (req: Request, res: Response): Promise<void> => {
    try {
      const parsed = sendOtpSchema.parse(req.body);
      const result = await AuthService.sendOtp(parsed.phoneNumber);
      res.status(200).json(result);
    } catch (err: any) {
      res.status(400).json({
        success: false,
        message: err.message || 'Failed to send OTP code',
      });
    }
  },

  resendOtp: async (req: Request, res: Response): Promise<void> => {
    try {
      const parsed = sendOtpSchema.parse(req.body);
      const result = await AuthService.resendOtp(parsed.phoneNumber);
      res.status(200).json(result);
    } catch (err: any) {
      res.status(400).json({
        success: false,
        message: err.message || 'Failed to resend OTP code',
      });
    }
  },

  verifyOtp: async (req: Request, res: Response): Promise<void> => {
    try {
      const parsed = verifyOtpSchema.parse(req.body);
      const result = await AuthService.verifyOtp(parsed.phoneNumber, parsed.otp);
      res.status(200).json({
        success: true,
        message: 'Phone verified successfully',
        data: result,
      });
    } catch (err: any) {
      res.status(400).json({
        success: false,
        message: err.message || 'Invalid OTP verification request',
      });
    }
  },

  firebaseLogin: async (req: Request, res: Response): Promise<void> => {
    try {
      const { idToken, phoneNumber } = req.body;
      if (!idToken || !phoneNumber) {
        res.status(400).json({ success: false, message: 'idToken and phoneNumber are required' });
        return;
      }
      const verified = await FirebaseAdminService.verifyIdToken(idToken);
      if (!verified) {
        res.status(401).json({ success: false, message: 'Invalid Firebase ID token' });
        return;
      }
      let user = UserStore.findByPhone(phoneNumber);
      let isNewUser = false;
      if (!user) {
        user = UserStore.create(phoneNumber);
        isNewUser = true;
      }
      const token = jwt.sign(
        { userId: user.id, phoneNumber: user.phoneNumber },
        process.env.JWT_SECRET || 'super_secret_drycleaning_jwt_key_2026',
        { expiresIn: '30d' }
      );
      res.status(200).json({
        success: true,
        message: 'Firebase phone auth verified successfully',
        data: { token, user, isNewUser },
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  getMe: async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = (req as any).user?.userId;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }
      const user = UserStore.findById(userId);
      if (!user) {
        res.status(444).json({ success: false, message: 'User not found' });
        return;
      }
      res.status(200).json({ success: true, data: user });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  adminLogin: async (req: Request, res: Response): Promise<void> => {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        res.status(400).json({ success: false, message: 'Email and password are required' });
        return;
      }

      const validEmail = process.env.ADMIN_EMAIL || 'admin@drycleaning.com';
      const validPassword = process.env.ADMIN_PASSWORD || 'admin123456';

      if (email.trim().toLowerCase() !== validEmail.toLowerCase() || password !== validPassword) {
        res.status(401).json({ success: false, message: 'Invalid admin credentials' });
        return;
      }

      const token = jwt.sign(
        { role: 'admin', email: validEmail },
        process.env.JWT_SECRET || 'super_secret_drycleaning_jwt_key_2026',
        { expiresIn: '7d' }
      );

      res.status(200).json({
        success: true,
        message: 'Admin login successful',
        data: {
          token,
          user: {
            name: 'Admin Owner',
            email: validEmail,
            role: 'admin'
          }
        }
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }
};

