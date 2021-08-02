import 'package:flutter/material.dart';

class CustomEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "this is empty",
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}
