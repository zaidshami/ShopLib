import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../MainModel.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../widgets/OtpWidgets.dart';
import '../../widgets/common/flux_image.dart';
import '../../widgets/common/login_animation.dart';
import '../users/registration_screen.dart';
import 'login_sms_viewmodel.dart';
import 'verify.dart';

class LoginSMSScreen extends StatefulWidget {
  const LoginSMSScreen();

  @override
  LoginSMSScreenState createState() => LoginSMSScreenState();
}

class LoginSMSScreenState<T extends LoginSMSScreen> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController _controller = TextEditingController(text: '');

  LoginSmsViewModel get viewModel => context.read<LoginSmsViewModel>();

  void _initScreen() {
    viewModel.loadConfig(
      code: LoginSMSConstants.countryCodeDefault,
      dialCode: LoginSMSConstants.dialCodeDefault,
      name: LoginSMSConstants.nameDefault,
    );

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.text != '') {
        viewModel.updatePhone(_controller.text);
      }
    });
  }

  void loginSMS(context) {
    if (viewModel.phoneNumber.isEmpty) {
      Tools.showSnackBar(
          ScaffoldMessenger.of(context), S.of(context).pleaseInput);
    } else {
      Future autoRetrieve(String verId) {
        return stopAnimation();
      }

      Future smsCodeSent(String verId, [int? forceCodeResend]) {
        stopAnimation();
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCode(
              verId: verId,
              phoneNumber: viewModel.phoneFullText,
              verifySuccessStream: viewModel.getStreamSuccess,
              resendToken: forceCodeResend,
            ),
          ),
        );
      }

      void verifyFailed(exception) {
        stopAnimation();
        failMessage(exception.message, context);
      }

      viewModel.verify(
        autoRetrieve: autoRetrieve,
        smsCodeSent: smsCodeSent,
        verifyFailed: verifyFailed,
        startVerify: playAnimation,
      );
    }
  }

  Future<void> _signInWithCredential(context) async {

    if (1==1) {
      await Provider.of<UserModel>(context, listen: false).loginFirebaseSMS(
        phoneNumber: _controller.text.trim().replaceAll('+', ''),
        success: (user) {
          print("yyyyyyy");
         // _stopAnimation();
          NavigateTools.navigateAfterLogin(user, context);
        },
        fail: (message) {
          print("rrrrrrrrr");

          failMessage("المستخدم غير موجود", context);

          // _stopAnimation();
          // _failMessage(message, context);
        },
        context: context
      );
    } else {
      // await _stopAnimation();
      // _failMessage(S.of(context).invalidSMSCode, context);
    }
  }

  void _onTapBackButton() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamed(RouteList.home);
    }
  }

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);
    final themeConfig = appModel.themeConfig;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onTapBackButton,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Consumer<LoginSmsViewModel>(
          builder: (context, viewmodel, child) {
            return Builder(
              builder: (context) => Stack(
                children: [
                  ListenableProvider.value(
                    value: Provider.of<UserModel>(context),
                    child: Consumer<UserModel>(
                      builder: (context, model, child) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 80.0),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Image.asset(
                                          AppParams().mainModel!.appConstants.appLogo,
                                          gaplessPlayback: true,
                                      //   package: AppParams().mainModel!.appConstants.appPackege,

                                          fit: BoxFit.contain,//widget.boxFit,
                                          height: 200,
                                          width: 250,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 120.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CountryCodePicker(
                                    onChanged: (CountryCode? countryCode) =>
                                        viewModel.updateCountryCode(
                                      code: countryCode?.code,
                                      dialCode: countryCode?.dialCode,
                                      name: countryCode?.name,
                                    ),
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: viewModel.countryCode,

                                    //Get the country information relevant to the initial selection
                                    onInit: (countryCode) =>
                                        viewModel.loadConfig(
                                      code: countryCode?.code,
                                      dialCode: countryCode?.dialCode,
                                      name: countryCode?.name,
                                    ),
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    dialogBackgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                          labelText: S.of(context).phone),
                                      keyboardType: TextInputType.phone,
                                      controller: _controller,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 60),
                              StaggerAnimation(
                                titleButton: S.of(context).sendSMSCode,
                                buttonController: _loginButtonController.view
                                    as AnimationController,
                                onTap: () {
                                  show_otp_dialog(context,_controller.text.trim(),() async {
                                    _signInWithCredential(context);
                                  });
                                }//=> loginSMS(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future playAnimation() async {
    try {
      viewModel.enableLoading();
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      viewModel.enableLoading(false);
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  void failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('⚠️: $message'),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
