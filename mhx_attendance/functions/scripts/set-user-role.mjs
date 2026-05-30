/**
 * Gán role + Custom Claims cho một user (dev / Super Admin đầu tiên).
 *
 * Cách chạy (trong thư mục functions):
 *   node scripts/set-user-role.mjs <UID> SUPER_ADMIN
 *
 * Yêu cầu: đã `firebase login` hoặc GOOGLE_APPLICATION_CREDENTIALS trỏ service account.
 */
import admin from "firebase-admin";

const uid = process.argv[2];
const role = process.argv[3] ?? "SUPER_ADMIN";

const allowed = new Set(["SUPER_ADMIN", "LOCAL_ADMIN", "USER"]);
if (!uid || !allowed.has(role)) {
  console.error("Usage: node scripts/set-user-role.mjs <UID> <SUPER_ADMIN|LOCAL_ADMIN|USER>");
  process.exit(1);
}

admin.initializeApp({ projectId: "mhx-attendance-dev" });

await admin.auth().setCustomUserClaims(uid, { role });

const patch = { role, is_active: true };
if (role === "SUPER_ADMIN") {
  patch.neighborhood_id = null;
  patch.neighborhood_name = null;
}

await admin.firestore().collection("users").doc(uid).set(patch, { merge: true });

console.log(`OK: ${uid} -> role=${role} (Firestore + Custom Claims)`);
console.log("User cần đăng xuất và đăng nhập lại để token mới có hiệu lực.");
process.exit(0);
