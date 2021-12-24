import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_session/http_session.dart';

void main() {
  const MethodChannel channel = MethodChannel('http_session');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HttpSession.platformVersion, '42');
  });
}
