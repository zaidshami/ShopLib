import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../../MainModel.dart';
import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../common/tools/flash.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../modules/sms_login/sms_login.dart';
import '../../services/index.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/flux_image.dart';
import '../../widgets/common/login_animation.dart';
import '../../widgets/common/webview.dart';
import '../base_screen.dart';
import 'forgot_password_screen.dart';

typedef LoginSocialFunction = Future<void> Function({
  required Function(User user) success,
  required Function(String) fail,
  BuildContext context,
});

typedef LoginFunction = Future<void> Function({
  required String username,
  required String password,
  required Function(User user) success,
  required Function(String) fail,
});

class LoginScreen extends StatefulWidget {
  final LoginFunction login;
  final LoginSocialFunction loginFB;
  final LoginSocialFunction loginApple;
  final LoginSocialFunction loginGoogle;
  final VoidCallback? loginSms;

  const LoginScreen({
    required this.login,
    required this.loginFB,
    required this.loginApple,
    required this.loginGoogle,
    this.loginSms,
  });

  @override
  BaseScreen<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends BaseScreen<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();

  late var parentContext;
  bool isLoading = false;
  bool isAvailableApple = false;
  bool isActiveAudio = false;

  AudioManager get audioPlayerService => injector<AudioManager>();

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    if (audioPlayerService.isStickyAudioWidgetActive) {
      isActiveAudio = true;
      audioPlayerService
        ..pause()
        ..hideStickyAudioWidget();
    }
    try {
      isAvailableApple =
          (await TheAppleSignIn.isAvailable()) || ServerConfig().isBuilder;
      setState(() {});
    } catch (e) {
      printLog('[Login] afterFirstLayout error');
    }
  }

  @override
  void dispose() async {
    _loginButtonController.dispose();
    username.dispose();
    password.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  Future _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  Future _welcomeMessage(user) async {
    final canPop = ModalRoute.of(context)!.canPop;
    if (canPop) {
      // When not required login
      Navigator.of(context).pop();
    } else {
      // When required login
      await Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
          .pushReplacementNamed(RouteList.dashboard);
    }
  }

  void _failMessage(String message) {
    if (message.isEmpty) return;

    var messageText = message;
    if (kReleaseMode) {
      messageText = S.of(context).UserNameInCorrect;
    }

    FlashHelper.errorMessage(
      context,
      message: S.of(context).warning(messageText),
    );
  }

  void _loginFacebook(context) async {
    //showLoading();
    await _playAnimation();
    await widget.loginFB(
      success: (user) {
        //hideLoading();
        _stopAnimation();
        _welcomeMessage(user);
      },
      fail: (message) {
        //hideLoading();
        _stopAnimation();
        _failMessage(message);
      },
      context: context,
    );
  }

  void _loginApple(context) async {
    await _playAnimation();
    await widget.loginApple(
        success: (user) {
          _stopAnimation();
          _welcomeMessage(user);
        },
        fail: (message) {
          _stopAnimation();
          _failMessage(message);
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final appModel = Provider.of<AppModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final themeConfig = appModel.themeConfig;

    var forgetPasswordUrl = ServerConfig().forgetPassword;

    Future launchForgetPassworddWebView(String url) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              WebView(url: url, title: S.of(context).resetPassword),
          fullscreenDialog: true,
        ),
      );
    }

    void launchForgetPasswordURL(String? url) async {
      if (url != null && url != '') {
        /// show as webview
        await launchForgetPassworddWebView(url);
      } else {
        /// show as native
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
        );
      }
    }

    void _login(context) async {
      if (username.text.isEmpty || password.text.isEmpty) {
        unawaited(
          FlashHelper.errorMessage(context, message: S.of(context).pleaseInput),
        );
      } else {
        await _playAnimation();
        await widget.login(
          username: username.text.trim(),
          password: password.text.trim(),
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message);
          },
        );
      }
    }

    void _loginSMS(context) {
      if (widget.loginSms != null) {
        widget.loginSms!();
        return;
      }
      final supportedPlatforms = [
        'wcfm',
        'dokan',
        'delivery',
        'vendorAdmin',
        'woo',
        'wordpress'
      ].contains(ServerConfig().typeName);
      if (supportedPlatforms && (kAdvanceConfig.enableNewSMSLogin)) {
        final model = Provider.of<UserModel>(context, listen: false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SMSLoginScreen(
              onSuccess: (user) async {
                await model.setUser(user);
                Navigator.of(context).pop();
                await _welcomeMessage(user);
              },
            ),
          ),
        );
        return;
      }

      if (kAdvanceConfig.enableDigitsMobileLogin) {
        Navigator.of(context).pushNamed(RouteList.digitsMobileLogin);
      } else {
        Navigator.of(context).pushNamed(RouteList.loginSMS);
      }
    }

    void _loginGoogle(context) async {
      await _playAnimation();
      await widget.loginGoogle(
          success: (user) {
            //hideLoading();
            _stopAnimation();
            _welcomeMessage(user);
          },
          fail: (message) {
            //hideLoading();
            _stopAnimation();
            _failMessage(message);
          },
          context: context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: AutoHideKeyboard(
          child: Center(
            child: Consumer<UserModel>(builder: (context, model, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                alignment: Alignment.center,
                width: screenSize.width /
                    (2 / (screenSize.height / screenSize.width)),
                constraints: const BoxConstraints(maxWidth: 700),
                child: AutofillGroup(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child:
                        Center(
                          child: Image.asset(
                            AppParams().mainModel!.appConstants.appLogo,
                            gaplessPlayback: true,
                          //  package: AppParams().mainModel!.appConstants.appPackege,

                            fit: BoxFit.contain,//widget.boxFit,
                            height: 200,
                            width: 250,
                          ),
                        ),
                        // FluxImage(
                        //   imageUrl: themeConfig.logo,
                        //   width: MediaQuery.of(context).size.width * 0.6,
                        //   fit: BoxFit.contain,
                        // ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20.0),
                              CustomTextField(
                                key: const Key('loginEmailField'),
                                controller: username,
                                autofillHints: const [AutofillHints.email],
                                showCancelIcon: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                nextNode: passwordNode,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).username,
                                  hintText: S
                                      .of(parentContext)
                                      .enterYourEmailOrUsername,
                                ),
                              ),
                              CustomTextField(
                                key: const Key('loginPasswordField'),
                                autofillHints: const [AutofillHints.password],
                                obscureText: true,
                                showEyeIcon: true,
                                textInputAction: TextInputAction.done,
                                controller: password,
                                focusNode: passwordNode,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).password,
                                  hintText:
                                      S.of(parentContext).enterYourPassword,
                                ),
                              ),
                              if (kLoginSetting.isResetPasswordSupported)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _loginSMS(context);
                                      // launchForgetPasswordURL(
                                      //     forgetPasswordUrl);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        S.of(context).resetPassword,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (!kLoginSetting.isResetPasswordSupported)
                                const SizedBox(height: 50.0),
                              StaggerAnimation(
                                key: const Key('loginSubmitButton'),
                                titleButton: S.of(context).signInWithEmail,
                                buttonController: _loginButtonController.view
                                    as AnimationController,
                                onTap: () {
                                  if (!isLoading) {
                                    _login(context);
                                  }
                                },
                              ),
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  SizedBox(
                                      height: 50.0,
                                      width: 200.0,
                                      child:
                                          Divider(color: Colors.grey.shade300)),
                                  Container(
                                      height: 30,
                                      width: 40,
                                      color: Theme.of(context).backgroundColor),
                                  if (kLoginSetting.showFacebook ||
                                      kLoginSetting.showSMSLogin ||
                                      kLoginSetting.showGoogleLogin ||
                                      kLoginSetting.showAppleLogin)
                                    Text(
                                      S.of(context).or,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400),
                                    )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  // if (kLoginSetting.showAppleLogin &&
                                  //     isAvailableApple)
                                  //   InkWell(
                                  //     onTap: () => _loginApple(context),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.all(12),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(40),
                                  //         color: Colors.black87,
                                  //       ),
                                  //       child: Image.asset(
                                  //         'assets/icons/logins/apple.png',
                                  //         width: 26,
                                  //         height: 26,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // if (kLoginSetting.showFacebook)
                                  //   InkWell(
                                  //     onTap: () => _loginFacebook(context),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.all(8),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(40),
                                  //         color: const Color(0xFF4267B2),
                                  //       ),
                                  //       child: const Icon(
                                  //         Icons.facebook_rounded,
                                  //         color: Colors.white,
                                  //         size: 34.0,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // if (kLoginSetting.showGoogleLogin)
                                  //   InkWell(
                                  //     onTap: () => _loginGoogle(context),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.all(12),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(40),
                                  //         color: Colors.grey.shade300,
                                  //       ),
                                  //       child: Image.asset(
                                  //         'assets/icons/logins/google.png',
                                  //         width: 28,
                                  //         height: 28,
                                  //       ),
                                  //     ),
                                  //   ),
                                  if (kLoginSetting.showSMSLogin)
                                    InkWell(
                                      onTap: () => _loginSMS(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: Colors.lightBlue.shade50,
                                        ),
                                        child: FluxImage(
                                          imageUrl: 'assets/icons/logins/sms.png',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 30.0),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(S.of(context).dontHaveAccount),
                                      GestureDetector(
                                        onTap: () {
                                          NavigateTools.navigateRegister(
                                              context);
                                        },
                                        child: Text(
                                          ' ${S.of(context).signup}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Container(
          padding: const EdgeInsets.all(50.0),
          child: kLoadingWidget(context),
        ));
      },
    );
  }

  void hideLoading() {
    Navigator.of(context).pop();
  }
}
