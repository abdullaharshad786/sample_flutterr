import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/in_app_purchase.dart';
import '/models/logged_user.dart';
import 'package:provider/provider.dart';

class BuyPremium extends StatelessWidget {
  const BuyPremium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<LoggedUser>(context);
    final iap = Provider.of<InAppPurchaseService>(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          height: 200.h,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Buy Premium',
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
              ),
              SizedBox(height: 18.h),
              const Text(
                'Create unlimited todos in a single day.',
                style:
                TextStyle(color: Colors.green),
              ),
              SizedBox(height: 12.h),
              TextButton(
                child: const Text(
                  'Purchase',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  iap.buyGroupMonthlySubscription(loggedUser.id!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}