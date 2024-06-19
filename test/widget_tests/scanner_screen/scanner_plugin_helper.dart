import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

const channelFlutter = MethodChannel('flutter/platform_views');
const channelPlugin = MethodChannel('net.touchcapture.qr.flutterqr/qrview_0');

void mockMethodChannels(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channelFlutter, (MethodCall methodCall) => Future.value(200)
  );
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channelPlugin, (MethodCall methodCall) {
        print("Call to platform: ${methodCall.method}, data: ${methodCall.arguments}");
        switch(methodCall.method) {
          case "onRecognizeQR":
            return Future(() => utf8.encode("Hello world"));
          default:
            return Future.value(200);
        }
      }
  );
}

MethodChannel get qrPluginChannel  => channelPlugin;


extension MethodChannelMock on MethodChannel {
  Future<void> invokeMockMethod(String method, dynamic arguments) async {
    const codec = StandardMethodCodec();
    final data = codec.encodeMethodCall(MethodCall(method, arguments));

    return ServicesBinding.instance.channelBuffers.push(
      name,
      data,
      (ByteData? data) {}
    );
  }
}