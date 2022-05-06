import 'package:flutter/material.dart';
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SuperEasyInAppPurchase inAppPurchase;

  @override
  void initState() {
    super.initState();
    inAppPurchase = SuperEasyInAppPurchase(
      inAppPurchaseItems: [
        InAppPurchaseItem(
          productId: 'product1',
          onPurchaseComplete: () => print('Product 1 purchased successfully !'),
          onPurchaseRefunded: () => print('Product 1 disabled successfully !'),
        ),
        InAppPurchaseItem(
          productId: 'product2',
          onPurchaseComplete: () => print('Product 2 purchased successfully !'),
          onPurchaseRefunded: () => print('Product 2 disabled successfully !'),
          isConsumable: true,
        ),
      ],
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
                await inAppPurchase.startPurchase('product2');
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Deactivate product 2'),
              onPressed: () async {
                await inAppPurchase.removeProduct('product2');
              },
            ),
          ],
        ),
      ),
    );
  }
}
