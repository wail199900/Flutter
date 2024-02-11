// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddActivityPage extends StatefulWidget {
  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _priceController = TextEditingController();
  final _minPersonsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _placeController.dispose();
    _priceController.dispose();
    _minPersonsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addActivity() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed to add to Firestore
      CollectionReference activities =
          FirebaseFirestore.instance.collection('activities');

      await activities.add({
        'category': _categoryController.text,
        'title': _titleController.text,
        'place': _placeController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'min_persons': int.tryParse(_minPersonsController.text) ?? 0,
        'image': _imageUrlController.text,
      });

      // Clear the text fields
      _categoryController.clear();
      _titleController.clear();
      _placeController.clear();
      _priceController.clear();
      _minPersonsController.clear();
      _imageUrlController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activity added successfully')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Add New Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(labelText: 'Place'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minPersonsController,
                decoration: InputDecoration(labelText: 'Minimum Persons'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimum number of persons';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addActivity,
                child: Text('Add Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
