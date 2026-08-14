import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/material_data.dart';
import '../models/material_model.dart';
import '../services/progress_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/resource_card.dart';
import '../widgets/unit_card.dart';

/// MaterialScreen implements Phase 3 of AIPE LAB.
/// Displays official GTU 5-unit syllabus structure, subtopics, learning notes,
/// and reference textbooks & online resources.
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  late List<UnitModel> _units;
  late List<ResourceModel> _resources;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Units',
    'Topics',
    'Books',
    'Online Resources',
  ];

  void _loadUnits() {
    final rawUnits = MaterialData.getUnits();
    _units = rawUnits.map((u) {
      final isComp = ProgressStorageService.isUnitCompletedSync(u.id);
      return u.copyWith(isCompleted: isComp);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _loadUnits();
    _resources = MaterialData.getResources();
    ProgressStorageService.progressChangeNotifier.addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {
        _loadUnits();
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

  Future<void> _toggleUnitCompletion(int unitId) async {
    await ProgressStorageService.toggleUnitCompletion(unitId);
  }

  List<UnitModel> get _filteredUnits {
    if (_selectedCategory == 'Books' ||
        _selectedCategory == 'Online Resources') {
      return [];
    }
    return _units.where((unit) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          unit.number.contains(query) ||
          unit.title.toLowerCase().contains(query) ||
          unit.shortDescription.toLowerCase().contains(query) ||
          unit.topics.any(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                t.subtopics.any((sub) => sub.toLowerCase().contains(query)),
          );

      return matchesSearch;
    }).toList();
  }

  List<ResourceModel> get _filteredResources {
    if (_selectedCategory == 'Units' || _selectedCategory == 'Topics') {
      return [];
    }
    return _resources.where((res) {
      final query = _searchQuery.toLowerCase();
      final matchesCategory = _selectedCategory == 'All' ||
          (_selectedCategory == 'Books' && res.type == ResourceType.book) ||
          (_selectedCategory == 'Online Resources' &&
              res.type == ResourceType.onlineResource);

      final matchesSearch = _searchQuery.isEmpty ||
          res.title.toLowerCase().contains(query) ||
          res.authorOrOrg.toLowerCase().contains(query) ||
          res.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _completedUnitCount => _units.where((u) => u.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // 1. Ambient Background Glow
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

          // 2. Main Content Scroll
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // TOP APP BAR & HERO HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'AIPE MATERIAL',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryCyan
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.primaryCyan,
                                        ),
                                      ),
                                      child: Text(
                                        'SYLLABUS',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryCyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Artificial Intelligence with Prompt Engineering',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryCyan,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.academicGold
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppTheme.academicGold,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Study Hero Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Study smarter with AIPE 📖',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"Explore concepts, prompting techniques, LLMs and AI application development."',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.secondaryTeal,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Course Stats (Sourced from Syllabus)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem('5 Units', 'GTU Syllabus'),
                                  _buildStatItem('45 Hours', 'Course Duration'),
                                  _buildStatItem(
                                      '100%', 'Coverage'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // UNIT STUDY PROGRESS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'UNIT STUDY PROGRESS',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '$_completedUnitCount / 5 Units Completed',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.academicGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _completedUnitCount / 5,
                                    backgroundColor: Colors.white10,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppTheme.academicGold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // SEARCH BAR
                        TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search topics, units or resources...',
                            hintStyle: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppTheme.primaryCyan,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: AppTheme.textMuted,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.surfaceCard,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // FILTER CHIPS
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _categories.map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSelected,
                                  label: Text(category),
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.black
                                        : AppTheme.textSecondary,
                                  ),
                                  selectedColor: AppTheme.primaryCyan,
                                  backgroundColor: AppTheme.surfaceCard,
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.primaryCyan
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SYLLABUS UNITS LIST
                if (_filteredUnits.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        'COURSE SYLLABUS UNITS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final unit = _filteredUnits[index];
                          return UnitCard(
                            key: ValueKey(unit.id),
                            unit: unit,
                            onToggleComplete: () =>
                                _toggleUnitCompletion(unit.id),
                          );
                        },
                        childCount: _filteredUnits.length,
                      ),
                    ),
                  ),
                ],

                // LEARNING RESOURCES LIST
                if (_filteredResources.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        'LEARNING RESOURCES & TEXTBOOKS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.academicGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final resource = _filteredResources[index];
                          return ResourceCard(
                            key: ValueKey(resource.id),
                            resource: resource,
                          );
                        },
                        childCount: _filteredResources.length,
                      ),
                    ),
                  ),
                ],

                // EMPTY RESULTS STATE
                if (_filteredUnits.isEmpty && _filteredResources.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No study material found',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching with a different keyword or category filter',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryCyan,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
