import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`\n[STARTUP] Dry Cleaning Backend Engine running on http://localhost:${PORT}`);
  console.log(`[STARTUP] Auth Endpoint: http://localhost:${PORT}/api/v1/auth`);
  console.log(`[STARTUP] Environment: ${process.env.NODE_ENV || 'development'}\n`);
});
