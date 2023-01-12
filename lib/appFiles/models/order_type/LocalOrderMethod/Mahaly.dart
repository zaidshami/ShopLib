

import 'LocalOrderMethod.dart';

class Mahaly extends LocalOrderMethod{


  static String _tableNmber="";

  String get tableNmber=>_tableNmber;

  void setTableNumber(String value)=>_tableNmber=value;

  @override
  String getType() =>"محلي (رقم الطاولة): "+tableNmber;




}