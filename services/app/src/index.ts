// Environment variables loaded via tsx --env-file flag
// Now import everything else
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { config } from './config/env.js';
import { registerHealthRoutes } from './routes/health.js';
import { registerAuthRoutes } from './routes/auth.js';
import { registerContactRoutes } from './routes/contacts.js';
import { registerPipelineRoutes } from './routes/pipelines.js';
import { registerAiRoutes } from './routes/ai.js';
import { registerIdentityRoutes } from './routes/identity.js';
import { registerAnchorRoutes } from './routes/anchor.js';
import { registerInsightRoutes } from './routes/insights.js';
import { registerOnboardingRoutes } from './routes/onboarding.js';
import { handleError } from './util/errors.js';
import './pipeline/nodes/registry.js';

const app = Fastify({ 
  logger: true,
  requestIdLogLabel: 'reqId',
  disableRequestLogging: false,
});

// CORS
await app.register(cors, { 
  origin: true,
  credentials: true,
});

// Global error handler
app.setErrorHandler((error, request, reply) => {
  const { code, message, statusCode, context } = handleError(error);
  app.log.error({ error, code, context, reqId: request.id }, message);
  reply.code(statusCode).send({ error: code, message, ...context });
});

// Routes
await app.register(registerHealthRoutes);
await app.register(registerAuthRoutes);
await app.register(registerContactRoutes);
await app.register(registerPipelineRoutes);
await app.register(registerAiRoutes);
await app.register(registerIdentityRoutes);
await app.register(registerAnchorRoutes);
await app.register(registerInsightRoutes);
await app.register(registerOnboardingRoutes);

// Cloud Run compatible HTTP server
app.listen({ port: config.server.port, host: config.server.host }, (err) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
  app.log.info(`🚀 Amber API listening on ${config.server.host}:${config.server.port}`);
  app.log.info(`✅ Privy configured: ${config.privy.appId.substring(0, 8)}...`);
});

// Export for Cloud Functions (if needed)
export const http = app;
