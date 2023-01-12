import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../../unicomapps.dart';
import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Address, AppModel, CartModel, Country, ShippingMethodModel, UserModel;
import '../../../models/order_type/LocalOrder.dart';
import '../../../models/order_type/LocalOrderMethod/Mahaly.dart';
import '../../../models/order_type/LocalOrderMethod/Safary.dart';
import '../../../services/index.dart';
import '../../../widgets/common/common_safe_area.dart';
import '../../../widgets/common/flux_image.dart';
import '../../../widgets/common/place_picker.dart';
import '../choose_address_screen.dart';


enum SingingCharacter { mahaly, safary }

class LocalAddressScreen extends StatefulWidget {
  final Function? onNext;

  const LocalAddressScreen({this.onNext});

  @override
  State<LocalAddressScreen> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<LocalAddressScreen> {
  final _formKey = GlobalKey<FormState>();


  final _lastNameNode = FocusNode();
  final _phoneNode = FocusNode();
bool is_loaded=true;
  SingingCharacter? _character = SingingCharacter.mahaly;

  Address? address;
  List<Country>? countries = [];
  List<dynamic> states = [];
  final TextEditingController _tableNumber = TextEditingController();
  final __tableNumberNode = FocusNode();

  void huh(String val){
    if(val=="محلي"){
      _character= SingingCharacter.mahaly;
    }if(val=="سفري"){
      _character= SingingCharacter.safary;

    }
  }
  @override
  void dispose() {


    _lastNameNode.dispose();
    _phoneNode.dispose();


    super.dispose();
  }

  @override
  void initState() {

    super.initState();
    _locOrder.setLocalOrderMethod(Mahaly());

    Future.delayed(
      Duration.zero,
          () async {
        //  await   get_ship_methods();

            final addressValue =
        await Provider.of<CartModel>(context, listen: false).getAddress();
        // ignore: unnecessary_null_comparison
        if (addressValue != null) {
          setState(() {
            address = addressValue;
            _setuserData();
            huh(address!.block!);

          });
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig.defaultCountryISOCode);
            if (kPaymentConfig.defaultStateISOCode != null) {
              address!.state = kPaymentConfig.defaultStateISOCode;
            }

            if (user != null) {
              address!.firstName = user.firstName;
              address!.lastName = user.lastName;
              address!.email = user.email;
              address!.phoneNumber = user.telephone;


            }
          });
        }
        print("zzzz "+address!.country!);
        countries = await Services().widget.newloadCountries();
        var country = countries!.firstWhereOrNull((element) =>
        //    element.id == address!.country || element.code == address!.country
        element.id=="184"
        );
        if (country == null) {
          if (countries!.isNotEmpty) {
            print("111111");
            country = countries![0];
            address!.country = countries![0].code;
          } else {
            print("111111 222222");

            country = Country.fromConfig(address!.country, null, null, []);
          }
        } else {
          print("111111 3333333");

          address!.country = country.code;
          address!.countryId = country.id;
        }
        if (mounted) {
          setState(() {});
        }
        print("111111 4444444");

        states = await Services().widget.loadStates(country);
        if (mounted) {
          setState(() {});
        }
        print("111111 5555555");

      },
    );
  }

 Future<void> get_ship_methods() async {
   print("za 1");

   await  _loadShipping(beforehand: true).then((value) {

      setState(() {
        print("za 2");

        is_loaded=true;
      });
    });
   print("za 3");

 }


  bool checkToSave() {
    final storage = LocalStorage(LocalStorageKey.address);
    var listAddress = <Address>[];
    try {
      var data = storage.getItem('data');
      if (data != null) {
        for (var item in (data as List)) {
          final add = Address.fromLocalJson(item);
          listAddress.add(add);
        }
      }
      for (var local in listAddress) {

        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).yourAddressExistYourLocal),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
        );
        return false;
      }
    } catch (err) {
      printLog(err);
    }
    return true;
  }

  void _setuserData(){
    var user = Provider.of<UserModel>(context, listen: false).user;
      if (user != null) {
        address!.firstName = user.firstName;
        address!.lastName = user.lastName;
        address!.phoneNumber = user.telephone;


      }

  }
  Future<void> saveDataToLocal() async {
    final storage = LocalStorage(LocalStorageKey.address);
    var listAddress = <Address?>[];
    listAddress.add(address);
    try {
      final ready = await storage.ready;
      if (ready) {
        var data = storage.getItem('data');
        if (data != null) {
          var listData = data as List;
          for (var item in listData) {
            final add = Address.fromLocalJson(item);
            listAddress.add(add);
          }
        }
        await storage.setItem(
            'data',
            listAddress.map((item) {
              return item!.toJsonEncodable();
            }).toList());
        await showDialog(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
        );
      }
    } catch (err) {
      printLog(err);
    }
  }
  LocalOrder get _locOrder=>orderMethod as LocalOrder;
  String? validateEmail(String email) {
    if (email.isEmail) {
      return null;
    }
    return 'The E-mail Address must be a valid email address.';
  }

  @override
  Widget build(BuildContext context) {

if(!is_loaded){
  return SizedBox(height: 100, child: kLoadingWidget(context));


}
    if (address == null) {
      return SizedBox(height: 100, child: kLoadingWidget(context));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      TextFormField(
                        autocorrect: false,
                        initialValue: address!.firstName,
                        autofillHints: const [AutofillHints.givenName],
                        decoration:
                        InputDecoration(labelText: S.of(context).firstName),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          return val!.isEmpty
                              ? S.of(context).firstNameIsRequired
                              : null;
                        },
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_lastNameNode),
                        onSaved: (String? value) {
                          address!.firstName = value;
                        },
                      ),
                      TextFormField(
                        autocorrect: false,
                        initialValue: address!.lastName,
                        autofillHints: const [AutofillHints.familyName],
                        focusNode: _lastNameNode,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          return val!.isEmpty
                              ? S.of(context).lastNameIsRequired
                              : null;
                        },
                        decoration:
                        InputDecoration(labelText: S.of(context).lastName),
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_phoneNode),
                        onSaved: (String? value) {
                          address!.lastName = value;
                        },
                      ),
                      TextFormField(
                        autocorrect: false,
                        initialValue: address!.phoneNumber,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        focusNode: _phoneNode,
                        decoration: InputDecoration(
                          labelText: S.of(context).phoneNumber,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          return val!.isEmpty
                              ? S.of(context).phoneIsRequired
                              : null;
                        },
                        keyboardType: TextInputType.number,
                        // onFieldSubmitted: (_) =>
                        //     FocusScope.of(context).requestFocus(),
                        onSaved: (String? value) {
                          address!.phoneNumber = value;
                        },
                      ),
                      Row(children: [

                        Expanded(
                          child: ListTile(
                            title: const Text('محلي'),
                            leading: Radio<SingingCharacter>(
                              value: SingingCharacter.mahaly,
                              groupValue: _character,
                              onChanged: (SingingCharacter? value) {
                                Provider.of<CartModel>(context, listen: false).address!.block="محلي";
                                setState(() {

                                  _character = value;
                                  _locOrder.setLocalOrderMethod(Mahaly());
                                });
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          child: ListTile(
                            title: const Text('سفري'),
                            leading: Radio<SingingCharacter>(
                              value: SingingCharacter.safary,
                              groupValue: _character,
                              onChanged: (SingingCharacter? value) {
                                Provider.of<CartModel>(context, listen: false).address!.block="سفري";
                                Provider.of<CartModel>(context, listen: false).address!.city="";
                                setState(() {
                                  _character = value;
                                  _locOrder.setLocalOrderMethod(Safary());

                                });
                              },
                            ),
                          ),
                        ),

                      ],),
                      _character== SingingCharacter.mahaly? TextFormField(
                        autocorrect: false,
                        initialValue:address!.city,
                        autofillHints: const ["رقم الطاولة"],
                        focusNode: __tableNumberNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText:"رقم الطاولة",),
                        textInputAction: TextInputAction.done,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return S.of(context).TableNumberRequired;
                          }
                          try{
                            int.parse(val);
                            return null;
                          }catch(k){
                            return "يرجى ادخال رقم الطاولة بالارقام ";

                          }

                          return null;
                          //return validateEmail(val);
                        },
                        onSaved: (String? value) {

                          _tableNumber.text=value!;
                          (orderMethod.localOrderMethod as Mahaly).setTableNumber(value);
                        //  address!.email = value;
                        },
                      ):const SizedBox(),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(

                          S.of(context).forrewardpoints,
                          style:const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // if (kPaymentConfig.allowSearchingAddress &&
                      //     kGoogleApiKey.isNotEmpty)
                      //   Row(
                      //     children: [
                      //       Expanded(
                      //         child: ButtonTheme(
                      //           height: 60,
                      //           child: ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               elevation: 0.0,
                      //               onPrimary:
                      //               Theme.of(context).colorScheme.secondary,
                      //               primary:
                      //               Theme.of(context).primaryColorLight,
                      //             ),
                      //             onPressed: () async {
                      //               final result =
                      //               await Navigator.of(context).push(
                      //                 MaterialPageRoute(
                      //                   builder: (context) => PlacePicker(
                      //                     kIsWeb
                      //                         ? kGoogleApiKey.web
                      //                         : isIos
                      //                         ? kGoogleApiKey.ios
                      //                         : kGoogleApiKey.android,
                      //                   ),
                      //                 ),
                      //               );
                      //
                      //               if (result is LocationResult) {
                      //                 address!.country = result.country;
                      //                 address!.street = result.street;
                      //                 address!.state = result.state;
                      //                 address!.city = result.city;
                      //                 address!.zipCode = result.zip;
                      //                 if (result.latLng?.latitude != null &&
                      //                     result.latLng?.latitude != null) {
                      //                   address!.mapUrl =
                      //                   'https://maps.google.com/maps?q=${result.latLng?.latitude},${result.latLng?.longitude}&output=embed';
                      //                   address!.latitude =
                      //                       result.latLng?.latitude.toString();
                      //                   address!.longitude =
                      //                       result.latLng?.longitude.toString();
                      //                 }
                      //
                      //                 setState(() {
                      //                   _cityController.text =
                      //                       address!.city ?? '';
                      //                   _stateController.text =
                      //                       address!.state ?? '';
                      //                   _streetController.text =
                      //                       address!.street ?? '';
                      //                   _zipController.text =
                      //                       address!.zipCode ?? '';
                      //                   _countryController.text =
                      //                       address!.country ?? '';
                      //                 });
                      //                 final c = Country(
                      //                     id: result.country,
                      //                     name: result.country);
                      //                 states =
                      //                 await Services().widget.loadStates(c);
                      //                 setState(() {});
                      //               }
                      //             },
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: <Widget>[
                      //                 const Icon(
                      //                   CupertinoIcons.arrow_up_right_diamond,
                      //                   size: 18,
                      //                 ),
                      //                 const SizedBox(width: 10.0),
                      //                 Text(S
                      //                     .of(context)
                      //                     .searchingAddress
                      //                     .toUpperCase()),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // const SizedBox(height: 10),
                      // ButtonTheme(
                      //   height: 60,
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       elevation: 0.0,
                      //       onPrimary: Theme.of(context).colorScheme.secondary,
                      //       primary: Theme.of(context).primaryColorLight,
                      //     ),
                      //     onPressed: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) =>
                      //               ChooseAddressScreen(updateState),
                      //         ),
                      //       );
                      //     },
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: <Widget>[
                      //         const Icon(
                      //           CupertinoIcons.person_crop_square,
                      //           size: 16,
                      //         ),
                      //         const SizedBox(width: 10.0),
                      //         Text(
                      //           S.of(context).selectAddress.toUpperCase(),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      // Text(
                      //   S.of(context).country,
                      //   style: const TextStyle(
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.w300,
                      //       color: Colors.grey),
                      // ),
                      // (countries!.length == 1)
                      //     ? Text(
                      //   picker.CountryPickerUtils.getCountryByIsoCode(
                      //       countries![0].code!)
                      //       .name,
                      //   style: const TextStyle(fontSize: 18),
                      // )
                      //     : GestureDetector(
                      //   onTap: _openCountryPickerDialog,
                      //   child: Column(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             vertical: 20),
                      //         child: Row(
                      //           crossAxisAlignment:
                      //           CrossAxisAlignment.center,
                      //           mainAxisAlignment:
                      //           MainAxisAlignment.spaceBetween,
                      //           children: <Widget>[
                      //             Expanded(
                      //               child: Text("countryName",
                      //                   style: const TextStyle(
                      //                       fontSize: 17.0)),
                      //             ),
                      //             const Icon(Icons.arrow_drop_down)
                      //           ],
                      //         ),
                      //       ),
                      //       const Divider(
                      //         height: 1,
                      //         color: kGrey900,
                      //       )
                      //     ],
                      //   ),
                      // ),
                    //  renderStateInput(),
                      // TextFormField(
                      //   autocorrect: false,
                      //   controller: _cityController,
                      //   autofillHints: const [AutofillHints.addressCity],
                      //   focusNode: _cityNode,
                      //   validator: (val) {
                      //     return val!.isEmpty
                      //         ? S.of(context).cityIsRequired
                      //         : null;
                      //   },
                      //   decoration:
                      //   InputDecoration(labelText: S.of(context).city),
                      //   textInputAction: TextInputAction.next,
                      //   onFieldSubmitted: (_) =>
                      //       FocusScope.of(context).requestFocus(_apartmentNode),
                      //   onSaved: (String? value) {
                      //     address!.city = value;
                      //   },
                      // ),
                      // TextFormField(
                      //   autocorrect: false,
                      //   controller: _apartmentController,
                      //   focusNode: _apartmentNode,
                      //   validator: (val) {
                      //     return null;
                      //   },
                      //   decoration: InputDecoration(
                      //       labelText: S.of(context).streetNameApartment),
                      //   textInputAction: TextInputAction.next,
                      //   onFieldSubmitted: (_) =>
                      //       FocusScope.of(context).requestFocus(_blockNode),
                      //   onSaved: (String? value) {
                      //     address!.apartment = value;
                      //   },
                      // ),
                      // TextFormField(
                      //   autocorrect: false,
                      //   controller: _blockController,
                      //   focusNode: _blockNode,
                      //   validator: (val) {
                      //     return null;
                      //   },
                      //   decoration: InputDecoration(
                      //       labelText: S.of(context).streetNameBlock),
                      //   textInputAction: TextInputAction.next,
                      //   onFieldSubmitted: (_) =>
                      //       FocusScope.of(context).requestFocus(_streetNode),
                      //   onSaved: (String? value) {
                      //     address!.block = value;
                      //   },
                      // ),
                      // TextFormField(
                      //   autocorrect: false,
                      //   controller: _streetController,
                      //   autofillHints: const [AutofillHints.fullStreetAddress],
                      //   focusNode: _streetNode,
                      //   validator: (val) {
                      //     return val!.isEmpty
                      //         ? S.of(context).streetIsRequired
                      //         : null;
                      //   },
                      //   decoration: InputDecoration(
                      //       labelText: S.of(context).streetName),
                      //   textInputAction: TextInputAction.next,
                      //   onFieldSubmitted: (_) =>
                      //       FocusScope.of(context).requestFocus(_zipNode),
                      //   onSaved: (String? value) {
                      //     address!.street = value;
                      //   },
                      // ),
                      // TextFormField(
                      //   autocorrect: false,
                      //   controller: _zipController,
                      //   autofillHints: const [AutofillHints.postalCode],
                      //   focusNode: _zipNode,
                      //   validator: (val) {
                      //     return val!.isEmpty
                      //         ? S.of(context).zipCodeIsRequired
                      //         : null;
                      //   },
                      //   keyboardType: kPaymentConfig.enableAlphanumericZipCode
                      //       ? TextInputType.text
                      //       : TextInputType.number,
                      //   textInputAction: TextInputAction.done,
                      //   decoration:
                      //   InputDecoration(labelText: S.of(context).zipCode),
                      //   onSaved: (String? value) {
                      //     address!.zipCode = value;
                      //   },
                      // ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildBottom(),
      ],
    );
  }

  Widget _buildBottom() {
    return CommonSafeArea(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () {
                if (!checkToSave()) return;
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Provider.of<CartModel>(context, listen: false)
                  //     .setAddress(address);
                  // saveDataToLocal();
                }
              },
              icon: const Icon(
                CupertinoIcons.plus_app,
                size: 20,
              ),
              label: Text(
                S.of(context).saveAddress.toUpperCase(),
                style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          Container(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                onPrimary: Colors.white,
                primary: Theme.of(context).primaryColor,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(
                Icons.local_shipping_outlined,
                size: 18,
              ),
              onPressed: _onNext,
              label: Text(
                (kPaymentConfig.enableShipping
                    ? S.of(context).continueToShipping
                    : kPaymentConfig.enableReview
                    ? S.of(context).continueToReview
                    : S.of(context).continueToPayment)
                    .toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Load Shipping beforehand
  Future<void> _loadShipping({bool beforehand = true}) async {
   await  Services().widget.loadShippingMethods(
        context, Provider.of<CartModel>(context, listen: false), beforehand);
  }

  /// on tap to Next Button
  Future<void> _onNext() async {
    {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
          jij();

        await  _loadShipping(beforehand: false);
        widget.onNext!();








      //  ShippingMethodModel?  shippingMethodModel = Provider.of<ShippingMethodModel>(context, listen: false);
      //  await _loadShipping();
      //  Provider.of<CartModel>(context, listen: false).setShippingMethod(shippingMethodModel.shippingMethods![0]);
       // print("fffff "+Provider.of<ShippingMethodModel>(context, listen: false).shippingMethods!.length.toString());
       // widget.onNext!();
      }
    }
  }

   jij()  {

    Provider.of<CartModel>(context, listen: false).address!.firstName= address!.firstName ;
    Provider.of<CartModel>(context, listen: false).address!.email="Guest@gmail.com";
    Provider.of<CartModel>(context, listen: false).address!.lastName= address!.lastName ;
    Provider.of<CartModel>(context, listen: false).address!.phoneNumber=address!.phoneNumber;
    _character == SingingCharacter.mahaly?
    Provider.of<CartModel>(context, listen: false).address!.city=_tableNumber.text:"";


   }

  Widget renderStateInput() {
    if (states.isNotEmpty) {
      var items = <DropdownMenuItem>[];
      for (var item in states) {
        items.add(
          DropdownMenuItem(
            value: item.id,
            child: Text(item.name),
          ),
        );
      }
      String? value;

      Object? firstState = states.firstWhereOrNull(
              (o) => o.id.toString() == address!.state.toString());

      if (firstState != null) {
        value = address!.state;
      }
      return DropdownButton(
        items: items,
        value: value,
        onChanged: (dynamic val) {
          setState(() {
            address!.state = val;
          });
        },
        isExpanded: true,
        itemHeight: 70,
        hint: Text(S.of(context).stateProvince),
      );
    } else {
      return TextFormField(
        autocorrect: false,
       // controller: _stateController,
        autofillHints: const [AutofillHints.addressState],
        validator: (val) {
          return val!.isEmpty ? S.of(context).streetIsRequired : null;
        },
        decoration: InputDecoration(labelText: S.of(context).stateProvince),
        onSaved: (String? value) {
          address!.state = value;
        },
      );
    }
  }

  void _openCountryPickerDialog() => showDialog(
    context: context,
    useRootNavigator: false,
    builder: (contextBuilder) => countries!.isEmpty
        ? Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.pink),
      child: SizedBox(
        height: 500,
        child: picker.CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          contentPadding: const EdgeInsets.all(2.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration:
          const InputDecoration(hintText: 'Search...'),
          isSearchable: true,
          title: Text(S.of(context).country),
          onValuePicked: (picker_country.Country country) async {
           // _countryController.text = country.isoCode;
            address!.country = country.isoCode;
            if (mounted) {
              setState(() {});
            }
            final c =
            Country(id: country.isoCode, name: country.name);
            states = await Services().widget.loadStates(c);
            if (mounted) {
              setState(() {});
            }
          },
          itemBuilder: (country) {
            return Row(
              children: <Widget>[
                picker.CountryPickerUtils.getDefaultFlagImage(
                    country),
                const SizedBox(width: 8.0),
                Expanded(child: Text(country.name)),
              ],
            );
          },
        ),
      ),
    )
        : Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            countries!.length,
                (index) {
              return GestureDetector(
                onTap: () async {
                  setState(() {
                  //  _countryController.text = countries![index].code!;
                    address!.country = countries![index].id;
                    address!.countryId = countries![index].id;
                  });
                  Navigator.pop(contextBuilder);
                  states = await Services()
                      .widget
                      .loadStates(countries![index]);
                  setState(() {});
                },
                child: ListTile(
                  leading: countries![index].icon != null
                      ? SizedBox(
                    height: 40,
                    width: 60,
                    child: FluxImage(
                      imageUrl: countries![index].icon!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : (countries![index].code != null
                      ? Image.asset(
                    picker.CountryPickerUtils
                        .getFlagImageAssetPath(
                        countries![index].code!),
                    height: 40,
                    width: 60,
                    fit: BoxFit.fill,
                    package: 'country_pickers',
                  )
                      : const SizedBox(
                    height: 40,
                    width: 60,
                    child: Icon(Icons.streetview),
                  )),
                  title: Text(countries![index].name!),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
