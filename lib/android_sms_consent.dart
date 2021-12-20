// Copyright (c) 2021 The Khalti Authors. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A class to request one-time consent to read an SMS with alphanumeric string.
///
/// SMS is listened for only if it meets these criteria:
/// - The message contains a 4-10 character alphanumeric string with at least one number.
/// - The message was sent by a phone number that's not in the user's contacts.
/// - If you specified the sender's phone number, the message was sent by that number.
class AndroidSmsConsent {
  /// Creates an instance of [AndroidSmsConsent].
  AndroidSmsConsent({
    required ValueChanged<String> onAllowed,
    String? pattern,
    VoidCallback? onDenied,
    VoidCallback? onTimeout,
    VoidCallback? onPatternUnmatched,
  }) : _channel = const MethodChannel('android_sms_consent') {
    _channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case 'onAllowed':
            final sms = call.arguments.toString();
            if (pattern == null) {
              onAllowed(sms);
            } else {
              final regex = RegExp(pattern);
              if (regex.hasMatch(sms)) {
                final message = regex.firstMatch(sms)!.group(0)!;
                onAllowed(message);
              } else {
                onPatternUnmatched?.call();
              }
            }
            break;
          case 'onDenied':
            onDenied?.call();
            break;
          case 'onTimeout':
            onTimeout?.call();
            break;
        }
      },
    );
  }

  final MethodChannel _channel;

  /// Starts listening for incoming messages(with 4-10 character alphanumeric string with at least one number)
  /// for the next 5 minutes.
  ///
  /// If [sender] is provided, messages from the sender is only listened for.
  /// Otherwise messages for any sender is listened.
  void start([String? sender]) => _invoke('start', sender);

  /// Stops the listener for incoming messages.
  void stop() => _invoke('stop');

  void _invoke(String method, [String? argument]) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _channel.invokeMethod<void>(method, argument);
    }
  }
}
