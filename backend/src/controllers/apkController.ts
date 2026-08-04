import { Request, Response } from 'express';
import { ApkReleaseModel, DEFAULT_APK_RELEASES } from '../models/apkModel';

const syncDefaultApkReleases = async () => {
  try {
    for (const defaultRelease of DEFAULT_APK_RELEASES) {
      await ApkReleaseModel.updateOne(
        { appType: defaultRelease.appType as any },
        { $setOnInsert: defaultRelease },
        { upsert: true }
      );
    }
  } catch (err) {
    console.error('Error syncing default APK releases:', err);
  }
};

export const ApkController = {
  // Public GET /api/v1/apk - Get all APK release metadata
  getApkReleases: async (req: Request, res: Response): Promise<void> => {
    try {
      await syncDefaultApkReleases();
      const releases = await ApkReleaseModel.find({}).lean();
      res.status(200).json({
        success: true,
        count: releases.length,
        data: releases,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // Admin PUT /api/v1/admin/apk/:appType - Dynamic update of APK release details
  updateApkRelease: async (req: Request, res: Response): Promise<void> => {
    try {
      const appTypeStr = String(req.params.appType).toLowerCase();
      if (appTypeStr !== 'customer' && appTypeStr !== 'rider') {
        res.status(400).json({ success: false, message: 'Invalid appType. Must be customer or rider.' });
        return;
      }

      const {
        version,
        buildDate,
        apkSize,
        releaseNotes,
        status,
        apkUrl,
        subtitle,
      } = req.body;

      const updatePayload: any = { updatedAt: new Date() };
      if (version !== undefined) updatePayload.version = version;
      if (buildDate !== undefined) updatePayload.buildDate = buildDate;
      if (apkSize !== undefined) updatePayload.apkSize = apkSize;
      if (releaseNotes !== undefined) updatePayload.releaseNotes = releaseNotes;
      if (status !== undefined) updatePayload.status = status;
      if (apkUrl !== undefined) updatePayload.apkUrl = apkUrl;
      if (subtitle !== undefined) updatePayload.subtitle = subtitle;

      const updated = await ApkReleaseModel.findOneAndUpdate(
        { appType: appTypeStr as any },
        { $set: updatePayload },
        { new: true, upsert: true }
      );

      res.status(200).json({
        success: true,
        message: `${appTypeStr === 'customer' ? 'Customer App' : 'Rider App'} release metadata updated successfully`,
        data: updated,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // POST /api/v1/apk/:appType/download - Increment download count
  trackDownload: async (req: Request, res: Response): Promise<void> => {
    try {
      const appTypeStr = String(req.params.appType).toLowerCase();
      await syncDefaultApkReleases();

      const updated = await ApkReleaseModel.findOneAndUpdate(
        { appType: appTypeStr as any },
        { $inc: { downloadCount: 1 }, $set: { updatedAt: new Date() } },
        { new: true }
      );

      res.status(200).json({
        success: true,
        message: 'Download tracked successfully',
        data: updated,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
};
