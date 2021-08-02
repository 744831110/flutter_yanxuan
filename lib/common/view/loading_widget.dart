import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "this is loading",
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}
