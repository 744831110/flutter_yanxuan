import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef NetworkStreamWidgetBuilder<T> = Widget Function(BuildContext context, T data);

class NetworkStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final NetworkStreamWidgetBuilder<T> builder;
  final Widget? errorView;
  final Widget? emptyView;

  NetworkStreamBuilder({required this.stream, required this.builder, this.errorView, this.emptyView});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: this.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("this is error view");
          return errorView ?? Container();
        } else {
          if (!snapshot.hasData) {
            print("this is empty view");
            return emptyView ?? Container();
          } else {
            print("provider snapdata is ${snapshot.data}");
            return Provider<T>.value(
              value: snapshot.data!,
              child: builder(context, snapshot.data!),
            );
          }
        }
      },
    );
  }
}
