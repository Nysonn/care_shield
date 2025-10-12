import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:care_shield/core/constants.dart';
import '../models/pharmacy.dart';
import '../models/pharmacy_drug.dart';
import '../models/service.dart';
import '../models/drug.dart';
import '../providers/pharmacy_provider.dart';
import 'checkout_screen.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Cart items
  final Map<String, PharmacyDrug> _selectedDrugs = {};
  final Map<String, PharmacyService> _selectedServices = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load pharmacy data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PharmacyProvider>(context, listen: false);
      provider.selectPharmacy(widget.pharmacy);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addDrugToCart(PharmacyDrug drug) {
    setState(() {
      if (_selectedDrugs.containsKey(drug.id)) {
        _selectedDrugs.remove(drug.id);
      } else {
        _selectedDrugs[drug.id] = drug;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _addServiceToCart(PharmacyService service) {
    setState(() {
      if (_selectedServices.containsKey(service.id)) {
        _selectedServices.remove(service.id);
      } else {
        _selectedServices[service.id] = service;
      }
    });
    HapticFeedback.lightImpact();
  }

  double get _cartTotal {
    double drugsTotal = _selectedDrugs.values.fold(
      0,
      (sum, d) => sum + d.price,
    );
    double servicesTotal = _selectedServices.values.fold(
      0,
      (sum, s) => sum + s.price,
    );
    return drugsTotal + servicesTotal;
  }

  int get _cartItemsCount {
    return _selectedDrugs.length + _selectedServices.length;
  }

  void _proceedToCheckout() {
    if (_cartItemsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one item to your cart'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convert selected items to lists
    final selectedPharmacyDrugs = _selectedDrugs.values.toList();
    final selectedPharmacyServices = _selectedServices.values.toList();

    // Convert PharmacyDrug to Drug for selectedDrugs parameter
    final drugs = selectedPharmacyDrugs.map((pharmDrug) {
      return Drug(
        id: pharmDrug.drug.id,
        name: pharmDrug.drug.name,
        description: pharmDrug.drug.description,
        dosage: pharmDrug.drug.dosage,
        price: pharmDrug.price,
        category: pharmDrug.drug.category,
        requiresPrescription: pharmDrug.drug.requiresPrescription,
      );
    }).toList();

    // Convert PharmacyService to OrderService
    final orderServices = selectedPharmacyServices.map((pharmService) {
      return OrderService(
        service: pharmService.service,
        quantity: 1,
        price: pharmService.price,
      );
    }).toList();

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          stage: 'New order',
          selectedDrugs: drugs,
          deliveryAddress: '', // User will fill in checkout
          pharmacy: widget.pharmacy,
          selectedPharmacyDrugs: selectedPharmacyDrugs,
          selectedServices: orderServices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildPharmacyHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDrugsTab(), _buildServicesTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cartItemsCount > 0 ? _buildCartButton() : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  'Pharmacy Details',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Select drugs and services',
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pharmacy.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.pharmacy.address,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.text.withOpacity(0.6),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Drugs'),
          Tab(text: 'Services'),
        ],
      ),
    );
  }

  Widget _buildDrugsTab() {
    return Consumer<PharmacyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.pharmacyDrugs.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.pharmacyDrugs.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        if (provider.pharmacyDrugs.isEmpty) {
          return _buildEmptyState('No drugs available at this pharmacy');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: provider.pharmacyDrugs.length,
          itemBuilder: (context, index) {
            final pharmacyDrug = provider.pharmacyDrugs[index];
            final isSelected = _selectedDrugs.containsKey(pharmacyDrug.id);
            return _buildDrugCard(pharmacyDrug, isSelected);
          },
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return Consumer<PharmacyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.pharmacyServices.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.pharmacyServices.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        if (provider.pharmacyServices.isEmpty) {
          return _buildEmptyState('No services available at this pharmacy');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: provider.pharmacyServices.length,
          itemBuilder: (context, index) {
            final pharmacyService = provider.pharmacyServices[index];
            final isSelected = _selectedServices.containsKey(
              pharmacyService.id,
            );
            return _buildServiceCard(pharmacyService, isSelected);
          },
        );
      },
    );
  }

  Widget _buildDrugCard(PharmacyDrug pharmacyDrug, bool isSelected) {
    final drug = pharmacyDrug.drug;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.secondaryGreen
              : AppColors.text.withOpacity(0.08),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.secondaryGreen.withOpacity(0.2)
                : AppColors.text.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addDrugToCart(pharmacyDrug),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medication,
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
                        drug.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        drug.dosage,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          drug.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'UGX ${pharmacyDrug.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryGreen
                            : AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected
                            ? Colors.white
                            : AppColors.primaryBlue,
                        size: 20,
                      ),
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

  Widget _buildServiceCard(PharmacyService pharmacyService, bool isSelected) {
    final service = pharmacyService.service;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.secondaryGreen
              : AppColors.text.withOpacity(0.08),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.secondaryGreen.withOpacity(0.2)
                : AppColors.text.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addServiceToCart(pharmacyService),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getServiceIcon(service.category),
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'UGX ${pharmacyService.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryGreen
                            : AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected ? Colors.white : AppColors.accent,
                        size: 20,
                      ),
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

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'testing':
        return Icons.science;
      case 'counseling':
        return Icons.psychology;
      case 'health check':
        return Icons.health_and_safety;
      case 'immunization':
        return Icons.vaccines;
      case 'consultation':
        return Icons.medical_services;
      case 'delivery':
        return Icons.local_shipping;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.local_hospital;
    }
  }

  Widget _buildCartButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _proceedToCheckout,
        backgroundColor: AppColors.secondaryGreen,
        icon: const Icon(Icons.shopping_cart, size: 20),
        label: Text(
          'Checkout ($_cartItemsCount) - UGX ${_cartTotal.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.text.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppColors.text.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.text.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing Here',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.text.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
