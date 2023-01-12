
import '../entities/address.dart';

enum OrderType{
  local,delivery
}

class OrderMethod{

static OrderType? _orderType;

OrderType? get  orderType=>_orderType;

void set_type(OrderType? orderType){
  _orderType=orderType;
}


}

// class MainOrder<T extends OrderMethod>{
//   static OrderMethod? _item;
//   OrderMethod? get  item=>_item;
//
//   OrderMethod  gettype(){
//     return this.item!.;
//   }
//
// }






