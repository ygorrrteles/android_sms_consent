# Android SMS Consent

Flutter plugin to perform one-tap SMS verification with the SMS User Consent API in Android.

The following criteria must meet for the API to be triggered:
    - The message contains a 4-10 character alphanumeric string with at least one number.
    - The message was sent by a phone number that's not in the user's contacts.
    - If you specified the sender's phone number, the message was sent by that number.

## Usage

```dart
  final androidSmsConsent = AndroidSmsConsent(
    pattern: r'\d{4,}',
    onAllowed: (sms) {
      print(sms);
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
  )..start('TestOne');
```