import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/models/admob.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime initialDaySelected;
  final Function changeDay;

  const CalendarWidget({Key? key, required this.initialDaySelected, required this.changeDay}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  InterstitialAd? _interstitialAd;
  final admob = AdMob();

  @override
  void initState() {
    super.initState();
    admob.createInterstitialAd();
    _focusedDay = widget.initialDaySelected;
  }

  @override
  void dispose() {
    _interstitialAd = admob.interstitialAd;
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return TableCalendar(
      firstDay: DateTime(2000,1,1),
      lastDay: DateTime(2100,1,1),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.horizontalSwipe,
      headerVisible: false,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        admob.showInterstitialAd();
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            widget.changeDay(_selectedDay);
          });
        }
      },
    );
  }
}
