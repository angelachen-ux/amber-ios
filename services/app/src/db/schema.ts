import {
  pgTable,
  serial,
  text,
  timestamp,
  jsonb,
  varchar,
  integer,
  boolean,
  pgEnum,
} from 'drizzle-orm/pg-core';

// ─── Enums ───────────────────────────────────────────────────────────────────

export const relationshipTypeEnum = pgEnum('relationship_type', [
  'parent', 'sibling', 'partner', 'child', 'other',
]);
export const insightPriorityEnum = pgEnum('insight_priority', ['high', 'medium', 'low']);
export const insightTopicEnum = pgEnum('insight_topic', ['health', 'connection', 'memory']);
export const runStatusEnum = pgEnum('run_status', ['queued', 'running', 'succeeded', 'failed']);

// PRIVACY-01
export const privacyTierEnum = pgEnum('privacy_tier', [
  'local_only',    // All data stays on device. Zero cloud sync.
  'selective',     // User chooses which fields sync.
  'full_social',   // All permitted data syncs. Full signal matching.
]);

// SIGNAL-01/02/03/04/05
export const signalTypeEnum = pgEnum('signal_type', [
  'birthday_3day',
  'birthday_1day',
  'birthday_today',
  'shared_calendar_event',
  'questionnaire_match',
]);

export const signalStatusEnum = pgEnum('signal_status', [
  'pending',
  'sent',
  'viewed',
  'acted',
  'dismissed',
]);

// ─── Core User Tables ─────────────────────────────────────────────────────────

// Users (linked to Privy)
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  privyUserId: varchar('privy_user_id', { length: 255 }).notNull().unique(),
  didPrimary: varchar('did_primary', { length: 255 }),
  privacyTier: privacyTierEnum('privacy_tier').default('local_only').notNull(),
  apnsDeviceToken: varchar('apns_device_token', { length: 512 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

// ONBOARD-01: Immutable identity objects (name, birthday, alma mater, hometown, city)
export const userProfiles = pgTable('user_profiles', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull().unique(),
  displayName: varchar('display_name', { length: 255 }),
  birthday: timestamp('birthday', { withTimezone: true }),       // date + time for horoscope
  birthdayLocation: varchar('birthday_location', { length: 255 }), // city of birth for rising sign
  horoscopeSign: varchar('horoscope_sign', { length: 50 }),     // auto-derived
  almaFkMater: varchar('alma_mater', { length: 255 }),
  hometown: varchar('hometown', { length: 255 }),
  currentCity: varchar('current_city', { length: 255 }),
  onboardingComplete: boolean('onboarding_complete').default(false).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// PRIVACY-01: Field-level permission table — controls which fields sync to cloud
export const userPermissions = pgTable('user_permissions', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull(),
  fieldType: varchar('field_type', { length: 100 }).notNull(), // e.g. 'contacts', 'birthday', 'health', 'calendar', 'location'
  syncEnabled: boolean('sync_enabled').default(false).notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// PRIVACY-01: Audit log for permission changes
export const permissionAuditLog = pgTable('permission_audit_log', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull(),
  fieldType: varchar('field_type', { length: 100 }).notNull(),
  oldValue: boolean('old_value'),
  newValue: boolean('new_value').notNull(),
  changedAt: timestamp('changed_at', { withTimezone: true }).defaultNow().notNull(),
});

// ─── Contact Graph ────────────────────────────────────────────────────────────

// DATA-01: iMessage contact graph — synced for selective/full_social users
export const contacts = pgTable('contacts', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull(),
  externalId: varchar('external_id', { length: 255 }), // CNContact identifier
  name: text('name').notNull(),
  phoneNumbers: jsonb('phone_numbers').$type<string[]>().default([]),
  emails: jsonb('emails').$type<string[]>().default([]),
  birthday: timestamp('birthday', { withTimezone: true }),
  messageFrequency: integer('message_frequency').default(0), // messages/30d
  lastContactedAt: timestamp('last_contacted_at', { withTimezone: true }),
  relationshipScore: integer('relationship_score').default(0), // 0-100
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// ─── Signals ──────────────────────────────────────────────────────────────────

// SIGNAL-01/04/05: Suggestion signals — one row per potential nudge
export const signals = pgTable('signals', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull(),
  contactId: integer('contact_id').references(() => contacts.id),
  signalType: signalTypeEnum('signal_type').notNull(),
  triggerDate: timestamp('trigger_date', { withTimezone: true }).notNull(),
  status: signalStatusEnum('status').default('pending').notNull(),
  payload: jsonb('payload'),  // event_id, match_type, etc.
  dedupeKey: varchar('dedupe_key', { length: 255 }).unique(), // prevents re-firing
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  sentAt: timestamp('sent_at', { withTimezone: true }),
  actedAt: timestamp('acted_at', { withTimezone: true }),
});

// ─── Circles (SOCIAL-01) ──────────────────────────────────────────────────────

export const circleVisibilityEnum = pgEnum('circle_visibility', ['private', 'members', 'public']);

export const circles = pgTable('circles', {
  id: serial('id').primaryKey(),
  createdByUserId: integer('created_by_user_id').references(() => users.id).notNull(),
  name: varchar('name', { length: 255 }).notNull(),
  visibility: circleVisibilityEnum('visibility').default('private').notNull(),
  inviteToken: varchar('invite_token', { length: 64 }).unique(), // for iMessage share link
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const circleMembers = pgTable('circle_members', {
  id: serial('id').primaryKey(),
  circleId: integer('circle_id').references(() => circles.id).notNull(),
  userId: integer('user_id').references(() => users.id).notNull(),
  joinedAt: timestamp('joined_at', { withTimezone: true }).defaultNow().notNull(),
});

// ─── Legacy tables (kept for backwards compat) ────────────────────────────────

export const persons = pgTable('persons', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  name: text('name').notNull(),
  dob: timestamp('dob', { withTimezone: true }),
  email: varchar('email', { length: 255 }),
  cNFT: varchar('c_nft', { length: 255 }),
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

export const wallets = pgTable('wallets', {
  id: serial('id').primaryKey(),
  personId: integer('person_id').references(() => persons.id).notNull(),
  chain: varchar('chain', { length: 50 }).default('solana').notNull(),
  address: varchar('address', { length: 255 }).notNull(),
  verified: timestamp('verified', { withTimezone: true }),
  labels: jsonb('labels'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const relationships = pgTable('relationships', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  fromId: integer('from_id').references(() => persons.id).notNull(),
  toId: integer('to_id').references(() => persons.id).notNull(),
  type: relationshipTypeEnum('type').notNull(),
  strength: integer('strength').default(50),
  evidenceHash: varchar('evidence_hash', { length: 255 }),
  s3Uri: varchar('s3_uri', { length: 512 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const pipelineDefs = pgTable('pipeline_defs', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  name: varchar('name', { length: 255 }).notNull(),
  def: jsonb('def').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const pipelineRuns = pgTable('pipeline_runs', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  defId: integer('def_id').references(() => pipelineDefs.id),
  status: runStatusEnum('status').notNull(),
  log: jsonb('log').$type<string[]>().default([]),
  result: jsonb('result'),
  startedAt: timestamp('started_at', { withTimezone: true }).defaultNow().notNull(),
  endedAt: timestamp('ended_at', { withTimezone: true }),
});

export const insights = pgTable('insights', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  priority: insightPriorityEnum('priority').notNull(),
  topic: insightTopicEnum('topic').notNull(),
  content: text('content').notNull(),
  sources: jsonb('sources').$type<string[]>().default([]),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const vcRecords = pgTable('vc_records', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id).notNull(),
  issuer: varchar('issuer', { length: 255 }).notNull(),
  schemaId: varchar('schema_id', { length: 255 }),
  s3Uri: varchar('s3_uri', { length: 512 }),
  contentHash: varchar('content_hash', { length: 255 }).notNull(),
  status: varchar('status', { length: 50 }).default('active'),
  issuedAt: timestamp('issued_at', { withTimezone: true }).defaultNow().notNull(),
  revokedAt: timestamp('revoked_at', { withTimezone: true }),
});

export const anchors = pgTable('anchors', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  kind: varchar('kind', { length: 100 }),
  contentHash: varchar('content_hash', { length: 255 }).notNull(),
  chainTx: varchar('chain_tx', { length: 255 }),
  uri: varchar('uri', { length: 512 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});
