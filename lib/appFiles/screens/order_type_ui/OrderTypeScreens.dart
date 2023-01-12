

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../MainModel.dart';
import '../../../unicomapps.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_base.dart';
import '../../models/entities/address.dart';
import '../../models/order_type/DeliveryOrder.dart';
import '../../models/order_type/LocalOrder.dart';
import '../../models/order_type/OrderType.dart';
import '../../models/order_type/Store.dart';
import '../../widgets/common/flux_image.dart';
import '../order_history/views/widgets/index.dart';
import 'GetLocation.dart';


abstract class BaseMethodWidget extends StatelessWidget{
    Function? onNextScreen;
    BaseMethodWidget(this.onNextScreen);
}

class SelectMethod extends BaseMethodWidget with LocationGetter{
  SelectMethod(Function? onNextScreen) : super(onNextScreen);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container(
        margin: EdgeInsets.only(left: 18.0,right: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppParams().mainModel!.appConstants.appLogo,
              gaplessPlayback: true,
              fit: BoxFit.contain,//widget.boxFit,
              height: 200,
           //   package: AppParams().mainModel!.appConstants.appPackege,

              width: 250,
            ),
            Row(
              children: [
                Expanded(
                  child: ButtonTheme(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context)
                            .backgroundColor,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () async {
                        var loc=await getloc();
                        if(loc.status&&loc.position!=null) {
                          // localOrder!.set_list(loc.position!);
                          //   orderMethod = localOrder;

                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => SelectStore(loc.position!,onNextScreen)));
                        }
                      },
                      child: Text(
                        "الطلب من ${AppParams().mainModel!.appConstants.appName} كافية",
                      ),
                    ),
                  ),
                )
              ],
            ),
            Divider(height: 20,),
            Row(
              children: [
                Expanded(
                  child: ButtonTheme(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context)
                            .primaryColor,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () async {
                        orderMethod=DeliveryOrder();

                        onNextScreen?.call();

                      },
                      child: Text(
                        "توصيل الطلب عبر المتجر الالكتروني",
                      ),
                    ),
                  ),
                )
              ],
            ),
          // InkWell(
          //   onTap: () async {
          //     var loc=await getloc();
          //     if(loc.status&&loc.position!=null) {
          //       // localOrder!.set_list(loc.position!);
          //       //   orderMethod = localOrder;
          //
          //         Navigator.of(context).pushReplacement(MaterialPageRoute(
          //             builder: (context) => SelectStore(loc.position!,onNextScreen)));
          //       }
          //     },
          //   child: Text("من داخل المتجر"),),
          // InkWell(
          //   onTap: (){
          //
          //     onNextScreen?.call();
          //   },
          //   child: Text("توصيل الى المنزل"),),


        ],),),
    );
  }


}

class SelectStore extends BaseMethodWidget{
  Position position;
  SelectStore(this.position,Function? onNextScreen) : super(onNextScreen);

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Image.asset(
          AppParams().mainModel!.appConstants.appLogo,
          gaplessPlayback: true,
          fit: BoxFit.contain,//widget.boxFit,
          height: 200,
          width: 250,
        ),
        Expanded(
          child: Container(
          //  height:localOrder!.storesList!.length*100 ,
            child: ListView.builder(
              itemCount: localOrder!.storesList!.length,
              itemBuilder: (context, index) {
                var store=localOrder!.storesList![index];
                double dictance=Geolocator.distanceBetween(position.latitude, position.longitude, store.lat!, store.lng!)/1000;
                return jijo(store,dictance,onNextScreen);

                //   InkWell(
                //   onTap: (){
                //     orderMethod=LocalOrder("");
                //    // OrderMethod().set_type(LocalOrder(""));
                //     orderMethod!.set_address(Address(
                //         firstName :"",
                //         lastName : "",
                //         apartment : "",
                //     street : ""+store.name!,
                //     block : "محلي",
                //     city :"",
                //     state :store.zoneId,
                //     country : store.countryId,
                //     latitude:position.latitude.toString() ,
                //     longitude: position.longitude.toString() ,
                //     zipCode  : ""));
                //     Provider.of<CartModel>(context, listen: false)
                //         .setAddress(LocalOrder("").address!);
                //     onNextScreen!.call();
                //   },
                //     child:jijo(store,dictance,onNextScreen)
                //
                //   //   Container(
                //   //     height: 100,
                //   //     child:ListTile(title:  Text(store.name!),
                //   //       subtitle:Text("المسافة :"+dictance.roundToDouble().toString() +" ك.م",),
                //   //       trailing: dictance<8?Container(width: 50,
                //   //         height: 30,
                //   //         decoration:BoxDecoration(
                //   //         color: Theme.of(context)
                //   //             .backgroundColor,
                //   //             shape: BoxShape.rectangle
                //   //         ) ,child:
                //   //         Center(child: Text("اختيار",style: TextStyle(
                //   //           fontWeight: FontWeight.w800,
                //   //           color: Colors.white.withOpacity(0.9),
                //   //         ),)),):SizedBox(),
                //   //     leading: Hero(
                //   //         tag: 'bljjog-${store.id}',
                //   //         child: ClipRRect(
                //   //           borderRadius: BorderRadius.all(
                //   //             Radius.circular(25),
                //   //           ),
                //   //           child: FluxImage(
                //   //             imageUrl: store.img!,
                //   //             width: 60,
                //   //             height: 60,
                //   //             fit: BoxFit.cover,
                //   //
                //   //           ),
                //   //         )),
                //   //
                //   //   ),
                //   // )
                //
                // );
              },),
          ),
        ),
      ],
    );
  }


}



class jijo extends StatelessWidget {
  Store store;
  double dictance;
  Function? onNextScreen;
  jijo(this.store,this.dictance,this.onNextScreen);


  @override
  Widget build(BuildContext context) {
bool if_avai=dictance<8?true:false;
    return Center(
     child: GestureDetector(
       onTap: () {
         if(if_avai){
           orderMethod=LocalOrder("");
           // OrderMethod().set_type(LocalOrder(""));
           orderMethod!.set_address(Address(
               firstName :"",
               lastName : "",
               apartment : "",
               street : ""+store.name!,
               block : "محلي",
               city :"",
               state :store.zoneId,
               country : store.countryId,
               latitude:store.lat.toString() ,
               longitude:store.lng.toString() ,
               zipCode  : ""));
           Provider.of<CartModel>(context, listen: false)
               .setAddress(LocalOrder("").address!);
           onNextScreen!.call();
         }

       },
       child: Container(
         width: double.maxFinite,
         height: 200,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(15.0),
           border: Border.all(color: Theme.of(context).primaryColor,),
           boxShadow: const [
             BoxShadow(
               color: Colors.black12,
               offset: Offset(0, 2),
               blurRadius: 6,
             )
           ],
         ),
         margin: const EdgeInsets.only(
           top: 15.0,
           left: 15.0,
           right: 15.0,
           bottom: 10.0,
         ),
         child: Column(
           children: [
             Expanded(
               flex: 1,
               child: Container(
                 padding: const EdgeInsets.only(
                     left: 10.0, top: 10.0, right: 15.0),
                 decoration: BoxDecoration(
                   borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(14.0),
                     topRight: Radius.circular(14.0),
                   ),
                   color: Colors.white,
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Positioned(
                       left: 0,
                       top: 0,
                       child: Hero(
                         tag:
                         'image-${store.id}',
                         child: Container(
                           width: 85,
                           height: 80,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(10.0),
                             boxShadow: const [
                               BoxShadow(
                                 color: Colors.black12,
                                 offset: Offset(0, 2),
                                 blurRadius: 2,
                               )
                             ],
                           ),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(10.0),
                             child: FluxImage(
                               imageUrl:store.img!,
                               width: 60,
                               height: 60,
                               fit: BoxFit.cover,

                             ),
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     Center(
                       child: Text(
                         store.name!,
                         style:  TextStyle(
                           fontSize: 18.0,
                           fontWeight: FontWeight.w700,
                           color: Theme.of(context).backgroundColor
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),

                   ],
                 ),
               ),
             ),
            
             Expanded(
               flex: 1,
               child: Container(
                 decoration: const BoxDecoration(
                   borderRadius:  BorderRadius.only(
                     bottomLeft: Radius.circular(14.0),
                     bottomRight: Radius.circular(14.0),
                   ),
                   color: Colors.white,
                 ),
                 child: Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(6),
                     color: Theme.of(context).primaryColorLight,
                   ),
                   margin: const EdgeInsets.all(8),
                   padding: EdgeInsets.only(
                       right: Tools.isRTL(context) ? 0.0 : 20,
                       left: !Tools.isRTL(context) ? 0.0 : 20),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         width: 15,
                         height: 62,
                         decoration: BoxDecoration(
                           color: if_avai?Colors.green:Colors.red,
                           borderRadius: BorderRadius.circular(5.0),
                         ),
                       ),
                       OrderStatusWidget(
                         title:"",
                         detail:if_avai?"متاح": S.of(context).unavailable,
                       ),
                       OrderStatusWidget(
                         title:S.of(context).distanceword,
                         detail:S.of(context).distance(dictance.roundToDouble().toString()),
                       ),


                       // OrderStatusWidget(
                       //   title: S.of(context).tax,
                       //   detail: PriceTools.getCurrencyFormatted(
                       //       order.totalTax, null,
                       //       currency: currencyCode),
                       // ),
                       // OrderStatusWidget(
                       //   title: S.of(context).Qty,
                       //   detail: order.quantity.toString(),
                       // ),
                       // if (order.status != null)
                       //   OrderStatusWidget(
                       //     title: S.of(context).status,
                       //     detail: order.status == OrderStatus.unknown &&
                       //         order.orderStatus != null
                       //         ? order.orderStatus
                       //         : order.status!.content,
                       //   ),
                     ],
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
  }

}