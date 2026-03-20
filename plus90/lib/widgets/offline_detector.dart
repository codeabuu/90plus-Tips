// lib/widgets/offline_detector.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:math' as math;

class OfflineDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;
  final bool showOfflineDialog;
  final bool autoRefresh;

  const OfflineDetector({
    super.key,
    required this.child,
    this.onOnline,
    this.onOffline,
    this.showOfflineDialog = true,
    this.autoRefresh = true,
  });

  @override
  State<OfflineDetector> createState() => _OfflineDetectorState();
}

class _OfflineDetectorState extends State<OfflineDetector> {
  bool _isOffline = false;
  bool _hasShownDialog = false;
  late Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkConnectivity();
    _listenForConnectivityChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _listenForConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateStatus(results);
      },
    );
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = _isOffline;
    final isNowOffline = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);

    if (mounted) {
      setState(() {
        _isOffline = isNowOffline;
      });
    }

    if (isNowOffline && !wasOffline) {
      widget.onOffline?.call();
      _hasShownDialog = false;
      if (widget.showOfflineDialog) {
        _showOfflineDialog();
      }
    } else if (!isNowOffline && wasOffline) {
      if (_hasShownDialog && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _hasShownDialog = false;
      }
      widget.onOnline?.call();
      _showBackOnlineMessage();
      if (widget.autoRefresh) {
        _refreshData();
      }
    }
  }

  void _showOfflineDialog() {
    if (_hasShownDialog || !widget.showOfflineDialog || !mounted) return;
    _hasShownDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const _OfflineDialog(),
      ),
    ).then((_) {
      _hasShownDialog = false;
    });
  }

  void _startAutoRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isConnected) {
        timer.cancel();
        if (mounted) {
          if (_hasShownDialog) {
            Navigator.of(context, rootNavigator: true).pop();
            _hasShownDialog = false;
          }
          _updateStatus(results);
        }
      }
    });
  }

  void _showBackOnlineMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Back online!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 4),
            Text('Refreshing data…'),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _refreshData() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return OfflinePlaceholder(onRetry: _checkConnectivity);
    }
    return widget.child;
  }
}

// ──────────────────────────────────────────────
// Offline dialog
// ──────────────────────────────────────────────

class _OfflineDialog extends StatefulWidget {
  const _OfflineDialog();

  @override
  State<_OfflineDialog> createState() => _OfflineDialogState();
}

class _OfflineDialogState extends State<_OfflineDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  bool _isRetrying = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  void _startAutoRetry() {
    setState(() {
      _isRetrying = true;
      _retryCount = 0;
    });

    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _retryCount++);

      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();
      final isConnected = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);

      if (isConnected) {
        timer.cancel();
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _stopRetry() {
    _retryTimer?.cancel();
    setState(() {
      _isRetrying = false;
      _retryCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFEF4444),
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'No Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'An internet connection is required.\nThe app will reconnect automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Retry status
                  if (_isRetrying) ...[
                    _RetryStatusChip(count: _retryCount),
                    const SizedBox(height: 20),
                  ],

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineButton(
                          label: 'Check Now',
                          onTap: () async {
                            _stopRetry();
                            final connectivity = Connectivity();
                            final results =
                                await connectivity.checkConnectivity();
                            final isConnected = results.isNotEmpty &&
                                results
                                    .any((r) => r != ConnectivityResult.none);
                            if (isConnected && mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isRetrying
                            ? _OutlineButton(
                                label: 'Stop',
                                onTap: _stopRetry,
                                color: const Color(0xFFEF4444),
                              )
                            : _PrimaryButton(
                                label: 'Auto-Retry',
                                onTap: _startAutoRetry,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryStatusChip extends StatelessWidget {
  final int count;
  const _RetryStatusChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          const SizedBox(width: 8),
          Text(
            count == 0
                ? 'Connecting…'
                : 'Retry $count — still offline',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            const Color(0xFFFBBF24),
            const Color(0xFFF97316),
            _controller.value,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          color: color.withOpacity(0.05),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.85),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Full-screen offline placeholder
// ──────────────────────────────────────────────

class OfflinePlaceholder extends StatefulWidget {
  final VoidCallback onRetry;

  const OfflinePlaceholder({super.key, required this.onRetry});

  @override
  State<OfflinePlaceholder> createState() => _OfflinePlaceholderState();
}

class _OfflinePlaceholderState extends State<OfflinePlaceholder>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isChecking = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onRetry();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          // Subtle animated background
          Positioned.fill(child: _AnimatedBackground(controller: _waveController)),

          // Content
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with rings
                        _AnimatedWifiIcon(controller: _waveController),
                        const SizedBox(height: 40),

                        // Heading
                        const Text(
                          'You\'re Offline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'No internet connection detected.\nConnect to Wi-Fi or mobile data to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Retry button
                        _RetryButton(
                          isLoading: _isChecking,
                          onTap: _handleRetry,
                        ),

                        const SizedBox(height: 20),

                        // Hint
                        Text(
                          'The app will reconnect automatically',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Animated background — slow glowing orbs
// ──────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return CustomPaint(
          painter: _BackgroundPainter(t),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double t;
  _BackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — indigo
    final center1 = Offset(
      size.width * (0.15 + 0.05 * math.sin(t * 2 * math.pi)),
      size.height * (0.25 + 0.06 * math.cos(t * 2 * math.pi)),
    );
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.18),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: 220));
    canvas.drawCircle(center1, 220, paint);

    // Orb 2 — violet
    final center2 = Offset(
      size.width * (0.85 + 0.04 * math.cos(t * 2 * math.pi)),
      size.height * (0.65 + 0.05 * math.sin(t * 2 * math.pi + 1)),
    );
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF8B5CF6).withOpacity(0.14),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: 200));
    canvas.drawCircle(center2, 200, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.t != t;
}

// ──────────────────────────────────────────────
// Animated wifi-off icon with pulsing rings
// ──────────────────────────────────────────────

class _AnimatedWifiIcon extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedWifiIcon({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring 3 — outermost, fades earliest
              _Ring(
                radius: 68,
                opacity: (1 - t).clamp(0.0, 1.0) * 0.12,
                color: const Color(0xFFEF4444),
              ),
              // Ring 2
              _Ring(
                radius: 52,
                opacity: ((0.6 - t + 1) % 1) * 0.2,
                color: const Color(0xFFEF4444),
              ),
              // Ring 1 — innermost
              _Ring(
                radius: 38,
                opacity: ((0.3 - t + 1) % 1) * 0.3,
                color: const Color(0xFFEF4444),
              ),

              // Center icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEF4444).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFEF4444),
                  size: 34,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Ring extends StatelessWidget {
  final double radius;
  final double opacity;
  final Color color;

  const _Ring({
    required this.radius,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity.clamp(0, 1)),
          width: 1.5,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Retry button with loading state
// ──────────────────────────────────────────────

class _RetryButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _RetryButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [const Color(0xFF334155), const Color(0xFF334155)]
                : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              )
            else
              const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              isLoading ? 'Checking…' : 'Try Again',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Context extension
// ──────────────────────────────────────────────

extension ConnectivityExtension on BuildContext {
  Future<bool> isConnected() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
  }
}