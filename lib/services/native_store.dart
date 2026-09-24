// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'native_core.dart';

/// Application-facing persistence API backed by the Rust core and SQLite.
///
/// This is the only layer the screens should use; it hides the JSON transport
/// and becomes a safe no-op when the native library is unavailable.
class NativeStore {
  NativeStore._();

  /// Shared singleton.
  static final NativeStore instance = NativeStore._();

  /// Opens (or creates) the local database in private application storage.
  /// Safe to call once at startup; returns whether it succeeded.
  Future<bool> initialise() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final directory = await getApplicationSupportDirectory();
      final path = '${directory.path}/dolphinport.db';
      final response = NativeCore.instance.call('db.migrate', {'path': path});
      return response?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Records an authentication attempt. The demo authentication always
  /// succeeds, so the record is stored as successful.
  void recordLogin(String identifier, {String method = 'password'}) {
    NativeCore.instance.call('auth.recordLogin', {
      'identifier': identifier,
      'method': method,
      'success': true,
    });
  }

  /// Returns the most recent login records, or `null` when unavailable.
  List<dynamic>? listLogins({int limit = 20}) {
    final response = NativeCore.instance.call('auth.listLogins', {
      'limit': limit,
    });
    if (response?['ok'] != true) return null;
    return response!['data'] as List<dynamic>;
  }
}
