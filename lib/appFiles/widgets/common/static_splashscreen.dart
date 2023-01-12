import 'package:flutter/material.dart';

import '../../../MainModel.dart';
import '../../../unicomapps.dart';
import '../../models/order_type/DeliveryOrder.dart';
import '../../screens/base_screen.dart';
import '../../screens/order_type_ui/OrderTypeScreens.dart';
import 'flux_image.dart';

class StaticSplashScreen extends StatefulWidget {
  final String? imagePath;
  final Function? onNextScreen;
  final int duration;
  final Color backgroundColor;
  final BoxFit boxFit;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;

  const StaticSplashScreen({
    this.imagePath,
    key,
    this.onNextScreen,
    this.duration = 2500,
    this.backgroundColor = Colors.white,
    this.boxFit = BoxFit.contain,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
    this.paddingLeft = 0.0,
    this.paddingRight = 0.0,
  }) : super(key: key);

  @override
  BaseScreen<StaticSplashScreen> createState() => _StaticSplashScreenState();
}

class _StaticSplashScreenState extends BaseScreen<StaticSplashScreen> {
  @override
  void afterFirstLayout(BuildContext context) {
    Future.delayed(Duration(milliseconds: widget.duration), () {
      if(AppParams().mainModel!.appConstants.isLocalOrders) {
       return Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SelectMethod(widget.onNextScreen)));
      }
      orderMethod=DeliveryOrder();

      widget.onNextScreen?.call();
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (context) => widget.onNextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor:  Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children: [

          Expanded(
            flex: 9,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: widget.paddingTop,
                bottom: widget.paddingBottom,
                left: widget.paddingLeft,
                right: widget.paddingRight,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return widget.imagePath!.startsWith('http')
                      ? FluxImage(
                          imageUrl: widget.imagePath!,
                          fit: widget.boxFit,
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                    package: "unicomapps",

                  )
                      : Image.asset(
                          widget.imagePath!,
                          gaplessPlayback: true,
                          fit: BoxFit.contain,//widget.boxFit,
                          height: 200,
                          width: 250,
                 //   package: AppParams().mainModel!.appConstants.appPackege,
                        );
                },
              ),
            ),
          ),
      Expanded(
        flex: 1,
        child: Container(
          alignment: Alignment.bottomCenter,
        child: Text("جميع الحقوق محفوظة ${AppParams().mainModel!.appConstants.appName} @ 2022",style:TextStyle(color:Theme.of(context).primaryColor),),
        ),
      )
        ],
      ),
    );
  }
}
