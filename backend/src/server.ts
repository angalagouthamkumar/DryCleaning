import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`\n🚀 Dry Cleaning Backend Engine running on http://localhost:${PORT}`);
  console.log(`🔑 Auth Endpoint: http://localhost:${PORT}/api/v1/auth`);
  console.log(`⚙️  Environment: ${process.env.NODE_ENV || 'development'}\n`);
});
