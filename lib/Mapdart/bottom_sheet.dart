import 'package:flutter/material.dart';
import 'station.dart';

class StationBottomSheet extends StatelessWidget {
  const StationBottomSheet(
      {
      required this.sidex,
      required this.sidey,
      required this.name,
      required this.addrs,
      required this.bikes,
      required this.index,
      required this.children,
      });

  final double sidex;
  final double sidey;
  final String name;
  final String addrs;
  final int bikes;
  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.75),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/placeHolderBike.jpeg', // Replace with your image asset
            width: MediaQuery.of(context)
                .size
                .width, // Set image width to full screen width
            height: MediaQuery.of(context).size.height *
                0.3, // Adjust the size accordingly
            fit: BoxFit
                .cover, // Cover the entire width while keeping aspect ratio
          ),
          SizedBox(height: 16),
          Text(
            '$name',
            style: TextStyle(fontSize: 30), // Adjust the style as needed
          ),
          Text(
            '$addrs',
            style: TextStyle(fontSize: 16), // Adjust the style as needed
          ),
          Text(
            'Remaining Bike: $bikes/10',
            style: TextStyle(fontSize: 16), // Adjust the style as needed
          ),
          SizedBox(height: 16),
          Align(
            alignment:
                Alignment.centerLeft, // Aligning only this widget to the left
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // To prevent the Row from occupying the entire horizontal space
              children: children,
            ),
          )
        ],
      ),
    );
  }
}