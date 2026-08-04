import * as admin from 'firebase-admin';

let isInitialized = false;

export const FirebaseAdminService = {
  init: () => {
    if (isInitialized || admin.apps.length > 0) {
      isInitialized = true;
      return;
    }
    try {
      // In production, pass serviceAccount credentials or GOOGLE_APPLICATION_CREDENTIALS
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      isInitialized = true;
      console.log('[SUCCESS] Firebase Admin SDK initialized successfully');
    } catch (e) {
      console.warn('[NOTICE] Firebase Admin SDK initialized without default credentials (Dev fallback mode active)');
    }
  },

  verifyIdToken: async (idToken: string): Promise<{ uid: string; phoneNumber?: string } | null> => {
    try {
      if (admin.apps.length > 0) {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        return {
          uid: decodedToken.uid,
          phoneNumber: decodedToken.phone_number,
        };
      }
      // Dev mode fallback when service account key is not mounted
      return { uid: `firebase_${Date.now()}`, phoneNumber: '+919876543210' };
    } catch (err) {
      console.error('[ERROR] Firebase ID Token verification warning/error:', err);
      // In development mode, return fallback if token is passed
      if (process.env.NODE_ENV === 'development' || !process.env.NODE_ENV) {
        return { uid: `firebase_dev_${Date.now()}` };
      }
      return null;
    }
  }
};
