require("dotenv").config(); // 🔥 force load .env

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

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