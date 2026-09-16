// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/native_store.dart';

/// Application entry point.
///
/// The local SQLite database is initialised before the first frame. Failure is
/// non-fatal: the demo continues with in-memory data when the native core is
/// unavailable.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeStore.instance.initialise();
  runApp(const DolphinPortApp());
}
