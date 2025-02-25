import 'package:cargo_run/models/order.dart';
import 'package:flutter/material.dart';

import '/services/service_locator.dart';
import '/services/orders/orders_abstract.dart';
import '/utils/shared_prefs.dart';

enum OrderStatus {
  initial,
  loading,
  pending,
  failed,
  success,
}

class OrderProvider extends ChangeNotifier {
  final OrdersService _ordersService = serviceLocator<OrdersService>();

  OrderStatus _orderStatus = OrderStatus.initial;
  Order? _currentOrder;
  List<Order?> _orders = [];

  String _category = '';
  String _url = '';
  String _deliveryOption = '';
  String _errorMessage = '';

  String get category => _category;
  String get deliveryOption => _deliveryOption;
  String get errorMessage => _errorMessage;
  String get url => _url;
  Order? get currentOrder => _currentOrder;
  OrderStatus get orderStatus => _orderStatus;
  List<Order?> get orders => _orders;

  AddressDetails? _addressDetails;
  ReceiverDetails? _receiverDetails;

  void setOrderStatus(OrderStatus status) {
    _orderStatus = status;
    sharedPrefs.orderStatus = status.toString().split('.').last;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void addAdrressDetails(
    String houseNo,
    String pickupAddress,
    String contactNumber,
  ) {
    _addressDetails = AddressDetails(
      houseNumber: int.parse(houseNo),
      landMark: pickupAddress,
      contactNumber: contactNumber,
      lat: 6.5244,
      lng: 6.5244,
    );
    notifyListeners();
  }

  void addRecipientDetails(
    String name,
    String phone,
    String address,
    String category,
    String deliveryOption,
  ) {
    _receiverDetails = ReceiverDetails(
      name: name,
      phone: phone,
      address: address,
      lat: 6.5244,
      lng: 6.5244,
    );
    _category = category;
    _deliveryOption = deliveryOption;
    notifyListeners();
  }

  Future<void> placeOrder() async {
    setOrderStatus(OrderStatus.loading);
    var response = await _ordersService.createOrder(
      _addressDetails!,
      _receiverDetails!,
      _deliveryOption,
      _category,
    );
    response.fold((error) {
      setOrderStatus(OrderStatus.failed);
      setErrorMessage(error.message);
    }, (success) {
      setOrderStatus(OrderStatus.pending);
      _currentOrder = Order.fromJson(success.data);
      notifyListeners();
    });
  }

  Future<void> initiatePayment() async {
    setOrderStatus(OrderStatus.loading);
    var response = await _ordersService.initializePayment(
      orderId: _currentOrder!.id!,
      amount: (_currentOrder!.deliveryFee! + 2000.00).toString(),
    );
    response.fold((error) {
      setOrderStatus(OrderStatus.failed);
      setErrorMessage(error.message);
    }, (success) {
      debugPrint(success.data.toString());
      _url = success.data['data']['authorizationUrl'];
      setOrderStatus(OrderStatus.success);
      notifyListeners();
    });
  }

  void getOrders() async {
    await _ordersService.getOrders().then(
          (value) => {
            value.fold((error) {
              debugPrint(error.message);
              setOrderStatus(OrderStatus.failed);
              _orders = [];
            }, (sucess) {
              setOrderStatus(OrderStatus.success);
              List<dynamic> data = sucess.data;
              List<Order?> fetched =
                  data.map((e) => Order.fromJson(e)).toList();
              _orders = fetched;
              notifyListeners();
            }),
          },
        );
  }

  // Future<List<Order?>> getOrders() async {
  //   List<Order?> res = [];
  //   var response = await _ordersService.getOrders();
  //   response.fold((error) {
  //     setOrderStatus(OrderStatus.failed);
  //     setErrorMessage(error.message);
  //     return [];
  //   }, (success) {
  //     debugPrint(success.data.toString());
  //     _orders = success.data.map((e) => Order.fromJson(e)).toList();
  //     res = _orders;
  //     setOrderStatus(OrderStatus.success);
  //     notifyListeners();
  //     return _orders;
  //   });
  //   return res;
  // }
}
