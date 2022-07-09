import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/models/logged_user.dart';
import 'package:provider/provider.dart';

const String _kSubscriptionId = 'todo_monthly_subscription';
const List<String> _kProductIds = <String>[_kSubscriptionId];

class InAppPurchaseService with ChangeNotifier {
  final InAppPurchase _connection = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  LoggedUser? loggedUser;

  Stream<List<PurchaseDetails>> getPurchaseDetailsList(BuildContext context) {
    loggedUser = Provider.of<LoggedUser>(context, listen: false);

    Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList, loggedUser!);
      },
      onDone: () {
        _subscription!.cancel();
      },
      onError: (error) {
        // handle error here. //flashbar may be or retry
      },
    );
    initStoreInfo();
    return purchaseUpdated;
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      _isAvailable = isAvailable;
      _products = [];
      _purchases = [];
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      return;
    }
    _isAvailable = isAvailable;
    _products = productDetailResponse.productDetails;
  }

  void buyGroupMonthlySubscription(String userId) async {
    if (_isAvailable) {
      ProductDetails product =
          _products.firstWhere((element) => element.id == _kSubscriptionId);
      debugPrint('product : ${product.id}');
      var param =
          PurchaseParam(productDetails: product, applicationUserName: userId);
      var requestSent =
          await _connection.buyNonConsumable(purchaseParam: param);
      if (!requestSent) {
        debugPrint('please try again');
      } else {
        debugPrint('request sent');
      }
    } else {
      debugPrint(
          'something wrong happened, try again some time cannot connect to store');
    }
  }

  void showPendingUI() {
    debugPrint('purchase is pending');
  }

  void handleError(IAPError? error) {
    debugPrint('purchase has error');
  }

  Future<bool> deliverProduct(
      PurchaseDetails purchaseDetails, LoggedUser loggedUser) async {
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    debugPrint('product deliver here');
    if (purchaseDetails.productID == _kSubscriptionId &&
        loggedUser.membership == 'STANDARD') {
      await loggedUser.upgradePremium();
      var membership = await loggedUser.fetchMemberShip();
      if (membership != 'PREMIUM') {
        debugPrint('not delivered at our end sorry');
        return Future<bool>.value(false);
      } else {
        loggedUser.membership = membership;
        return Future<bool>.value(true);
      }
    } else {
      _purchases.add(purchaseDetails);
      return Future<bool>.value(false);
    }
  }

  Future<bool> _verifyPurchase(
      PurchaseDetails purchaseDetails, LoggedUser loggedUser) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.

    debugPrint('verifying purchase');
    debugPrint(
        'local verify : ${purchaseDetails.verificationData.localVerificationData}');
    debugPrint(
        'server verify : ${purchaseDetails.verificationData.serverVerificationData}');

    final Map<String, dynamic> localVerificationData =
        json.decode(purchaseDetails.verificationData.localVerificationData);
    if (localVerificationData.containsKey("obfuscatedAccountId")) {
      if (localVerificationData['obfuscatedAccountId'].toString() ==
          loggedUser.id) return Future<bool>.value(true);
    }

    return Future<bool>.value(false);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList, LoggedUser loggedUser) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails, loggedUser);
          if (valid) {
            if (await loggedUser.setPurchaseToken(
                    purchaseDetails.verificationData.serverVerificationData) &&
                await deliverProduct(purchaseDetails, loggedUser)) {
              if (purchaseDetails.pendingCompletePurchase) {
                await InAppPurchase.instance.completePurchase(purchaseDetails);
              }
            }
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
      }
    });
  }
}
