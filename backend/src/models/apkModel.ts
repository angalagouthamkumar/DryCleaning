import mongoose, { Schema, Document } from 'mongoose';

export interface IApkRelease extends Document {
  appType: 'customer' | 'rider';
  appName: string;
  subtitle: string;
  version: string;
  buildDate: string;
  apkSize: string;
  releaseNotes: string;
  status: string;
  downloadCount: number;
  apkUrl: string;
  updatedAt: Date;
}

const ApkReleaseSchema = new Schema<IApkRelease>({
  appType: { type: String, required: true, unique: true },
  appName: { type: String, required: true },
  subtitle: { type: String, required: true, default: 'Latest Production APK' },
  version: { type: String, required: true, default: '1.0.0+1' },
  buildDate: { type: String, required: true, default: 'Aug 3, 2026' },
  apkSize: { type: String, required: true, default: '82.3 MB' },
  releaseNotes: { type: String, required: true, default: 'Initial production release featuring 15-stage order progress tracking, SemPay UPI payment integration, and voice instruction recording.' },
  status: { type: String, required: true, default: 'Production' },
  downloadCount: { type: Number, required: true, default: 0 },
  apkUrl: { type: String, required: true },
  updatedAt: { type: Date, default: Date.now },
});

export const ApkReleaseModel = mongoose.model<IApkRelease>('ApkRelease', ApkReleaseSchema);

export const DEFAULT_APK_RELEASES = [
  {
    appType: 'customer',
    appName: 'Customer App',
    subtitle: 'Latest Production APK',
    version: '1.0.0+1',
    buildDate: 'Aug 3, 2026',
    apkSize: '82.3 MB',
    releaseNotes: 'Official customer mobile app release with 15-stage real-time tracking, live GPS location booking, voice instruction recording, stain photo attachments, and SemPay UPI payment integration.',
    status: 'Production',
    downloadCount: 124,
    apkUrl: '/CustomerApp.apk',
  },
  {
    appType: 'rider',
    appName: 'Rider App',
    subtitle: 'Latest Production APK',
    version: '1.0.0+1',
    buildDate: 'Aug 3, 2026',
    apkSize: '82.1 MB',
    releaseNotes: 'Official rider partner mobile app release with Google Maps turn-by-turn navigation, voice instruction streaming, duty toggle, task detail inspection, and instant delivery earnings ledger.',
    status: 'Production',
    downloadCount: 68,
    apkUrl: '/RiderApp.apk',
  },
];
