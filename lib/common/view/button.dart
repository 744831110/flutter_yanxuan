import 'package:flutter/material.dart';

// 后面封装下不同状态的button, select disable
class CommonButton extends StatefulWidget {
  double? height;
  double? width;
  BoxDecoration? decoration;
  final Widget child;
  Widget? selectChild;
  void Function(bool isSelect)? onTap;
  EdgeInsets? padding;
  EdgeInsets? margin;
  final bool initIsSelect;
  bool isInnerControlSelectState;
  bool isSelect;
  CommonButton({
    this.height,
    this.width,
    required this.child,
    this.selectChild,
    this.onTap,
    this.padding,
    this.margin,
    this.initIsSelect = false,
    this.decoration,
    this.isInnerControlSelectState = true,
    this.isSelect = false,
  });
  @override
  State<StatefulWidget> createState() {
    return _CommonButtonState();
  }
}

class _CommonButtonState extends State<CommonButton> {
  late bool isSelect;
  @override
  void initState() {
    super.initState();
    widget.isSelect = widget.initIsSelect;
    isSelect = widget.isSelect;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInnerControlSelectState) {
      isSelect = widget.isSelect;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        decoration: widget.decoration,
        child: isSelect ? (widget.selectChild ?? widget.child) : widget.child,
      ),
      onTap: () {
        if (widget.isInnerControlSelectState) {
          setState(() {
            isSelect = !isSelect;
          });
        }
        if (widget.onTap != null) {
          widget.onTap!(isSelect);
        }
      },
    );
  }
}
