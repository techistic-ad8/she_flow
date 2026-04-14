import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../models/cycle_data.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 10;

  // Answers
  int _age = 25;
  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  bool _hasMissedPeriods = false;
  int _missedMonths = 0;
  String _activityLevel = 'moderate';
  String _waterIntake = '6-8';
  int _stressLevel = 2;
  double _sleepHours = 7;
  final List<String> _medicalConditions = [];
  bool _onMedication = false;
  final TextEditingController _medicationController = TextEditingController();

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final auth = context.read<AuthProvider>();
    final cycleProvider = context.read<CycleProvider>();

    // Update user profile with questionnaire answers
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final updatedProfile = currentUser.copyWith(
        age: _age,
        activityLevel: _activityLevel,
        waterIntake: _waterIntake,
        stressLevel: _stressLevel,
        sleepHours: _sleepHours,
        medicalConditions: _medicalConditions,
        onMedication: _onMedication,
        medicationDetails: _medicationController.text,
      );
      await auth.updateProfile(updatedProfile);
    }

    // Save cycle data
    await cycleProvider.updateCycleData(CycleData(
      cycleLength: _cycleLength,
      periodLength: _periodLength,
      lastPeriodDate: _lastPeriodDate,
      missedMonths: _missedMonths,
    ));

    // Log initial period entry
    await cycleProvider.logPeriod(PeriodEntry(
      startDate: _lastPeriodDate,
      endDate: _lastPeriodDate.add(Duration(days: _periodLength - 1)),
    ));

    await auth.completeQuestionnaire();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _medicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            onPressed: _prevPage,
                            icon: const Icon(Icons.arrow_back_ios,
                                color: AppColors.primary, size: 20),
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            'Tell Us About You',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentPage + 1} of $_totalPages',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  children: [
                    _buildAgePage(),
                    _buildCycleLengthPage(),
                    _buildPeriodLengthPage(),
                    _buildLastPeriodPage(),
                    _buildMissedPeriodsPage(),
                    _buildActivityPage(),
                    _buildWaterPage(),
                    _buildStressPage(),
                    _buildSleepPage(),
                    _buildMedicalPage(),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.primaryMedium.withValues(alpha: 0.3),
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _currentPage == _totalPages - 1
                        ? _finish
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1
                          ? 'Start Tracking 🌸'
                          : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  // ── Page Builders ──

  Widget _questionCard({
    required String emoji,
    required String question,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(emoji, style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          Text(
            question,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return _questionCard(
      emoji: '🎂',
      question: 'How old are you?',
      subtitle: 'This helps us personalize your experience',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              '$_age',
              style: GoogleFonts.poppins(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 60,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryMedium.withValues(alpha: 0.3),
            label: '$_age years',
            onChanged: (val) => setState(() => _age = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLengthPage() {
    return _questionCard(
      emoji: '🔄',
      question: 'How long is your cycle?',
      subtitle: 'Average is 28 days (from period to next period)',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_cycleLength',
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'days',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _cycleLength.toDouble(),
            min: 21,
            max: 45,
            divisions: 24,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryMedium.withValues(alpha: 0.3),
            label: '$_cycleLength days',
            onChanged: (val) => setState(() => _cycleLength = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodLengthPage() {
    return _questionCard(
      emoji: '🩸',
      question: 'How long does your period last?',
      subtitle: 'Average is 4-6 days',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_periodLength',
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'days',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _periodLength.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryMedium.withValues(alpha: 0.3),
            label: '$_periodLength days',
            onChanged: (val) => setState(() => _periodLength = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPeriodPage() {
    return _questionCard(
      emoji: '📅',
      question: 'When did your last period start?',
      subtitle: 'Select the start date of your most recent period',
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate,
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _lastPeriodDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMedium.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to change date',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedPeriodsPage() {
    return _questionCard(
      emoji: '❓',
      question: 'Have you missed any periods recently?',
      subtitle: 'This helps us detect irregularities',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleChip('No', !_hasMissedPeriods,
                  () => setState(() => _hasMissedPeriods = false)),
              const SizedBox(width: 16),
              _toggleChip('Yes', _hasMissedPeriods,
                  () => setState(() => _hasMissedPeriods = true)),
            ],
          ),
          if (_hasMissedPeriods) ...[
            const SizedBox(height: 32),
            Text(
              'How many months?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _missedMonths > 1
                      ? () => setState(() => _missedMonths--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                  iconSize: 36,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$_missedMonths',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _missedMonths++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  iconSize: 36,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    final activities = [
      {'key': 'sedentary', 'label': 'Sedentary', 'icon': '🛋️'},
      {'key': 'light', 'label': 'Light', 'icon': '🚶‍♀️'},
      {'key': 'moderate', 'label': 'Moderate', 'icon': '🏃‍♀️'},
      {'key': 'active', 'label': 'Active', 'icon': '💪'},
      {'key': 'veryActive', 'label': 'Very Active', 'icon': '🏋️‍♀️'},
    ];

    return _questionCard(
      emoji: '🏃‍♀️',
      question: 'Physical activity level?',
      subtitle: 'Exercise affects your cycle regularity',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final a = activities[index];
          final isSelected = _activityLevel == a['key'];
          return GestureDetector(
            onTap: () => setState(() => _activityLevel = a['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.primaryMedium.withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(a['icon']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Text(
                    a['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterPage() {
    final options = [
      {'key': '<4', 'label': 'Less than 4 glasses', 'icon': '💧'},
      {'key': '4-6', 'label': '4-6 glasses', 'icon': '💧💧'},
      {'key': '6-8', 'label': '6-8 glasses', 'icon': '💧💧💧'},
      {'key': '8+', 'label': '8+ glasses', 'icon': '💧💧💧💧'},
    ];

    return _questionCard(
      emoji: '💧',
      question: 'Daily water intake?',
      subtitle: 'Hydration plays a key role in cycle health',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final o = options[index];
          final isSelected = _waterIntake == o['key'];
          return GestureDetector(
            onTap: () => setState(() => _waterIntake = o['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primaryMedium.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(o['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 16),
                  Text(
                    o['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressPage() {
    final emojis = ['😌', '🙂', '😐', '😟', '😰'];
    final labels = ['Very Low', 'Low', 'Moderate', 'High', 'Very High'];

    return _questionCard(
      emoji: '🧘‍♀️',
      question: 'How stressed are you?',
      subtitle: 'Stress significantly impacts your cycle',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = _stressLevel == index + 1;
              return GestureDetector(
                onTap: () => setState(() => _stressLevel = index + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(emojis[index],
                          style: TextStyle(
                              fontSize: isSelected ? 40 : 32)),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepPage() {
    return _questionCard(
      emoji: '😴',
      question: 'Hours of sleep per night?',
      subtitle: 'Sleep quality affects hormonal balance',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sleepHours.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'hrs',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _sleepHours,
            min: 3,
            max: 12,
            divisions: 18,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryMedium.withValues(alpha: 0.3),
            label: '${_sleepHours.toStringAsFixed(1)} hours',
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalPage() {
    final conditions = [
      'PCOS',
      'Endometriosis',
      'Thyroid Issues',
      'Anemia',
      'Diabetes',
      'None',
    ];

    return _questionCard(
      emoji: '🏥',
      question: 'Any medical conditions?',
      subtitle: 'Select all that apply',
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: conditions.map((c) {
              final isSelected = c == 'None'
                  ? _medicalConditions.isEmpty
                  : _medicalConditions.contains(c);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (c == 'None') {
                      _medicalConditions.clear();
                    } else {
                      if (_medicalConditions.contains(c)) {
                        _medicalConditions.remove(c);
                      } else {
                        _medicalConditions.add(c);
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryMedium.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    c,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Medication toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'On hormonal medication? ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              Switch(
                value: _onMedication,
                onChanged: (val) => setState(() => _onMedication = val),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (_onMedication) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _medicationController,
              decoration: InputDecoration(
                hintText: 'Enter medication details...',
                prefixIcon: const Icon(Icons.medical_services_outlined,
                    color: AppColors.primaryMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primaryMedium,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
