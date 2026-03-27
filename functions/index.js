require("dotenv").config(); // 🔥 force load .env

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();

// ✅ ENV key safely load
const SENDGRID_KEY = process.env.SENDGRID_KEY;

if (!SENDGRID_KEY) {
  console.error("❌ SENDGRID KEY missing in .env");
} else {
  sgMail.setApiKey(SENDGRID_KEY);
}

const ADMIN_EMAIL = "wastenotapplication@gmail.com";

exports.sendEmailOnNewMessage = functions.firestore
  .document("contact_messages/{id}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data() || {};

      const name = data.name || "Unknown";
      const email = data.email || "Unknown";
      const role = data.role || "unknown";
      const message = data.message || "";

      const msg = {
        to: ADMIN_EMAIL,
        from: ADMIN_EMAIL, // ⚠️ must be verified in SendGrid
        subject: `New Contact Message from ${role.toUpperCase()}`,
        text: `
Name: ${name}
Email: ${email}
Role: ${role}

Message:
${message}
`,
      };

      // ✅ extra safety
      if (!SENDGRID_KEY) {
        console.error("❌ Email not sent - missing API key");
        return null;
      }

      await sgMail.send(msg);

      console.log("✅ Email sent successfully:", context.params.id);
      return null;
    } catch (error) {
      console.error("❌ Failed to send email:", error);
      return null;
    }
  });

const TWO_HOURS_MS = 2 * 60 * 60 * 1000;
const GOALS_COLLECTION = "goals";

const toMillis = (value) => {
  if (!value) {
    return null;
  }
  if (typeof value.toDate === "function") {
    return value.toDate().getTime();
  }
  if (value instanceof Date) {
    return value.getTime();
  }
  if (typeof value === "number") {
    return value;
  }
  return null;
};

const monthKeyForDate = (date) => {
  const month = `${date.getUTCMonth() + 1}`.padStart(2, "0");
  return `${date.getUTCFullYear()}-${month}`;
};

const monthBoundsFromKey = (monthKey) => {
  const parts = `${monthKey}`.split("-");
  if (parts.length !== 2) {
    return null;
  }

  const year = Number.parseInt(parts[0], 10);
  const month = Number.parseInt(parts[1], 10);
  if (!Number.isInteger(year) || !Number.isInteger(month)) {
    return null;
  }

  const start = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(year, month, 1, 0, 0, 0, 0));
  return { start, end };
};

const monthLabelFromKey = (monthKey) => {
  const bounds = monthBoundsFromKey(monthKey);
  if (!bounds) {
    return "this";
  }

  return bounds.start.toLocaleString("en-US", {
    month: "long",
    timeZone: "UTC",
  });
};

const parseMealsToInt = (value) => {
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
};

const calculateGoalPercentage = (achieved, target) => {
  if (!target || target <= 0) {
    return 0;
  }
  return Math.round((achieved / target) * 100);
};

exports.expireDonations = onSchedule("every 5 minutes", async () => {
  const db = admin.firestore();
  const nowMillis = Date.now();
  const expiryTimestamp = admin.firestore.Timestamp.fromMillis(nowMillis);

  try {
    const snapshot = await db
      .collection("donations")
      .where("status", "==", "active")
      .get();

    if (snapshot.empty) {
      return;
    }

    const expiredRefs = [];

    snapshot.forEach((doc) => {
      const data = doc.data() || {};
      if (data.status !== "active") {
        return;
      }
      if (data.expiryAt != null) {
        return;
      }
      if (data.completedAt != null) {
        return;
      }

      const acceptedByNgoId =
        typeof data.acceptedByNgoId === "string"
          ? data.acceptedByNgoId.trim()
          : "";

      const createdAtMillis = toMillis(data.createdAt);
      const acceptedAtMillis = toMillis(data.acceptedAt);

      const shouldExpireUnaccepted =
        !acceptedByNgoId &&
        createdAtMillis != null &&
        createdAtMillis + TWO_HOURS_MS < nowMillis;

      const shouldExpireAccepted =
        acceptedByNgoId &&
        acceptedAtMillis != null &&
        acceptedAtMillis + TWO_HOURS_MS < nowMillis;

      if (shouldExpireUnaccepted || shouldExpireAccepted) {
        expiredRefs.push(doc.ref);
      }
    });

    if (expiredRefs.length === 0) {
      return;
    }

    for (let i = 0; i < expiredRefs.length; i += 500) {
      const batch = db.batch();
      expiredRefs.slice(i, i + 500).forEach((ref) => {
        batch.update(ref, {
          status: "expired",
          expiryAt: expiryTimestamp,
        });
      });
      await batch.commit();
    }
  } catch (error) {
    console.error("Failed to expire donations:", error);
  }
});

exports.sendMonthlyGoalSummaryNotifications = onSchedule(
  "every 60 minutes",
  async () => {
    const db = admin.firestore();
    const currentMonth = monthKeyForDate(new Date());

    try {
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
        const targetMeals = Number.parseInt(`${data.targetMeals ?? data.monthlyTarget ?? 0}`, 10) || 0;

        if (!month || !userId || !role || targetMeals <= 0) {
          continue;
        }

        if (data.monthEndNotificationSentAt) {
          continue;
        }

        const bounds = monthBoundsFromKey(month);
        if (!bounds) {
          continue;
        }

        let donationQuery = db
          .collection("donations")
          .where("status", "==", "completed")
          .where(
            "completedAt",
            ">=",
            admin.firestore.Timestamp.fromDate(bounds.start),
          )
          .where(
            "completedAt",
            "<",
            admin.firestore.Timestamp.fromDate(bounds.end),
          );

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
            achieved += parseMealsToInt(
              donation.quantity ?? donation.servings ?? "",
            );
          }
        } else {
          achieved = donationsSnapshot.size;
        }

        const percent = calculateGoalPercentage(achieved, targetMeals);
        const monthLabel = monthLabelFromKey(month);
        const notificationRef = db.collection("notifications").doc();

        const batch = db.batch();
        batch.set(notificationRef, {
          notificationId: notificationRef.id,
          receiverId: userId,
          uid: userId,
          userId,
          title: "Monthly goal summary",
          body: `You completed ${percent}% of your ${monthLabel} goal. Keep it up!`,
          message: `You completed ${percent}% of your ${monthLabel} goal. Keep it up!`,
          type: "monthly_goal_summary",
          goalMonth: month,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
          read: false,
        });
        batch.update(doc.ref, {
          monthEndNotificationSentAt:
            admin.firestore.FieldValue.serverTimestamp(),
        });
        await batch.commit();
      }
    } catch (error) {
      console.error("Failed to send monthly goal summary notifications:", error);
    }
  },
);
