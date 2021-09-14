import 'package:flutter/material.dart';

// 后面封装下不同状态的button, select disable
class CommonImageButton extends StatefulWidget {
  double? height;
  double? width;
  final Image normalImage;
  Image? selectImage;
  void Function(bool isSelect)? onTap;
  EdgeInsets? padding;
  EdgeInsets? margin;
  CommonImageButton({
    this.height,
    this.width,
    required this.normalImage,
    this.selectImage,
    this.onTap,
    this.padding,
    this.margin,
  });
  @override
  State<StatefulWidget> createState() {
    return _CommonImageButtonState();
  }
}

class _CommonImageButtonState extends State<CommonImageButton> {
  bool isSelect = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        child: isSelect ? (widget.selectImage ?? widget.normalImage) : widget.normalImage,
      ),
      onTap: () {
        setState(() {
          this.isSelect = !this.isSelect;
        });
        if (widget.onTap != null) {
          widget.onTap!(this.isSelect);
        }
      },
    );
  }
}
