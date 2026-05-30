/**
 * Seed collection `neighborhoods` — dữ liệu mẫu để thử CAM-03.
 *
 * Production (Firestore cloud):
 *   cd functions
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="path\to\service-account.json"
 *   npm run seed:neighborhoods
 *
 *   Lấy key: Firebase Console → Project settings → Service accounts → Generate new private key
 *
 * Emulator (chạy `firebase emulators:start` trước):
 *   npm run seed:neighborhoods:emulator
 *
 * Tuỳ chọn: ghi đè document đã có
 *   node scripts/seed-neighborhoods.mjs --force
 */
import admin from "firebase-admin";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

const useEmulator = process.argv.includes("--emulator");
const force = process.argv.includes("--force");
const keyArgIndex = process.argv.indexOf("--service-account");
const serviceAccountPath =
  keyArgIndex >= 0 ? process.argv[keyArgIndex + 1] : null;
const projectId = process.env.FIREBASE_PROJECT_ID ?? "mhx-attendance-dev";

if (useEmulator) {
  process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
  console.log(`Firestore emulator: ${process.env.FIRESTORE_EMULATOR_HOST}`);
  const [host, portStr] = process.env.FIRESTORE_EMULATOR_HOST.split(":");
  const port = Number(portStr ?? 8080);
  try {
    const net = await import("node:net");
    await new Promise((resolve, reject) => {
      const socket = net.connect(port, host);
      socket.once("connect", () => {
        socket.end();
        resolve();
      });
      socket.once("error", reject);
      setTimeout(() => {
        socket.destroy();
        reject(new Error("timeout"));
      }, 2000);
    });
  } catch {
    console.error(
      `\nEmulator chưa chạy tại ${host}:${port}.\n` +
        "Terminal khác: cd mhx_attendance && firebase emulators:start\n" +
        "Hoặc seed cloud với service account (xem đầu file script).\n",
    );
    process.exit(1);
  }
} else {
  console.log(`Firestore cloud: project ${projectId}`);
  const credPath =
    serviceAccountPath ?? process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (credPath) {
    const abs = resolve(credPath);
    if (!existsSync(abs)) {
      console.error(`Không tìm thấy service account: ${abs}`);
      process.exit(1);
    }
    console.log(`Service account: ${abs}`);
  } else {
    console.log(
      "Cần GOOGLE_APPLICATION_CREDENTIALS hoặc --service-account <file.json>",
    );
  }
}

function initAdmin() {
  const credPath =
    serviceAccountPath ?? process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (credPath && !useEmulator) {
    const abs = resolve(credPath);
    admin.initializeApp({
      projectId,
      credential: admin.credential.cert(JSON.parse(readFileSync(abs, "utf8"))),
    });
    return;
  }
  admin.initializeApp({ projectId });
}

try {
  initAdmin();
} catch (e) {
  console.error(`Không khởi tạo Firebase Admin: ${e.message}`);
  process.exit(1);
}

/** Khớp schema README — document ID = mã khu phố. */
const SAMPLE_NEIGHBORHOODS = [
  {
    id: "KP01",
    name: "Khu phố 1",
    ward_name: "Phường Bình Quới",
    city_name: "TP. Hồ Chí Minh",
  },
  {
    id: "KP02",
    name: "Khu phố 2",
    ward_name: "Phường Bình Quới",
    city_name: "TP. Hồ Chí Minh",
  },
  {
    id: "KP03",
    name: "Khu phố 3",
    ward_name: "Phường Bình Quới",
    city_name: "TP. Hồ Chí Minh",
  },
  {
    id: "KP04",
    name: "Khu phố 4",
    ward_name: "Phường Bình Quới",
    city_name: "TP. Hồ Chí Minh",
  },
  {
    id: "KP05",
    name: "Khu phố 5",
    ward_name: "Phường Bình Quới",
    city_name: "TP. Hồ Chí Minh",
  },
];

const db = admin.firestore();
let created = 0;
let skipped = 0;

try {
  for (const n of SAMPLE_NEIGHBORHOODS) {
    const ref = db.collection("neighborhoods").doc(n.id);
    const existing = await ref.get();

    if (existing.exists && !force) {
      console.log(`SKIP ${n.id} (đã tồn tại — dùng --force để ghi đè)`);
      skipped++;
      continue;
    }

    await ref.set(
      {
        name: n.name,
        ward_name: n.ward_name,
        city_name: n.city_name,
        admin_uid: null,
        admin_name: null,
        member_count: 0,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: !force },
    );

    console.log(`${existing.exists ? "UPDATE" : "CREATE"} neighborhoods/${n.id}`);
    created++;
  }
} catch (e) {
  if (e.message?.includes("Could not load the default credentials")) {
    console.error(`
Thiếu quyền ghi Firestore cloud. Chọn một cách:

1) Service account (khuyến nghị, một lần):
   Firebase Console → mhx-attendance-dev → ⚙ Project settings → Service accounts
   → «Generate new private key» → lưu file JSON (không commit git)

   PowerShell:
   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\\path\\to\\key.json"
   npm run seed:neighborhoods

2) Emulator (không cần key, app phải trỏ emulator):
   firebase emulators:start
   npm run seed:neighborhoods:emulator
`);
  } else {
    console.error(e);
  }
  process.exit(1);
}

console.log(`\nXong: ${created} ghi, ${skipped} bỏ qua.`);
console.log("Mở app → Chiến dịch → chi tiết → «Thêm Bí thư» để thử CAM-03.");
console.log(
  "Lưu ý: dropdown Bí thư cần user role LOCAL_ADMIN — xem set-user-role.mjs",
);
process.exit(0);
