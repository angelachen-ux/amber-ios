/**
 * ONBOARD-01: Onboarding flow — immutable objects collection
 * ONBOARD-02: Device token registration for APNs
 */
import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { db, schema } from '../db/client.js';
import { eq } from 'drizzle-orm';
import { authenticate, AuthenticatedRequest } from '../auth/middleware.js';

const HOROSCOPE_SIGNS = [
  { sign: 'Capricorn', start: [12, 22], end: [1, 19] },
  { sign: 'Aquarius',  start: [1, 20],  end: [2, 18] },
  { sign: 'Pisces',    start: [2, 19],  end: [3, 20] },
  { sign: 'Aries',     start: [3, 21],  end: [4, 19] },
  { sign: 'Taurus',    start: [4, 20],  end: [5, 20] },
  { sign: 'Gemini',    start: [5, 21],  end: [6, 20] },
  { sign: 'Cancer',    start: [6, 21],  end: [7, 22] },
  { sign: 'Leo',       start: [7, 23],  end: [8, 22] },
  { sign: 'Virgo',     start: [8, 23],  end: [9, 22] },
  { sign: 'Libra',     start: [9, 23],  end: [10, 22] },
  { sign: 'Scorpio',   start: [10, 23], end: [11, 21] },
  { sign: 'Sagittarius', start: [11, 22], end: [12, 21] },
];

function deriveHoroscope(birthday: Date): string {
  const m = birthday.getMonth() + 1;
  const d = birthday.getDate();
  for (const { sign, start, end } of HOROSCOPE_SIGNS) {
    const [sm, sd] = start;
    const [em, ed] = end;
    if ((m === sm && d >= sd) || (m === em && d <= ed)) return sign;
  }
  return 'Capricorn'; // fallback for Dec 22–31
}

const OnboardingSchema = z.object({
  displayName: z.string().min(1),
  birthday: z.string(), // ISO8601
  birthdayLocation: z.string().optional(),
  almaMater: z.string().optional(),
  hometown: z.string().optional(),
  currentCity: z.string().optional(),
});

const DeviceTokenSchema = z.object({
  apnsDeviceToken: z.string().min(1),
});

export async function registerOnboardingRoutes(app: FastifyInstance) {
  /**
   * GET /onboarding/profile
   * Fetch the current user's profile (or null if not yet onboarded)
   */
  app.get('/onboarding/profile', { preHandler: authenticate }, async (req: AuthenticatedRequest) => {
    const [profile] = await db
      .select()
      .from(schema.userProfiles)
      .where(eq(schema.userProfiles.userId, req.userId!))
      .limit(1);
    return profile ?? null;
  });

  /**
   * PUT /onboarding/profile
   * Upsert the immutable identity objects. Horoscope is auto-derived.
   */
  app.put('/onboarding/profile', { preHandler: authenticate }, async (req: AuthenticatedRequest) => {
    const body = OnboardingSchema.parse(req.body);
    const birthday = new Date(body.birthday);
    const horoscope = deriveHoroscope(birthday);

    const existing = await db
      .select({ id: schema.userProfiles.id })
      .from(schema.userProfiles)
      .where(eq(schema.userProfiles.userId, req.userId!))
      .limit(1);

    if (existing.length > 0) {
      const [updated] = await db
        .update(schema.userProfiles)
        .set({
          displayName: body.displayName,
          birthday,
          birthdayLocation: body.birthdayLocation,
          horoscopeSign: horoscope,
          almaFkMater: body.almaMater,
          hometown: body.hometown,
          currentCity: body.currentCity,
          onboardingComplete: true,
          updatedAt: new Date(),
        })
        .where(eq(schema.userProfiles.userId, req.userId!))
        .returning();
      return updated;
    }

    const [created] = await db
      .insert(schema.userProfiles)
      .values({
        userId: req.userId!,
        displayName: body.displayName,
        birthday,
        birthdayLocation: body.birthdayLocation,
        horoscopeSign: horoscope,
        almaFkMater: body.almaMater,
        hometown: body.hometown,
        currentCity: body.currentCity,
        onboardingComplete: true,
      })
      .returning();
    return created;
  });

  /**
   * POST /onboarding/device-token
   * ONBOARD-02 / SIGNAL-02: Register APNs device token for push notifications
   */
  app.post('/onboarding/device-token', { preHandler: authenticate }, async (req: AuthenticatedRequest) => {
    const { apnsDeviceToken } = DeviceTokenSchema.parse(req.body);
    await db
      .update(schema.users)
      .set({ apnsDeviceToken })
      .where(eq(schema.users.id, req.userId!));
    return { ok: true };
  });
}
