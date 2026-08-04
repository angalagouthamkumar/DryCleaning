import mongoose from 'mongoose';

let isConnected = false;

export const connectDB = async (): Promise<typeof mongoose | null> => {
  if (isConnected || mongoose.connection.readyState >= 1) {
    isConnected = true;
    return mongoose;
  }
  
  const mongoUri = process.env.MONGO_URI || 'mongodb+srv://gouthamkumar5523_db_user:BjBZRwCAa9sDLqFv@drclean.4jpda6i.mongodb.net/test?retryWrites=true&w=majority';
  try {
    const conn = await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 3000,
    });
    isConnected = true;
    console.log(`[SUCCESS] MongoDB Atlas connected successfully to host: ${conn.connection.host}`);
    return conn;
  } catch (err: any) {
    console.error(`[NOTICE] MongoDB Atlas connection notice (${err.message}). Proceeding with OrderStore fallback.`);
    return null;
  }
};
