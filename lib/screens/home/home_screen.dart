// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/transaction.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/visa_card.dart';
import '../scanner/scanner_screen.dart';

/// Home screen: a black header (balance and payment card) and a white
/// transaction list share one scroll view. Scrolling up moves the header and
/// card out of view; pulling down brings them back. A floating capsule
/// navigation bar sits over the content.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _balance = 0;
  double _scannedSpend = 0;
  late final AnimationController _balanceController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _balanceController.addListener(() {
      setState(
        () => _balance = kDemoBalance * _balanceController.value - _scannedSpend,
      );
    });
    // Start the balance animation after the first frame, rather than during
    // build; no timer is left behind.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _balanceController.forward();
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Formats an integer amount with thousands separators.
  String _formatBalance(double value) {
    final grouped = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '\$$grouped';
  }

  /// Shows a short snackbar for destinations that the demo does not include.
  void _showDemoNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not part of the demo.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Scrolls the content back to the top.
  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  /// Opens the scanner. On success the scanner returns a random expense,
  /// which is added to the ledger and deducted from the displayed balance.
  Future<void> _openScanner() async {
    final transaction = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute<Transaction>(builder: (_) => const ScannerScreen()),
    );
    if (transaction == null || !mounted) return;

    walletRepository.addTransaction(transaction);
    setState(() {
      _scannedSpend += transaction.amount;
      _balance = kDemoBalance - _scannedSpend;
    });
    await _scrollToTop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paid ${transaction.title} · ${_formatBalance(transaction.amount)}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final recentTransactions = walletRepository.recentTransactions();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Black rounded container that fully encloses the actions,
                // balance and the whole payment card, resting on the list.
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20, topInset + 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance block on the left shares the top row with
                        // the action buttons on the right, so the top-left is
                        // filled and everything hugs the top of the screen.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Available balance',
                                    style: TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatBalance(_balance),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _circleButton(
                              Icons.qr_code_scanner_rounded,
                              onTap: _openScanner,
                            ),
                            const SizedBox(width: 8),
                            _circleButton(Icons.add),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // The full card sits inside the black container.
                        const VisaCard(brand: kBrandName),
                      ],
                    ),
                  ),
                ),
                // White transactions heading row.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Recent transactions',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.allTransactions,
                          ),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          TransactionTile(tx: recentTransactions[index]),
                      childCount: recentTransactions.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
              ],
            ),
            // Floating capsule navigation.
            Positioned(
              left: 0,
              right: 0,
              bottom: 22,
              child: Center(
                child: Container(
                  width: 200,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavDot(
                        icon: Icons.home_rounded,
                        active: true,
                        onTap: () => LoadingOverlay.runThen(
                          context,
                          () async => _scrollToTop(),
                        ),
                      ),
                      _NavDot(
                        icon: Icons.bar_chart_rounded,
                        active: false,
                        onTap: () => LoadingOverlay.runThen(
                          context,
                          () async => Navigator.pushNamed(
                            context,
                            RouteNames.analytics,
                          ),
                        ),
                      ),
                      _NavDot(
                        icon: Icons.grid_view_rounded,
                        active: false,
                        onTap: () => LoadingOverlay.runThen(
                          context,
                          () async => _showDemoNotice(),
                        ),
                      ),
                      _NavDot(
                        icon: Icons.person_outline_rounded,
                        active: false,
                        onTap: () => LoadingOverlay.runThen(
                          context,
                          () async => _showDemoNotice(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Semi-transparent circular action button in the header.
  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// A single icon entry in the capsule navigation.
class _NavDot extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavDot({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.black : AppColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
