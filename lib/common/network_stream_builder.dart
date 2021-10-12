import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef NetworkStreamWidgetBuilder<T> = Widget Function(BuildContext context, T data, Widget? child);
typedef NetworkStreamSnapShotBuilder<T> = Widget Function(BuildContext context, AsyncSnapshot<T> snapshot, Widget? child);

class NetworkStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  // 已处理snapshot返回data，如果无data或出现错误，显示emptyview或errorview
  final NetworkStreamWidgetBuilder<T>? dataBuilder;
  // 自行处理snapshot，无emptyview，errorview以及provider
  final NetworkStreamSnapShotBuilder<T>? snapShotBuilder;
  final Widget? errorView;
  final Widget? emptyView;
  final bool needProvider;
  final Widget? child;

  NetworkStreamBuilder({
    required this.stream,
    this.dataBuilder,
    this.snapShotBuilder,
    this.errorView,
    this.emptyView,
    this.needProvider = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: this.stream,
      builder: (context, snapshot) {
        if (snapShotBuilder != null) {
          return setProvider(snapShotBuilder!(context, snapshot, child), snapshot);
        }
        if (snapshot.hasError) {
          return errorView ?? Container();
        } else {
          if (!snapshot.hasData) {
            return emptyView ?? Container();
          } else {
            if (dataBuilder != null) {
              return setProvider(dataBuilder!(context, snapshot.data!, child), snapshot);
            } else {
              return Container();
            }
          }
        }
      },
    );
  }

  Widget setProvider(Widget builder, AsyncSnapshot snapshot) {
    if (needProvider && snapshot.hasData) {
      return Provider<T>.value(
        value: snapshot.data!,
        child: builder,
      );
    } else {
      return builder;
    }
  }
}
