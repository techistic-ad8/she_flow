import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_data.dart';

class CycleProvider extends ChangeNotifier {
  CycleData _cycleData = CycleData();
  List<PeriodEntry> _periodEntries = [];
  bool _isLoaded = false;

  CycleData get cycleData => _cycleData;
  List<PeriodEntry> get periodEntries => List.unmodifiable(_periodEntries);
  bool get isLoaded => _isLoaded;

  CycleProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final cycleJson = prefs.getString('cycleData');
    if (cycleJson != null) {
      _cycleData = CycleData.fromJsonString(cycleJson);
    }

    final entriesJson = prefs.getString('periodEntries');
    if (entriesJson != null) {
      final List<dynamic> list = jsonDecode(entriesJson);
      _periodEntries = list.map((e) => PeriodEntry.fromJson(e)).toList();
      _periodEntries.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateCycleData(CycleData data) async {
    _cycleData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cycleData', data.toJsonString());
    notifyListeners();
  }

  Future<void> logPeriod(PeriodEntry entry) async {
    // Remove existing entry for the same period if exists
    _periodEntries.removeWhere((e) => e.id == entry.id);
    _periodEntries.add(entry);
    _periodEntries.sort((a, b) => b.startDate.compareTo(a.startDate));
    await _saveEntries();
    notifyListeners();
  }

  Future<void> removePeriodEntry(String id) async {
    _periodEntries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(_periodEntries.map((e) => e.toJson()).toList());
    await prefs.setString('periodEntries', jsonString);
  }

  // ── Cycle Prediction Logic ──

  DateTime get nextPeriodDate {
    if (_periodEntries.isNotEmpty) {
      final lastEntry = _periodEntries.first;
      return lastEntry.startDate.add(Duration(days: _cycleData.cycleLength));
    }
    return _cycleData.lastPeriodDate
        .add(Duration(days: _cycleData.cycleLength));
  }

  int get daysUntilNextPeriod {
    final now = DateTime.now();
    final next = nextPeriodDate;
    final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get currentCycleDay {
    DateTime lastStart;
    if (_periodEntries.isNotEmpty) {
      lastStart = _periodEntries.first.startDate;
    } else {
      lastStart = _cycleData.lastPeriodDate;
    }
    final now = DateTime.now();
    final diff =
        DateTime(now.year, now.month, now.day).difference(lastStart).inDays + 1;
    if (diff < 1) return 1;
    if (diff > _cycleData.cycleLength) return diff % _cycleData.cycleLength;
    return diff;
  }

  CyclePhase get currentPhase {
    final day = currentCycleDay;
    if (day <= _cycleData.periodLength) return CyclePhase.menstrual;
    if (day <= (_cycleData.cycleLength * 0.46).round()) {
      return CyclePhase.follicular;
    }
    if (day <= (_cycleData.cycleLength * 0.5).round()) {
      return CyclePhase.ovulation;
    }
    return CyclePhase.luteal;
  }

  double get cycleProgress {
    return currentCycleDay / _cycleData.cycleLength;
  }

  DateTime get ovulationDate {
    DateTime lastStart;
    if (_periodEntries.isNotEmpty) {
      lastStart = _periodEntries.first.startDate;
    } else {
      lastStart = _cycleData.lastPeriodDate;
    }
    // Ovulation typically occurs 14 days before the next period
    return lastStart.add(Duration(days: _cycleData.cycleLength - 14));
  }

  DateTimeRange get fertileWindow {
    final ovDay = ovulationDate;
    return DateTimeRange(
      start: ovDay.subtract(const Duration(days: 3)),
      end: ovDay.add(const Duration(days: 1)),
    );
  }

  // Check if a specific date is a period day (logged)
  bool isPeriodDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (final entry in _periodEntries) {
      final start =
          DateTime(entry.startDate.year, entry.startDate.month, entry.startDate.day);
      final end = DateTime(entry.endDate.year, entry.endDate.month, entry.endDate.day);
      if (!d.isBefore(start) && !d.isAfter(end)) return true;
    }
    return false;
  }

  // Check if a date is a predicted period day
  bool isPredictedPeriodDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final nextStart = nextPeriodDate;
    final nextEnd =
        nextStart.add(Duration(days: _cycleData.periodLength - 1));
    final ns = DateTime(nextStart.year, nextStart.month, nextStart.day);
    final ne = DateTime(nextEnd.year, nextEnd.month, nextEnd.day);
    return !d.isBefore(ns) && !d.isAfter(ne);
  }

  // Check if a date is the ovulation day
  bool isOvulationDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final ov = ovulationDate;
    return d.year == ov.year && d.month == ov.month && d.day == ov.day;
  }

  // Check if a date is in the fertile window
  bool isFertileDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final window = fertileWindow;
    final ws = DateTime(window.start.year, window.start.month, window.start.day);
    final we = DateTime(window.end.year, window.end.month, window.end.day);
    return !d.isBefore(ws) && !d.isAfter(we);
  }

  // Get missed period dates (expected but not logged)
  List<DateTime> getMissedPeriods() {
    final missed = <DateTime>[];
    if (_periodEntries.isEmpty) return missed;

    final now = DateTime.now();
    DateTime expectedDate = _periodEntries.last.startDate;

    while (expectedDate.isBefore(now)) {
      expectedDate = expectedDate.add(Duration(days: _cycleData.cycleLength));
      if (expectedDate.isBefore(now)) {
        final isLogged = _periodEntries.any((entry) {
          final diff = entry.startDate.difference(expectedDate).inDays.abs();
          return diff <= 5; // within 5/days tolerance
        });
        if (!isLogged) {
          missed.add(expectedDate);
        }
      }
    }
    return missed;
  }
}
