# super_easy_in_app_purchase

A flutter plugin for creating in app purchase in a super simple way.

Currently it doesn't supports subscription.

In App Purchase(IAP) is a very complicated thing to implement in any mobile app for many years. Generally, it takes 200+ lines of code just to implement in app purchase. But I have tried my best to make it as simple as possible using this plugin.

Please support me via [Donation](https://paypal.me/riturajshakti). Your donation seriously helps me to regularly update this plugin and do bug fixes fast.

## How to use

### Step 1:

First add this package in your `pubspec.yaml` file using the following command in your terminal:

```sh
flutter pub add super_easy_in_app_purchase
```

Make sure you are in the root of the flutter project directory inside terminal at the time of running this command.

### Step 2

Create in app product in your Google Play Store and Apple App Store account. Follow the links for more detail steps:

[Creating In App Product in Google Play Store](https://support.google.com/googleplay/android-developer/answer/1153481)

[Creating In App Product in Apple App Store](https://help.apple.com/app-store-connect/#/devae49fb316)

### Step 3

Create a class level variable (e.g. `inAppPurchase`) in your State class in stateful widget

```dart
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';
...

class _MyAppState extends State<MyApp> {
  SuperEasyInAppPurchase inAppPurchase;
  ...
```

### Step 4

Initialise that variable in `initState()` method

This is the most important and difficult step to understand.

```dart
@override
void initState() {
  super.initState();
  inAppPurchase = SuperEasyInAppPurchase(
      inAppPurchaseItems: [
        InAppPurchaseItem(
          // This must be unique accross entire play/app store
          productId: 'product1',
          // This function will run when 'product1' is purchased successfully
          // For simplicity, only a message is printed to console
          // In real app, you should use shared preference to store related data
          onPurchaseComplete: () => print('Product 1 purchased successfully !'),
          // This function will run when 'product1' is refunded by google or removed intentionally by you using inAppPurchase.removeProduct('product1')
          // These functions can also be an async
          // In real app, you should use shared preference to store related data
          onPurchaseRefunded: () => print('Product 1 disabled successfully !'),
        ),
        InAppPurchaseItem(
          productId: 'product2',
          onPurchaseComplete: () => print('Product 2 purchased successfully !'),
          onPurchaseRefunded: () => print('Product 2 disabled successfully !'),
          // Setting this to true means you can later disable this product using inAppPurchase.removeProduct('product2')
          isConsumable: true,
        ),
      ],
    );
}
```

`SuperEasyInAppPurchase()` constructor required a single named parameter `inAppPurchaseItems` which is of type `List<InAppPurchaseItem>`. Each `InAppPurchaseItem` takes 3 required parameters and 1 optional parameter.

* `String productId`: It identifies the digital product. This id must be unique accross entire play/app store.
* `Function onPurchaseComplete`: This function will run when its corresponding product is purchased successfully. The main purpose of this function is to activate the product (Generally using _Shared Preferences_).
* `Function onPurchaseRefunded`: This function will run when its corresponding product is refunded/disabled intentionally by the developer. The main purpose of this function is to deactivate the product (Generally using _shared preferences_).
* `bool isConsumable = false`: (Optional) Determines if the product is One-Time or Consumable. Setting this to true means you can later disable this product using `inAppPurchase.removeProduct(productId)`.

**Note:** _Consumables_ are those products which needs to be purchased again and again, e.g. - The fuel of racing car. By default, `isConsumable` parameter is set to `false`.

### Step 5

Prevent memory leaks by calling `stop()` method in your App State's `dispose()` method:

```dart
@override
void dispose() {
  inAppPurchase.stop();
  super.dispose();
}
```

### Step 6

Start a purchase

Write this line of code in your button's onPressed function:

```dart
await inAppPurchase.startPurchase('product1');
```

### Step 7 (Optional)

Consume(disable) the purchase

In order to remove the purchase, use:

```dart
await inAppPurchase.removeProduct('product2');
```

When you consume a purchase, the user has to purchase it again in order to use its features.

## Other useful packages

- [super_easy_permissions](https://pub.dev/packages/super_easy_permissions)

## References

- [API docs of this package](https://pub.dev/documentation/super_easy_in_app_purchase/latest/super_easy_in_app_purchase/SuperEasyInAppPurchase-class.html)
- [Complete example on github](https://github.com/riturajshakti/SuperEasyInAppPurchase/tree/main/example)
- [Flutter official in app purchase codelab](https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases)

## Issues

Don't hesitate to email any issues or feature at <riturajshakti@gmail.com>.

## Want to contribute

**Please support me via [Donation](https://paypal.me/riturajshakti).
Your donation seriously motivates me to develop more useful packages like this.**

## Author

This flutter plugin is developed by [Rituraj Shakti](https://www.freelancer.com/u/riturajshakti). You can contact me at <riturajshakti@gmail.com>
