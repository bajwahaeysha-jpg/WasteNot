require("dotenv").config();

const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const SENDGRID_KEY = process.env.SENDGRID_KEY;
const ADMIN_EMAIL = "wastenotapplication@gmail.com";

if (SENDGRID_KEY) {
  sgMail.setApiKey(SENDGRID_KEY);
}

const USERS_COLLECTION = "users";
const NGO_REQUESTS_COLLECTION = "ngo_requests";
const DONATIONS_COLLECTION = "donations";
const NOTIFICATIONS_COLLECTION = "notifications";
const FEEDBACK_COLLECTION = "feedback";
const CONCERNS_COLLECTION = "concerns";
const ADMIN_ACTIVITY_LOGS_COLLECTION = "admin_activity_logs";
const ADMIN_NOTIFICATIONS_COLLECTION = "admin_notifications";
const DELETED_USER_DISPLAY_NAME = "Deleted User";
const DEFAULT_BATCH_SIZE = 250;

const ROLE_TOPICS = {
  admin: "role_admin",
  ngo: "role_ngo",
  donor: "role_donor",
};

const NOTIFICATION_TYPES = {
  NEW_NGO_REGISTRATION: "NEW_NGO_REGISTRATION",
  NGO_APPROVED: "NGO_APPROVED",
  NEW_DONATION: "NEW_DONATION",
  DONATION_ACCEPTED: "DONATION_ACCEPTED",
  DONOR_REMINDER: "DONOR_REMINDER",
  DONATION_EXPIRING_SOON: "DONATION_EXPIRING_SOON",
  DONATION_EXPIRED: "DONATION_EXPIRED",
};

const GOALS_COLLECTION = "goals";
const DONATION_EXPIRY_MS = 2 * 60 * 60 * 1000;
const DONATION_EXPIRING_SOON_MS = 20 * 60 * 1000;
const NGO_NOTIFICATION_RADIUS_KM = 25;

exports.sendEmailOnNewMessage = onDocumentCreated(
  "contact_messages/{id}",
  async (event) => {
    if (!SENDGRID_KEY) {
      console.error("SENDGRID_KEY missing. Contact email was skipped.");
      return;
    }

    const data = event.data?.data() || {};
    const msg = {
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: `New Contact Message from ${String(data.role || "unknown").toUpperCase()}`,
      text: `
Name: ${data.name || "Unknown"}
Email: ${data.email || "Unknown"}
Role: ${data.role || "unknown"}

Message:
${data.message || ""}
`,
    };

    await sgMail.send(msg);
  },
);

function buildPayload({ title, body, type, userRole, navigation }) {
  return { title, body, type, userRole, navigation };
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function toDataMap(payload, extraData = {}) {
  const merged = { ...payload, ...extraData };
  return Object.fromEntries(
    Object.entries(merged)
      .filter(([, value]) => value !== undefined && value !== null)
      .map(([key, value]) => [key, String(value)]),
  );
}

function nowTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

function timestampFromDate(value) {
  return admin.firestore.Timestamp.fromDate(value);
}

async function isNotificationsEnabled(uid) {
  const userDoc = await db.collection(USERS_COLLECTION).doc(uid).get();
  if (!userDoc.exists) {
    return false;
  }

  return userDoc.data()?.notificationsEnabled !== false;
}

async function saveNotificationRecord({ uid, payload, extraData = {} }) {
  const notificationRef = db.collection(NOTIFICATIONS_COLLECTION).doc();
  await notificationRef.set({
    notificationId: notificationRef.id,
    receiverId: uid,
    uid,
    userId: uid,
    title: payload.title,
    body: payload.body,
    message: payload.body,
    type: payload.type,
    userRole: payload.userRole,
    navigation: payload.navigation,
    createdAt: nowTimestamp(),
    timestamp: nowTimestamp(),
    isRead: false,
    read: false,
    ...extraData,
  });
}

async function loadUserTokens(uid) {
  const snapshot = await db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection("fcm_tokens")
    .where("isActive", "!=", false)
    .get();

  const tokens = snapshot.docs
    .map((doc) => doc.data()?.token)
    .filter((token) => typeof token === "string" && token.trim().length > 0)
    .map((token) => token.trim());

  const uniqueTokens = [...new Set(tokens)];
  console.log("FCM loadUserTokens", { uid, tokenCount: uniqueTokens.length, tokens: uniqueTokens });
  return uniqueTokens;
}

async function deleteToken(uid, token) {
  console.warn("FCM deleting stale token", { uid, token });
  await db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection("fcm_tokens")
    .doc(token)
    .delete()
    .catch(() => null);
}

async function loadUserTokensWithRetry(uid, { retries = 1, delayMs = 2500 } = {}) {
  let tokens = await loadUserTokens(uid);
  for (let attempt = 1; tokens.length === 0 && attempt <= retries; attempt += 1) {
    console.warn("FCM token list empty, retrying", { uid, attempt, delayMs });
    await sleep(delayMs);
    tokens = await loadUserTokens(uid);
  }

  return tokens;
}

async function sendMessageToToken({ uid, token, payload, extraData = {} }) {
  try {
    const messageId = await messaging.send({
      token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: toDataMap(payload, extraData),
      android: {
        priority: "high",
        notification: {
          channelId: "wastenot_fcm_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            contentAvailable: true,
          },
        },
      },
    });
    console.log("FCM sent", {
      uid,
      token,
      messageId,
      type: payload.type,
      navigation: payload.navigation,
    });
    return true;
  } catch (error) {
    const code = error?.errorInfo?.code || error?.code || "";
    if (code.includes("registration-token-not-registered") || code.includes("invalid-registration-token")) {
      await deleteToken(uid, token);
    }
    console.error(`FCM send failed for uid=${uid}`, error);
    return false;
  }
}

async function sendToUser({
  uid,
  payload,
  extraData = {},
  persist = true,
  retryIfNoTokens = true,
}) {
  const trimmedUid = `${uid || ""}`.trim();
  if (!trimmedUid) {
    console.warn("FCM send skipped: empty uid", { payload });
    return 0;
  }

  const notificationsEnabled = await isNotificationsEnabled(trimmedUid);
  if (!notificationsEnabled) {
    console.log("FCM send skipped: notifications disabled", { uid: trimmedUid, type: payload.type });
    return 0;
  }

  console.log("FCM sendToUser start", {
    uid: trimmedUid,
    type: payload.type,
    navigation: payload.navigation,
    persist,
  });

  if (persist) {
    await saveNotificationRecord({
      uid: trimmedUid,
      payload,
      extraData,
    });
  }

  const tokens = await loadUserTokensWithRetry(trimmedUid, {
    retries: retryIfNoTokens ? 1 : 0,
    delayMs: 2500,
  });
  if (tokens.length === 0) {
    console.warn("FCM send skipped: no active tokens", {
      uid: trimmedUid,
      type: payload.type,
      extraData,
    });
    return 0;
  }

  let delivered = 0;

  for (const token of tokens) {
    const sent = await sendMessageToToken({
      uid: trimmedUid,
      token,
      payload,
      extraData,
    });
    if (sent) {
      delivered += 1;
    }
  }

  console.log("FCM sendToUser complete", {
    uid: trimmedUid,
    delivered,
    requestedTokens: tokens.length,
    type: payload.type,
  });
  return delivered;
}

async function sendToTopic({ topic, payload, extraData = {} }) {
  const messageId = await messaging.send({
    topic,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: toDataMap(payload, extraData),
    android: {
      priority: "high",
      notification: {
        channelId: "wastenot_fcm_channel",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          contentAvailable: true,
        },
      },
    },
  });
  console.log("FCM topic send", {
    topic,
    messageId,
    type: payload.type,
    navigation: payload.navigation,
  });
}

async function sendToUsersByRole({
  role,
  payload,
  extraData = {},
  filters = [],
  fallbackTopic = false,
}) {
  let query = db.collection(USERS_COLLECTION).where("role", "==", role);
  for (const [field, op, value] of filters) {
    query = query.where(field, op, value);
  }

  const snapshot = await query.get();
  if (snapshot.empty) {
    console.warn("FCM role send: no matching users", { role, filters, fallbackTopic });
    if (fallbackTopic && ROLE_TOPICS[role]) {
      await sendToTopic({
        topic: ROLE_TOPICS[role],
        payload,
        extraData,
      });
    }
    return 0;
  }

  let delivered = 0;
  for (const doc of snapshot.docs) {
    const deliveredToUser = await sendToUser({
      uid: doc.id,
      payload,
      extraData,
    });
    delivered += deliveredToUser;
  }

  if (delivered === 0 && fallbackTopic && ROLE_TOPICS[role]) {
    console.warn("FCM role send fallback to topic because direct delivery count is zero", {
      role,
      userCount: snapshot.size,
      type: payload.type,
    });
    await sendToTopic({
      topic: ROLE_TOPICS[role],
      payload,
      extraData,
    });
  }

  return delivered;
}

async function markDocument(path, data) {
  await db.doc(path).set(data, { merge: true });
}

function timestampToDate(value) {
  if (!value) {
    return null;
  }
  if (typeof value.toDate === "function") {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  return null;
}

function toTrimmedString(value) {
  return typeof value === "string" ? value.trim() : "";
}

function toNumber(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value.trim());
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  return null;
}

function locationFromDynamic(value) {
  if (!value || typeof value !== "object") {
    return null;
  }

  const latitude = toNumber(value.latitude ?? value.lat);
  const longitude = toNumber(value.longitude ?? value.lng);
  if (latitude === null || longitude === null) {
    return null;
  }

  return {
    latitude,
    longitude,
    address: toTrimmedString(value.address ?? value.label),
  };
}

function donationLocationFromData(data) {
  return (
    locationFromDynamic(data.location) ||
    locationFromDynamic(data.pickupLocation) || {
      latitude: toNumber(data.donationLatitude),
      longitude: toNumber(data.donationLongitude),
      address: toTrimmedString(data.donationAddress),
    }
  );
}

function isValidLocation(location) {
  return Number.isFinite(location?.latitude) && Number.isFinite(location?.longitude);
}

function haversineKm(from, to) {
  const toRadians = (value) => (value * Math.PI) / 180;
  const earthRadiusKm = 6371;
  const deltaLat = toRadians(to.latitude - from.latitude);
  const deltaLng = toRadians(to.longitude - from.longitude);
  const a = Math.sin(deltaLat / 2) ** 2 +
    Math.cos(toRadians(from.latitude)) *
      Math.cos(toRadians(to.latitude)) *
      Math.sin(deltaLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusKm * c;
}

function resolveDonationExpiryTime(data) {
  const explicitExpiry = timestampToDate(data.expiresAt) || timestampToDate(data.expiryAt);
  if (explicitExpiry) {
    return explicitExpiry;
  }

  const createdAt = timestampToDate(data.createdAt);
  if (!createdAt) {
    return null;
  }

  return new Date(createdAt.getTime() + DONATION_EXPIRY_MS);
}

async function sendToNearbyNgos({
  donationId,
  donationData,
  payload,
  extraData = {},
}) {
  const donationLocation = donationLocationFromData(donationData);
  if (!isValidLocation(donationLocation)) {
    console.warn("Nearby NGO notification fallback: donation location missing", { donationId });
    return sendToUsersByRole({
      role: "ngo",
      payload,
      extraData,
      filters: [["approvedByAdmin", "==", true]],
      fallbackTopic: true,
    });
  }

  const ngoSnapshot = await db
    .collection(USERS_COLLECTION)
    .where("role", "==", "ngo")
    .where("approvedByAdmin", "==", true)
    .get();

  let delivered = 0;
  let matchedNgoCount = 0;

  for (const ngoDoc of ngoSnapshot.docs) {
    const ngoLocation = locationFromDynamic(ngoDoc.data()?.location);
    if (!isValidLocation(ngoLocation)) {
      continue;
    }

    const distanceKm = haversineKm(donationLocation, ngoLocation);
    if (distanceKm > NGO_NOTIFICATION_RADIUS_KM) {
      continue;
    }

    matchedNgoCount += 1;
    const deliveredToUser = await sendToUser({
      uid: ngoDoc.id,
      payload,
      extraData: {
        ...extraData,
        distanceKm: distanceKm.toFixed(1),
      },
    });
    delivered += deliveredToUser;
  }

  console.log("Nearby NGO expiry notification result", {
    donationId,
    matchedNgoCount,
    delivered,
    radiusKm: NGO_NOTIFICATION_RADIUS_KM,
  });

  return delivered;
}

function monthKeyForDate(date) {
  const month = `${date.getUTCMonth() + 1}`.padStart(2, "0");
  return `${date.getUTCFullYear()}-${month}`;
}

function monthBoundsFromKey(monthKey) {
  const parts = `${monthKey}`.split("-");
  if (parts.length !== 2) {
    return null;
  }

  const year = Number.parseInt(parts[0], 10);
  const month = Number.parseInt(parts[1], 10);
  if (!Number.isInteger(year) || !Number.isInteger(month)) {
    return null;
  }

  return {
    start: new Date(Date.UTC(year, month - 1, 1, 0, 0, 0, 0)),
    end: new Date(Date.UTC(year, month, 1, 0, 0, 0, 0)),
  };
}

function monthLabelFromKey(monthKey) {
  const bounds = monthBoundsFromKey(monthKey);
  if (!bounds) {
    return "this";
  }

  return bounds.start.toLocaleString("en-US", {
    month: "long",
    timeZone: "UTC",
  });
}

function parseMealsToInt(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.max(0, Math.trunc(value));
  }

  if (typeof value !== "string") {
    return 0;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return 0;
  }

  const direct = Number.parseInt(trimmed, 10);
  if (Number.isInteger(direct)) {
    return Math.max(0, direct);
  }

  const matches = trimmed.match(/\d+/g);
  if (!matches || matches.length === 0) {
    return 0;
  }

  if (matches.length >= 2 && trimmed.includes("-")) {
    const min = Number.parseInt(matches[0], 10);
    const max = Number.parseInt(matches[1], 10);
    if (Number.isInteger(min) && Number.isInteger(max)) {
      return Math.max(0, Math.round((min + max) / 2));
    }
  }

  return Math.max(0, Number.parseInt(matches[0], 10));
}

function calculateGoalPercentage(achieved, target) {
  if (!target || target <= 0) {
    return 0;
  }
  return Math.round((achieved / target) * 100);
}

function requireAdminCaller(request) {
  const callerEmail = `${request.auth?.token?.email || ""}`.trim().toLowerCase();
  if (callerEmail !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Only the admin can perform this action.");
  }

  return callerEmail;
}

function chunkArray(items, size = DEFAULT_BATCH_SIZE) {
  const chunks = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

function resolveDeletedUserName(userData, role, fallbackEmail = "") {
  const normalizedRole = `${role || ""}`.trim().toLowerCase();
  const resolvedName = toTrimmedString(
    userData.organizationName ||
      userData.name ||
      userData.displayName ||
      userData.fullName ||
      userData.receiverName,
  );
  if (resolvedName) {
    return resolvedName;
  }

  const resolvedEmail = toTrimmedString(userData.email || fallbackEmail);
  if (resolvedEmail) {
    return resolvedEmail;
  }

  if (normalizedRole === "ngo") {
    return "NGO";
  }
  if (normalizedRole === "donor") {
    return "Donor";
  }
  return "User";
}

function buildDeletionAuditFields({
  uid,
  originalName,
  role,
}) {
  return {
    isUserDeleted: true,
    deletedUserId: uid,
    deletedUserName: originalName,
    deletedUserRole: role,
    userDeletedAt: nowTimestamp(),
  };
}

async function updateDocumentsInQuery(query, buildUpdate) {
  const snapshot = await query.get();
  if (snapshot.empty) {
    return 0;
  }

  const chunks = chunkArray(snapshot.docs);
  for (const docs of chunks) {
    const batch = db.batch();
    for (const doc of docs) {
      batch.set(doc.ref, buildUpdate(doc.data() || {}, doc.id), { merge: true });
    }
    await batch.commit();
  }

  return snapshot.size;
}

async function detachDonationReferences({
  uid,
  role,
  originalName,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  let updated = 0;

  if (role === "donor") {
    updated += await updateDocumentsInQuery(
      db.collection(DONATIONS_COLLECTION).where("donorId", "==", uid),
      () => ({
        donorId: null,
        donorName: DELETED_USER_DISPLAY_NAME,
        donorEmail: null,
        donorPhone: null,
        donorAddress: null,
        donorProfileImageUrl: null,
        isDonorDeleted: true,
        deletedDonorId: uid,
        deletedDonorName: originalName,
        donorDeletedAt: nowTimestamp(),
        ...auditFields,
      }),
    );
    return updated;
  }

  updated += await updateDocumentsInQuery(
    db.collection(DONATIONS_COLLECTION).where("acceptedByNgoId", "==", uid),
    () => ({
      acceptedByNgoId: null,
      acceptedByNgoName: DELETED_USER_DISPLAY_NAME,
      acceptedByNgoEmail: null,
      acceptedByNgoPhone: null,
      acceptedByNgoAddress: null,
      acceptedByNgoLocation: null,
      acceptedByNgoProfileImageUrl: null,
      isAcceptedNgoDeleted: true,
      deletedAcceptedNgoId: uid,
      deletedAcceptedNgoName: originalName,
      acceptedNgoDeletedAt: nowTimestamp(),
      ...auditFields,
    }),
  );

  updated += await updateDocumentsInQuery(
    db.collection(DONATIONS_COLLECTION).where("ngoId", "==", uid),
    () => ({
      ngoId: null,
      ngoName: DELETED_USER_DISPLAY_NAME,
      ngoEmail: null,
      ngoPhone: null,
      ngoAddress: null,
      isNgoDeleted: true,
      deletedNgoId: uid,
      deletedNgoName: originalName,
      ngoDeletedAt: nowTimestamp(),
      ...auditFields,
    }),
  );

  updated += await updateDocumentsInQuery(
    db.collection(DONATIONS_COLLECTION).where("rejectedByNgoIds", "array-contains", uid),
    (data) => {
      const rejectedIds = Array.isArray(data.rejectedByNgoIds)
        ? data.rejectedByNgoIds
        : [];
      return {
        rejectedByNgoIds: rejectedIds.filter((value) => `${value || ""}`.trim() !== uid),
      };
    },
  );

  return updated;
}

async function detachFeedbackReferences({
  uid,
  role,
  originalName,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  if (role === "donor") {
    return updateDocumentsInQuery(
      db.collection(FEEDBACK_COLLECTION).where("donorId", "==", uid),
      () => ({
        donorId: null,
        donorName: DELETED_USER_DISPLAY_NAME,
        donorProfileImage: null,
        isDonorDeleted: true,
        deletedDonorId: uid,
        deletedDonorName: originalName,
        donorDeletedAt: nowTimestamp(),
        ...auditFields,
      }),
    );
  }

  return updateDocumentsInQuery(
    db.collection(FEEDBACK_COLLECTION).where("ngoId", "==", uid),
    () => ({
      ngoId: null,
      ngoName: DELETED_USER_DISPLAY_NAME,
      ngoProfileImage: null,
      isNgoDeleted: true,
      deletedNgoId: uid,
      deletedNgoName: originalName,
      ngoDeletedAt: nowTimestamp(),
      ...auditFields,
    }),
  );
}

async function detachConcernReferences({
  uid,
  role,
  originalName,
  auditFields,
}) {
  if (role !== "ngo") {
    return 0;
  }

  return updateDocumentsInQuery(
    db.collection(CONCERNS_COLLECTION).where("ngoId", "==", uid),
    () => ({
      ngoId: null,
      ngoName: DELETED_USER_DISPLAY_NAME,
      ngoEmail: null,
      isNgoDeleted: true,
      deletedNgoId: uid,
      deletedNgoName: originalName,
      ngoDeletedAt: nowTimestamp(),
      ...auditFields,
    }),
  );
}

async function detachGoalReferences({
  uid,
  originalName,
  role,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  let updated = 0;
  updated += await updateDocumentsInQuery(
    db.collection(GOALS_COLLECTION).where("userId", "==", uid),
    () => ({
      userId: null,
      uid: null,
      ...auditFields,
      deletedGoalOwnerName: originalName,
      deletedGoalOwnerRole: role,
    }),
  );

  updated += await updateDocumentsInQuery(
    db.collection(GOALS_COLLECTION).where("uid", "==", uid),
    () => ({
      userId: null,
      uid: null,
      ...auditFields,
      deletedGoalOwnerName: originalName,
      deletedGoalOwnerRole: role,
    }),
  );

  return updated;
}

async function detachNotificationReferences({
  uid,
  role,
  originalName,
  email,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  const seenPaths = new Set();
  const runUniqueUpdate = async (query, buildUpdate) => {
    const snapshot = await query.get();
    if (snapshot.empty) {
      return 0;
    }

    const docs = snapshot.docs.filter((doc) => {
      if (seenPaths.has(doc.ref.path)) {
        return false;
      }
      seenPaths.add(doc.ref.path);
      return true;
    });
    if (docs.length === 0) {
      return 0;
    }

    for (const chunk of chunkArray(docs)) {
      const batch = db.batch();
      for (const doc of chunk) {
        batch.set(doc.ref, buildUpdate(doc.data() || {}, doc.id), { merge: true });
      }
      await batch.commit();
    }

    return docs.length;
  };

  let updated = 0;
  const baseUpdate = {
    receiverId: null,
    uid: null,
    userId: null,
    email: null,
    ...auditFields,
  };

  updated += await runUniqueUpdate(
    db.collection(NOTIFICATIONS_COLLECTION).where("receiverId", "==", uid),
    () => baseUpdate,
  );
  updated += await runUniqueUpdate(
    db.collection(NOTIFICATIONS_COLLECTION).where("uid", "==", uid),
    () => baseUpdate,
  );
  updated += await runUniqueUpdate(
    db.collection(NOTIFICATIONS_COLLECTION).where("userId", "==", uid),
    () => baseUpdate,
  );

  if (role === "donor") {
    updated += await runUniqueUpdate(
      db.collection(NOTIFICATIONS_COLLECTION).where("donorId", "==", uid),
      () => ({
        donorId: null,
        ...baseUpdate,
      }),
    );
  }

  if (role === "ngo") {
    updated += await runUniqueUpdate(
      db.collection(NOTIFICATIONS_COLLECTION).where("ngoId", "==", uid),
      () => ({
        ngoId: null,
        ...baseUpdate,
      }),
    );
  }

  const normalizedEmail = toTrimmedString(email).toLowerCase();
  if (normalizedEmail) {
    updated += await runUniqueUpdate(
      db.collection(NOTIFICATIONS_COLLECTION).where("email", "==", normalizedEmail),
      () => baseUpdate,
    );
  }

  return updated;
}

async function detachAdminActivityReferences({
  uid,
  originalName,
  role,
  email,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  const seenPaths = new Set();
  const updateUnique = async (query) => {
    const snapshot = await query.get();
    if (snapshot.empty) {
      return 0;
    }

    const docs = snapshot.docs.filter((doc) => {
      if (seenPaths.has(doc.ref.path)) {
        return false;
      }
      seenPaths.add(doc.ref.path);
      return true;
    });

    if (docs.length === 0) {
      return 0;
    }

    for (const chunk of chunkArray(docs)) {
      const batch = db.batch();
      for (const doc of chunk) {
        batch.set(doc.ref, {
          targetUserId: null,
          relatedUserId: null,
          receiverName: originalName,
          targetName: originalName,
          ...auditFields,
          archivedTargetName: originalName,
          archivedTargetRole: role,
          archivedTargetEmail: toTrimmedString(email) || null,
        }, { merge: true });
      }
      await batch.commit();
    }

    return docs.length;
  };

  let updated = 0;
  updated += await updateUnique(
    db.collection(ADMIN_ACTIVITY_LOGS_COLLECTION).where("targetUserId", "==", uid),
  );
  updated += await updateUnique(
    db.collection(ADMIN_ACTIVITY_LOGS_COLLECTION).where("relatedUserId", "==", uid),
  );
  return updated;
}

async function detachAdminNotificationReferences({
  uid,
  originalName,
  role,
  email,
  auditFields,
}) {
  if (role !== "donor" && role !== "ngo") {
    return 0;
  }

  const normalizedEmail = toTrimmedString(email).toLowerCase();
  const seenPaths = new Set();
  const updateUnique = async (query, shouldDetach) => {
    const snapshot = await query.get();
    if (snapshot.empty) {
      return 0;
    }

    const docs = snapshot.docs.filter((doc) => {
      if (seenPaths.has(doc.ref.path)) {
        return false;
      }
      if (!shouldDetach(doc.data() || {})) {
        return false;
      }
      seenPaths.add(doc.ref.path);
      return true;
    });

    if (docs.length === 0) {
      return 0;
    }

    for (const chunk of chunkArray(docs)) {
      const batch = db.batch();
      for (const doc of chunk) {
        batch.set(doc.ref, {
          relatedUserId: null,
          receiverName: originalName,
          targetName: originalName,
          ...auditFields,
          archivedTargetName: originalName,
          archivedTargetRole: role,
          archivedTargetEmail: normalizedEmail || null,
        }, { merge: true });
      }
      await batch.commit();
    }

    return docs.length;
  };

  let updated = 0;
  updated += await updateUnique(
    db.collection(ADMIN_NOTIFICATIONS_COLLECTION).where("relatedUserId", "==", uid),
    (data) => `${data.relatedUserId || ""}`.trim() === uid,
  );

  if (normalizedEmail) {
    updated += await updateUnique(
      db.collection(ADMIN_NOTIFICATIONS_COLLECTION).where("relatedUserId", "==", normalizedEmail),
      (data) => {
        const source = `${data.source || ""}`.trim().toLowerCase();
        const rawRelatedUserId = `${data.relatedUserId || ""}`.trim().toLowerCase();
        return rawRelatedUserId === normalizedEmail && source.includes("register");
      },
    );
  }

  return updated;
}

async function detachUserDataReferences({
  uid,
  role,
  originalName,
  email,
}) {
  const auditFields = buildDeletionAuditFields({
    uid,
    originalName,
    role,
  });

  const counts = {
    donations: await detachDonationReferences({
      uid,
      role,
      originalName,
      auditFields,
    }),
    feedback: await detachFeedbackReferences({
      uid,
      role,
      originalName,
      auditFields,
    }),
    concerns: await detachConcernReferences({
      uid,
      role,
      originalName,
      auditFields,
    }),
    goals: await detachGoalReferences({
      uid,
      role,
      originalName,
      auditFields,
    }),
    notifications: await detachNotificationReferences({
      uid,
      role,
      originalName,
      email,
      auditFields,
    }),
    adminActivityLogs: await detachAdminActivityReferences({
      uid,
      role,
      originalName,
      email,
      auditFields,
    }),
    adminNotifications: await detachAdminNotificationReferences({
      uid,
      role,
      originalName,
      email,
      auditFields,
    }),
  };

  return counts;
}

async function writeDeletionAuditLog({
  uid,
  role,
  originalName,
  email,
  initiatedByType,
  initiatedByUid,
  initiatedByEmail,
}) {
  await db.collection(ADMIN_ACTIVITY_LOGS_COLLECTION).doc().set({
    actionType: initiatedByType === "admin" ? `admin_deleted_${role || "user"}` : "user_self_deleted_account",
    type: "account_deletion",
    title: initiatedByType === "admin" ? "Account Deleted by Admin" : "User Deleted Own Account",
    message: initiatedByType === "admin"
      ? `Admin permanently deleted the ${role || "user"} account.`
      : `${role || "user"} permanently deleted their own account.`,
    receiverName: originalName,
    targetName: originalName,
    targetUserId: null,
    deletedUserId: uid,
    deletedUserName: originalName,
    deletedUserRole: role,
    archivedTargetEmail: toTrimmedString(email) || null,
    createdAt: nowTimestamp(),
    initiatedByType,
    createdBy: initiatedByUid || null,
    adminId: initiatedByType === "admin" ? initiatedByUid || "admin" : null,
    adminName: initiatedByType === "admin" ? "System Admin" : null,
    initiatedByEmail: toTrimmedString(initiatedByEmail) || null,
    source: "account_deletion",
    isUserDeleted: true,
  });
}

async function deleteUserAccountWithHistoryDetachment({
  uid,
  requestedRole = "",
  initiatedByType,
  initiatedByUid = "",
  initiatedByEmail = "",
  fallbackEmail = "",
}) {
  const normalizedUid = `${uid || ""}`.trim();
  if (!normalizedUid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  const userRef = db.collection(USERS_COLLECTION).doc(normalizedUid);
  const [userSnapshot, authRecord] = await Promise.all([
    userRef.get(),
    admin.auth().getUser(normalizedUid).catch((error) => {
      if (error?.code === "auth/user-not-found") {
        return null;
      }
      throw error;
    }),
  ]);

  const userData = userSnapshot.data() || {};
  const role = `${requestedRole || userData.role || ""}`.trim().toLowerCase();
  const actualRole = `${userData.role || ""}`.trim().toLowerCase();
  if (userSnapshot.exists && actualRole && role && actualRole !== role) {
    throw new HttpsError("failed-precondition", "User role does not match the requested deletion role.");
  }

  if (role && role !== "donor" && role !== "ngo") {
    throw new HttpsError("invalid-argument", "role must be donor or ngo.");
  }

  const email = toTrimmedString(userData.email || authRecord?.email || fallbackEmail).toLowerCase();
  const originalName = resolveDeletedUserName(
    userData,
    role,
    email,
  );

  const detachedRecords = await detachUserDataReferences({
    uid: normalizedUid,
    role,
    originalName,
    email,
  });

  await writeDeletionAuditLog({
    uid: normalizedUid,
    role,
    originalName,
    email,
    initiatedByType,
    initiatedByUid,
    initiatedByEmail,
  });

  try {
    await db.recursiveDelete(userRef);
  } catch (error) {
    console.warn("Recursive delete failed for user document, falling back to direct delete.", {
      uid: normalizedUid,
      error,
    });
    await userRef.delete().catch(() => null);
  }

  if (authRecord) {
    try {
      await admin.auth().deleteUser(normalizedUid);
    } catch (error) {
      if (error?.code !== "auth/user-not-found") {
        console.error("Failed to delete auth user", { uid: normalizedUid, error });
        throw new HttpsError("internal", "Failed to delete authentication account.");
      }
    }
  }

  return {
    uid: normalizedUid,
    role,
    deleted: true,
    detachedRecords,
  };
}

exports.notifyAdminOnNewNgoRequest = onDocumentCreated(
  `${NGO_REQUESTS_COLLECTION}/{requestId}`,
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      return;
    }

    if (`${data.status || ""}`.trim().toLowerCase() !== "pending") {
      return;
    }

    const payload = buildPayload({
      title: "New NGO Approval Request",
      body: "A new NGO wants approval",
      type: NOTIFICATION_TYPES.NEW_NGO_REGISTRATION,
      userRole: "admin",
      navigation: "admin_ngo_requests",
    });

    await sendToUsersByRole({
      role: "admin",
      payload,
      extraData: {
        requestId: event.params.requestId,
        ngoEmail: data.email || "",
        organizationName: data.organizationName || "",
      },
      fallbackTopic: true,
    });
  },
);

exports.notifyNgoWhenApprovedAfterUpdate = onDocumentUpdated(
  `${USERS_COLLECTION}/{userId}`,
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }

    const role = `${after.role || ""}`.trim().toLowerCase();
    const approvedBefore = before?.approvedByAdmin === true;
    const approvedAfter = after.approvedByAdmin === true;
    const alreadySent = Boolean(after.approvalNotificationSentAt);
    const tokenBefore = `${before?.latestFcmToken || ""}`.trim();
    const tokenAfter = `${after.latestFcmToken || ""}`.trim();
    const approvalJustChanged = !approvedBefore && approvedAfter;
    const tokenBecameAvailable = tokenAfter.length > 0 && tokenBefore !== tokenAfter;

    if (role !== "ngo" || !approvedAfter || alreadySent) {
      return;
    }

    if (!approvalJustChanged && !tokenBecameAvailable) {
      console.log("FCM NGO approval update ignored", {
        uid: event.params.userId,
        approvalJustChanged,
        tokenBecameAvailable,
        tokenAfter,
      });
      return;
    }

    const payload = buildPayload({
      title: "Registration Approved",
      body: "Your account is approved. You can now login.",
      type: NOTIFICATION_TYPES.NGO_APPROVED,
      userRole: "ngo",
      navigation: "ngo_dashboard",
    });

    const delivered = await sendToUser({
      uid: event.params.userId,
      payload,
      retryIfNoTokens: true,
    });

    if (delivered === 0) {
      console.warn("FCM NGO approval deferred because no token was available", {
        uid: event.params.userId,
        tokenAfter,
      });
      return;
    }

    await markDocument(`${USERS_COLLECTION}/${event.params.userId}`, {
      approvalNotificationSentAt: nowTimestamp(),
    });
  },
);

exports.notifyAdminWhenNgoRequestBecomesPending = onDocumentUpdated(
  `${NGO_REQUESTS_COLLECTION}/{requestId}`,
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }

    const beforeStatus = `${before?.status || ""}`.trim().toLowerCase();
    const afterStatus = `${after.status || ""}`.trim().toLowerCase();
    if (afterStatus !== "pending" || beforeStatus === "pending") {
      return;
    }

    const payload = buildPayload({
      title: "New NGO Approval Request",
      body: "A verified NGO is waiting for approval",
      type: NOTIFICATION_TYPES.NEW_NGO_REGISTRATION,
      userRole: "admin",
      navigation: "admin_ngo_requests",
    });

    await sendToUsersByRole({
      role: "admin",
      payload,
      extraData: {
        requestId: event.params.requestId,
        ngoEmail: after.email || "",
        organizationName: after.organizationName || "",
      },
      fallbackTopic: true,
    });
  },
);

exports.sendTestNotificationToUid = onCall(async (request) => {
  const callerEmail = requireAdminCaller(request);

  const uid = `${request.data?.uid || ""}`.trim();
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  const payload = buildPayload({
    title: `${request.data?.title || "FCM Test"}`.trim() || "FCM Test",
    body: `${request.data?.body || "Manual test notification from Cloud Functions."}`.trim(),
    type: `${request.data?.type || "MANUAL_TEST"}`.trim() || "MANUAL_TEST",
    userRole: `${request.data?.userRole || "unknown"}`.trim() || "unknown",
    navigation: `${request.data?.navigation || "manual_test"}`.trim() || "manual_test",
  });

  const delivered = await sendToUser({
    uid,
    payload,
    extraData: {
      triggeredBy: callerEmail,
      source: "manual_test_function",
    },
  });

  return {
    uid,
    delivered,
    payload,
  };
});

exports.adminDeleteUserAccount = onCall(async (request) => {
  const callerEmail = requireAdminCaller(request);

  const uid = `${request.data?.uid || ""}`.trim();
  const role = `${request.data?.role || ""}`.trim().toLowerCase();
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  if (role !== "donor" && role !== "ngo") {
    throw new HttpsError("invalid-argument", "role must be donor or ngo.");
  }

  return deleteUserAccountWithHistoryDetachment({
    uid,
    requestedRole: role,
    initiatedByType: "admin",
    initiatedByUid: `${request.auth?.uid || ""}`.trim(),
    initiatedByEmail: callerEmail,
  });
});



exports.selfDeleteUserAccount = onCall(
  {
    region: "us-central1",
    invoker: "public",
    enforceAppCheck: false,
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError("unauthenticated", "User not authenticated");
    }

    // tumhara existing logic yahan rahega
    return { success: true };
  }
);

exports.ensureDonationExpiryFields = onDocumentCreated(
  `${DONATIONS_COLLECTION}/{donationId}`,
  async (event) => {
    const snapshot = event.data;
    const data = snapshot?.data();
    if (!snapshot || !data) {
      return;
    }

    const createdAt = timestampToDate(data.createdAt);
    if (!createdAt) {
      console.warn("Donation expiry initialization skipped: missing createdAt", {
        donationId: event.params.donationId,
      });
      return;
    }

    const expiryTime = resolveDonationExpiryTime(data);
    if (!expiryTime) {
      return;
    }

    await snapshot.ref.set({
      expired: false,
      expiryAt: timestampFromDate(expiryTime),
      expiresAt: timestampFromDate(expiryTime),
      expiringSoonNotificationSent: false,
    }, { merge: true });
  },
);

exports.notifyNgosOnNewDonation = onDocumentCreated(
  `${DONATIONS_COLLECTION}/{donationId}`,
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      return;
    }

    if (`${data.status || ""}`.trim().toLowerCase() !== "active") {
      return;
    }

    const payload = buildPayload({
      title: "New Donation Available",
      body: "New donation is available. Hurry up and accept!",
      type: NOTIFICATION_TYPES.NEW_DONATION,
      userRole: "ngo",
      navigation: "available_donations",
    });

    await sendToUsersByRole({
      role: "ngo",
      payload,
      extraData: {
        donationId: event.params.donationId,
        donorId: data.donorId || "",
      },
      filters: [["approvedByAdmin", "==", true]],
      fallbackTopic: true,
    });
  },
);

exports.notifyDonorWhenDonationExpires = onDocumentUpdated(
  `${DONATIONS_COLLECTION}/{donationId}`,
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }

    const beforeStatus = `${before?.status || ""}`.trim().toLowerCase();
    const afterStatus = `${after.status || ""}`.trim().toLowerCase();
    if (afterStatus !== "expired" || beforeStatus === "expired") {
      return;
    }

    const donorId = `${after.donorId || ""}`.trim();
    if (!donorId) {
      return;
    }

    const payload = buildPayload({
      title: "Donation Expired",
      body: "Your donation has expired",
      type: NOTIFICATION_TYPES.DONATION_EXPIRED,
      userRole: "donor",
      navigation: "donor_expired_donations",
    });

    await sendToUser({
      uid: donorId,
      payload,
      extraData: {
        donationId: event.params.donationId,
      },
    });
  },
);

exports.notifyDonorWhenDonationAccepted = onDocumentUpdated(
  `${DONATIONS_COLLECTION}/{donationId}`,
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }

    const beforeNgoId = `${before?.acceptedByNgoId || ""}`.trim();
    const afterNgoId = `${after.acceptedByNgoId || ""}`.trim();
    const donorId = `${after.donorId || ""}`.trim();

    if (!afterNgoId || beforeNgoId === afterNgoId || !donorId) {
      return;
    }

    const payload = buildPayload({
      title: "Donation Accepted",
      body: "Your donation has been accepted",
      type: NOTIFICATION_TYPES.DONATION_ACCEPTED,
      userRole: "donor",
      navigation: "accepted_donations",
    });

    await sendToUser({
      uid: donorId,
      payload,
      extraData: {
        donationId: event.params.donationId,
        ngoId: afterNgoId,
        ngoName: after.acceptedByNgoName || "",
      },
    });
  },
);

exports.checkDonationExpiryWindows = onSchedule("every 1 minutes", async () => {
  const now = new Date();
  console.log("Donation expiry scheduler started", { now: now.toISOString() });

  const snapshot = await db
    .collection(DONATIONS_COLLECTION)
    .where("status", "==", "active")
    .get();

  let expiredCount = 0;
  let notifiedCount = 0;
  let skippedWithoutCreatedAt = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data() || {};
    const donationId = doc.id;
    const createdAt = timestampToDate(data.createdAt);

    if (!createdAt) {
      skippedWithoutCreatedAt += 1;
      console.warn("Donation expiry skipped: missing createdAt", { donationId });
      continue;
    }

    const expiryTime = resolveDonationExpiryTime(data);
    if (!expiryTime) {
      skippedWithoutCreatedAt += 1;
      console.warn("Donation expiry skipped: unable to resolve expiry time", { donationId });
      continue;
    }

    const notificationTime = new Date(expiryTime.getTime() - DONATION_EXPIRING_SOON_MS);
    const normalizationUpdate = {};
    if (data.expired !== false) {
      normalizationUpdate.expired = false;
    }
    if (!timestampToDate(data.expiryAt)) {
      normalizationUpdate.expiryAt = timestampFromDate(expiryTime);
    }
    if (!timestampToDate(data.expiresAt)) {
      normalizationUpdate.expiresAt = timestampFromDate(expiryTime);
    }
    if (data.expiringSoonNotificationSent == null) {
      normalizationUpdate.expiringSoonNotificationSent = false;
    }
    if (Object.keys(normalizationUpdate).length > 0) {
      try {
        await doc.ref.set(normalizationUpdate, { merge: true });
      } catch (error) {
        console.warn("Donation expiry normalization failed", { donationId, error });
      }
    }

    if (now >= expiryTime) {
      try {
        await doc.ref.update({
          status: "expired",
          expired: true,
          expiryAt: timestampFromDate(expiryTime),
          expiresAt: timestampFromDate(expiryTime),
          expiredAt: nowTimestamp(),
          expiredBySchedulerAt: nowTimestamp(),
        });
        expiredCount += 1;
        console.log("Donation marked expired", {
          donationId,
          createdAt: createdAt.toISOString(),
          expiryTime: expiryTime.toISOString(),
        });
      } catch (error) {
        console.error("Failed to expire donation", { donationId, error });
      }
      continue;
    }

    const alreadyNotified =
      data.expiringSoonNotificationSent === true ||
      data.notificationSent === true;
    const shouldNotify = now >= notificationTime && !alreadyNotified;
    if (!shouldNotify) {
      continue;
    }

    let reservedNotification = false;
    try {
      reservedNotification = await db.runTransaction(async (transaction) => {
        const freshSnapshot = await transaction.get(doc.ref);
        if (!freshSnapshot.exists) {
          return false;
        }

        const freshData = freshSnapshot.data() || {};
        const freshStatus = `${freshData.status || ""}`.trim().toLowerCase();
        const freshCreatedAt = timestampToDate(freshData.createdAt);
        const freshExpiryTime = resolveDonationExpiryTime(freshData);
        if (
          freshStatus !== "active" ||
          !freshCreatedAt ||
          !freshExpiryTime ||
          freshData.expiringSoonNotificationSent === true ||
          freshData.notificationSent === true
        ) {
          return false;
        }

        const freshNotificationTime = new Date(
          freshExpiryTime.getTime() - DONATION_EXPIRING_SOON_MS,
        );
        if (now < freshNotificationTime || now >= freshExpiryTime) {
          return false;
        }

        transaction.update(doc.ref, {
          notificationSent: true,
          expiringSoonNotificationSent: true,
          notificationSentAt: nowTimestamp(),
          expiryAt: timestampFromDate(freshExpiryTime),
          expiresAt: timestampFromDate(freshExpiryTime),
        });
        return true;
      });
    } catch (error) {
      console.error("Failed to reserve donation expiry notification", { donationId, error });
      continue;
    }

    if (!reservedNotification) {
      continue;
    }

    try {
      const delivered = await sendToNearbyNgos({
        donationId,
        donationData: data,
        payload: buildPayload({
          title: "Donation About To Expire",
          body: "A donation is about to expire. Accept it before its gone.",
          type: NOTIFICATION_TYPES.DONATION_EXPIRING_SOON,
          userRole: "ngo",
          navigation: "available_donations",
        }),
        extraData: {
          donationId,
          donorId: toTrimmedString(data.donorId),
        },
      });
      notifiedCount += delivered;
      console.log("Donation expiry notification sent", {
        donationId,
        delivered,
        notificationTime: notificationTime.toISOString(),
        expiryTime: expiryTime.toISOString(),
      });
    } catch (error) {
      console.error("Failed to send donation expiry notification", {
        donationId,
        error,
      });
    }
  }

  console.log("Donation expiry scheduler finished", {
    processed: snapshot.size,
    expiredCount,
    notifiedCount,
    skippedWithoutCreatedAt,
  });
});

async function donorNeedsReminder(userDoc) {
  const userId = userDoc.id;
  const userData = userDoc.data() || {};

  if (userData.notificationsEnabled === false) {
    return false;
  }

  const lastReminderAt = timestampToDate(userData.lastDonationReminderAt);
  if (lastReminderAt) {
    const daysSinceReminder = (Date.now() - lastReminderAt.getTime()) / (1000 * 60 * 60 * 24);
    if (daysSinceReminder < 3) {
      return false;
    }
  }

  const latestDonationSnapshot = await db
    .collection(DONATIONS_COLLECTION)
    .where("donorId", "==", userId)
    .orderBy("createdAt", "desc")
    .limit(1)
    .get();

  if (latestDonationSnapshot.empty) {
    return true;
  }

  const latestDonation = latestDonationSnapshot.docs[0].data();
  const latestDonationDate = timestampToDate(latestDonation.createdAt);
  if (!latestDonationDate) {
    return true;
  }

  const daysSinceDonation = (Date.now() - latestDonationDate.getTime()) / (1000 * 60 * 60 * 24);
  return daysSinceDonation >= 34;
}

exports.sendDonorReminders = onSchedule("every 72 hours", async () => {
  const donorSnapshot = await db
    .collection(USERS_COLLECTION)
    .where("role", "==", "donor")
    .get();

  for (const donorDoc of donorSnapshot.docs) {
    const shouldSend = await donorNeedsReminder(donorDoc);
    if (!shouldSend) {
      continue;
    }

    const payload = buildPayload({
      title: "Donate Now",
      body: "Donate food now so we can feed the needy",
      type: NOTIFICATION_TYPES.DONOR_REMINDER,
      userRole: "donor",
      navigation: "donation_form",
    });

    await sendToUser({
      uid: donorDoc.id,
      payload,
    });

    await donorDoc.ref.set({
      lastDonationReminderAt: nowTimestamp(),
    }, { merge: true });
  }
});

exports.sendMonthlyGoalSummaryNotifications = onSchedule(
  "every 60 minutes",
  async () => {
    const currentMonth = monthKeyForDate(new Date());
    const goalsSnapshot = await db
      .collection(GOALS_COLLECTION)
      .where("month", "<", currentMonth)
      .get();

    if (goalsSnapshot.empty) {
      return;
    }

    for (const doc of goalsSnapshot.docs) {
      const data = doc.data() || {};
      const month = typeof data.month === "string" ? data.month.trim() : "";
      const userId =
        typeof data.userId === "string"
          ? data.userId.trim()
          : typeof data.uid === "string"
            ? data.uid.trim()
            : "";
      const role =
        typeof data.role === "string" ? data.role.trim().toLowerCase() : "";
      const targetMeals =
        Number.parseInt(`${data.targetMeals ?? data.monthlyTarget ?? 0}`, 10) || 0;

      if (!month || !userId || !role || targetMeals <= 0 || data.monthEndNotificationSentAt) {
        continue;
      }

      const bounds = monthBoundsFromKey(month);
      if (!bounds) {
        continue;
      }

      let donationQuery = db
        .collection(DONATIONS_COLLECTION)
        .where("status", "==", "completed")
        .where("completedAt", ">=", admin.firestore.Timestamp.fromDate(bounds.start))
        .where("completedAt", "<", admin.firestore.Timestamp.fromDate(bounds.end));

      if (role === "ngo") {
        donationQuery = donationQuery.where("acceptedByNgoId", "==", userId);
      } else if (role === "donor") {
        donationQuery = donationQuery.where("donorId", "==", userId);
      } else {
        continue;
      }

      const donationsSnapshot = await donationQuery.get();
      let achieved = 0;

      if (role === "ngo") {
        for (const donationDoc of donationsSnapshot.docs) {
          const donation = donationDoc.data() || {};
          achieved += parseMealsToInt(donation.quantity ?? donation.servings ?? "");
        }
      } else {
        achieved = donationsSnapshot.size;
      }

      const percent = calculateGoalPercentage(achieved, targetMeals);
      const monthLabel = monthLabelFromKey(month);
      const payload = buildPayload({
        title: "Monthly goal summary",
        body: `You completed ${percent}% of your ${monthLabel} goal. Keep it up!`,
        type: "MONTHLY_GOAL_SUMMARY",
        userRole: role,
        navigation: role === "ngo" ? "ngo_dashboard" : "donation_form",
      });

      await sendToUser({
        uid: userId,
        payload,
        extraData: {
          goalMonth: month,
        },
      });

      await doc.ref.set({
        monthEndNotificationSentAt: nowTimestamp(),
      }, { merge: true });
    }
  },
);
