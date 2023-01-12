import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../widgets/common/paging_list.dart';
import '../../common/app_bar_mixin.dart';
import '../models/list_order_history_model.dart';
import '../models/order_history_detail_model.dart';
import 'widgets/order_list_item.dart';
import 'widgets/order_list_loading_item.dart';

class ListOrderHistoryScreen extends StatefulWidget {
  @override
  State<ListOrderHistoryScreen> createState() => _ListOrderHistoryScreenState();
}

class _ListOrderHistoryScreenState extends State<ListOrderHistoryScreen>
    with AppBarMixin {
  ListOrderHistoryModel get listOrderViewModel =>
      Provider.of<ListOrderHistoryModel>(context, listen: false);

  var mapOrderHistoryDetailModel = <int, OrderHistoryDetailModel>{};

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user ?? User();
    return renderScaffold(
      routeName: RouteList.orders,
      body:  DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text(
              S.of(context).orderHistory,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).backgroundColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_sharp,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom:  TabBar(
              tabs: [
                Tab(child: Text("الطلبات الحالية",
                style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
          ),
                ),
                    icon: Icon(Icons.lock_clock,color: Colors.white)),
                Tab(child: Text("كل الطلبات",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                    icon: Icon(Icons.history,color: Colors.white,)),
              ],
            ),
          ),
          body:  TabBarView(
            children: [
              PagingList<ListOrderHistoryModel, Order>(
                onRefresh: mapOrderHistoryDetailModel.clear,

                itemBuilder: (_, order, index) {

                  if (mapOrderHistoryDetailModel[index] == null) {
                    final orderHistoryDetailModel = OrderHistoryDetailModel(
                      order: order,
                      user: user,
                    );
                    mapOrderHistoryDetailModel[index] = orderHistoryDetailModel;
                  }

                  bool isview=(mapOrderHistoryDetailModel[index]!.order.status==OrderStatus.pending||
                      mapOrderHistoryDetailModel[index]!.order.status==OrderStatus.processing)?true:false;

                  return isview?ChangeNotifierProvider<OrderHistoryDetailModel>.value(
                    value: mapOrderHistoryDetailModel[index]!,
                    child: CurrentOrderListItem(),
                  ):SizedBox();
                },
                lengthLoadingWidget: 3,
                loadingWidget: const OrderListLoadingItem(),
              ),
              PagingList<ListOrderHistoryModel, Order>(
                onRefresh: mapOrderHistoryDetailModel.clear,
                itemBuilder: (_, order, index) {
                  if (mapOrderHistoryDetailModel[index] == null) {
                    final orderHistoryDetailModel = OrderHistoryDetailModel(
                      order: order,
                      user: user,
                    );
                    mapOrderHistoryDetailModel[index] = orderHistoryDetailModel;
                  }
                  return ChangeNotifierProvider<OrderHistoryDetailModel>.value(
                    value: mapOrderHistoryDetailModel[index]!,
                    child: CurrentOrderListItem(),
                  );
                },
                lengthLoadingWidget: 3,
                loadingWidget: const OrderListLoadingItem(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
