import 'package:flutter/material.dart';

typedef RetryCallback<T> = Widget Function();

class CustomErrorWidget extends StatelessWidget {
  final bool isRetry;
  final RetryCallback? retryCallback;

  CustomErrorWidget({this.isRetry = false, this.retryCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "this is error",
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}
