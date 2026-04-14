import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';
import '../models/cycle_data.dart';

class CycleLogScreen extends StatelessWidget {
  const CycleLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, _) {
        final entries = cycleProvider.periodEntries;
        final missed = cycleProvider.getMissedPeriods();

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Cycle History',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                // Stats summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat(
                            '${entries.length}', 'Logged\nPeriods', AppColors.primary),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.primaryMedium.withValues(alpha: 0.3),
                        ),
                        _miniStat(
                            '${missed.length}', 'Missed\nPeriods', AppColors.coral),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.primaryMedium.withValues(alpha: 0.3),
                        ),
                        _miniStat(
                          '${cycleProvider.cycleData.cycleLength}d',
                          'Avg\nCycle',
                          AppColors.lavender,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Entries list
                Expanded(
                  child: entries.isEmpty && missed.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📋',
                                  style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'No periods logged yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Use the calendar to log your period',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Missed period alerts
                            if (missed.isNotEmpty) ...[
                              Text(
                                'Missed Periods',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.coral,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...missed.map((date) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.coral.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.coral
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.coral
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.warning_amber_rounded,
                                              color: AppColors.coral,
                                              size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Expected ~${DateFormat('MMM d, y').format(date)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.coral,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 16),
                            ],

                            // Logged periods
                            if (entries.isNotEmpty) ...[
                              Text(
                                'Logged Periods',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...entries.map((entry) => _PeriodEntryCard(
                                    entry: entry,
                                    onDelete: () {
                                      cycleProvider
                                          .removePeriodEntry(entry.id);
                                    },
                                  )),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class _PeriodEntryCard extends StatelessWidget {
  final PeriodEntry entry;
  final VoidCallback onDelete;

  const _PeriodEntryCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final flowLabels = ['Light Flow', 'Medium Flow', 'Heavy Flow'];
    final flowEmojis = ['💧', '💧💧', '💧💧💧'];

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMedium.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${entry.startDate.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(entry.startDate),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('MMM d').format(entry.startDate)} – ${DateFormat('MMM d').format(entry.endDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${entry.durationDays} days',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${flowEmojis[entry.flowLevel.index]} ${flowLabels[entry.flowLevel.index]}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  if (entry.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.notes,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primaryMedium, size: 20),
          ],
        ),
      ),
    );
  }
}
