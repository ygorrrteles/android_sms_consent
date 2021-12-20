// Copyright (c) 2021 The Khalti Authors. All rights reserved.

import 'package:android_sms_consent/android_sms_consent.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AndroidSmsConsent _androidSmsConsent;
  ScaffoldMessengerState? _scaffoldMessenger;

  String _sms = '';

  @override
  void initState() {
    super.initState();
    _androidSmsConsent = AndroidSmsConsent(
      pattern: r'\d{4,}',
      onAllowed: (sms) {
        _sms = sms;
        setState(() {});
      },
      onDenied: () {
        _scaffoldMessenger?.showSnackBar(
          const SnackBar(content: Text('User denied!')),
        );
      },
      onPatternUnmatched: () {
        _scaffoldMessenger?.showSnackBar(
          const SnackBar(
            content: Text('OTP not found! Please try entering OTP manually.'),
          ),
        );
      },
    )
      ..start('TestOne')
      ..start('TestTwo');
  }

  @override
  void dispose() {
    _androidSmsConsent.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Android SMS Consent'),
        ),
        body: Builder(
          builder: (context) {
            _scaffoldMessenger ??= ScaffoldMessenger.of(context);

            return Center(
              child: Text(
                'SMS: $_sms',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            );
          },
        ),
      ),
    );
  }
}
