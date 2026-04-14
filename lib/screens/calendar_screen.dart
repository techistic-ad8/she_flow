import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';
import '../models/cycle_data.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          'Calendar',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        // Legend button
                        IconButton(
                          onPressed: () => _showLegend(context),
                          icon: const Icon(Icons.info_outline,
                              color: AppColors.primaryMedium),
                        ),
                      ],
                    ),
                  ),

                  // Calendar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMedium.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showDayDetails(context, selectedDay, cycleProvider);
                      },
                      onFormatChanged: (format) {
                        setState(() => _calendarFormat = format);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        // Today
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryMedium.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        // Selected
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        // Default
                        defaultTextStyle: GoogleFonts.poppins(
                          color: AppColors.textDark,
                        ),
                        weekendTextStyle: GoogleFonts.poppins(
                          color: AppColors.textMedium,
                        ),
                        outsideTextStyle: GoogleFonts.poppins(
                          color: AppColors.textLight.withValues(alpha: 0.5),
                        ),
                        markersMaxCount: 3,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        titleTextStyle: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        formatButtonTextStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryMedium),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leftChevronIcon: const Icon(
                            Icons.chevron_left, color: AppColors.primary),
                        rightChevronIcon: const Icon(
                            Icons.chevron_right, color: AppColors.primary),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                        weekendStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final isPeriod = cycleProvider.isPeriodDay(date);
                          final isPredicted =
                              cycleProvider.isPredictedPeriodDay(date);
                          final isOvulation =
                              cycleProvider.isOvulationDay(date);
                          final isFertile = cycleProvider.isFertileDay(date);

                          List<Widget> markers = [];

                          if (isPeriod) {
                            markers.add(_buildMarkerDot(AppColors.primary));
                          }
                          if (isPredicted && !isPeriod) {
                            markers
                                .add(_buildMarkerDot(AppColors.primaryMedium));
                          }
                          if (isOvulation) {
                            markers.add(_buildMarkerDot(AppColors.lavender));
                          }
                          if (isFertile && !isOvulation) {
                            markers.add(_buildMarkerDot(
                                AppColors.lavender.withValues(alpha: 0.5)));
                          }

                          if (markers.isEmpty) return const SizedBox.shrink();

                          return Positioned(
                            bottom: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: markers,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _legendItem(AppColors.primary, 'Period'),
                        _legendItem(AppColors.primaryMedium, 'Predicted'),
                        _legendItem(AppColors.lavender, 'Ovulation'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick log button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showLogPeriodSheet(
                              context, cycleProvider, DateTime.now()),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Log Period Today',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarkerDot(Color color) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Calendar Legend',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendRow(AppColors.primary, '🩸 Period Days',
                'Logged period dates'),
            const SizedBox(height: 12),
            _legendRow(AppColors.primaryMedium, '🔮 Predicted',
                'Predicted period dates'),
            const SizedBox(height: 12),
            _legendRow(
                AppColors.lavender, '🥚 Ovulation', 'Estimated ovulation day'),
            const SizedBox(height: 12),
            _legendRow(AppColors.lavender.withValues(alpha: 0.5), '✨ Fertile',
                'Fertile window'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!',
                style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDayDetails(
      BuildContext context, DateTime day, CycleProvider provider) {
    final isPeriod = provider.isPeriodDay(day);
    final isPredicted = provider.isPredictedPeriodDay(day);
    final isOvulation = provider.isOvulationDay(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryMedium.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('EEEE, MMMM d, y').format(day),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (isPeriod)
              _statusChip('🩸 Period Day', AppColors.primary),
            if (isPredicted && !isPeriod)
              _statusChip('🔮 Predicted Period', AppColors.primaryMedium),
            if (isOvulation)
              _statusChip('🥚 Ovulation Day', AppColors.lavender),
            if (!isPeriod && !isPredicted && !isOvulation)
              _statusChip('📅 Regular Day', AppColors.textLight),
            const SizedBox(height: 16),
            if (!isPeriod)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogPeriodSheet(context, provider, day);
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Log Period',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showLogPeriodSheet(
      BuildContext context, CycleProvider provider, DateTime startDate) {
    int periodDays = provider.cycleData.periodLength;
    FlowLevel flowLevel = FlowLevel.medium;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMedium.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Log Period',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Starting: ${DateFormat('MMM d, y').format(startDate)}',
                  style: GoogleFonts.poppins(color: AppColors.textMedium),
                ),
                const SizedBox(height: 20),

                // Duration
                Text('Duration',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: periodDays > 1
                          ? () => setSheetState(() => periodDays--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.primary),
                    ),
                    Text('$periodDays days',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(
                      onPressed: () => setSheetState(() => periodDays++),
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Flow level
                Text('Flow Level',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: FlowLevel.values.map((level) {
                    final isSelected = flowLevel == level;
                    final labels = ['Light', 'Medium', 'Heavy'];
                    final icons = ['💧', '💧💧', '💧💧💧'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setSheetState(() => flowLevel = level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(icons[level.index]),
                              const SizedBox(height: 4),
                              Text(
                                labels[level.index],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Notes
                Text('Notes (optional)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Any symptoms, moods...',
                    hintStyle:
                        GoogleFonts.poppins(color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final entry = PeriodEntry(
                        startDate: startDate,
                        endDate: startDate
                            .add(Duration(days: periodDays - 1)),
                        flowLevel: flowLevel,
                        notes: notesController.text,
                      );
                      provider.logPeriod(entry);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Period logged! 🌸',
                              style: GoogleFonts.poppins()),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Save',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
