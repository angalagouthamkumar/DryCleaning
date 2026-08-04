import { Router } from 'express';
import { AdminController } from '../controllers/adminController';
import { AdminRiderController } from '../controllers/adminRiderController';
import { ContentController } from '../controllers/contentController';

const router = Router();

router.get('/analytics', AdminController.getAnalytics);
router.get('/customers', AdminController.getCustomers);
router.get('/search', AdminController.searchOrders);
router.get('/payments', AdminController.getPayments);

// Customer Content Management Endpoints
router.get('/content', ContentController.getAllContent);
router.post('/content/bulk-update', ContentController.bulkUpdateContent);

// Rider Management Endpoints
router.get('/riders', AdminRiderController.getRiders);
router.patch('/riders/:riderId/status', AdminRiderController.updateRiderStatus);
router.post('/riders/:riderId/assign-order', AdminRiderController.assignOrder);
router.post('/riders/:riderId/payout', AdminRiderController.processPayout);

export default router;
