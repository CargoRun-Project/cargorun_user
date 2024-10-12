import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_text_field/open_street_location_picker.dart';
import 'package:provider/provider.dart';
// import 'package:cargo_run/providers/order_provider.dart';
import '../../../../styles/app_colors.dart';
import '../../../../widgets/app_buttons.dart';
import '../../../../widgets/app_textfields.dart';
import '../../../../widgets/page_widgets/appbar_widget.dart';
import '../../../../providers/order_provider.dart';
import '../../../../utils/app_router.gr.dart';

@RoutePage()
class RequestRider extends StatefulWidget {
  final String type;
  const RequestRider({super.key, required this.type});

  @override
  State<RequestRider> createState() => _RequestRiderState();
}

class _RequestRiderState extends State<RequestRider> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _pickupAddressController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context, title: 'Pickup Details'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40.0),
              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10.0),
              AppTextField(
                noLabel: true,
                labelText: 'House No',
                hintText: 'House No.',
                keyboardType: TextInputType.number,
                controller: _houseNoController,
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: LocationPicker(
                  label: "From",
                  controller: _pickupAddressController,
                  onSelect: (data) {
                    _pickupAddressController.text = data.displayname;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              AppTextField(
                noLabel: true,
                labelText: 'Contact Number',
                hintText: 'Contact Number',
                isPhone: true,
                keyboardType: TextInputType.phone,
                controller: _contactNumberController,
              ),
              const Spacer(),
              Consumer<OrderProvider>(builder: (context, watch, _) {
                return AppButton(
                  text: 'Next',
                  hasIcon: true,
                  textColor: Colors.white,
                  backgroundColor: primaryColor1,
                  onPressed: () async {
                    watch.addAdrressDetails(
                      _houseNoController.text,
                      _pickupAddressController.text,
                      _contactNumberController.text,
                    );
                    if (_formKey.currentState!.validate()) {
                      if (widget.type == 'bulk') {
                        context.router.push(const BulkDeliveryDetailsRoute());
                      } else {
                        context.router.push(const DeliveryDetailsRoute());
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget textField(String hint,
      {bool? isPhone, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              keyboardType:
                  (isPhone == true) ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              validator: (value) =>
                  value!.isEmpty ? '*Field cannot be empty' : null,
            ),
          ),
        ],
      ),
    );
  }
}
