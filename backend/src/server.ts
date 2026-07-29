import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes';
import orderRoutes from './routes/orderRoutes';
import { connectDB } from './config/db';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With', 'Origin'],
}));
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'online',
    service: 'Dry Cleaning Quick-Commerce Backend API',
    timestamp: new Date(),
  });
});

// Auth API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/orders', orderRoutes);

// Fallback for 404
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

const startServer = async () => {
  try {
    await connectDB();
  } catch (err) {
    console.error('⚠️ Could not connect to MongoDB Atlas at startup:', err);
  }

  app.listen(PORT, () => {
    console.log(`\n🚀 Dry Cleaning Backend Engine running on http://localhost:${PORT}`);
    console.log(`🔑 Auth Endpoint: http://localhost:${PORT}/api/v1/auth`);
    console.log(`⚙️  Environment: ${process.env.NODE_ENV || 'development'}\n`);
  });
};

startServer();
