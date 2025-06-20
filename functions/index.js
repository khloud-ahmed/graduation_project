const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ✅ 1) إشعار تغيير حالة المنتج (Expiring / Expired)
exports.sendExpirationNotification = functions.firestore
  .document("product_instance/{docId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.expiration_status === after.expiration_status) return null;

    const userId = after.user_id || after.User_Id;
    const productName = after.product_name || after.Product_Name;
    const newStatus = after.expiration_status;
    const instanceId = after.instance_id || after.Instance_Id;

    try {
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      const fcmToken = userDoc.data().fcm_token;

      if (!fcmToken) {
        console.log("No FCM Token found for user: " + userId);
        return null;
      }

      let title = "";
      let body = "";
      let response = "no";

      switch (newStatus) {
        case "expiring":
          title = "⏰ Product Expiring Soon!";
          body = "Your product \"" + productName + "\" is about to expire soon. Consider donating or using it!";
          break;
        case "expired":
          title = "⚠ Product Expired!";
          body = "Oops! Your product \"" + productName + "\" has expired. Please dispose of it safely.";
          break;
        case "safe":
        default:
          return null;
      }

      await admin.firestore().collection("notification").add({
        title: title,
        body: body,
        type: "expiry_warning",
        is_read: false,
        sent_at: admin.firestore.FieldValue.serverTimestamp(),
        response: response,
        instance_id: instanceId,
        user_id: userId,
      });

      const message = {
        token: fcmToken,
        data: {
          title: title,
          body: body,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          status: newStatus,
          product_id: after.product_id || after.Product_Id,
          instance_id: instanceId || "",
          response: response,
          type: "expiry_warning",
          is_read: "false",
          user_id: userId,
        },
      };

      await admin.messaging().send(message);
      console.log("Notification sent and saved for user: " + userId);
    } catch (error) {
      console.error("Error sending expiration notification:", error);
    }

    return null;
  });


// ✅ 2) إشعار استخدام المنتج عند الإنشاء (للتست)
exports.sendUsageReminderOnCreate = functions.firestore
  .document("product_instance/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = data.user_id || data.User_Id;
    const productName = data.product_name || data.Product_Name;

    if (!userId || !productName) {
      console.log("Missing userId or productName");
      return null;
    }

    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    const fcmToken = userDoc.data().fcm_token;

    if (!fcmToken) {
      console.log("No FCM Token found for user: " + userId);
      return null;
    }

    await admin.firestore().collection("notification").add({
      title: "Are you still using " + productName + "?",
      body: "Tap to tell us if you're still using this item.",
      type: "usage_reminder",
      is_read: false,
      sent_at: admin.firestore.FieldValue.serverTimestamp(),
      response: "ask_usage",
      instance_id: context.params.docId,
      user_id: userId,
    });

    await admin.messaging().send({
      token: fcmToken,
      data: {
        title: "Are you still using " + productName + "?",
        body: "Tap to tell us if you're still using this item.",
        response: "ask_usage",
        instance_id: context.params.docId,
        product_name: productName,
        is_read: "false",
        user_id: userId,
        type: "usage_reminder",
      },
    });

    console.log("Initial usage reminder sent to user: " + userId);
    return null;
  });


// ✅ 3) إشعار شهري للمنتجات Safe Zone
exports.sendMonthlyUsageReminder = functions.pubsub
  .schedule("0 9 1 * *").timeZone("UTC")
  .onRun(async (context) => {
    const db = admin.firestore();

    const productsSnapshot = await db
      .collection("product_instance")
      .where("expiration_status", "==", "safe")
      .get();

    await Promise.all(productsSnapshot.docs.map(async (doc) => {
      const data = doc.data();
      const userId = data.user_id || data.User_Id;
      const productName = data.product_name || data.Product_Name;

      const userDoc = await db.collection("users").doc(userId).get();
      const fcmToken = userDoc.data().fcm_token;

      if (!fcmToken) return;

      await db.collection("notification").add({
        title: "Are you still using " + productName + "?",
        body: "Tap to tell us if you're still using this item.",
        type: "usage_reminder",
        is_read: false,
        sent_at: admin.firestore.FieldValue.serverTimestamp(),
        response: "ask_usage",
        instance_id: doc.id,
        user_id: userId,
      });

      await admin.messaging().send({
        token: fcmToken,
        data: {
          title: "Are you still using " + productName + "?",
          body: "Tap to tell us if you're still using this item.",
          response: "ask_usage",
          instance_id: doc.id,
          product_name: productName,
          is_read: "false",
          user_id: userId,
          type: "usage_reminder",
        },
      });

      console.log("Monthly usage reminder sent to user: " + userId);
    }));

    return null;
  });
