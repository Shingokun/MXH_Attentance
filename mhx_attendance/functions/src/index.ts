import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";

import { onAuthUserCreate } from "./auth/on_user_create";

admin.initializeApp();

setGlobalOptions({ maxInstances: 10, region: "asia-southeast1" });

/** Health check for emulator / deploy smoke test (Giai đoạn 0). */
export const health = onRequest((_req, res) => {
  res.status(200).json({ ok: true, service: "mhx-attendance-functions" });
});

export { onAuthUserCreate };
