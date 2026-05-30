import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";

const db = admin.firestore();

/** AUTH-02: Tạo hồ sơ Firestore + Custom Claim `USER` khi đăng ký mới. */
export const onAuthUserCreate = functions
  .region("asia-southeast1")
  .auth.user()
  .onCreate(async (user) => {
    const role = "USER";

    await admin.auth().setCustomUserClaims(user.uid, { role });

    await db.collection("users").doc(user.uid).set({
      uid: user.uid,
      email: user.email ?? "",
      full_name: user.displayName ?? "",
      photo_url: user.photoURL ?? null,
      role,
      neighborhood_id: null,
      neighborhood_name: null,
      device_token: null,
      is_active: true,
      temp_attendance_permission: false,
      temp_permission_expires_at: null,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      created_by: null,
    });
  });
