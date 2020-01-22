import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowController {
  static const _channel = const MethodChannel('window_controller');

  static final Random _random = Random.secure();

  static Future<bool> createWindow(String key,
      {Offset offset, Size size}) async {
    await _channel.invokeMethod('createWindow', {
      "key": key,
      "x": offset?.dx,
      "y": offset?.dy,
      "width": size?.width,
      "height": size?.height,
    });
    var _key = await lastWindowKey();
    return _key == key;
  }

  static Future<bool> closeWindow(String key) {
    try {
      return _channel.invokeMethod<bool>('closeWindow', {"key": key});
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<String> openWebView(String key, String url,
      {Offset offset, Size size, String jsMessage = ""}) async {
    return _channel.invokeMethod<String>('openWebView', {
      "key": key,
      "url": url,
      "jsMessage": jsMessage,
      "x": offset?.dx,
      "y": offset?.dy,
      "width": size?.width,
      "height": size?.height,
    });
  }

  static Future<bool> closeWebView(String key) {
    try {
      return _channel.invokeMethod<bool>('closeWebView', {
        "key": key,
      });
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> resizeWindow(String key, Size size) async {
    return _channel.invokeMethod<bool>('resizeWindow', {
      "key": key,
      "width": size?.width,
      "height": size?.height,
    });
  }

  static Future<bool> moveWindow(String key, Offset offset) async {
    return _channel.invokeMethod<bool>('moveWindow', {
      "key": key,
      "x": offset?.dx,
      "y": offset?.dy,
    });
  }

  static Future<int> keyIndex(String key) {
    return _channel.invokeMethod<int>('keyIndex', {"key": key});
  }

  static Future<int> windowCount() {
    return _channel.invokeMethod<int>('windowCount');
  }

  static Future<String> lastWindowKey() {
    return _channel.invokeMethod<String>("lastWindowKey");
  }

  static Future<Map> getWindowStats(String key) {
    return _channel.invokeMethod<Map>("getWindowStats", {"key": key});
  }

  static Future<Size> getWindowSize(String key) async {
    final _stats = await getWindowStats(key);
    final w = _stats['width'] as double;
    final h = _stats['height'] as double;
    return Size(w, h);
  }

  static Future<Offset> getWindowOffset(String key) async {
    final _stats = await getWindowStats(key);
    final x = _stats['offsetX'] as double;
    final y = _stats['offsetY'] as double;
    return Offset(x, y);
  }

  static String generateKey([int length = 10]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }
}
