require("dotenv").config();

const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
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

const ROLE_TOPICS = {
  admin: "role_admin",
  ngo: "role_ngo",
  donor: "role_donor",
};

const NOTIFICATION_TYPES = {
  NEW_NGO_REGISTRATION: "NEW_NGO_REGISTRATION",
  NGO_APPROVED: "NGO_APPROVED",
  NEW_DONATION: "NEW_DONATION",
  DONOR_REMINDER: "DONOR_REMINDER",
  DONATION_EXPIRING_SOON: "DONATION_EXPIRING_SOON",
  DONATION_EXPIRED: "DONATION_EXPIRED",
};

const GOALS_COLLECTION = "goals";

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

  return snapshot.docs
    .map((doc) => doc.data()?.token)
    .filter((token) => typeof token === "string" && token.trim().length > 0)
    .map((token) => token.trim());
}

async function deleteToken(uid, token) {
  await db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection("fcm_tokens")
    .doc(token)
    .delete()
    .catch(() => null);
}

async function sendMessageToToken({ uid, token, payload, extraData = {} }) {
  try {
    await messaging.send({
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
          },
        },
      },
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

async function sendToUser({ uid, payload, extraData = {}, persist = true }) {
  const trimmedUid = `${uid || ""}`.trim();
  if (!trimmedUid) {
    return 0;
  }

  const notificationsEnabled = await isNotificationsEnabled(trimmedUid);
  if (!notificationsEnabled) {
    return 0;
  }

  if (persist) {
    await saveNotificationRecord({
      uid: trimmedUid,
      payload,
      extraData,
    });
  }

  const tokens = await loadUserTokens(trimmedUid);
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

  return delivered;
}

async function sendToTopic({ topic, payload, extraData = {} }) {
  await messaging.send({
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
        },
      },
    },
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
    delivered += await sendToUser({
      uid: doc.id,
      payload,
      extraData,
    });
  }

  return delivered;
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

  return Math.max(0, Number.parseInt(matches[matches.length - 1], 10));
}

function calculateGoalPercentage(achieved, target) {
  if (!target || target <= 0) {
    return 0;
  }
  return Math.round((achieved / target) * 100);
}

exports.notifyAdminOnNewNgoRequest = onDocumentCreated(
  `${NGO_REQUESTS_COLLECTION}/{requestId}`,
  async (event) => {
    const data = event.data?.data();
    if (!data) {
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

exports.notifyNgoWhenApproved = onDocumentCreated(
  `${USERS_COLLECTION}/{userId}`,
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      return;
    }

    const role = `${data.role || ""}`.trim().toLowerCase();
    const approvedByAdmin = data.approvedByAdmin === true;
    if (role !== "ngo" || !approvedByAdmin) {
      return;
    }

    const payload = buildPayload({
      title: "Registration Approved",
      body: "You are successfully registered as an NGO in WasteNot. Login now.",
      type: NOTIFICATION_TYPES.NGO_APPROVED,
      userRole: "ngo",
      navigation: "ngo_dashboard",
    });

    await sendToUser({
      uid: event.params.userId,
      payload,
    });
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

exports.checkDonationExpiryWindows = onSchedule("every 1 hours", async () => {
  const now = new Date();
  const thirtyMinutesFromNow = new Date(now.getTime() + 30 * 60 * 1000);

  const snapshot = await db
    .collection(DONATIONS_COLLECTION)
    .where("status", "==", "active")
    .get();

  const batch = db.batch();

  for (const doc of snapshot.docs) {
    const data = doc.data() || {};
    const expiryAt = timestampToDate(data.expiryAt);
    if (!expiryAt) {
      continue;
    }

    const donationId = doc.id;

    if (expiryAt <= now) {
      batch.update(doc.ref, {
        status: "expired",
        expiryAt: admin.firestore.Timestamp.fromDate(expiryAt),
        expiredBySchedulerAt: nowTimestamp(),
      });
      continue;
    }

    const alreadySentExpiringAlert = Boolean(data.expiringNotificationSentAt);
    if (alreadySentExpiringAlert) {
      continue;
    }

    if (expiryAt <= thirtyMinutesFromNow) {
      const payload = buildPayload({
        title: "Donation Expiring Soon",
        body: "Save food and feed the hungry before it expires!",
        type: NOTIFICATION_TYPES.DONATION_EXPIRING_SOON,
        userRole: "ngo",
        navigation: "available_donations",
      });

      await sendToUsersByRole({
        role: "ngo",
        payload,
        extraData: { donationId },
        filters: [["approvedByAdmin", "==", true]],
        fallbackTopic: true,
      });

      batch.update(doc.ref, {
        expiringNotificationSentAt: nowTimestamp(),
      });
    }
  }

  await batch.commit();
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
