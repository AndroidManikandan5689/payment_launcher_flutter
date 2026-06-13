import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/payment_config.dart';

bool isMobileBrowserImpl() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('mobi') ||
      userAgent.contains('android') ||
      userAgent.contains('iphone') ||
      userAgent.contains('ipad');
}

Future<void> launchUpiImpl({
  required Function(String) onError,
  required Function() onDesktopWarning,
}) async {
  if (!isMobileBrowserImpl()) {
    onDesktopWarning();
    return;
  }

  // Generate UPI URL
  // Example: upi://pay?pa=test@upi&pn=Demo Merchant&am=1.00&cu=INR&tn=FlutterWebTest
  final String upiUrl = 'upi://pay'
      '?pa=${Uri.encodeComponent(PaymentConfig.upiId)}'
      '&pn=${Uri.encodeComponent(PaymentConfig.merchantName)}'
      '&am=${Uri.encodeComponent(PaymentConfig.amount)}'
      '&cu=INR'
      '&tn=${Uri.encodeComponent('FlutterWebTest')}';

  try {
    final uri = Uri.parse(upiUrl);
    // In web, launchUrl with webOnlyWindowName: '_self' launches in the same tab.
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    );
    if (!launched) {
      // Fallback direct redirection
      html.window.location.href = upiUrl;
    }
  } catch (e) {
    onError('Failed to launch UPI: $e');
  }
}

Future<void> launchAaniPayImpl({
  required Function(String) onAppNotInstalled,
  required Function(String) onError,
}) async {
  final String deepLink = PaymentConfig.aaniPayDeepLink;

  bool wasBlurred = false;

  final blurSubscription = html.window.onBlur.listen((event) {
    wasBlurred = true;
  });

  final visibilitySubscription =
      html.document.onVisibilityChange.listen((event) {
    if (html.document.visibilityState == 'hidden') {
      wasBlurred = true;
    }
  });

  try {
    final uri = Uri.parse(deepLink);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      html.window.location.href = deepLink;
    }
  } catch (e) {
    blurSubscription.cancel();
    visibilitySubscription.cancel();
    onError('Error launching Aani Pay: $e');
    return;
  }

  // Wait 2.5 seconds to see if the browser lost focus or tab became hidden (meaning the app launched).
  await Future.delayed(const Duration(milliseconds: 2500));

  blurSubscription.cancel();
  visibilitySubscription.cancel();

  if (!wasBlurred) {
    onAppNotInstalled('Aani Pay application is not installed.');
  }
}
