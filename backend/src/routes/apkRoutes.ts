import { Router } from 'express';
import { ApkController } from '../controllers/apkController';

const router = Router();

// Public & Admin endpoints for APK Releases
router.get('/', ApkController.getApkReleases);
router.post('/:appType/download', ApkController.trackDownload);
router.put('/admin/:appType', ApkController.updateApkRelease);

export default router;
