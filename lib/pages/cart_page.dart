// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;
  double totalPrice = 0.0; // Variable to store the total price of activities.

  Future<List<Map<String, dynamic>>> getUserCart() async {
    if (user == null) {
      return [];
    }
    var cartData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    List<dynamic> cartItems = cartData.data()?['cart'] ?? [];
    List<Map<String, dynamic>> activities = [];
    totalPrice = 0.0; // Reset the total price

    for (var itemId in cartItems) {
      var activityData = await FirebaseFirestore.instance
          .collection('activities')
          .doc(itemId)
          .get();
      var data = activityData.data() as Map<String, dynamic>;
      data['id'] = itemId; // Add the ID to the data map
      activities.add(data);
      totalPrice += data['price']; // Add the activity's price to the total
    }

    return activities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUserCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your cart is empty'));
          }
          List<Map<String, dynamic>> activities = snapshot.data!;
          return Stack(
            children: [
              Positioned.fill(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    var activity = activities[index];
                    String imageUrl = activity['image'];

                    return InkWell(
                      onTap: () {},
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: EdgeInsets.all(15.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image);
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity['title'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        activity['place'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '\€${activity['price']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Remove from cart',
                                onPressed: () async {
                                  var activityIdToRemove = activity[
                                      'id']; // Get the ID from the activity data

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user!.uid)
                                      .update({
                                    'cart': FieldValue.arrayRemove(
                                        [activityIdToRemove])
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Activity deleted from your cart")),
                                  );

                                  setState(() {
                                    activities.removeAt(index);
                                    totalPrice -= activity[
                                        'price']; // Subtract the activity's price from the total
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.05,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 2.0,
                      color: Colors.deepPurple,
                    ),
                    Container(
                      color: Colors.deepPurple[50],
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_checkout,
                              color: Colors.deepPurple),
                          Text(
                            ' Total: \€${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
