import mongoose from 'mongoose';

export const connectDB = async (): Promise<typeof mongoose> => {
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/drycleaning_db';
  try {
    const conn = await mongoose.connect(mongoUri);
    console.log(`✅ MongoDB Atlas connected successfully to host: ${conn.connection.host}, database: ${conn.connection.name}`);
    return conn;
  } catch (err: any) {
    console.error(`❌ MongoDB Atlas connection error (${err.message}).`);
    throw err;
  }
};

