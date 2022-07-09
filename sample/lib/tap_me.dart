import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'counter_provider.dart';

class TapMe extends StatelessWidget {
  final Function plusOne;

  const TapMe({Key? key, required this.plusOne}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    CounterProvider counterProvider =
    Provider.of<CounterProvider>(context, listen: true);

    return SizedBox(
      width: 300,
      height: 100,
      child: InkWell(
        onTap: () => plusOne(counterProvider),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.lightBlueAccent.withOpacity(0.5),
          child: Center(
            child: Text(
              'Tap me to add 1',
              style: GoogleFonts.pacifico(),
            ),
          ),
        ),
      ),
    );
  }
}