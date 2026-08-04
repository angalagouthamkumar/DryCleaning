import { Router } from 'express';
import { uploadMiddleware } from '../middlewares/uploadMiddleware';
import { UploadController } from '../controllers/uploadController';

const router = Router();

router.post('/audio', uploadMiddleware.single('audio'), UploadController.uploadAudio);
router.post('/image', uploadMiddleware.array('images', 10), UploadController.uploadImage);

export default router;
