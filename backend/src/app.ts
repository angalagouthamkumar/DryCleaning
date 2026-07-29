import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes';
import orderRoutes from './routes/orderRoutes';
import { connectDB } from './config/db';

dotenv.config();

const app = express();

app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With', 'Origin'],
}));
app.use(express.json());

// Ensure MongoDB connection for serverless requests
app.use(async (req, res, next) => {
  try {
    await connectDB();
    next();
  } catch (err) {
    console.error('Failed to connect DB:', err);
    next(err);
  }
});

// Request logger middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoints
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

// Auth & Order API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/orders', orderRoutes);

// Fallback for 404
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

export default app;
