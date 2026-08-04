import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import authRoutes from './routes/authRoutes';
import orderRoutes from './routes/orderRoutes';
import adminRoutes from './routes/adminRoutes';
import riderRoutes from './routes/riderRoutes';
import serviceRoutes from './routes/serviceRoutes';
import uploadRoutes from './routes/uploadRoutes';
import apkRoutes from './routes/apkRoutes';
import { connectDB } from './config/db';

dotenv.config();

const app = express();

app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With', 'Origin', 'Range'],
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Serve APK files for direct download
const rootDir = path.join(__dirname, '../../');
app.get('/CustomerApp.apk', (req, res) => {
  const filePath = path.join(rootDir, 'CustomerApp.apk');
  if (fs.existsSync(filePath)) {
    res.download(filePath, 'CustomerApp.apk');
  } else {
    res.status(404).json({ success: false, message: 'CustomerApp.apk file not found on server' });
  }
});

app.get('/RiderApp.apk', (req, res) => {
  const filePath = path.join(rootDir, 'RiderApp.apk');
  if (fs.existsSync(filePath)) {
    res.download(filePath, 'RiderApp.apk');
  } else {
    res.status(404).json({ success: false, message: 'RiderApp.apk file not found on server' });
  }
});

// Ensure upload directory exists
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Serve uploaded audio and photo attachments as static files with proper headers
app.use('/uploads', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Range');
  res.header('Accept-Ranges', 'bytes');
  next();
}, express.static(uploadsDir));

// Request logger middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoints (available even if DB is connecting/re-connecting)
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'online',
    service: 'Dry Cleaning Quick-Commerce Backend API',
    timestamp: new Date(),
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'online',
    service: 'Dry Cleaning Quick-Commerce Backend API',
    timestamp: new Date(),
  });
});

app.get('/api/v1/health', (req, res) => {
  res.status(200).json({
    status: 'online',
    service: 'Dry Cleaning Quick-Commerce Backend API',
    timestamp: new Date(),
  });
});

// Ensure MongoDB connection for API routes
app.use(async (req, res, next) => {
  try {
    await connectDB();
  } catch (_) {}
  next();
});

import { ContentController } from './controllers/contentController';

// Auth, Order, Admin, Rider, Services, Upload & APK API Routes
app.get('/api/v1/content', ContentController.getContentMap);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/rider', riderRoutes);
app.use('/api/v1/services', serviceRoutes);
app.use('/api/v1/upload', uploadRoutes);
app.use('/api/v1/apk', apkRoutes);

// Fallback for 404
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

export default app;
