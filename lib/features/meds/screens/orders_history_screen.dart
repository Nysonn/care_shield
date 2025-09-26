import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../meds/providers/meds_provider.dart';
import '../../meds/models/payment_models.dart';
import 'package:intl/intl.dart';
import 'package:care_shield/core/constants.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen>
    with TickerProviderStateMixin {
  late Future<List<MedOrder>> _ordersFuture;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final meds = Provider.of<MedsProvider>(context, listen: false);
    _ordersFuture = meds.fetchOrders();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Stagger animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _slideController.forward();
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _scaleController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getOrderStatus(MedOrder order) {
    // Check payment status first
    if (order.paymentInfo != null) {
      switch (order.paymentInfo!.status) {
        case PaymentStatus.pending:
          return 'Payment Pending';
        case PaymentStatus.processing:
          return 'Payment Processing';
        case PaymentStatus.failed:
          return 'Payment Failed';
        case PaymentStatus.completed:
          break; // Continue to delivery status
      }
    }

    // If payment is completed or no payment info, check delivery status
    final now = DateTime.now();
    final daysSinceOrder = now.difference(order.createdAt).inDays;

    if (daysSinceOrder == 0) {
      return 'Processing';
    } else if (daysSinceOrder <= 2) {
      return 'In Transit';
    } else if (daysSinceOrder <= 4) {
      return 'Out for Delivery';
    } else {
      return 'Delivered';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Payment Pending':
      case 'Payment Processing':
        return AppColors.accent;
      case 'Payment Failed':
        return Colors.red;
      case 'Processing':
        return AppColors.accent;
      case 'In Transit':
        return AppColors.primaryBlue;
      case 'Out for Delivery':
        return AppColors.primaryBlue.withOpacity(0.8);
      case 'Delivered':
        return AppColors.secondaryGreen;
      default:
        return AppColors.text;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Payment Pending':
        return Icons.schedule_outlined;
      case 'Payment Processing':
        return Icons.sync_outlined;
      case 'Payment Failed':
        return Icons.error_outline;
      case 'Processing':
        return Icons.hourglass_empty_outlined;
      case 'In Transit':
        return Icons.local_shipping_outlined;
      case 'Out for Delivery':
        return Icons.delivery_dining_outlined;
      case 'Delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildOrdersSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 200,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 18),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              final meds = Provider.of<MedsProvider>(context, listen: false);
              _ordersFuture = meds.fetchOrders();
            });
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Order History',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.security_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure & confidential tracking',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FutureBuilder<List<MedOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          final totalOrders = orders.length;
          final deliveredOrders = orders
              .where((order) => _getOrderStatus(order) == 'Delivered')
              .length;
          final inTransitOrders = orders
              .where(
                (order) => [
                  'Processing',
                  'In Transit',
                  'Out for Delivery',
                ].contains(_getOrderStatus(order)),
              )
              .length;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.text.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your medication deliveries',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Total Orders',
                        totalOrders.toString(),
                        AppColors.primaryBlue,
                        Icons.shopping_bag_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryItem(
                        'In Transit',
                        inTransitOrders.toString(),
                        AppColors.accent,
                        Icons.local_shipping_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryItem(
                        'Delivered',
                        deliveredOrders.toString(),
                        AppColors.secondaryGreen,
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your medication order history',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<MedOrder>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _buildLoadingState();
              }

              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return _buildEmptyState();
              }

              // Sort orders by creation date (newest first)
              orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withOpacity(0.08), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your orders...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryBlue,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you place your first product order, it will appear here for tracking.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.text.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(MedOrder order, int index) {
    final status = _getOrderStatus(order);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final date = DateFormat('MMM dd, yyyy').format(order.createdAt);
    final time = DateFormat('h:mm a').format(order.createdAt);

    // Different accent colors for visual variety
    final accentColors = [
      AppColors.primaryBlue,
      AppColors.secondaryGreen,
      AppColors.accent,
      AppColors.primaryBlue.withOpacity(0.8),
    ];
    final accentColor = accentColors[index % accentColors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.stage} • $date at $time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Medications list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.text.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products (${order.drugs.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.drugs
                      .map(
                        (drug) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                color: accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  drug.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment and delivery information
            if (order.paymentInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondaryGreen.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: AppColors.secondaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid via ${order.paymentInfo!.method.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                          if (order.paymentInfo!.referenceCode != null)
                            Text(
                              'Ref: ${order.paymentInfo!.referenceCode}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryGreen.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      'UGX ${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Delivery information
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.text.withOpacity(0.6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text.withOpacity(0.7),
                    ),
                  ),
                ),
                if (order.deliveryOption != null)
                  Text(
                    '${order.deliveryOption!.name} • ${order.eta}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text.withOpacity(0.6),
                    ),
                  )
                else
                  Text(
                    'ETA: ${order.eta}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
