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
          return errorView ?? Container();
        } else {
          if (!snapshot.hasData) {
            return emptyView ?? Container();
          } else {
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
