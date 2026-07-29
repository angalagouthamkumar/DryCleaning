import { Router } from 'express';
import { OrderController } from '../controllers/orderController';

const router = Router();

router.post('/', OrderController.createOrder);
router.get('/', OrderController.getOrders);
router.get('/sempay-config', OrderController.getSemPayConfig);
router.patch('/:id/status', OrderController.updateStatus);

export default router;
