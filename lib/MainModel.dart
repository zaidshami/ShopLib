
import 'package:flutter/material.dart';

class MainModel{
  AppConstants appConstants;
  ThemeColors themeColors;


  MainModel({required this.appConstants,required this.themeColors});


}

class AppParams{
  static MainModel? _mainModel;
  MainModel? get  mainModel=>_mainModel;

  setMainModel(MainModel? _tempmainModel){
    _mainModel=_tempmainModel;
  }
}

class ThemeColors{
  Color praimaryColor;
  Color secandoryColor;
  Color textThemeColor;
  Color colorScheme;
  ThemeColors({required this.praimaryColor ,required this.secandoryColor,
    required this.textThemeColor ,required this.colorScheme });
}

class AppConstants{

  String serverUrl;
  String appLogo;
  String appPackege;
  bool isLocalOrders;

  String appName;
  List<String> boaredImg;

  AppConstants({required this.serverUrl,required this.appLogo
    ,required this.appPackege,required this.isLocalOrders,required this.appName,required this.boaredImg});
}