// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

// Native signatures for the Rust C ABI.
//   char* dp_call(char* request);
//   void  dp_free(char* response);
typedef CallNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef CallDart = Pointer<Utf8> Function(Pointer<Utf8>);
typedef FreeNative = Void Function(Pointer<Utf8>);
typedef FreeDart = void Function(Pointer<Utf8>);

/// Thin transport over the bundled Rust shared object.
///
/// Requests and responses are JSON. On Android the library
/// `libdolphinport_core.so` is packaged inside the APK and opened by name.
/// When the library cannot be opened (for example, host-side widget tests or a
/// desktop build), [call] returns `null` and callers degrade gracefully, so no
/// platform exception ever reaches the UI.
class NativeCore {
  NativeCore._();

  /// Shared singleton.
  static final NativeCore instance = NativeCore._();

  CallDart? _call;
  FreeDart? _free;
  bool _tried = false;
  bool _available = false;

  /// Whether the native library was loaded successfully.
  bool get isAvailable => _available;

  /// Opens and bind the shared object once.
  bool _open() {
    if (_tried) return _available;
    _tried = true;
    try {
      final library = DynamicLibrary.open('libdolphinport_core.so');
      _call = library.lookupFunction<CallNative, CallDart>('dp_call');
      _free = library
          .lookup<NativeFunction<FreeNative>>('dp_free')
          .asFunction<FreeDart>();
      _available = true;
    } catch (error) {
      _available = false;
      throw StateError("Native library failed to load: $error");
    }
    return _available;
  }

  /// Invokes [method] with optional [params] and returns the decoded response
  /// map, or `null` when the native side is unavailable or the call fails.
  /// Check the response's `ok` field for success.
  Map<String, dynamic>? call(String method, [Map<String, dynamic>? params]) {
    if (!_open() || _call == null || _free == null) return null;

    final request = jsonEncode({'method': method, 'params': params ?? {}});
    final requestPointer = request.toNativeUtf8();

    Pointer<Utf8> responsePointer;
    try {
      responsePointer = _call!(requestPointer);
    } finally {
      calloc.free(requestPointer);
    }

    if (responsePointer == nullptr) {
      throw StateError("Native core returned nullptr");
    }
    String text;
    try {
      text = responsePointer.toDartString();
    } finally {
      _free!(responsePointer);
    }
    if (text.isEmpty) return null;

    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
