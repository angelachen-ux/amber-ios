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
import { registerProfileRoutes } from './routes/profile.js';
import { registerPrivacyRoutes } from './routes/privacy.js';
import { registerSignalRoutes } from './routes/signals.js';
import { registerCircleRoutes } from './routes/circles.js';
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

// ─── Routes ───────────────────────────────────────────────────────────────────

// Legacy / infrastructure
await app.register(registerHealthRoutes);
await app.register(registerAuthRoutes);
await app.register(registerContactRoutes);
await app.register(registerPipelineRoutes);
await app.register(registerAiRoutes);
await app.register(registerIdentityRoutes);
await app.register(registerAnchorRoutes);
await app.register(registerInsightRoutes);

// GCP+Onboarding+Auth
await app.register(registerOnboardingRoutes);
await app.register(registerProfileRoutes);

// Sprint 1 MVP
await app.register(registerPrivacyRoutes);    // PRIVACY-01
await app.register(registerSignalRoutes);     // SIGNAL-01/02/03/04/05
await app.register(registerCircleRoutes);     // SOCIAL-01

// ─── Server ───────────────────────────────────────────────────────────────────

app.listen({ port: config.server.port, host: config.server.host }, (err) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
  app.log.info(`🚀 Amber API listening on ${config.server.host}:${config.server.port}`);
  app.log.info(`✅ Privy configured: ${config.privy.appId.substring(0, 8)}...`);
  app.log.info(`📊 Sentry DSN: ${config.sentry.dsn ? 'configured' : 'not set (optional)'}`);
});

// Export for Cloud Functions (if needed)
export const http = app;
