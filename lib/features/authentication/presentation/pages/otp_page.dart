import 'package:flutter/widgets.dart';

/// Minimal placeholder OTP verification page for route wiring.
/// Custom UI/UX design system will be implemented in the next phase.
class OtpPage extends StatelessWidget {
  const OtpPage({super.key, this.phone = ''});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('OTP Page Foundation: $phone'),
    );
  }
}
