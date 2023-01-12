

import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import '../entities/address.dart';
import 'LocalOrderMethod/LocalOrderMethod.dart';
import 'OrderType.dart';
import 'Store.dart';

class LocalOrder<T extends LocalOrderMethod> extends OrderMethod{


  static Address? _address;
  static List<Store> _storesList=[];

   T? localOrderMethod;

  List<Store>? get  storesList=>_storesList;

  void setLocalOrderMethod(T value)=>localOrderMethod=value;

  LocalOrder(String stores_string){
    if(_storesList.isEmpty) {
      setStoresList(stores_string);
    }
  }

  void set_list(Position postion){
    _storesList.forEach((element) {
      element.distance=Geolocator.distanceBetween(
          element.lat!,element.lng!, postion.latitude,postion.longitude);

    });
    _storesList.sort((a, b) => a.distance!.compareTo(b.distance!));


  }

  void setStoresList(String stores_string){
    List<Store> storesList=[];
    var data=jsonDecode(stores_string);
    for(int i =0;i<data.length;i++){
      storesList.add(Store.fromJson(data[i]));
    }
    print("wwwd2");
    _storesList=storesList;
  }

  Address? get  address=>_address;

  void set_address(Address? address){
    _address=address;
  }

}

