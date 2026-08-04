import { Router } from 'express';
import { RiderController } from '../controllers/riderController';
import { RiderEarningsController } from '../controllers/riderEarningsController';

const router = Router();

router.get('/tasks', RiderController.getRiderTasks);
router.post('/tasks/:id/accept', RiderController.acceptTask);
router.patch('/tasks/:id/step', RiderController.updateTaskStep);

// Rider Earnings APIs
router.get('/earnings/day', RiderEarningsController.getDailyEarnings);
router.get('/earnings/week', RiderEarningsController.getWeeklyEarnings);
router.get('/earnings/month', RiderEarningsController.getMonthlyEarnings);
router.get('/earnings/breakdown', RiderEarningsController.getEarningsBreakdown);
router.get('/earnings/report', RiderEarningsController.getEarningsReport);

export default router;
