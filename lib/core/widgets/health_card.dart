import 'package:flutter/material.dart';
import 'package:care_shield/features/health/models/health_center.dart';
import 'package:care_shield/core/constants.dart';

class HealthCard extends StatelessWidget {
  final HealthCenter center;
  final VoidCallback onTap;

  const HealthCard({super.key, required this.center, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.text.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section with name and status indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        center.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusIndicator(),
                  ],
                ),

                const SizedBox(height: 8),

                // Address with location icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.text.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        center.address,
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer section with enhanced info display
                Row(
                  children: [
                    // Distance chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.text.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_walk_outlined,
                            size: 12,
                            color: AppColors.text,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${center.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Operating hours
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: AppColors.text.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          center.openHours,
                          style: TextStyle(
                            color: AppColors.text.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Navigation arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.text.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // Determine if the center is currently open
    final bool isOpen = _isCurrentlyOpen();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isOpen ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentlyOpen() {
    // Simple logic - you can enhance this based on your actual business logic
    final now = DateTime.now();
    final currentHour = now.hour;

    // Assuming most health centers are open between 8 AM and 6 PM
    // You should replace this with actual parsing of center.openHours
    return currentHour >= 8 && currentHour < 18;
  }
}
