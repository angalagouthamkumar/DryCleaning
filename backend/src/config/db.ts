import mongoose from 'mongoose';

let isConnected = false;

export const connectDB = async (): Promise<typeof mongoose> => {
  if (isConnected || mongoose.connection.readyState >= 1) {
    isConnected = true;
    return mongoose;
  }
  
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/drycleaning_db';
  try {
    const conn = await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000,
    });
    isConnected = true;
    console.log(`✅ MongoDB Atlas connected successfully to host: ${conn.connection.host}`);
    return conn;
  } catch (err: any) {
    console.error(`❌ MongoDB Atlas connection error (${err.message}).`);
    throw err;
  }
};
