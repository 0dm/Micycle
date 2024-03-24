import 'package:flutter/material.dart';

class StationBubble extends StatelessWidget{

  final VoidCallback onPressed;
  final Icon icon;

  const StationBubble({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Diameter of the circle
      height: 80, // Diameter of the circle
      margin: EdgeInsets.only(right: 8), // Spacing between buttons
      decoration: BoxDecoration(
        color: Colors.blue, // Color of the circle
        shape: BoxShape.circle,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              primary: Colors.blue, // Background color of the button
            ),
          child: icon,
          ),
      );
  }

}