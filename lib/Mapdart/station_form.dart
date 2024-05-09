import 'package:flutter/material.dart';

class StationForm extends StatelessWidget{
  final String text;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController bikesController;
  final VoidCallback onPressed;

  StationForm({
    required this.text,
    required this.nameController,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
    required this.bikesController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(text),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Station Name'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: bikesController,
                decoration: InputDecoration(labelText: 'Number of Bikes'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: onPressed,
          ),
        ],
      );
  }

}