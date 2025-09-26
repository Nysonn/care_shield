import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:care_shield/core/widgets/product_card.dart';
import '../models/drug.dart';
import '../providers/meds_provider.dart';
import 'med_order_screen.dart';
import 'orders_history_screen.dart';
import 'package:care_shield/core/constants.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _slideController.forward();
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _staggerController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meds = Provider.of<MedsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildActionCards(),
                      const SizedBox(height: 40),
                      _buildMedicationsSection(meds),
                      const SizedBox(height: 32),
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

  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Browse and order products',
                    style: TextStyle(
                      color: AppColors.text.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrdersHistoryScreen(),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.history,
                  color: AppColors.secondaryGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order refills or browse our health product catalog',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _staggerAnimation,
        builder: (context, child) {
          return Column(
            children: [
              Transform.translate(
                offset: Offset(0, 50 * (1 - _staggerAnimation.value)),
                child: Opacity(
                  opacity: _staggerAnimation.value,
                  child: _buildActionCard(
                    title: 'Order Refill',
                    subtitle: 'Refill your existing prescription',
                    icon: Icons.refresh,
                    color: AppColors.primaryBlue,
                    onTap: () => _navigateToOrder('Refill'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Transform.translate(
                offset: Offset(0, 30 * (1 - _staggerAnimation.value)),
                child: Opacity(
                  opacity: _staggerAnimation.value,
                  child: _buildActionCard(
                    title: 'Browse Products',
                    subtitle: 'Explore our health product catalog',
                    icon: Icons.inventory_2,
                    color: AppColors.secondaryGreen,
                    onTap: () => _navigateToOrder('New order'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection(MedsProvider meds) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meds.drugs.length} products available',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppColors.secondaryGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          color: AppColors.secondaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(
                meds.drugs.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildMedicationCard(meds.drugs[index], index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Drug drug, int index) {
    return ProductCard(
      drug: drug,
      index: index,
      isCompact: false, // Use full layout for meds screen
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MedOrderScreen(stage: 'Refill', preselectedDrug: drug),
          ),
        );
      },
    );
  }

  void _navigateToOrder(String stage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedOrderScreen(stage: stage)),
    );
  }
}
