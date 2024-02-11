// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'get_activitiy.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _appBarTitles = ['Activities', 'Cart', 'Profile'];
  final user = FirebaseAuth.instance.currentUser!;
  List<String> docIDs = [];
  int _selectedIndex = 0;
  String? _selectedCategory;
  List<String> _categories = []; // Initialize categories list

  late Future<List<String>> docIdFuture =
      getDocIdFilteredByCategory(_selectedCategory);

  @override
  void initState() {
    super.initState();
    getCategoriesFromFirestore(); // Load categories from Firestore
  }

  Future<void> getCategoriesFromFirestore() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('activities').get();
    setState(() {
      _categories = ['All'] +
          categoriesSnapshot.docs // Add 'All' at the beginning
              .map((doc) => doc['category'].toString())
              .toSet() // Remove duplicates
              .toList();
    });
  }

  Future<List<String>> getDocIdFilteredByCategory(String? category) async {
    List<String> ids = [];
    Query query = FirebaseFirestore.instance.collection('activities');
    // If the category is 'All' or null, do not filter by category.
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    QuerySnapshot querySnapshot = await query.get();
    for (var document in querySnapshot.docs) {
      ids.add(document.reference.id);
    }
    return ids;
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index] == 'All'
                          ? null
                          : _categories[index];
                    });
                    docIdFuture = getDocIdFilteredByCategory(_selectedCategory);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildWidgetOption(int index) {
    switch (index) {
      case 0:
        return FutureBuilder<List<String>>(
          future: docIdFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No activities found');
            }
            docIDs = snapshot.data!;
            return ListView.builder(
              itemCount: docIDs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetActivity(documentId: docIDs[index]),
                );
              },
            );
          },
        );
      case 1:
        return CartPage(); // Cart page
      case 2:
        return ProfilePage(); // Profile page
      default:
        return Text('Error: Unknown page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: _selectedIndex == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Opacity(
                    opacity: 0,
                    child: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: null,
                    ),
                  ),
                  Text(
                    _appBarTitles[_selectedIndex],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  // Actual IconButton for the category selector
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _showCategorySelector,
                  ),
                ],
              )
            : Text(
                _appBarTitles[_selectedIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
        centerTitle: true,
      ),
      body: Center(
        child: _buildWidgetOption(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Icon(Icons.local_activity),
            ),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
