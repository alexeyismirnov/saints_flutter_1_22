import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'dart:async';
import 'dart:io';

import 'globals.dart' as G;

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  final storeName = Platform.isIOS ? "AppStore" : "Google Play";
  bool isLoading, isAvailable;

  String price, currency;
  ProductDetails product;

  List<ProductDetails> products = [];

  @override
  void initState() {
    super.initState();

    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;

    _subscription = purchaseUpdates.listen((purchases) {
      PurchaseDetails p = purchases[0];
      if (p.status == PurchaseStatus.purchased) {
        InAppPurchaseConnection.instance.completePurchase(p);

        AlertDialog alert = AlertDialog(
          title: Text("Спасибо!"),
          content: Text("Благодарим за пожертвование!"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );

        showDialog(context: context, builder: (BuildContext context) => alert);
      }
    });

    isLoading = true;
    isAvailable = false;

    InAppPurchaseConnection.instance.isAvailable().then((isAvailable) {
      if (!isAvailable) throw ("not available");

      const Set<String> _kIds = {'saints1', 'saints2', 'saints3', 'saints4'};
      return InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    }).then((response) {
      print("reponse ${response}");

      if (response.notFoundIDs.isNotEmpty) throw ("not found");

      isAvailable = true;

      products = List<ProductDetails>.from(response.productDetails);
      products.sort((a, b) => a.id.compareTo(b.id));
    }).whenComplete(() {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Widget donationButton(ProductDetails product) => Center(
      child: SizedBox(
          width: 300.0,
          child: Card(
              elevation: 5.0,
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: GestureDetector(
                      onTap: () {},
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(product.description,
                                style: Theme.of(context).textTheme.bodyText2,
                                textAlign: TextAlign.center),
                            SizedBox(height: 20),
                            Text(product.price,
                                style: Theme.of(context).textTheme.headline6)
                          ]))))));

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(fontSize: G.fontSize.val());

    var message =
        'Мы издаем православную литературу на китайском языке, а также разрабатываем мобильные приложения.\n\n'
        'Мы хотели бы выпустить приложение "Жития святых" для китайских пользователей, '
        'но нам нужно собрать 5000 USD для оплаты работы переводчиков.\n\n'
        'Пожалуйста, поддержите наш проект, пожертвовав деньги с помощью кнопок на этой странице. '
        'О других способах поддержки можно узнать на сайте https://orthodoxy.hk\n\n'
        'Благодарим за участие!\n';

    Widget busyIndicator = Container();

    if (isLoading)
      busyIndicator = Center(child: CircularProgressIndicator());
    else if (!isAvailable)
      busyIndicator =
          Center(child: Text("Невозможно подключиться к ${storeName}"));

    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
              SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  title: Text(
                    "Приход свв. апп. Петра и Павла в Гонконге",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ))
            ],
        body: CustomScrollView(slivers: <Widget>[
          SliverPadding(
              padding: EdgeInsets.all(15),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                    height: 300.0,
                    padding: EdgeInsets.only(bottom: 10),
                    child: FittedBox(
                      child: Image.asset(
                        "images/church.jpg",
                      ),
                      fit: BoxFit.contain,
                    )),
                Text(message, style: style),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: busyIndicator),
                if (products.length > 0) ...[
                  donationButton(products[0]),
                  donationButton(products[1]),
                  donationButton(products[2]),
                  donationButton(products[3]),
                ]
              ])))
        ]));
  }
}
