import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:care_shield/core/constants.dart';
import 'package:care_shield/features/meds/models/drug.dart';
import 'package:care_shield/features/meds/screens/med_order_screen.dart';

/// A reusable product card widget that displays drug/product information
/// Used across home screen and meds screen for consistent UI
class ProductCard extends StatelessWidget {
  final Drug drug;
  final int? index;
  final bool isCompact; // Controls card layout style
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.drug,
    this.index,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _defaultOnTap(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isCompact
              ? _buildCompactLayout(context)
              : _buildFullLayout(context),
        ),
      ),
    );
  }

  /// Compact layout used in home screen - horizontal row layout
  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: [
        // Icon with gradient background
        _buildProductIcon(),
        const SizedBox(width: 16),

        // Product details - expanded to take available space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Text(
                drug.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Category
              Text(
                drug.category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Price and dosage row
              Row(
                children: [
                  _buildPriceTag(),
                  const SizedBox(width: 12),
                  _buildDosageBadge(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Order button
        _buildOrderButton(isCompact: true, context: context),
      ],
    );
  }

  /// Full layout used in meds screen - vertical column layout
  Widget _buildFullLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with gradient background
            _buildProductIcon(),
            const SizedBox(width: 16),

            // Product details - expanded to take available space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    drug.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Category
                  Text(
                    drug.category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bottom row with price, dosage, and order button
        Row(
          children: [
            // Price
            _buildPriceTag(),
            const SizedBox(width: 12),
            // Dosage badge
            _buildDosageBadge(),
            const Spacer(),
            // Order button
            _buildOrderButton(isCompact: false, context: context),
          ],
        ),
      ],
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.2),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.medication, color: AppColors.primaryBlue, size: 24),
    );
  }

  Widget _buildPriceTag() {
    return Text(
      'UGX ${drug.price.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDosageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryGreen.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        drug.dosage,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryGreen,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildOrderButton({
    required bool isCompact,
    required BuildContext context,
  }) {
    final buttonWidth = isCompact ? 100.0 : 70.0;
    final buttonHeight = isCompact ? 40.0 : 36.0;
    final iconSize = isCompact ? 16.0 : 14.0;
    final fontSize = isCompact ? 12.0 : 12.0;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => _defaultOnTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart, size: iconSize),
            if (isCompact) ...[
              const SizedBox(width: 4),
              Text(
                'Order',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ] else
              const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedOrderScreen(stage: 'Refill', preselectedDrug: drug),
      ),
    );
  }
}
