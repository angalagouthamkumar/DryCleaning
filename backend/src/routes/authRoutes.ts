import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { requireAuth } from '../middlewares/authMiddleware';

const router = Router();

router.post('/send-otp', AuthController.sendOtp);
router.post('/resend-otp', AuthController.resendOtp);
router.post('/verify-otp', AuthController.verifyOtp);
router.post('/firebase-login', AuthController.firebaseLogin);
router.post('/admin-login', AuthController.adminLogin);
router.get('/me', requireAuth, AuthController.getMe);

export default router;
