//
//
// initapp22(MainModel mainModel)async {
//
//   AppParams().setMainModel(mainModel);
// }
// Future<Widget> initapp(MainModel mainModel)async {
//   AppParams().setMainModel(mainModel);
//
//   Widget iiiii=SizedBox();
//   String errottext="";
//   printLog('[main] ===== START main.dart =======');
//   Configurations().setConfigurationValues(environment);
//
//   /// Fix issue android sdk version 22 can not run the app.
//   if (UniversalPlatform.isAndroid) {
//     SecurityContext.defaultContext
//         .setTrustedCertificatesBytes(Uint8List.fromList(isrgRootX1.codeUnits));
//   }
//
//   /// Support Webview (iframe) for Flutter Web. Requires this below header.
//   /// Content-Security-Policy: frame-ancestors 'self' *.yourdomain.com
//   registerWebViewWebImplementation();
//
//   /// Update status bar color on Android
//   if (isMobile) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.black,
//     ));
//   }
//
//   Provider.debugCheckInvalidValueType = null;
//   var languageCode = kAdvanceConfig.defaultLanguage;
//
//   LicenseRegistry.addLicense(() async* {
//     final license = await rootBundle.loadString('google_fonts/OFL.txt');
//     yield LicenseEntryWithLineBreaks(['google_fonts'], license);
//   });
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//
//
//   printLog('🔴 isssss before page');
//
//   await   runZonedGuarded(() async {
//     if (!foundation.kIsWeb) {
//       /// Enable network traffic logging.
//       HttpClient.enableTimelineLogging = !foundation.kReleaseMode;
//
//       /// Lock portrait mode.
//       unawaited(SystemChrome.setPreferredOrientations(
//           [DeviceOrientation.portraitUp]));
//     }
//
//     await GmsCheck().checkGmsAvailability(enableLog: foundation.kDebugMode);
//     try {
//       if (isMobile) {
//         /// Init Firebase settings due to version 0.5.0+ requires to.
//         /// Use await to prevent any usage until the initialization is completed.
//         await Services().firebase.init();
//         await Configurations().loadRemoteConfig();
//       }
//     } catch (e) {
//       printLog(e);
//       printLog('🔴 Firebase init issue');
//     }
//
//     await DependencyInjection.inject();
//     Services().setAppConfig(serverConfig);
//     if (isMobile && kAdvanceConfig.autoDetectLanguage) {
//       final lang = injector<SharedPreferences>().getString('language');
//
//       if (lang?.isEmpty ?? true) {
//         languageCode = await LocaleService().getDeviceLanguage();
//       } else {
//         languageCode = lang.toString();
//       }
//     }
//     ResponsiveSizingConfig.instance.setCustomBreakpoints(
//         const ScreenBreakpoints(desktop: 900, tablet: 600, watch: 100));
//     iiiii= App(languageCode: languageCode,mainModel:mainModel ,);
//   }, (e, stack) async {
//
//   })!.whenComplete(() {
//     print("kkkkk");
//     return iiiii;
//   });
//
// //   runZonedGuarded(() async {
// //     if (!foundation.kIsWeb) {
// //       /// Enable network traffic logging.
// //       HttpClient.enableTimelineLogging = !foundation.kReleaseMode;
// //
// //       /// Lock portrait mode.
// //       unawaited(SystemChrome.setPreferredOrientations(
// //           [DeviceOrientation.portraitUp]));
// //     }
// //
// //     await GmsCheck().checkGmsAvailability(enableLog: foundation.kDebugMode);
// //
// //     try {
// //       if (isMobile) {
// //         /// Init Firebase settings due to version 0.5.0+ requires to.
// //         /// Use await to prevent any usage until the initialization is completed.
// //         await Services().firebase.init();
// //         await Configurations().loadRemoteConfig();
// //       }
// //     } catch (e) {
// //       printLog(e);
// //       printLog('🔴 Firebase init issue');
// //     }
// //
// //     await DependencyInjection.inject();
// //     Services().setAppConfig(serverConfig);
// //
// //     if (isMobile && kAdvanceConfig.autoDetectLanguage) {
// //       final lang = injector<SharedPreferences>().getString('language');
// //
// //       if (lang?.isEmpty ?? true) {
// //         languageCode = await LocaleService().getDeviceLanguage();
// //       } else {
// //         languageCode = lang.toString();
// //       }
// //     }      printLog('🔴 isssss before page');
// //
// //
// //     ResponsiveSizingConfig.instance.setCustomBreakpoints(
// //         const ScreenBreakpoints(desktop: 900, tablet: 600, watch: 100));
// //     iiiii=App(languageCode: languageCode,mainModel:mainModel ,);
// //     //return App(languageCode: languageCode,mainModel:mainModel ,);
// // }, (e, stack) async {
// //     errottext=e.toString()+"  kkk "+stack.toString();
// //
// //     iiiii=Directionality(
// //         textDirection: TextDirection.ltr,
// //         child: new Text('Hello '+errottext));
// //     printLog('🔴'+e.toString());
// //     printLog('🔴'+stack.toString());
// //   });
//
//   return iiiii;
//
// }
