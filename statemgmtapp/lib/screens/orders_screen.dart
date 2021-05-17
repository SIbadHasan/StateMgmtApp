import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName= '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

@override
 void initState(){
   Future.delayed(Duration.zero).then((_) {
     Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
   });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final orderdata = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders')),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orderdata.order.length,
        itemBuilder: (ctx, i) => OrderItem(orderdata.order[i]),
      ),
    );
  }
}
