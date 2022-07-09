import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoggedUser with ChangeNotifier {
  String? _id;
  String? _name;
  String? _email;
  String _membership = 'STANDARD';
  String? _purchasedToken;


  String? get id => _id;

  set id(String? value) {
    _id = value;
  }

  Future<void> upgradePremium() async {
    final auth = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    try {
      if(auth!=null) {
        await db
            .collection('users')
            .doc(auth.uid)
            .update({'membership': 'PREMIUM'});
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<String> fetchMemberShip() async {
    final auth = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    String memberShip = 'STANDARD';
    try {
      if(auth!=null) {
        final user = await db.collection('users').doc(auth.uid).get();
        if(user.data()!=null) {
          memberShip = user.data()!['membership'];
        }
      }
      return memberShip;
    } catch (error) {
      debugPrint(error.toString());
    }
    return memberShip;
  }

  Future<bool> setPurchaseToken(String val) async {
    final db = FirebaseFirestore.instance;
    try {
      await db.collection('users').doc(_id).update({'purchasedToken': val});
      return Future<bool>.value(true);
    } catch (error) {
      return Future<bool>.value(false);
    }
  }

  Future<void> setProfileInfo() async {
    try {
      final auth = FirebaseAuth.instance.currentUser;

      if(auth!=null) {
        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();
        _id = auth.uid;
        if(user.data()!= null) {
          _email = user.data()!['email'];
          _name = user.data()!['username'];
          _purchasedToken = user.data()!.containsKey('purchaseToken') ? user.data()!['purchaseToken'] : null;
          _membership = user.data()!['membership'];
        }
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  String? get name => _name;

  set name(String? value) {
    _name = value;
  }

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  String get membership => _membership;

  set membership(String value) {
    _membership = value;
    notifyListeners();
  }

  String? get purchasedToken => _purchasedToken;

  set purchasedToken(String? value) {
    _purchasedToken = value;
  }
}