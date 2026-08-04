import { Request, Response } from 'express';
import { ServiceModel } from '../models/serviceModel';
import { ContentModel } from '../models/contentModel';

export const ServiceController = {
  getServices: async (req: Request, res: Response): Promise<void> => {
    try {
      // 1. Fetch live content dictionary from MongoDB Content collection
      const contentDocs = await ContentModel.find({}).lean();
      const contentMap: Record<string, string> = {};
      contentDocs.forEach((doc) => {
        contentMap[doc.key] = doc.text;
      });

      const parsePriceValue = (priceStr: string, defaultVal: number): number => {
        if (!priceStr) return defaultVal;
        const nums = priceStr.replace(/[^\d.]/g, '');
        const val = parseFloat(nums);
        return isNaN(val) ? defaultVal : val;
      };

      const getLiveText = (keys: string[], defaultText: string) => {
        for (const key of keys) {
          if (contentMap[key] && contentMap[key].trim() !== '') {
            return contentMap[key].trim();
          }
        }
        return defaultText;
      };

      const defaultServices = [
        {
          id: 's1',
          category: getLiveText(['customer.services.category_dry_cleaning'], 'Dry Cleaning'),
          title: getLiveText(['customer.services.s1_title'], "Men's Shirt / T-Shirt"),
          price: getLiveText(['customer.services.s1_price'], '₹60'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s1_price'], '₹60'), 60),
          originalPrice: getLiveText(['customer.services.s1_original_price'], '₹80'),
        },
        {
          id: 's2',
          category: getLiveText(['customer.services.category_dry_cleaning'], 'Dry Cleaning'),
          title: getLiveText(['customer.services.s2_title'], 'Trousers / Jeans'),
          price: getLiveText(['customer.services.s2_price'], '₹70'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s2_price'], '₹70'), 70),
        },
        {
          id: 's3',
          category: getLiveText(['customer.services.category_dry_cleaning'], 'Dry Cleaning'),
          title: getLiveText(['customer.services.s3_title'], '2-Piece Suit'),
          price: getLiveText(['customer.services.s3_price'], '₹250'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s3_price'], '₹250'), 250),
          originalPrice: getLiveText(['customer.services.s3_original_price'], '₹300'),
        },
        {
          id: 's4',
          category: getLiveText(['customer.services.category_dry_cleaning'], 'Dry Cleaning'),
          title: getLiveText(['customer.services.s4_title'], 'Silk Saree / Heavy Lehenga'),
          price: getLiveText(['customer.services.s4_price'], '₹180'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s4_price'], '₹180'), 180),
        },
        {
          id: 's5',
          category: getLiveText(['customer.services.category_wash_fold'], 'Wash & Fold'),
          title: getLiveText(['customer.services.wash_fold_title', 'customer.services.s5_title'], 'Wash & Fold (per kg)'),
          price: getLiveText(['customer.services.wash_fold_price', 'customer.services.s5_price'], '₹60'),
          priceValue: parsePriceValue(getLiveText(['customer.services.wash_fold_price', 'customer.services.s5_price'], '₹60'), 60),
        },
        {
          id: 's6',
          category: getLiveText(['customer.services.category_wash_iron'], 'Wash & Iron'),
          title: getLiveText(['customer.services.s6_title'], 'Daily Wear Wash & Iron'),
          price: getLiveText(['customer.services.s6_price'], '₹80'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s6_price'], '₹80'), 80),
        },
        {
          id: 's7',
          category: getLiveText(['customer.services.category_steam_iron'], 'Steam Iron'),
          title: getLiveText(['customer.services.s7_title', 'customer.services.steam_iron_title'], 'Steam Iron Shirt/Top'),
          price: getLiveText(['customer.services.s7_price'], '₹25'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s7_price'], '₹25'), 25),
        },
        {
          id: 's8',
          category: getLiveText(['customer.services.category_household'], 'Household'),
          title: getLiveText(['customer.services.s8_title'], 'Double Blanket / Quilt'),
          price: getLiveText(['customer.services.s8_price'], '₹350'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s8_price'], '₹350'), 350),
          originalPrice: getLiveText(['customer.services.s8_original_price'], '₹400'),
        },
        {
          id: 's9',
          category: getLiveText(['customer.services.category_household'], 'Household'),
          title: getLiveText(['customer.services.s9_title'], 'Curtain Dry Clean (per panel)'),
          price: getLiveText(['customer.services.s9_price'], '₹120'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s9_price'], '₹120'), 120),
        },
        {
          id: 's10',
          category: getLiveText(['customer.services.category_shoe_care'], 'Shoe Care'),
          title: getLiveText(['customer.services.s10_title'], 'Sneaker Cleaning & Polish'),
          price: getLiveText(['customer.services.s10_price'], '₹299'),
          priceValue: parsePriceValue(getLiveText(['customer.services.s10_price'], '₹299'), 299),
        },
      ];

      const defaultPacks = [
        {
          id: 'p1',
          title: getLiveText(['customer.services.p1_title'], 'Weekly Laundry'),
          subtitle: getLiveText(['customer.services.p1_subtitle'], '5 Shirts + 3 Trousers'),
          price: getLiveText(['customer.services.p1_price'], '₹349'),
          priceValue: parsePriceValue(getLiveText(['customer.services.p1_price'], '₹349'), 349),
        },
        {
          id: 'p2',
          title: getLiveText(['customer.services.p2_title'], 'Office Wear'),
          subtitle: getLiveText(['customer.services.p2_subtitle'], '4 Suits + 4 Ties'),
          price: getLiveText(['customer.services.p2_price'], '₹599'),
          priceValue: parsePriceValue(getLiveText(['customer.services.p2_price'], '₹599'), 599),
        },
        {
          id: 'p3',
          title: getLiveText(['customer.services.p3_title'], 'Family Pack'),
          subtitle: getLiveText(['customer.services.p3_subtitle'], '15 Mixed Items Wash & Iron'),
          price: getLiveText(['customer.services.p3_price'], '₹899'),
          priceValue: parsePriceValue(getLiveText(['customer.services.p3_price'], '₹899'), 899),
        },
      ];

      res.status(200).json({
        success: true,
        data: {
          services: defaultServices,
          packs: defaultPacks,
        },
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
};
