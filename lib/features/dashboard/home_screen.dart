import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:care_shield/core/constants.dart';
import 'package:care_shield/core/widgets/product_card.dart';
import 'package:care_shield/features/meds/screens/med_order_screen.dart';
import 'package:care_shield/features/meds/screens/meds_screen.dart';
import 'package:care_shield/features/meds/models/drug.dart';
import 'package:care_shield/features/meds/providers/meds_provider.dart';
import 'package:care_shield/features/care/screens/care_screen.dart';
import '../survey/providers/survey_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(_onSearchChanged);
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Drug> _getFilteredDrugs(MedsProvider meds) {
    if (_searchQuery.isEmpty) {
      return meds.drugs;
    }

    return meds.drugs.where((drug) {
      final nameLower = drug.name.toLowerCase();
      final categoryLower = drug.category.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();

      return nameLower.contains(queryLower) ||
          categoryLower.contains(queryLower);
    }).toList();
  }

  void _showBookingForm(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BookingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meds = Provider.of<MedsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 28),
                _buildMedicationsSection(meds),
                const SizedBox(height: 20),
                _buildMedicationsGrid(meds),
                const SizedBox(height: 20),
                _buildViewMoreButton(),
                const SizedBox(height: 28),
                _buildCareSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
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
          child: Row(
            children: [
              Expanded(
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Good Day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hi Alex',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How is your health today?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.text.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (value) => _onSearchChanged(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Search for products...',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.text.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.clear,
                        color: AppColors.text.withOpacity(0.6),
                        size: 18,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _searchController.clear();
                      _searchFocus.unfocus();
                    },
                  )
                : null, // Remove the filter icon completely
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            hintStyle: TextStyle(
              color: AppColors.text.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not feeling okay today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.secondaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We\'re here to help',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get professional care and support when you need it most',
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showBookingForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: Icon(Icons.calendar_today, size: 20),
                    label: Text(
                      'Book a Care Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(MedsProvider meds) {
    final filteredDrugs = _getFilteredDrugs(meds);

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row with title and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Title and count
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isNotEmpty
                          ? '${filteredDrugs.length} results found'
                          : '${meds.drugs.length} products available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16), // Add spacing
              // Right side - Status and action button
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // In Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
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
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In Stock',
                            style: TextStyle(
                              color: AppColors.secondaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsGrid(MedsProvider meds) {
    final filteredDrugs = _getFilteredDrugs(meds);
    final displayDrugs = _searchQuery.isEmpty
        ? (filteredDrugs.length > 5
              ? filteredDrugs.take(5).toList()
              : filteredDrugs)
        : filteredDrugs; // Show all results when searching

    if (filteredDrugs.isEmpty) {
      return _buildNoResultsMessage();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          ...List.generate(displayDrugs.length, (index) {
            final drug = displayDrugs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildMedicationCard(drug, index),
            );
          }),
          // Show "View More" button only when not searching and there are more items
          if (_searchQuery.isEmpty && filteredDrugs.length > 5)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Text(
                'Showing 5 of ${filteredDrugs.length} products',
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off,
                color: AppColors.primaryBlue.withOpacity(0.6),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching with different keywords'
                    : 'No products available at the moment',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _searchController.clear();
                  _searchFocus.unfocus();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Clear Search',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Drug drug, int index) {
    return ProductCard(
      drug: drug,
      index: index,
      isCompact: false, // Changed from true to false to match meds screen
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

  Widget _buildViewMoreButton() {
    return Consumer<MedsProvider>(
      builder: (context, meds, child) {
        final filteredDrugs = _getFilteredDrugs(meds);

        // Don't show the button if we're searching or if there are no more items to show
        if (_searchQuery.isNotEmpty || filteredDrugs.length <= 5) {
          return const SizedBox.shrink();
        }

        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide.none,
              ),
              icon: Icon(
                Icons.visibility,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              label: Text(
                'View More Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuickSurveySheet extends StatefulWidget {
  const QuickSurveySheet({super.key});

  @override
  State<QuickSurveySheet> createState() => _QuickSurveySheetState();
}

class _QuickSurveySheetState extends State<QuickSurveySheet>
    with TickerProviderStateMixin {
  final _notes = TextEditingController();
  String _severity = 'Mild';
  List<String> _symptoms = [];
  final allSymptoms = ['Fever', 'Headache', 'Nausea', 'Fatigue', 'Other'];

  bool _submitting = false;
  String? _successMsg;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Text('Select at least one symptom'),
            ],
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _successMsg = null;
    });

    try {
      final surveyProv = Provider.of<SurveyProvider>(context, listen: false);
      await surveyProv.createTicket(
        symptoms: _symptoms,
        severity: _severity,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      setState(() {
        _successMsg = 'Survey submitted. Health worker will review it.';
      });

      // Show success haptic feedback
      HapticFeedback.mediumImpact();

      // Auto close after success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: AppColors.secondaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Check-in',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'How are you feeling today?',
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

              const SizedBox(height: 28),

              // Symptoms selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select symptoms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allSymptoms.map((s) {
                  final selected = _symptoms.contains(s);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (selected) {
                          _symptoms.remove(s);
                        } else {
                          _symptoms.add(s);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.secondaryGreen
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.secondaryGreen
                              : AppColors.text.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.secondaryGreen.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Severity dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.text.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _severity,
                  decoration: InputDecoration(
                    labelText: 'Severity level',
                    labelStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  items: ['Mild', 'Moderate', 'Severe']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _severity = v ?? 'Mild'),
                ),
              ),

              const SizedBox(height: 20),

              // Notes field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.text.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Additional notes (optional)',
                    hintText: 'Describe any additional details...',
                    labelStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Success message
              if (_successMsg != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.secondaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMsg!,
                          style: TextStyle(
                            color: AppColors.secondaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_successMsg != null) const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitting || _successMsg != null
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: AppColors.text.withOpacity(0.1),
                  ),
                  child: _submitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _successMsg != null ? 'Submitted ✓' : 'Submit Survey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
