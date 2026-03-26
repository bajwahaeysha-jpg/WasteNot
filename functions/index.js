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
