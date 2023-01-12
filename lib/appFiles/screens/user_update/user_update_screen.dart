import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/widgets/auto_hide_keyboard.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_base.dart';
import '../../models/user_model.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/loading_body.dart';
import '../base_screen.dart';
import '../common/delete_account_mixin.dart';
import '../settings/settings_screen.dart';
import '../users/delete_account_screen.dart';

class UserUpdateScreen extends StatefulWidget {
  @override
  BaseScreen<UserUpdateScreen> createState() => _StateUserUpdate();
}

class _StateUserUpdate extends BaseScreen<UserUpdateScreen>  with DeleteAccountMixin{
  TextEditingController? userEmail;
  TextEditingController? userPassword;
  TextEditingController? userDisplayName;
  late TextEditingController userNiceName;
  late TextEditingController userUrl;
  TextEditingController? currentPassword;

  TextEditingController? userFirstname;
  TextEditingController? userLastname;

  String? avatar;
  bool isLoading = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool isValidPassword() => userPassword!.text.length >= 8;

  bool get hasChangePassword => isValidPassword();

  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    setState(() {
      userEmail = TextEditingController(text: user!.email);
      userPassword = TextEditingController(text: '');
      currentPassword = TextEditingController(text: '');
      userDisplayName = TextEditingController(text: user.name);
      userNiceName = TextEditingController(text: user.telephone);
      userFirstname = TextEditingController(text: user.firstName);
      userLastname = TextEditingController(text: user.lastName);
      userUrl = TextEditingController(text: user.userUrl);
      avatar = user.picture;
    });
  }

  void updateUserInfo() {
    if (userPassword!.text.isNotEmpty && !isValidPassword()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorPasswordFormat),
        ),
      );
      return;
    }

    final user = Provider.of<UserModel>(context, listen: false).user;
    setState(() {
      isLoading = true;
    });
    Services().widget.updateUserInfo(
          loggedInUser: user,
          onError: (e) {
            _scaffoldMessengerKey.currentState
                ?.showSnackBar(SnackBar(content: Text(e)));
            setState(() {
              isLoading = false;
            });
          },
          onSuccess: (user) {
            Provider.of<UserModel>(context, listen: false).updateUser(user);
            setState(() {
              isLoading = false;
            });

            /// If update password, need to pop true to force user log-out and
            /// login again to make effect
            Navigator.of(context).pop(hasChangePassword);
          },
          currentPassword: currentPassword!.text,
          userDisplayName: userDisplayName!.text,
          userEmail: userEmail!.text,
          userNiceName: userNiceName.text,
          userUrl: userUrl.text,
          userPassword: userPassword!.text,
          userFirstname: userFirstname?.text,
          userLastname: userLastname?.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user!;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: AutoHideKeyboard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.elliptical(100, 10),
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 8)
                          ]),
                      child: (avatar?.isNotEmpty ?? false)
                          ? Image.network(
                              avatar!,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: Theme.of(context).primaryColorLight),
                        child: (avatar?.isNotEmpty ?? false)
                            ? Image.network(
                                avatar!,
                                width: 150,
                                height: 150,
                              )
                            : const Icon(
                                Icons.person,
                                size: 120,
                              ),
                      ),
                    ),

                    SafeArea(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(left: 10),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final acceptDelete =
                              await showConfirmDeleteAccountDialog(
                                App.fluxStoreNavigatorKey.currentContext ?? context,
                              );
                              if (acceptDelete) {
                                _processDeleteAccount();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(left: 10),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // SafeArea(
                    //   child: GestureDetector(
                    //     onTap: () async {
                    //       final acceptDelete =
                    //           await showConfirmDeleteAccountDialog(
                    //         App.fluxStoreNavigatorKey.currentContext ?? context,
                    //       );
                    //       if (acceptDelete) {
                    //         _processDeleteAccount();
                    //       }
                    //     },
                    //     child: Container(
                    //       padding: const EdgeInsets.all(10),
                    //       margin: const EdgeInsets.only(left: 10),
                    //       child: const Icon(
                    //         Icons.delete,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              Expanded(
                child: LoadingBody(
                  isLoading: isLoading,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(height: 8),
                                    Text(
                                      S.of(context).email,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: userEmail,
                                        enabled: !user.isSocial!,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      S.of(context).name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                        controller: userDisplayName,
                                        enabled: ServerConfig().type !=
                                            ConfigType.magento,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const SizedBox(height: 16),
                                    Services()
                                        .widget
                                        .renderCurrentPassInputforEditProfile(
                                          context: context,
                                          currentPasswordController:
                                              currentPassword,
                                        ),
                                    if (!user.isSocial!)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[

                                          const SizedBox(height: 8),
                                          ExpandablePanel(
                                            theme: ExpandableThemeData(iconColor: Colors.white),
                                            header:Text(
                                              S.of(context).updatePassword,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                            collapsed: Text("",),
                                            expanded:Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: TextField(
                                                obscureText: true,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                controller: userPassword,
                                              ),
                                            ),

                                            // tapHeaderToExpand: true,
                                            // hasIcon: true,
                                          ),

                                        ],
                                      ),
                                    const SizedBox(height: 50),
                                    Container(
                                        height: 30,
                                        child: buildButtonUpdate()),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // if (user != null &&
                      //     kAdvanceConfig.gdprConfig.showDeleteAccount &&
                      //     ServerConfig().isSupportDeleteAccount)
                      //   Padding(
                      //     padding:
                      //     const EdgeInsets.symmetric(horizontal: itemPadding),
                      //     child: SettingItem(
                      //       iconWidget: const Icon(
                      //         CupertinoIcons.delete,
                      //         color: kColorRed,
                      //         size: 22,
                      //       ),
                      //       titleWidget: Text(
                      //         S.current.deleteAccount,
                      //         style: const TextStyle(color: kColorRed),
                      //       ),
                      //       onTap: () async {
                      //         final acceptDelete =
                      //         await showConfirmDeleteAccountDialog(
                      //           App.fluxStoreNavigatorKey.currentContext ?? context,
                      //         );
                      //         if (acceptDelete) {
                      //           _processDeleteAccount();
                      //         }
                      //       },
                      //     ),
                      //   ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _processDeleteAccount() async {
    final result = await FluxNavigate.pushNamed(
      RouteList.deleteAccount,
      arguments: DeleteAccountArguments(
        confirmCaptcha: kAdvanceConfig.gdprConfig.confirmCaptcha,
        userToken:
        Provider.of<UserModel>(context, listen: false).user?.cookie ?? '',
      ),
    ) as bool?;
    if (result ?? false) {
      _deleteUserOnFirebase();
      _onLogout();
    }
  }
  void _deleteUserOnFirebase() {
    Services().firebase.deleteAccount();
  }
  void _onLogout() {
    Provider.of<CartModel>(context, listen: false).clearAddress();
    Provider.of<UserModel>(context, listen: false).logout();
    if (Services().widget.isRequiredLogin) {
      Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
          .pushNamedAndRemoveUntil(
        RouteList.login,
            (route) => false,
      );
    }
  }
  List<Widget> buildDisplayName() {
    return [
      Text(S.of(context).displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
                color: Theme.of(context).primaryColorLight, width: 1.5)),
        child: TextField(
            decoration: const InputDecoration(border: InputBorder.none),
            controller: userDisplayName,
            enabled: ServerConfig().type != ConfigType.magento),
      ),
    ];
  }

  List<Widget> buildEnterNameOfUser() {
    return [
      Text(S.of(context).firstName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
                color: Theme.of(context).primaryColorLight, width: 1.5)),
        child: TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          controller: userFirstname,
        ),
      ),
      Text(S.of(context).lastName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
                color: Theme.of(context).primaryColorLight, width: 1.5)),
        child: TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          controller: userLastname,
        ),
      )
    ];
  }

  Widget buildButtonUpdate() {
    return  Row(
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
              onPressed:updateUserInfo,
              child: Text(
                S.of(context).update,
              ),
            ),
          ),
        ),
      ],
    );

    //   TextButton(
    //   style: TextButton.styleFrom(
    //     primary: Theme.of(context).primaryColor,
    //   ),
    //   onPressed: updateUserInfo,
    //   child: SafeArea(
    //     top: false,
    //     child: Container(
    //       padding: const EdgeInsets.symmetric(vertical: 12),
    //       child: SizedBox(
    //         height: 20,
    //         width: 100,
    //         child: Center(
    //           child: Text(
    //             S.of(context).update,
    //             style: TextStyle(
    //               fontSize: 18,
    //               fontWeight: FontWeight.w600,
    //               color: Theme.of(context).primaryColor,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
