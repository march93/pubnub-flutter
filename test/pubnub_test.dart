import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubnub/pubnub.dart';

void main() {
  const MethodChannel channel = MethodChannel('pubnub');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Pubnub.platformVersion, '42');
  });
}
