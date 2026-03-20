// lib/widgets/offline_detector.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OfflineDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;
  final bool autoRefresh;

  const OfflineDetector({
    super.key,
    required this.child,
    this.onOnline,
    this.onOffline,
    this.autoRefresh = true,
  });

  @override
  State<OfflineDetector> createState() => _OfflineDetectorState();
}

class _OfflineDetectorState extends State<OfflineDetector> {
  bool _isOffline = false;
  late Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = _isOffline;
    final isNowOffline = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);

    if (mounted) setState(() => _isOffline = isNowOffline);

    if (isNowOffline && !wasOffline) {
      widget.onOffline?.call();
    } else if (!isNowOffline && wasOffline) {
      widget.onOnline?.call();
      _showBackOnlineSnackbar();
      if (widget.autoRefresh && mounted) setState(() {});
    }
  }

  void _showBackOnlineSnackbar() {
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
            Text('Back online!',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(width: 4),
            Text('Refreshing data…'),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Homescreen always stays rendered — never swapped out
        widget.child,

        // Offline overlay slides up from the bottom when disconnected
        AnimatedSlide(
          offset: _isOffline ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _isOffline ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 280),
            child: _OfflineOverlay(onRetry: _checkConnectivity),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Offline overlay — slides up over the homescreen
// ─────────────────────────────────────────────────────────

class _OfflineOverlay extends StatefulWidget {
  final VoidCallback onRetry;
  const _OfflineOverlay({required this.onRetry});

  @override
  State<_OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<_OfflineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // Dimmed area — homescreen still visible behind it
        Expanded(
          child: GestureDetector(
            onTap: () {}, // absorb taps so homescreen isn't interactive
            child: Container(color: Colors.black.withOpacity(0.40)),
          ),
        ),

        // Bottom sheet panel
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.97),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 36,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(28, 20, 28, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon + text
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: 0.92 + 0.08 * _pulseController.value,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444).withOpacity(0.12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.28),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xFFEF4444),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check your Wi-Fi or mobile data.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Retry button
              GestureDetector(
                onTap: _isChecking ? null : _handleRetry,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isChecking
                          ? [const Color(0xFF334155), const Color(0xFF334155)]
                          : [
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isChecking
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
                      if (_isChecking)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        )
                      else
                        const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isChecking ? 'Checking…' : 'Try Again',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Will reconnect automatically when back online',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.22),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Context extension
// ─────────────────────────────────────────────────────────

extension ConnectivityExtension on BuildContext {
  Future<bool> isConnected() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
  }
}