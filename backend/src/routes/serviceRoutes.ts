import { Router } from 'express';
import { ServiceController } from '../controllers/serviceController';

const router = Router();

router.get('/', ServiceController.getServices);

export default router;
