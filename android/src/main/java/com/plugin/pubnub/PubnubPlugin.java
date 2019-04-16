package com.plugin.pubnub;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.pubnub.api.PNConfiguration;
import com.pubnub.api.PubNub;

/** PubnubPlugin */
public class PubnubPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "pubnub");
    channel.setMethodCallHandler(new PubnubPlugin());

    final EventChannel messageChannel = new EventChannel(registrar.messenger(), "plugins.flutter.io/pubnub_message");
    // final MessageStreamHandler messageStreamHandler = new MessageStreamHandler();
    messageChannel.setStreamHandler(new StreamHandler() {
      @Override
      public void onListen(Object arguments, EventSink events) {

      }

      @Override
      public void onCancel(Object arguments) {

      }
    });
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
      case "create":
        onCreate(call, result);
      default:
        result.notImplemented();
    }
  }

  public void onCreate(MethodCall call, Result result) {
    final String publishKey = call.argument("publishKey");
    final String subscribeKey = call.argument("subscribeKey");
    final String uuid = call.argument("uuid");

    if ((publishKey != null && !publishKey.isEmpty()) && (subscribeKey != null && !subscribeKey.isEmpty())) {
      PNConfiguration pnConfiguration = new PNConfiguration();
      pnConfiguration.setPublishKey(publishKey);
      pnConfiguration.setSubscribeKey(subscribeKey);
      pnConfiguration.setSecure(true);

      if (uuid != null && !uuid.isEmpty()) {
        pnConfiguration.setUuid(uuid);
      } else {
        pnConfiguration.setUuid(pnConfiguration.getUuid());
      }

      PubNub pubnub = new PubNub(pnConfiguration);
    }

    result.success(null);
  }
}
