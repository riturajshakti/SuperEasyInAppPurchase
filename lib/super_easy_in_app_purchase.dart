import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// A wrapper widget class around in_app_purchase to handle all the complex things of in app purchases
/// and allows users to focus on business logic rather than focusing on in app
/// purchase implementation logic
class SuperEasyInAppPurchase {
  final List<InAppPurchaseItem> inAppPurchaseItems;
  final Function? onProductsFetchError;

  SuperEasyInAppPurchase({
    required this.inAppPurchaseItems,
    this.onProductsFetchError,
  }) {
    _initialize();
  }

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// This will stop the IAP listeners, preventing memory leaks
  void stop() {
    _subscription.cancel();
  }

  /// Initialize in app purchase
  Future<void> _initialize() async {
    // Listen to new purchases
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      (purchaseDetailsList) => () async {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onError: onProductsFetchError,
    );
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      print('IAP not available !');
      return;
    }

    // Step 1: get all products from app store
    final Set<String> productIds =
        inAppPurchaseItems.map<String>((e) => e.productId).toSet();
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(productIds);
    _products = response.productDetails;

    // Step 2: recall products stream listener
    await InAppPurchase.instance.restorePurchases();

    // Step 3: check each products
    _verifyPurchase();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach(
      (PurchaseDetails purchaseDetails) async {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          // show pending UI
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          // handle purchase error
          await _removeProduct(purchaseDetails.productID);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.status != PurchaseStatus.pending &&
            purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      },
    );
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase() {
    for (var prod in _products) {
      PurchaseDetails? purchase = _hasPurchased(prod.id);

      // do your serverside verification & record consumable in the database

      if (purchase != null &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        // Deliver the product
        _deliverProduct(purchase);
      }
    }
  }

  /// Returns purchase of specific product ID
  PurchaseDetails? _hasPurchased(String productID) {
    try {
      return _purchases.firstWhere(
        (purchase) => purchase.productID == productID,
      );
    } catch (e) {
      return null;
    }
  }

  /// This will deliver the product
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    if (inAppPurchaseItems.any((e) => e.productId == purchase.productID)) {
      final item = inAppPurchaseItems
          .firstWhere((e) => e.productId == purchase.productID);
      await item.onPurchaseComplete();
      if (_purchases.every((p) => p.productID != purchase.productID)) {
        _purchases.add(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  /// This will remove the product only,
  /// it does not consume the product from appstore/playstore
  Future<void> _removeProduct(String id) async {
    for (var id in inAppPurchaseItems.map((e) => e.productId)) {
      if (inAppPurchaseItems.any((e) => e.productId == id)) {
        final item = inAppPurchaseItems.firstWhere((e) => e.productId == id);
        if (!item.isConsumable) return;
        await item.onPurchaseRefunded();
      }
    }
  }

  /// Purchase a product
  Future<void> _buyProduct(ProductDetails prod) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    InAppPurchaseItem item;
    if (inAppPurchaseItems.every((e) => e.productId != prod.id)) {
      print('Product Item not found !');
      return;
    }
    item = inAppPurchaseItems.firstWhere((e) => e.productId == prod.id);
    if (item.isConsumable) {
      await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else {
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Start a purchase.
  Future<void> startPurchase(String productID) async {
    for (var prod in _products) {
      final purchase = _hasPurchased(prod.id);
      if (purchase != null) {
        // Already purchased
        await _deliverProduct(purchase);
      } else if (prod.id == productID) {
        await _buyProduct(prod);
      }
    }
  }

  /// Use it carefully.
  ///
  /// This will remove the product from purchase list.
  ///
  /// i.e. It will consume/disable the product
  Future<void> removeProduct(String productID) async {
    await _removeProduct(productID);
  }
}

/// A model class for each in app purchase item.
class InAppPurchaseItem {
  /// This is the unique product id for in app purchase
  String productId;

  /// This checks if the product is consumable.
  ///
  /// A consumable is a product which can be disabled after certain use. e.g. Fuel of a vehicle, Gold coins, etc.
  bool isConsumable;

  /// This function will get executed when [productId] product is successfully purchased.
  ///
  /// It could also be an async function
  ///
  /// Its main task is to activate the product (like changing shared preference data)
  Function onPurchaseComplete;

  /// This will get executed when [productId] product is refunded.
  ///
  /// It could also be an async function
  ///
  /// Its main task is to deactivate the product.
  Function onPurchaseRefunded;

  InAppPurchaseItem({
    required this.productId,
    required this.onPurchaseComplete,
    required this.onPurchaseRefunded,
    this.isConsumable = false,
  });

  @override
  int get hashCode => productId.hashCode;

  @override
  bool operator ==(Object o) {
    return o is InAppPurchaseItem && o.productId == productId;
  }
}
