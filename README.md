# super_easy_in_app_purchase

A flutter plugin for creating in app purchase in a super simple way.

In App Purchase(IAP) is a very complicated thing to implement in any mobile app for many years. Generally, it takes about 200 lines of code just to implement in app purchase. But I have tried my best to make it as simple as possible using this plugin.

Please support me via [Donation](https://paypal.me/riturajshakti). Your donation seriously motivates me to build many useful plugins like this.

## How to use

### Step 1:

First add this package in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  super_easy_in_app_purchase: any
```

Make sure to **GET** all the pub packages after saving this file.

### Step 2

Create in app product in your google play account and app store account. Follow the links for more detail steps:

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

Initialise the variable in `initState()` method

This is the most important and difficult step to understand.

```dart
@override
void initState() {
  super.initState();
  inAppPurchase = SuperEasyInAppPurchase(
    // Any of these function will run when its corresponding product gets purchased successfully
    // For simplicity, only a message is printed to console
    whenSuccessfullyPurchased: <String, Function>{
      'product1': () => print('Product 1 purchased!'),
      'product2': () async => print('product 2 activated!'),
      'product3': () {},
    },

    // Any of these function will run when its corresponding product gets refunded
    whenUpgradeDisabled: <String, Function>{
      'product1': () async => print('Product 1 refunded !'),
      'product2': () => print('product 2 deactivated !'),
    },
  );
}
```

`SuperEasyInAppPurchase()` constructor takes two parameters:

(i) `whenSuccessfullyPurchased`: It takes a `Map<String, Function>`. Each pair in this map represents a Product ID (String) and its corresponding function, which gets executed after successful purchase. These functions generally contains shared preferences data modifications.

(ii) `whenUpgradeDisabled`: This also takes `Map<String, Function>` but this time, these functions will get executed when the product is refunded. So these function's main task is to disable the corresponding product. This parameter is optional but recommended.

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

Write this line of code in your button's onPressed listener:

```dart
await inAppPurchase.startPurchase('product1');
```

or if your product is consumable, then use:

```dart
await inAppPurchase.startPurchase('product1', isConsumable: true);
```

**Note:** _Consumables_ are those products which needs to be purchased again and again, e.g. - The fuel of racing car. By default, `isConsumable` parameter is set to `false`.

### Step 7 (Optional)

Consume(disable) the purchase

In order to remove the purchase, use:

```dart
await inAppPurchase.consumePurchase('product1');
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

This Permission plugin for Flutter is developed by [Rituraj Shakti](https://www.freelancer.com/u/riturajshakti). You can contact me at <riturajshakti@gmail.com>
