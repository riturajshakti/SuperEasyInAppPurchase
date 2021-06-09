import 'dart:async';
import 'dart:io';

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
  /// These functions will be called when a user successfully purchased its corresponding product.
  /// These functions also usually contains SharedPreference modifications
  /// and can be async function.
  /// Setting this is an optional choice, but is recommended
  final Map<String, Function>? whenUpgradeDisabled;

  SuperEasyInAppPurchase({
    required this.whenSuccessfullyPurchased,
    this.whenUpgradeDisabled,
  }) {
    _initialize().then((_) {});
    Future.delayed(
      Duration(seconds: 15),
      () async => await _checkAndRemoveAllProducts(),
    );
  }

  /// Is the API available on the device
  bool _available = true;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  /// Updates to purchases
  late StreamSubscription _subscription;

  /// This will initiate the IAP.
  /// Call this function only once in your entire app.
  /// i.e. inside the first line of main() function
  /// Otherwise, it will raise an Error
  static void start() {
    InAppPurchaseConnection.enablePendingPurchases();
  }

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
      await _getPastPurchases();
      // Verify and deliver a purchase with your own business logic
      await _verifyPurchase();
    }

    // Listen to new purchases
    _subscription = _iap.purchaseUpdatedStream.listen(
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

  /// Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchaseDetails in response.pastPurchases) {
      if (purchaseDetails.billingClientPurchase!.purchaseState == PurchaseStateWrapper.purchased) {
        // Activating the pro if product is purchased
        _deliverProduct(purchaseDetails.productID);
      }
      final pending = Platform.isIOS ? purchaseDetails.pendingCompletePurchase : !purchaseDetails.billingClientPurchase!.isAcknowledged;

      if (pending) {
        InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
      }
    }
    _purchases = response.pastPurchases;
  }

  /// Returns purchase of specific product ID
  PurchaseDetails? _hasPurchased(String productID) {
    return _purchases.firstWhereOrNull(
      (purchase) => purchase.productID == productID,
    );
  }

  /// Your own business logic to setup a consumable
  Future<void> _verifyPurchase() async {
    if (_products == null) return;
    for (var prod in _products) {
      PurchaseDetails? purchase = _hasPurchased(prod.id);

      // do your serverside verification & record consumable in the database

      if (purchase != null && purchase.status == PurchaseStatus.purchased) {
        // Deliver the product
        await _deliverProduct(prod.id);
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
    for (var productID in whenUpgradeDisabled!.keys) {
      if (id == productID) {
        Function function = whenUpgradeDisabled![id]!;
        await function();
      }
    }
  }

  /// This will remove those products which are not purchased or refunded
  Future<void> _checkAndRemoveAllProducts() async {
    if (whenUpgradeDisabled == null) return;
    for (var productID in whenUpgradeDisabled!.keys) {
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
      _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
    else
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// This will deliver the product
  Future<void> _deliverProduct(String productID) async {
    for (var id in whenSuccessfullyPurchased.keys) {
      if (id == productID) {
        Function function = whenSuccessfullyPurchased[id]!;
        await function();
      }
    }
  }

  /// Start a purchase.
  /// isConsumable parameter checks if the product can be disabled later.
  /// i.e. can be consumed later, using consumeProduct(id)
  Future<void> startPurchase(String productID, {bool isConsumable = false}) async {
    await _checkAndRemoveAllProducts();
    for (var prod in _products) {
      if (_hasPurchased(prod.id) != null) {
        // Already purchased
        await _deliverProduct(prod.id);
      } else if (prod.id == productID) {
        _buyProduct(prod, isConsumable: isConsumable);
      }
    }
  }

  /// Use it carefully.
  /// This will remove the product from purchase list.
  /// i.e. It will consume(disable) the product
  Future<void> consumePurchase(String productID) async {
    for (var id in whenUpgradeDisabled!.keys) {
      if (id == productID) {
        Function function = whenUpgradeDisabled![id]!;
        await function();
        await _iap.consumePurchase(
          _purchases.firstWhere((purchase) => purchase.productID == productID),
        );
      }
    }
  }
}
