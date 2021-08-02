import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef RefreshCallback = Future<void> Function();
typedef RefreshIndicatorExtendCallback = void Function(bool isExtend, double extendHeight);

class DropDownRefreshAnimateWidget extends StatefulWidget {
  final double dropProgress;
  final RefreshIndicatorMode mode;
  final Color textColor;
  DropDownRefreshAnimateWidget({Key? key, required this.dropProgress, required this.mode, this.textColor = Colors.white}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DropDownRefreshAnimateWidgetState();
  }
}

class _DropDownRefreshAnimateWidgetState extends State<DropDownRefreshAnimateWidget> {
  late Matrix4 leftMatrix4;
  late Matrix4 rightMatrix4;

  @override
  void initState() {
    super.initState();
    //调整坐标系
    leftMatrix4 = Matrix4.identity();
    leftMatrix4.rotateX(pi * 0.27);
    leftMatrix4.rotateZ(pi * 0.18);
    // pi * -0.25 - pi * 0.85
    rightMatrix4 = Matrix4.identity();
    rightMatrix4.rotateX(pi * 0.27);
    rightMatrix4.rotateZ(-pi * 0.18);
    // pi * -0.85 - pi * 0.25
  }

  @override
  Widget build(BuildContext context) {
    var leftProgress = widget.mode == RefreshIndicatorMode.armed || widget.mode == RefreshIndicatorMode.done ? -0.25 : progressValue(0.85, -0.25, widget.dropProgress / 100.0);
    var rightProgress = widget.mode == RefreshIndicatorMode.armed || widget.mode == RefreshIndicatorMode.done ? 0.25 : progressValue(-0.85, 0.25, widget.dropProgress / 100.0);
    return Center(
      child: Container(
        height: 120,
        width: 70,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: CustomPaint(
                size: Size(70, 120),
                foregroundPainter: _BoxForegroundPainter(),
                painter: _BoxBackPainter(),
                child: Container(
                  width: 70,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 54,
                        bottom: 30,
                        child: Transform(
                          transform: leftMatrix4.clone()..rotateY(leftProgress * pi),
                          alignment: Alignment.bottomRight,
                          child: CustomPaint(
                            size: Size(19, 9),
                            painter: _BoxSide(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 54,
                        bottom: 30,
                        child: Transform(
                          transform: rightMatrix4.clone()..rotateY(rightProgress * pi),
                          alignment: Alignment.bottomLeft,
                          child: CustomPaint(
                            size: Size(19, 9),
                            painter: _BoxSide(isRight: true),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              child: Text(
                "严选",
                style: TextStyle(color: Color.fromARGB(255, 138, 119, 83), fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  double progressValue(double startValue, double endValue, double progress) {
    return startValue + (endValue - startValue) * progress;
  }
}

class _BoxSide extends CustomPainter {
  final double width;
  final double height;
  final double offset;
  final bool isRight;
  _BoxSide({this.width = 19, this.height = 9, this.offset = 6.3, this.isRight = false}) : super();
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color.fromARGB(255, 222, 207, 190);
    if (isRight) {
      Path path = Path()
        ..moveTo(width, 0)
        ..relativeLineTo(-width, 0)
        ..relativeLineTo(0, height)
        ..relativeLineTo(width + offset, 0);
      canvas.drawPath(path, paint);
    } else {
      Path path = Path()
        ..moveTo(0 - offset, height)
        ..relativeLineTo(offset + width, 0)
        ..relativeLineTo(0, -height)
        ..relativeLineTo(-width, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoxSide oldDelegate) {
    return oldDelegate.offset != this.offset;
  }
}

class _BoxBackPainter extends CustomPainter {
  final boxInsideColor = Color.fromARGB(255, 191, 168, 141);
  final boxSideColor = Color.fromARGB(255, 209, 188, 171);
  final boxInsideLineColor = Color.fromARGB(255, 195, 118, 109);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = boxInsideColor;
    canvas.drawRect(Offset(21, 85) & Size(28, 5), paint);
    paint.color = boxSideColor;
    Path trianglePath1 = Path()
      ..moveTo(16, 90)
      ..relativeLineTo(5, 0)
      ..relativeLineTo(0, -5)
      ..close();
    canvas.drawPath(trianglePath1, paint);
    Path trianglePath2 = Path()
      ..moveTo(49, 85)
      ..relativeLineTo(0, 5)
      ..relativeLineTo(5, 0)
      ..close();
    canvas.drawPath(trianglePath2, paint);

    paint.color = boxInsideLineColor;
    paint.style = PaintingStyle.stroke;
    Path triangeleLinePath1 = Path()
      ..moveTo(21, 85)
      ..relativeLineTo(-5, 5)
      ..relativeLineTo(5, 0);
    canvas.drawPath(triangeleLinePath1, paint);
    canvas.drawPath(trianglePath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BoxForegroundPainter extends CustomPainter {
  final ovalColor = Color.fromARGB(255, 196, 56, 61);
  final boxOutsideColor = Color.fromARGB(255, 222, 207, 190);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ovalColor;
    canvas.drawOval(Offset(10, 112) & Size(50, 8), paint);

    paint.color = boxOutsideColor;
    canvas.drawRect(Offset(16, 90) & Size(38, 26), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

final double kCustomRefreshShowContentHeight = 100;

class CustomCupertinoSliverRefreshControl extends StatefulWidget {
  const CustomCupertinoSliverRefreshControl({
    Key? key,
    this.refreshTriggerPullDistance = _defaultRefreshTriggerPullDistance,
    this.refreshIndicatorExtent = _defaultRefreshIndicatorExtent,
    this.builder = dropDownRefreshContent,
    this.onRefresh,
    this.refreshIndicatorExtendCallback,
  })  : assert(refreshTriggerPullDistance != null),
        assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
          refreshTriggerPullDistance >= refreshIndicatorExtent,
          'The refresh indicator cannot take more space in its final state '
          'than the amount initially created by overscrolling.',
        ),
        super(key: key);

  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;

  final RefreshControlIndicatorBuilder? builder;
  final RefreshCallback? onRefresh;

  final RefreshIndicatorExtendCallback? refreshIndicatorExtendCallback;

  static const double _defaultRefreshTriggerPullDistance = 100.0;
  static const double _defaultRefreshIndicatorExtent = 60.0;

  @visibleForTesting
  static RefreshIndicatorMode state(BuildContext context) {
    final _CustomCupertinoSliverRefreshControlState state = context.findAncestorStateOfType<_CustomCupertinoSliverRefreshControlState>()!;
    return state.refreshState;
  }

  static Widget dropDownRefreshContent(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    double progress = (pulledExtent - 100 - 20) * 100 / refreshTriggerPullDistance;
    return Center(
      child: Container(
        color: Colors.red,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              bottom: 0,
              child: DropDownRefreshAnimateWidget(
                dropProgress: progress >= 100 ? 100 : progress,
                mode: refreshState,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  _CustomCupertinoSliverRefreshControlState createState() => _CustomCupertinoSliverRefreshControlState();
}

class _CustomCupertinoSliverRefreshControlState extends State<CustomCupertinoSliverRefreshControl> {
  static const double _inactiveResetOverscrollFraction = 0.1;

  late RefreshIndicatorMode refreshState;

  Future<void>? refreshTask;
  double latestIndicatorBoxExtent = 0.0;
  bool _hasSliverLayoutExtent = false;
  bool get hasSliverLayoutExtent => _hasSliverLayoutExtent;
  set hasSliverLayoutExtent(bool value) {
    _hasSliverLayoutExtent = value;
    if (widget.refreshIndicatorExtendCallback != null) {
      widget.refreshIndicatorExtendCallback!(value, widget.refreshIndicatorExtent);
    }
  }

  @override
  void initState() {
    super.initState();
    refreshState = RefreshIndicatorMode.inactive;
  }

  RefreshIndicatorMode transitionNextState() {
    RefreshIndicatorMode nextState;

    void goToDone() {
      nextState = RefreshIndicatorMode.done;
      if (SchedulerBinding.instance!.schedulerPhase == SchedulerPhase.idle) {
        setState(() => hasSliverLayoutExtent = false);
      } else {
        SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
          setState(() => hasSliverLayoutExtent = false);
        });
      }
    }

    switch (refreshState) {
      case RefreshIndicatorMode.inactive:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorMode.inactive;
        } else {
          nextState = RefreshIndicatorMode.drag;
        }
        continue drag;
      drag:
      case RefreshIndicatorMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return RefreshIndicatorMode.inactive;
        } else if (latestIndicatorBoxExtent < widget.refreshTriggerPullDistance + kCustomRefreshShowContentHeight) {
          return RefreshIndicatorMode.drag;
        } else {
          if (widget.onRefresh != null) {
            HapticFeedback.mediumImpact();
            SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
              refreshTask = widget.onRefresh!()
                ..whenComplete(() {
                  if (mounted) {
                    setState(() => refreshTask = null);
                    refreshState = transitionNextState();
                  }
                });
              setState(() => hasSliverLayoutExtent = true);
            });
          }
          return RefreshIndicatorMode.armed;
        }
      case RefreshIndicatorMode.armed:
        if (refreshState == RefreshIndicatorMode.armed && refreshTask == null) {
          goToDone();
          continue done;
        }

        if (latestIndicatorBoxExtent > widget.refreshIndicatorExtent) {
          return RefreshIndicatorMode.armed;
        } else {
          nextState = RefreshIndicatorMode.refresh;
        }
        continue refresh;
      refresh:
      case RefreshIndicatorMode.refresh:
        if (refreshTask != null) {
          return RefreshIndicatorMode.refresh;
        } else {
          goToDone();
        }
        continue done;
      done:
      case RefreshIndicatorMode.done:
        if (latestIndicatorBoxExtent > widget.refreshTriggerPullDistance * _inactiveResetOverscrollFraction + kCustomRefreshShowContentHeight) {
          return RefreshIndicatorMode.done;
        } else {
          nextState = RefreshIndicatorMode.inactive;
        }
        break;
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoSliverRefresh(
      refreshIndicatorLayoutExtent: widget.refreshIndicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          latestIndicatorBoxExtent = constraints.maxHeight;
          refreshState = transitionNextState();
          if (widget.builder != null && latestIndicatorBoxExtent > 0) {
            return widget.builder!(
              context,
              refreshState,
              latestIndicatorBoxExtent,
              widget.refreshTriggerPullDistance,
              widget.refreshIndicatorExtent,
            );
          }
          return Container();
        },
      ),
    );
  }
}

class _CupertinoSliverRefresh extends SingleChildRenderObjectWidget {
  const _CupertinoSliverRefresh({
    Key? key,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    Widget? child,
  })  : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  final double refreshIndicatorLayoutExtent;

  final bool hasLayoutExtent;

  @override
  _RenderCupertinoSliverRefresh createRenderObject(BuildContext context) {
    return _RenderCupertinoSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCupertinoSliverRefresh renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RenderCupertinoSliverRefresh extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {
  _RenderCupertinoSliverRefresh({
    required double refreshIndicatorExtent,
    required bool hasLayoutExtent,
    RenderBox? child,
  })  : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  set refreshIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;
  set hasLayoutExtent(bool value) {
    assert(value != null);
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    final double layoutExtent = (_hasLayoutExtent ? 1.0 : 0.0) * (_refreshIndicatorExtent);
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }
    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent = constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    child!.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent + overscrolledExtent + kCustomRefreshShowContentHeight,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent + kCustomRefreshShowContentHeight,
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: max(
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0) + kCustomRefreshShowContentHeight,
      );
    } else {
      geometry = SliverGeometry(
        scrollExtent: kCustomRefreshShowContentHeight,
        paintOrigin: -constraints.scrollOffset,
        paintExtent: kCustomRefreshShowContentHeight,
        maxPaintExtent: kCustomRefreshShowContentHeight,
        layoutExtent: max(kCustomRefreshShowContentHeight - constraints.scrollOffset, 0),
      );
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 || constraints.scrollOffset + child!.size.height > 0) {
      paintContext.paintChild(child!, offset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
