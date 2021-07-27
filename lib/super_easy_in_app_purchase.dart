import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:in_app_purchase/in_app_purchase.dart';

/// A wrapper widget class to handle all the complex things of in app purchases
/// and allows users to focus on business logic rather than focusing on in app
/// purchase implementation logic
class SuperEasyInAppPurchase {
  /// String refers to productID, Function refers to callback for successfull purchase.
  /// These functions will be called when a user successfully purchased its corresponding product.
  /// These functions usually contains SharedPreference modifications
  /// and can be async function.
  final Map<String, Function> whenSuccessfullyPurchased;

  /// String refers to productID, Function refers to callback for successfull refund.
  /// In these functions, you have to disable the pro products.
  /// These functions will be called when a user successfully refunded its corresponding product.
  /// These functions also usually contains SharedPreference modifications and can be async function.
  final Map<String, Function>? whenUpgradeDisabled;

  SuperEasyInAppPurchase({
    required this.whenSuccessfullyPurchased,
    this.whenUpgradeDisabled,
  }) {
    _initialize().then((_) {});
    // Future.delayed(
    //   Duration(seconds: 15),
    //   () async => await _checkAndRemoveAllProducts(),
    // );
  }

  /// Is the API available on the device
  bool _available = true;

  /// The In App Purchase plugin
  InAppPurchase _iap = InAppPurchase.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  /// Updates to purchases
  late StreamSubscription _subscription;

  /// This will stop the IAP listeners, preventing memory leaks
  void stop() {
    _subscription.cancel();
  }

  /// Initialize in app purchase
  Future<void> _initialize() async {
    // Check availability of In App Purchases
    _available = await _iap.isAvailable();

    if (_available) {
      await _getProducts();
      await _iap.restorePurchases();
      // Verify and deliver a purchase with your own business logic
      await _verifyPurchase();
    }

    // Listen to new purchases
    _subscription = _iap.purchaseStream.listen(
      (data) => () async {
        _purchases.addAll(data);
        await _verifyPurchase();
      },
    );
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    Set<String> ids = Set.from(whenSuccessfullyPurchased.keys);

    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  /// Returns purchase of specific product ID
  PurchaseDetails? _hasPurchased(String productID) {
    return _purchases.firstWhereOrNull(
      (purchase) => purchase.productID == productID,
    );
  }

  /// Your own business logic to setup a consumable
  Future<void> _verifyPurchase() async {
    for (var prod in _products) {
      PurchaseDetails? purchase = _hasPurchased(prod.id);

      // do your serverside verification & record consumable in the database

      if (purchase != null &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        // Deliver the product
        await _deliverProduct(prod.id, purchase);
      } else {
        // Remove the product
        await _removeProduct(prod.id);
      }
    }
  }

  /// This will remove the product only,
  /// it does not consume the product from appstore/playstore
  Future<void> _removeProduct(String id) async {
    if (whenUpgradeDisabled == null) return;
    for (final productID in whenUpgradeDisabled!.keys) {
      if (id == productID) {
        Function function = whenUpgradeDisabled![id]!;
        await function();
      }
    }
  }

  /// This will remove those products which are not purchased or refunded
  Future<void> _checkAndRemoveAllProducts() async {
    if (whenUpgradeDisabled == null) return;
    for (final productID in whenUpgradeDisabled!.keys) {
      if (_hasPurchased(productID) != null) {
        Function function = whenUpgradeDisabled![productID]!;
        await function();
      }
    }
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod, {bool isConsumable = false}) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    if (isConsumable)
      _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
    else
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// This will deliver the product
  Future<void> _deliverProduct(
      String productID, PurchaseDetails purchase) async {
    for (var id in whenSuccessfullyPurchased.keys) {
      if (id == productID) {
        Function function = whenSuccessfullyPurchased[id]!;
        await function();
        if (purchase.pendingCompletePurchase)
          await _iap.completePurchase(purchase);
      }
    }
  }

  /// Start a purchase.
  /// isConsumable parameter checks if the product can be disabled later.
  /// i.e. can be consumed later, using consumeProduct(id)
  Future<void> startPurchase(String productID,
      {bool isConsumable = false}) async {
    // await _checkAndRemoveAllProducts();
    for (var prod in _products) {
      final purchase = _hasPurchased(prod.id);
      if (purchase != null) {
        // Already purchased
        await _deliverProduct(prod.id, purchase);
      } else if (prod.id == productID) {
        _buyProduct(prod, isConsumable: isConsumable);
      }
    }
  }

  /// Use it carefully.
  /// This will remove the product from purchase list.
  /// i.e. It will consume/disable the product
  Future<void> consumePurchase(String productID) async {
    for (final id in whenUpgradeDisabled!.keys) {
      if (id == productID) {
        Function function = whenUpgradeDisabled![id]!;
        await function();
      }
    }
  }
}
