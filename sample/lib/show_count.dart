import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class ShowCount extends StatelessWidget {
  final int count;

  const ShowCount({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      position: BadgePosition.topEnd(top: 0, end: 2),
      elevation: 0,
      shape: BadgeShape.circle,
      badgeColor: Colors.redAccent.shade100,
      badgeContent: Text('$count'),
      child: SizedBox(
        width: 300,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.lightGreenAccent.withOpacity(0.5),
          child: Center(
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}