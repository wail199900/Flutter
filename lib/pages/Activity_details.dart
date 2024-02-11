// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ActivityDetailsPage extends StatelessWidget {
  final String documentId;

  ActivityDetailsPage({required this.documentId});

  Future<void> addToCart(BuildContext context, String activityId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in");
      return;
    }

    String userId = currentUser.uid; // Get current user's UID
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        // User document with the UID does not exist in Firestore, create it or handle the error
        print("User document with ID $userId does not exist in Firestore");
        return;
      }

      List<dynamic> cart =
          (snapshot.data() as Map<String, dynamic>)['cart'] ?? [];
      if (!cart.contains(activityId)) {
        // Activity is not in the cart, add it
        cart.add(activityId);
        transaction.update(userDoc, {'cart': cart});
        print("Activity with ID $activityId added to cart");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Activity added to your cart successfully")),
        );
      } else {
        // Activity is already in the cart
        print("Activity with ID $activityId already in cart");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Activity is already in the cart")),
        );
      }
    }).catchError((error) {
      print("Failed to add to cart: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference activities =
        FirebaseFirestore.instance.collection('activities');

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Activity Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: activities.doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data?.exists != true) {
              return Center(child: Text('Activity not found'));
            }
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            String imageUrl = data['image'];
            String title = data['title'];
            String place = data['place'];
            int price = data['price'];
            String category = data['category'];
            int minPersons = data['min_persons'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: 8),
                        Text(place,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            )),
                        SizedBox(height: 16),
                        Text('Price: \€${price.toString()}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            )),
                        SizedBox(height: 8),
                        Text('Category: $category',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            )),
                        SizedBox(height: 8),
                        Text(
                          'Minimum number required: ${minPersons.toString()}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => addToCart(context, documentId),
                          child: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 30.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
