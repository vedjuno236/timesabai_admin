import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;

  const CustomProgressHUD({
    required Key key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    widgetList.add(child);
    if (inAsyncCall) {
      final modal = Stack(
        children: [
          Opacity(
            opacity: opacity,
            child: ModalBarrier(
              dismissible: false,
              color: color,
            ),
          ),
          Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.blue,
              size: 50,
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}



class LoadingPlatformV2 extends StatelessWidget {
  final Color? color;
  final double? size;
  

  const LoadingPlatformV2({
    super.key,
    this.color,
     this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitChasingDots(
      color: color ?? Colors.white,
      size: size ??40,
    );
  }
}
