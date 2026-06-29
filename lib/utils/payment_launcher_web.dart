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
  final TargetPlatform platform = defaultTargetPlatform;

  if (platform == TargetPlatform.android) {
    try {
      final Uri parsedUri = Uri.parse(deepLink);
      String intentScheme = parsedUri.scheme;
      if (intentScheme != 'aani' && intentScheme != 'aanipay') {
        intentScheme = 'aani';
      }

      String intentHost = parsedUri.host;
      if (parsedUri.scheme == 'http' || parsedUri.scheme == 'https') {
        if (parsedUri.path.contains('request_to_pay_payment')) {
          intentHost = 'request_to_pay_payment';
        } else {
          intentHost = 'pay';
        }
      } else {
        if (intentHost.isEmpty) {
          intentHost = 'pay';
        }
      }

      String intentPath = parsedUri.path;
      if ((parsedUri.scheme == 'http' || parsedUri.scheme == 'https') && parsedUri.path.contains('request_to_pay_payment')) {
        intentPath = parsedUri.path.replaceAll('/request_to_pay_payment', '');
      }

      if (parsedUri.query.isNotEmpty) {
        intentPath += '?${parsedUri.query}';
      }

      final String currentUrl = html.window.location.href;
      String cleanUrl = currentUrl;
      if (cleanUrl.contains('aani_installed=')) {
        cleanUrl = cleanUrl.replaceAll(RegExp(r'[&?]aani_installed=[^&]*'), '');
      }
      final String separator = cleanUrl.contains('?') ? '&' : '?';
      final String fallbackUrl = '$cleanUrl${separator}aani_installed=false';

      final String intentUrl = 'intent://$intentHost$intentPath#Intent;scheme=$intentScheme;package=ae.aletihadpayments.aani;S.browser_fallback_url=${Uri.encodeComponent(fallbackUrl)};end';

      html.window.location.href = intentUrl;
    } catch (e) {
      onError('Error launching Aani Pay: $e');
    }
    return;
  }

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
      mode: LaunchMode.platformDefault,
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
