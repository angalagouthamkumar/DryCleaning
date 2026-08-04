import { Request, Response } from 'express';
import { ContentModel, DEFAULT_CUSTOMER_CONTENT } from '../models/contentModel';

const syncDefaultContent = async () => {
  try {
    const bulkOps = DEFAULT_CUSTOMER_CONTENT.map((defaultItem) => ({
      updateOne: {
        filter: { key: defaultItem.key },
        update: { $setOnInsert: defaultItem },
        upsert: true,
      },
    }));
    await ContentModel.bulkWrite(bulkOps);
  } catch (_) {}
};

export const ContentController = {
  // Public GET /api/v1/content - Returns key-value dictionary for Customer App
  getContentMap: async (req: Request, res: Response): Promise<void> => {
    try {
      await syncDefaultContent();
      const items = await ContentModel.find({}).lean();

      const map: Record<string, string> = {};
      items.forEach((item) => {
        map[item.key] = item.text;
      });

      res.status(200).json({
        success: true,
        count: Object.keys(map).length,
        data: map,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // Admin GET /api/v1/admin/content - Returns full item array for Admin Dashboard
  getAllContent: async (req: Request, res: Response): Promise<void> => {
    try {
      await syncDefaultContent();
      const items = await ContentModel.find({}).lean();

      res.status(200).json({
        success: true,
        count: items.length,
        data: items,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // Admin POST /api/v1/admin/content/bulk-update - Bulk updates content items
  bulkUpdateContent: async (req: Request, res: Response): Promise<void> => {
    try {
      const { items } = req.body;
      if (!Array.isArray(items) || items.length === 0) {
        res.status(400).json({ success: false, message: 'Items array is required for bulk update' });
        return;
      }

      const bulkOps = items.map((item: { key: string; text: string }) => ({
        updateOne: {
          filter: { key: item.key },
          update: { $set: { text: item.text, updatedAt: new Date() } },
        },
      }));

      await ContentModel.bulkWrite(bulkOps);
      const updatedList = await ContentModel.find({}).lean();

      res.status(200).json({
        success: true,
        message: `${items.length} content item(s) updated successfully`,
        data: updatedList,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
};
