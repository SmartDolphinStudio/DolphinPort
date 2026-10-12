import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'native_core.dart';

void _nativeWorker(SendPort startup) {
  final requests = ReceivePort();
  startup.send(requests.sendPort);
  requests.listen((dynamic message) {
    final data = message as List<dynamic>;
    final reply = data[0] as SendPort;
    try {
      reply.send(
        NativeCore.instance.call(
          data[1] as String,
          data[2] as Map<String, dynamic>,
        ),
      );
    } catch (error) {
      reply.send({'ok': false, 'error': error.toString()});
    }
  });
}

class NativeStore {
  NativeStore._();
  static final instance = NativeStore._();
  final status = ValueNotifier<String>('Persistence not initialised');
  Future<SendPort>? _worker;
  Future<SendPort> _start() async {
    final ready = ReceivePort();
    await Isolate.spawn(_nativeWorker, ready.sendPort);
    final port = await ready.first as SendPort;
    ready.close();
    return port;
  }

  Future<Map<String, dynamic>?> _request(
    String method,
    Map<String, dynamic> params,
  ) async {
    try {
      final worker = await (_worker ??= _start());
      final reply = ReceivePort();
      worker.send([reply.sendPort, method, params]);
      final result = await reply.first;
      reply.close();
      if (result is! Map<String, dynamic> || result['ok'] != true) {
        status.value =
            'Local storage failed: ${result is Map ? result['error'] : 'no response'}';
        return null;
      }
      status.value = 'Local storage ready';
      return result;
    } catch (error) {
      status.value = 'Local storage unavailable: $error';
      return null;
    }
  }

  Future<bool> initialise() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      status.value = 'Local persistence disabled on this platform';
      return false;
    }
    try {
      final dir = await getApplicationSupportDirectory();
      return await _request('db.migrate', {
            'path': '${dir.path}/dolphinport.db',
          }) !=
          null;
    } catch (error) {
      status.value = 'Local storage unavailable: $error';
      return false;
    }
  }

  Future<void> recordLogin(
    String identifier, {
    String method = 'password',
  }) async {
    await _request('auth.recordLogin', {
      'identifier': 'demo-login',
      'method': method,
      'success': true,
    });
  }

  Future<List<dynamic>?> listLogins({int limit = 20}) async {
    final result = await _request('auth.listLogins', {'limit': limit});
    return result?['data'] as List<dynamic>?;
  }

  Future<void> clearPersonalData() async {
    await _request('db.clearPersonalData', {});
  }
}
