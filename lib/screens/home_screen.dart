import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/practical_data.dart';
import '../models/practical_model.dart';
import '../services/progress_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/aipe_logo.dart';
import '../widgets/practical_card.dart';

/// HomeScreen implements Phase 2 of AIPE LAB.
/// Features a premium educational dashboard displaying 12 AIPE practicals,
/// instant search, category filters, and real-time progress tracking.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  late List<PracticalModel> _practicals;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'AI Tools',
    'NLP',
    'LLM',
    'Prompt Engineering',
    'AI Applications',
  ];

  void _loadPracticals() {
    final rawList = PracticalData.getPracticals();
    _practicals = rawList.map((p) {
      final isComp = ProgressStorageService.isPracticalCompletedSync(p.id);
      return p.copyWith(isCompleted: isComp);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _loadPracticals();
    ProgressStorageService.progressChangeNotifier.addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {
        _loadPracticals();
      });
    }
  }

  @override
  void dispose() {
    ProgressStorageService.progressChangeNotifier.removeListener(_onProgressChanged);
    _bgPulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Toggle completion state for a practical persistently
  Future<void> _toggleCompletion(int id) async {
    await ProgressStorageService.togglePracticalCompletion(id);
  }

  // Filtered practicals list getter
  List<PracticalModel> get _filteredPracticals {
    return _practicals.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.number.contains(_searchQuery) ||
          p.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.officialOutcome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // 1. Ambient Background Neural Glow
          AnimatedBuilder(
            animation: _bgPulseController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: AIBackgroundPainter(
                  animationValue: _bgPulseController.value,
                ),
              );
            },
          ),

          // 2. Main Scrollable Dashboard Layout
          SafeArea(
            child: Column(
              children: [
                // A. PREMIUM TOP APP BAR
                _buildAppBar(),

                // B. DASHBOARD BODY (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // WELCOME HEADER BANNER
                        _buildWelcomeHeader(),
                        const SizedBox(height: 20),

                        // PROGRESS CARD
                        _buildProgressCard(),
                        const SizedBox(height: 20),

                        // SEARCH BAR
                        _buildSearchBar(),
                        const SizedBox(height: 16),

                        // CATEGORY CHIPS
                        _buildCategoryChips(),
                        const SizedBox(height: 24),

                        // PRACTICALS SECTION TITLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PRACTICAL LAB EXPERIMENTS',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCyan,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${_filteredPracticals.length} of 12',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 12 PRACTICAL CARDS LIST
                        if (_filteredPracticals.isEmpty)
                          _buildEmptySearchState()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredPracticals.length,
                            itemBuilder: (context, index) {
                              final practical = _filteredPracticals[index];
                              return PracticalCard(
                                key: ValueKey(practical.id),
                                practical: practical,
                                onToggleComplete: () =>
                                    _toggleCompletion(practical.id),
                              );
                            },
                          ),

                        const SizedBox(height: 32),
                      ],
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

  // Top AppBar Widget
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Branding Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'AIPE LAB',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'DI05016011',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Artificial Intelligence with Prompt Engineering',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Official App Logo (replaces anonymous icon)
          const AipeLogo(
            size: 40,
            animateGlow: false,
          ),
        ],
      ),
    );
  }

  // Welcome Header Banner Widget
  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primaryCyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Welcome to AIPE Lab 👋',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.academicGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.academicGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'SEM 5 • IT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.academicGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"Learn • Experiment • Build"',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '12 Practical Experiments • DI05016011 • Diploma IT',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Progress Card Widget
  Widget _buildProgressCard() {
    return ValueListenableBuilder<int>(
      valueListenable: ProgressStorageService.progressChangeNotifier,
      builder: (context, val, child) {
        final int completed = ProgressStorageService.getCompletedCountSync();
        final double percent = ProgressStorageService.getProgressPercentageSync() / 100.0;

        String statusMsg = 'Start your first experiment';
        if (completed > 0 && completed < 12) {
          statusMsg = '$completed of 12 completed! Keep going!';
        } else if (completed == 12) {
          statusMsg = 'All 12 Practicals Completed! 🎉';
        }

        return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PRACTICAL PROGRESS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$completed / 12 Completed',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryCyan,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                completed == 12
                    ? Icons.emoji_events_rounded
                    : Icons.rocket_launch_rounded,
                size: 14,
                color: completed == 12
                    ? AppTheme.academicGold
                    : AppTheme.primaryCyan,
              ),
              const SizedBox(width: 6),
              Text(
                statusMsg,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
);
}

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search practicals by title or code...',
          hintStyle: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontSize: 13.5,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.primaryCyan,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // Category Filter Chips Widget
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
              selectedColor: AppTheme.primaryCyan,
              backgroundColor: const Color(0xFF0F172A),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryCyan
                    : Colors.white.withValues(alpha: 0.1),
              ),
              labelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // Empty Search Result Widget
  Widget _buildEmptySearchState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No Practicals Found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with a different keyword or select "All".',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
