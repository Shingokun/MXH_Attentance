import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/firebase_bootstrap.dart';

/// Khởi động app; [initializeFirebase] tắt trong widget test.
Future<void> bootstrap({bool initializeFirebase = true}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (initializeFirebase) {
    await FirebaseBootstrap.initialize();
  }

  runApp(const ProviderScope(child: MhxApp()));
}
