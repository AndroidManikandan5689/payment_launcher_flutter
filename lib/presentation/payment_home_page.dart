import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/payment_config.dart';
import '../utils/payment_launcher.dart';

class PaymentHomePage extends StatefulWidget {
  const PaymentHomePage({super.key});

  @override
  State<PaymentHomePage> createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends State<PaymentHomePage> {
  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  // Show desktop warning for UPI
  void _showUpiDesktopWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.laptop_mac, size: 48, color: Colors.orange),
        title: const Text('Mobile Device Required'),
        content: const Text(
          'UPI payments can only be launched from a mobile device.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show app not installed warning for Aani Pay
  void _showAaniPayNotInstalled() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.redAccent),
        title: const Text('App Not Installed'),
        content: const Text(
          'Aani Pay application is not installed.',
          textAlign: TextAlign.center,
        ),
        actions: [
          if (PaymentConfig.aaniPayStoreUrl.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri.parse(PaymentConfig.aaniPayStoreUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  _showErrorSnackBar('Could not launch app store: $e');
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Install Aani Pay'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Process UPI Payment
  Future<void> _handleUpiPay() async {
    _setLoading(true);
    await PaymentLauncher.launchUpi(
      onError: (error) {
        _setLoading(false);
        _showErrorSnackBar(error);
      },
      onDesktopWarning: () {
        _setLoading(false);
        _showUpiDesktopWarning();
      },
    );
    // Add small delay to keep loading animation smooth if app launches
    await Future.delayed(const Duration(milliseconds: 500));
    _setLoading(false);
  }

  // Process Aani Pay
  Future<void> _handleAaniPay() async {
    _setLoading(false); // Reset just in case
    _setLoading(true);
    await PaymentLauncher.launchAaniPay(
      onAppNotInstalled: (msg) {
        _setLoading(false);
        _showAaniPayNotInstalled();
      },
      onError: (error) {
        _setLoading(false);
        _showErrorSnackBar(error);
      },
    );
    await Future.delayed(const Duration(milliseconds: 500));
    _setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
                  theme.colorScheme.secondaryContainer.withOpacity(0.2),
                  theme.colorScheme.background,
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Hero(
                  tag: 'payment_card',
                  child: Card(
                    elevation: 8,
                    shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wallet_outlined,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App Title
                          Text(
                            'Payment Launcher',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onBackground,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            'Choose a payment method',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // UPI Button
                          _buildPaymentButton(
                            context: context,
                            text: 'Pay via UPI',
                            icon: Icons.payments,
                            color: theme.colorScheme.primary,
                            onPressed: _isLoading ? null : _handleUpiPay,
                          ),
                          const SizedBox(height: 16),

                          // Aani Pay Button
                          _buildPaymentButton(
                            context: context,
                            text: 'Open Aani Pay',
                            icon: Icons.account_balance_wallet,
                            color: theme.colorScheme.secondary,
                            onPressed: _isLoading ? null : _handleAaniPay,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.surfaceVariant,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.38),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
