
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../common/tools/tools.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart' as loc;


mixin LocationGetter{
  Future<CurrentPostionModel> getloc() async {
    CurrentPostionModel currentPostionModel=await _determinePosition();
    print(currentPostionModel.msg);

    currentPostionModel.msg.length>2?Fluttertoast.showToast(
        msg: currentPostionModel.msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    ):"";

    return currentPostionModel;
  }
}

class CurrentPostionModel{
  bool status;
  String msg;
  Position? position;
  CurrentPostionModel(this.status,this.msg,this.position);
}

Future<CurrentPostionModel> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  loc.Location location = loc.Location();
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await location.requestService().then((value) async {
      if(value){
        return CurrentPostionModel(true,"", await Geolocator.getCurrentPosition());


      }else{
        return CurrentPostionModel(false,"يرجى تفعيل خدمة الموقع من الاعدادات",null);

      }

    });

    return CurrentPostionModel(false,"يرجى تفعيل خدمة الموقع من الاعدادات",null);
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      await location.requestPermission();
      return CurrentPostionModel(false,"يرجى منح صلاحيات الوصول للموقع من الاعدادات",null);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return CurrentPostionModel(false,"يرجى منح صلاحيات الوصول للموقع من الاعدادات",null);

  }
  return CurrentPostionModel(true,"", await Geolocator.getCurrentPosition());


}
//
// Future<CurrentPostionModel> _determinePosition() async {
//   bool serviceEnabled;
//  // LocationPermission permission;
//   loc.Location location = loc.Location();
//   // Test if location services are enabled.
//   //serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//  var serviceEnsabled= loc.PermissionStatus;
//   if (serviceEnsabled==PermissionStatus) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//     await location.requestService().then((value) async {
//       if(value){
//         return CurrentPostionModel(true,"", await Geolocator.getCurrentPosition());
//
//
//       }else{
//         return CurrentPostionModel(false,"يرجى تفعيل خدمة الموقع من الاعدادات",null);
//
//       }
//
//     });
//
//     return CurrentPostionModel(false,"يرجى تفعيل خدمة الموقع من الاعدادات",null);
//   }
//
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       await location.requestPermission();
//       return CurrentPostionModel(false,"يرجى منح صلاحيات الوصول للموقع من الاعدادات",null);
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever, handle appropriately.
//     return CurrentPostionModel(false,"يرجى منح صلاحيات الوصول للموقع من الاعدادات",null);
//
//   }
//   return CurrentPostionModel(true,"", await Geolocator.getCurrentPosition());
//
//
// }