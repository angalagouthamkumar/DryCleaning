import { Request, Response } from 'express';

export const UploadController = {
  uploadAudio: async (req: Request, res: Response): Promise<void> => {
    try {
      const file = req.file;
      if (!file) {
        res.status(400).json({ success: false, message: 'No audio file uploaded' });
        return;
      }

      const host = req.get('host') || 'localhost:5000';
      const protocol = req.protocol === 'https' || req.get('x-forwarded-proto') === 'https' ? 'https' : 'http';
      const fileUrl = `${protocol}://${host}/uploads/audio/${file.filename}`;

      console.log(`Audio file uploaded successfully: ${fileUrl}`);

      res.status(200).json({
        success: true,
        message: 'Audio file uploaded successfully',
        data: {
          url: fileUrl,
          filename: file.filename,
          size: file.size,
          mimetype: file.mimetype,
        },
      });
    } catch (err: any) {
      console.error('[ERROR] Audio upload exception:', err);
      res.status(500).json({ success: false, message: err.message });
    }
  },

  uploadImage: async (req: Request, res: Response): Promise<void> => {
    try {
      const files = req.files as Express.Multer.File[] | undefined;
      const file = req.file;

      const host = req.get('host') || 'localhost:5000';
      const protocol = req.protocol === 'https' || req.get('x-forwarded-proto') === 'https' ? 'https' : 'http';

      if (files && files.length > 0) {
        const urls = files.map((f) => `${protocol}://${host}/uploads/images/${f.filename}`);
        console.log(`${files.length} Image files uploaded successfully:`, urls);
        res.status(200).json({
          success: true,
          message: 'Images uploaded successfully',
          data: { urls },
        });
        return;
      }

      if (file) {
        const url = `${protocol}://${host}/uploads/images/${file.filename}`;
        console.log(`Image file uploaded successfully: ${url}`);
        res.status(200).json({
          success: true,
          message: 'Image uploaded successfully',
          data: { url, urls: [url] },
        });
        return;
      }

      res.status(400).json({ success: false, message: 'No image file uploaded' });
    } catch (err: any) {
      console.error('[ERROR] Image upload exception:', err);
      res.status(500).json({ success: false, message: err.message });
    }
  },
};
