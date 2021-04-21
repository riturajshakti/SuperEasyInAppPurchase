# super_easy_in_app_purchase

A flutter plugin for creating in app purchase in a super simple way.

In App Purchase(IAP) is a very complicated thing to implement in any mobile app for many years. Generally, it takes about 200 lines of code(in flutter) just to implement IAP. But I have tried my best to make it as simple as possible using this plugin.

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

### Step 2:

#### Android

Add the **INTERNET** permission in your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Step 3

Create in app product in your google play account and app store account. Follow the links for more detail steps:

[Creating In App Product in Google Play Store](support.google.com/googleplay/android-developer/answer/1153481)

[Creating In App Product in Apple App Store](https://help.apple.com/app-store-connect/#/devae49fb316)

### Step 4

In your `main()` function in `main.dart` file, import the package and add the static method- `start()`:

```dart
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';

void main() {
  SuperEasyInAppPurchase.start();
  runApp(MyApp());
}
```

### Step 5

Create a class level variable in your State class in the stateful widget

```dart
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';
...

class _MyAppState extends State<MyApp> {
  SuperEasyInAppPurchase inAppPurchase;
  ...
```

### Step 6

Initialise the variable in `initState()` method

This is the most important and difficult step to understand.

```dart
@override
void initState() {
  super.initState();
  inAppPurchase = SuperEasyInAppPurchase(
    // Any of these function will run when its corresponding product gets purchased successfully
    // For simplicity, I have just printed a message to console
    whenSuccessfullyPurchased: <String, Function>{
      'product1': () async => print('Product 1 purchased!'),
      'product2': () async => print('product 2 activated!'),
    },

    // Any of these function will run when its corresponding product gets refunded
    // For simplicity, I have just printed a message to console
    // This is completely an optional
    whenUpgradeDisabled: <String, Function>{
      'product1': () async => print('Product 1 refunded !'),
      'product2': () async => print('product 2 refunded !'),
    },
  );
}
```

`SuperEasyInAppPurchase()` constructor takes two parameters, first one is `whenSuccessfullyPurchased`, it takes a `Map<String, Function>` each pair in the map represents a Product ID (String) and its corresponding function which will executed after successfull purchase.

The second optional parameter `whenUpgradeDisabled` also takes `Map<String, Function>` but this time, these functions will get executed when your product is refunded. So these function's main task is to disable the corresponding product (if already purchased).

### Step 7

Start a purchase

Write this line of code in your button's onPressed listener:

```dart
await inAppPurchase.startPurchase('myProductID');
```

or if your product is consumable, then use:

```dart
await inAppPurchase.startPurchase('myProductID', isConsumable: true);
```

**Note:** Consumables are those products which needs to be purchased again and again, like - The fuel of racing car. By default, `isConsumable` parameter is set to `false`.

### Step 8 (Optional)

Consume(remove) the purchase

In order to remove the purchase, use:

```dart
await inAppPurchase.consumePurchase('myProductID');
```

When you consume a purchase, the user has to purchase it again in order to use its features.

## Issues

Don't hesitate to email any issues or feature at <riturajshakti@gmail.com>.

## Want to contribute

**Please support me via [Donation](https://paypal.me/riturajshakti).
Your donation seriously motivates me to develop more useful packages like this.**

## Author

This Permission plugin for Flutter is developed by [Rituraj Shakti](https://www.freelancer.com/u/riturajshakti). You can contact me at <riturajshakti@gmail.com>
