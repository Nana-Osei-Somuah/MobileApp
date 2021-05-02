import 'package:athlete/Screens/product_page.dart';
import 'package:athlete/services/firebase_services.dart';
import 'package:athlete/widgets/custom_action_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:athlete/Screens/payment.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  FirebaseServices _firebaseServices = FirebaseServices();
  String productId;

  int totalPrice;

   @override
  initState() {
    super.initState();
    queryValues();
  }


  Future deleteFromCart(productId) {
    return _firebaseServices.usersRef
        .doc(_firebaseServices.getUserId())
        .collection("Cart")
        .doc(productId)
        .delete();
  }

    void queryValues() {
     _firebaseServices.usersRef
        .doc(_firebaseServices.getUserId())
        .collection("Cart")
        .snapshots()
        .listen((snapshot) {
      int tempTotal = snapshot.docs.fold(0, (tot, doc) => tot + doc.data()['price']);
      setState(() {totalPrice = tempTotal;});
      debugPrint(totalPrice.toString());
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: _firebaseServices.usersRef
                .doc(_firebaseServices.getUserId())
                .collection("Cart")
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              // Collection Data ready to display
              if (snapshot.connectionState == ConnectionState.done) {
                // Display the data inside a list view
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: 108.0,
                          bottom: 12.0,
                        ),
                        children: snapshot.data.docs.map((document) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      productId: document.id,
                                    ),
                                  ));
                            },
                            child: FutureBuilder(
                              future: _firebaseServices.productsRef
                                  .doc(document.id)
                                  .get(),
                              builder: (context, productSnap) {
                                if (productSnap.hasError) {
                                  return Container(
                                    child: Center(
                                      child: Text("${productSnap.error}"),
                                    ),
                                  );
                                }

                                if (productSnap.connectionState ==
                                    ConnectionState.done) {
                                  Map _productMap = productSnap.data.data();
                                  print(_productMap['price']);

                               
          
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 24.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              "${_productMap['images'][0]}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${_productMap['name']}",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                ),
                                                child: Text(
                                                  "GHS ${_productMap['price']}",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Text(
                                                "Size - ${document.data()['size']}",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              IconButton(
                                                  onPressed: () async {
                                                    await deleteFromCart(
                                                        document.id);
                                                  
                                                  },
                                                  icon: Icon(Icons.delete))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Price',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(totalPrice.toString()),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(25),
                      child: FlatButton(
                        child: Text(
                          'Confirm Checkout',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.greenAccent,
                        textColor: Colors.white,
                        onPressed: () {
                            Navigator.push(
                              context,
                                MaterialPageRoute(builder: (context) => CheckoutMethodCard(totalPrice)),
                            );},
                      ),
                    ),
                  ],
                );
              }

              // Loading State
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          CustomActionBar(
            hasBackArrrow: true,
            title: "Cart",
          ),
        ],
      ),
    );
  }
}
