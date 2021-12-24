
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class HttpSession {
  static const MethodChannel _channel = MethodChannel('http_session');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String?> get(String url) async {
    return await _channel.invokeMethod('get', {"url": url});
  }

  Future<String?> post(String url, Map<String, String> data) async {
    String? response = await _channel.invokeMethod('post', {"url": url, "data": jsonEncode(data)});
    return response;
  }

  Future<String?> multipart(String url, String fileFieldName, String fileUrl, Map<String, String> data) async {
    String? response = await _channel.invokeMethod('multipart', {"url": url, "data": jsonEncode(data), "fileFieldName": fileFieldName, "fileUrl": fileUrl});
    return response;
  }
}
