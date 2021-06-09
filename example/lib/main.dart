import 'package:flutter/material.dart';
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';

void main() {
  SuperEasyInAppPurchase.start();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SuperEasyInAppPurchase inAppPurchase;

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
      // This is completely an optional, but recommended
      whenUpgradeDisabled: <String, Function>{
        'product1': () async => print('Product 1 refunded !'),
        'product2': () async => print('product 2 deactivated !'),
      },
    );
  }

  @override
  void dispose() {
    inAppPurchase.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Super Easy In App Purchase'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Activate product 1'),
              onPressed: () async {
                await inAppPurchase.startPurchase('product1');
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Activate product 2'),
              onPressed: () async {
                await inAppPurchase.startPurchase('product2', isConsumable: true);
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Deactivate product 2'),
              onPressed: () async {
                await inAppPurchase.consumePurchase('product2');
              },
            ),
          ],
        ),
      ),
    );
  }
}
