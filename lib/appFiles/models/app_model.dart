import 'dart:async';
import 'dart:convert' as convert;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/config.dart';
import '../common/config/models/index.dart';
import '../common/constants.dart';
import '../modules/dynamic_layout/config/app_config.dart';
import '../services/index.dart';
import 'advertisement/index.dart' show AdvertisementConfig;
import 'cart/cart_model.dart';
import 'category_model.dart';

class AppModel with ChangeNotifier {
  AppConfig? appConfig;
  AdvertisementConfig advertisement = const AdvertisementConfig();
  Map? deeplink;
  late bool isMultivendor;

  /// Loading State setting
  bool isLoading = true;
  bool isInit = false;

  /// Current and Payment settings
  String? currency;
  String? currencyCode;
  Map<String, dynamic> currencyRate = <String, dynamic>{};
  double? smallestUnitRate;

  /// Language Code
  String _langCode = kAdvanceConfig.defaultLanguage;

  String get langCode => _langCode;

  /// Theming values for light or dark theme mode
  ThemeMode? themeMode;

  bool get darkTheme => themeMode == ThemeMode.dark;

  set darkTheme(bool value) =>
      themeMode = value ? ThemeMode.dark : ThemeMode.light;

  ThemeConfig get themeConfig => darkTheme ? kDarkConfig : kLightConfig;

  /// The app will use mainColor from env.dart,
  /// or override it with mainColor from config JSON if found.
  String get mainColor {
    final configJsonMainColor = appConfig?.settings.mainColor;
    if (configJsonMainColor != null && configJsonMainColor.isNotEmpty) {
      return configJsonMainColor;
    }
    return themeConfig.mainColor;
  }

  /// Product and Category Layout setting
  List<String>? categories;
  List<Map>? remapCategories;
  Map? categoriesIcons;
  String categoryLayout = '';

  String get productListLayout => appConfig!.settings.productListLayout;

  double get ratioProductImage =>
      appConfig!.settings.ratioProductImage ??
      (kAdvanceConfig.ratioProductImage * 1.0);

  String get productDetailLayout =>
      appConfig!.settings.productDetail ?? kProductDetail.layout;

  kBlogLayout get blogDetailLayout => appConfig!.settings.blogDetail != null
      ? kBlogLayout.values.byName(appConfig!.settings.blogDetail!)
      : kAdvanceConfig.detailedBlogLayout;

  /// App Model Constructor
  AppModel([String? lang]) {
    _langCode = lang ?? kAdvanceConfig.defaultLanguage;

    advertisement = AdvertisementConfig.fromJson(adConfig: kAdConfig);
    isMultivendor = ServerConfig().typeName.isMultiVendor;
  }

  void _updateAndSaveDefaultLanguage(String? lang) async {
    var prefs = injector<SharedPreferences>();
    final prefLang = prefs.getString('language');
    _langCode = prefLang != null && prefLang.isNotEmpty
        ? prefLang
        : lang ?? kAdvanceConfig.defaultLanguage;
    await prefs.setString('language', _langCode.split('-').first.toLowerCase());
  }

  /// Get persist config from Share Preference
  Future<bool> getPrefConfig({String? lang}) async {
    try {
      _updateAndSaveDefaultLanguage(lang);

      var prefs = injector<SharedPreferences>();
      var defaultCurrency = kAdvanceConfig.defaultCurrency;

      darkTheme = prefs.getBool('darkTheme') ?? kDefaultDarkTheme;
      currency =
          prefs.getString('currency') ?? defaultCurrency?.currencyDisplay;
      currencyCode =
          prefs.getString('currencyCode') ?? defaultCurrency?.currencyCode;
      smallestUnitRate = defaultCurrency?.smallestUnitRate;
      isInit = true;
      await updateTheme(darkTheme);

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeLanguage(String languageCode, BuildContext context) async {
    try {
      _langCode = languageCode;
      var prefs = injector<SharedPreferences>();
      await prefs.setString('language', _langCode);

      await loadAppConfig(isSwitched: true);
      await loadCurrency();
      eventBus.fire(const EventChangeLanguage());

      await Provider.of<CategoryModel>(context, listen: false).getCategories(
        lang: languageCode,
        sortingList: categories,
        remapCategories: remapCategories,
      );

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> changeCurrency(String? item, BuildContext context,
      {String? code}) async {
    try {
      Provider.of<CartModel>(context, listen: false)
          .changeCurrency(code ?? item);
      var prefs = injector<SharedPreferences>();
      currency = item;
      currencyCode = code;
      await prefs.setString('currencyCode', currencyCode!);
      await prefs.setString('currency', currency!);
      notifyListeners();
    } catch (error) {
      printLog('[changeCurrency] error: ${error.toString()}');
    }
  }

  Future<void> updateTheme(bool theme) async {
    try {
      var prefs = injector<SharedPreferences>();
      darkTheme = theme;
      await prefs.setBool('darkTheme', theme);
      notifyListeners();
    } catch (error) {
      printLog('[updateTheme] error: ${error.toString()}');
    }
  }
  Map<String, Object> kkkkkk={
  "HorizonLayout": [
    {
      "layout": "logo",
      "showMenu": true,
      "showSearch": true,
      "showLogo": true,
      "showCart": false,
      "showNotification": false,
      "menuIcon": {
        "name": "blur_on",
        "fontFamily": "MaterialIcons"
      },
      "image": "https://trello.com/1/cards/634319314bdd620381bd5bde/attachments/634319343c2baf01ccf595e0/download/lastsplash.png"
    },
    {
      "layout": "category",
      "type": "image",
      "wrap": false,
      "showShortDescription": true,
      "size": 1,
      "radius": 80,
      "spacing": 12,
      "items": [
        {
          "showDescription": false,
          "category": "59",
          "keepDefaultTitle": false,
          "originalColor": true,
          "showText": true
        },
        {
          "category": "61",
          "showText": true,
          "originalColor": true,
          "keepDefaultTitle": false,
          "showDescription": false
        }
      ],
      "line": false,
      "marginLeft": 0,
      "marginRight": 0,
      "marginTop": 10,
      "marginBottom": 10,
      "paddingX": 10,
      "paddingY": 10,
      "marginX": 0,
      "marginY": 0,
      "hideTitle": false,
      "noBackground": false,
      "imageBorderWidth": 1.5,
      "imageBorderColor": "ff242100",
      "imageBorderStyle": "dot",
      "imageSpacing": 10,
      "labelFontSize": 14,
      "border": 0.6,
      "enableBorder": false,
      "textAlignment": "topCenter",
      "imageBoxFit": "fitWidth",
      "itemSize": {
        "width": 370,
        "height": 160
      }
    },
    {
      "layout": "bannerImage",
      "design": "static",
      "fit": "fitWidth",
      "marginLeft": 10,
      "items": [
        {
          "padding": 5,
          "products": [],
          "image": "https://qanateer.allinye.com/image/catalog/banner/66666.jpg",
          "bannerWithProduct": false,
          "defaultShowProduct": false,
          "showSubcategory": false,
          "radius": 23.7
        },
        {
          "image": "https://qanateer.allinye.com/image/catalog/banner/000099887.jpg",
          "showSubcategory": false,
          "padding": 5,
          "bannerWithProduct": false,
          "products": [],
          "defaultShowProduct": false,
          "radius": 28.1
        }
      ],
      "marginBottom": 0,
      "height": 0.25,
      "marginRight": 10,
      "marginTop": 10,
      "enableParallax": false,
      "parallaxImageRatio": 1.2,
      "isHorizontal": false,
      "parallax": false
    },
    {
      "vPadding": 0,
      "parallax": false,
      "showHeart": false,
      "enableBottomAddToCart": false,
      "hideStore": false,
      "hMargin": 6,
      "rows": 1,
      "showQuantity": false,
      "parallaxImageRatio": 1.2,
      "showCartButtonWithQuantity": false,
      "name": "",
      "backgroundRadius": 10,
      "hideTitle": false,
      "columns": 0,
      "vMargin": 0,
      "cardDesign": "card",
      "hideEmptyProductListRating": false,
      "showCartIcon": true,
      "enableRating": true,
      "onSale": false,
      "isSnapping": false,
      "borderRadius": 3,
      "hPadding": 0,
      "hidePrice": false,
      "showCountDown": false,
      "featured": false,
      "cartIconRadius": 9,
      "hideEmptyProductLayout": false,
      "boxShadow": {
        "y": 6,
        "blurRadius": 14,
        "x": 0,
        "colorOpacity": 0.1,
        "spreadRadius": 10
      },
      "image": "",
      "imageRatio": 1.2,
      "showCartIconColor": false,
      "layout": "largeCard",
      "imageBoxfit": "cover",
      "showOnlyImage": false,
      "showCartButton": false,
      "showStockStatus": true
    },
    {
      "layout": "twoColumn",
      "name": "انواع القهوة",
      "image": "",
      "category": "59",
      "isSnapping": false,
      "borderRadius": 3,
      "hMargin": 6,
      "vMargin": 0,
      "hPadding": 6,
      "vPadding": 2,
      "cardDesign": "card",
      "backgroundRadius": 10,
      "showCountDown": false,
      "onSale": false,
      "rows": 1,
      "columns": 3,
      "imageRatio": 1.2,
      "imageBoxfit": "cover",
      "hidePrice": false,
      "hideStore": false,
      "hideTitle": false,
      "enableRating": true,
      "showStockStatus": true,
      "hideEmptyProductListRating": false,
      "showHeart": false,
      "showCartButton": false,
      "showCartIcon": true,
      "showCartIconColor": false,
      "cartIconRadius": 9,
      "showQuantity": false,
      "enableBottomAddToCart": false,
      "showOnlyImage": false,
      "showCartButtonWithQuantity": false,
      "parallax": false,
      "parallaxImageRatio": 1.2,
      "hideEmptyProductLayout": false
    },
    {
      "layout": "bannerImage",
      "design": "stack",
      "fit": "cover",
      "marginLeft": 0,
      "items": [
        {
          "image": "http://qanateer.allinye.com/image/cache/catalog/banner/1645449951-main2%201200x500-2400x1000-1000x450.png",
          "coupon": "blackf",
          "showSubcategory": false,
          "bannerWithProduct": false,
          "defaultShowProduct": false,
          "products": []
        },
        {
          "image": "https://qanateer.allinye.com/image/catalog/banner/5685688ttw.jpg",
          "showSubcategory": false,
          "bannerWithProduct": false,
          "defaultShowProduct": false,
          "products": []
        }
      ],
      "marginBottom": 0,
      "height": 0.15,
      "marginRight": 0,
      "marginTop": 20,
      "radius": 6,
      "padding": 0,
      "enableParallax": false,
      "parallaxImageRatio": 1.2,
      "isHorizontal": false,
      "isSlider": true,
      "autoPlay": true,
      "intervalTime": 3,
      "showNumber": false,
      "isBlur": false,
      "showBackground": false,
      "upHeight": 0,
      "parallax": false
    },
    {
      "layout": "recentView",
      "name": "Recent View"
    },
    {
      "name": "احدث الاصناف",
      "limit": 20,
      "layout": "fourColumn",
      "isSnapping": false,
      "image": "",
      "borderRadius": 3,
      "hMargin": 6,
      "vMargin": 0,
      "hPadding": 6,
      "vPadding": 2,
      "cardDesign": "card",
      "backgroundRadius": 10,
      "showCountDown": false,
      "onSale": false,
      "rows": 1,
      "columns": 3,
      "imageRatio": 1.2,
      "imageBoxfit": "cover",
      "hidePrice": false,
      "hideStore": false,
      "hideTitle": false,
      "enableRating": true,
      "showStockStatus": true,
      "hideEmptyProductListRating": false,
      "showHeart": false,
      "showCartButton": false,
      "showCartIcon": true,
      "showCartIconColor": false,
      "cartIconRadius": 9,
      "showQuantity": false,
      "enableBottomAddToCart": false,
      "showOnlyImage": false,
      "showCartButtonWithQuantity": false,
      "parallax": false,
      "parallaxImageRatio": 1.2,
      "hideEmptyProductLayout": false
    }
  ],
  "Setting": {
    "StickyHeader": false,
    "FontFamily": "Roboto",
    "ShowChat": true,
    "FontHeader": "Raleway",
    "ProductListLayout": "list",
    "TabBarConfig": null,
    "MainColor": "ff0f2800"
  },
  "TabBar": [
    {
      "layout": "home",
      "icon": "assets/icons/tabs/icon-home.png",
      "pos": 100,
      "key": "7mq3irv3k1"
    },
    {
      "layout": "category",
      "icon": "assets/icons/tabs/icon-category.png",
      "pos": 200,
      "categoryLayout": "card",
      "categories": [
        "61",
        "59"
      ],
      "parallax": false,
      "parallaxImageRatio": 1.2,
      "key": "7mq3irv3k1"
    },
    {
      "icon": "assets/icons/tabs/icon-search.png",
      "layout": "search",
      "pos": 300,
      "key": "7mq3irv3k1"
    },
    {
      "icon": "assets/icons/tabs/icon-cart2.png",
      "pos": 400,
      "layout": "cart",
      "key": "7mq3irv3k1"
    },
    {
      "pos": 500,
      "showChat": true,
      "layout": "profile",
      "icon": "assets/icons/tabs/icon-user.png",
      "key": "7mq3irv3k1"
    }
  ],
  //"Drawer": "",
  "AppBar": {}
};
  void loadStreamConfig(config) {
    appConfig = AppConfig.fromJson(config);
    isLoading = false;
    notifyListeners();
  }
  Future<AppConfig?> loadAppConfig(
      {isSwitched = false, Map<String, dynamic>? config}) async {
    var startTime = DateTime.now();

    print("conffff 1");
    if (_langCode == '') {
      _langCode = kAdvanceConfig.defaultLanguage;
    }

    try {
      if (!isInit || _langCode.isEmpty) {
        print("conffff 2");

        await getPrefConfig();
      }

      if (config != null) {
        print("conffff 3");

        appConfig = AppConfig.fromJson(config);
      } else {
        print("conffff 4");

        var loadAppConfigDone = false;

        /// load config from Notion
        if (ServerConfig().type == ConfigType.notion) {
          print("conffff 5");

          final appCfg = await Services().widget.onGetAppConfig(langCode);

          if (appCfg != null) {
            print("conffff 6");

            appConfig = appCfg;
            loadAppConfigDone = true;
          }
        }

        if (loadAppConfigDone == false) {
          print("conffff 7");

          /// we only apply the http config if isUpdated = false, not using switching language
          // ignore: prefer_contains
          if (kAppConfig.indexOf('http') != -1) {
            print("conffff 8");

            // load on cloud config and update on air
            var path = kAppConfig;
            if (path.contains('.json')) {
              print("conffff 9");

              path = path.substring(0, path.lastIndexOf('/'));
              path += '/config_$langCode.json';
            }
            // final appJson = await httpGet(Uri.encodeFull(path).toUri()!,
            //     headers: {'Accept': 'application/json'});
            appConfig = AppConfig.fromJson(convert.jsonDecode(path));
            print("conffff 88");

            // final appJson = await httpGet(Uri.encodeFull(path).toUri()!,
            //     headers: {'Accept': 'application/json'});
            // appConfig = AppConfig.fromJson(
            //     convert.jsonDecode(convert.utf8.decode(appJson.bodyBytes)));
          } else {
            print("conffff 10");

            // load local config
            var path = 'lib/appFiles/config/config_$langCode.json';
            try {
              print("conffff 11");

              final appJson = await rootBundle.loadString(path);
              appConfig = AppConfig.fromJson(convert.jsonDecode(appJson));
            } catch (e) {
              print("conffff 12");

              final appJson = await rootBundle.loadString(kAppConfig);
              appConfig = AppConfig.fromJson(convert.jsonDecode(appJson));
            }
          }
        }
      }

      /// apply App Caching if isCaching is enable
      /// not use for Fluxbuilder
      if (!ServerConfig().isBuilder) {
        await Services().widget.onLoadedAppConfig(langCode, (configCache) {
          appConfig = AppConfig.fromJson(configCache);
        });
      }

      /// Load categories config for the Tabbar menu
      /// User to sort the category Setting
      final categoryTab = appConfig!.tabBar.toList().firstWhereOrNull(
              (e) => e.layout == 'category' || e.layout == 'vendors');
      if (categoryTab != null) {
        if (categoryTab.categories != null) {
          categories = List<String>.from(categoryTab.categories ?? []);
        }
        if (categoryTab.images != null) {
          categoriesIcons =
          categoryTab.images is Map ? Map.from(categoryTab.images) : null;
        }
        if (categoryTab.remapCategories != null) {
          remapCategories = categoryTab.remapCategories;
        }
        categoryLayout = categoryTab.categoryLayout;
      }

      if (appConfig?.settings.tabBarConfig.alwaysShowTabBar != null) {
        Configurations().setAlwaysShowTabBar(
            appConfig?.settings.tabBarConfig.alwaysShowTabBar ?? false);
      }
      isLoading = false;

      notifyListeners();
      printLog('[Debug] Finish Load AppConfig', startTime);
      return appConfig;
    } catch (err, trace) {
      printLog('🔴 AppConfig JSON loading error');
      printLog(err);
      printLog(trace);
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

//   Future<AppConfig?> loadAppConfig(
//       {isSwitched = false, Map<String, dynamic>? config}) async {
//     var startTime = DateTime.now();
//
// print("conffff 1");
//     if (_langCode == '') {
//       _langCode = kAdvanceConfig.defaultLanguage;
//     }
//
//     try {
//       if (!isInit || _langCode.isEmpty) {
//         print("conffff 2");
//
//         await getPrefConfig();
//       }
//
//       if (config != null) {
//         print("conffff 3");
//
//         appConfig = AppConfig.fromJson(config);
//       } else {
//         print("conffff 4");
//
//         var loadAppConfigDone = false;
//
//         /// load config from Notion
//         if (ServerConfig().type == ConfigType.notion) {
//           print("conffff 5");
//
//           final appCfg = await Services().widget.onGetAppConfig(langCode);
//
//           if (appCfg != null) {
//             print("conffff 6");
//
//             appConfig = appCfg;
//             loadAppConfigDone = true;
//           }
//         }
//
//         if (loadAppConfigDone == false) {
//           print("conffff 7");
//
//           /// we only apply the http config if isUpdated = false, not using switching language
//           // ignore: prefer_contains
//           if (kAppConfig.indexOf('http') != -1) {
//             print("conffff 8");
//
//             // load on cloud config and update on air
//             var path = kAppConfig;
//             if (path.contains('.json')) {
//               print("conffff 9");
//
//               path = path.substring(0, path.lastIndexOf('/'));
//               path += '/config_$langCode.json';
//             }
//             // final appJson = await httpGet(Uri.encodeFull(path).toUri()!,
//             //     headers: {'Accept': 'application/json'});
//           //  appConfig = AppConfig.fromJson(convert.jsonDecode(path));
//             appConfig = AppConfig.fromJson(kkkkkk);
//             print("conffff 88");
//
//             // final appJson = await httpGet(Uri.encodeFull(path).toUri()!,
//             //     headers: {'Accept': 'application/json'});
//             // appConfig = AppConfig.fromJson(
//             //     convert.jsonDecode(convert.utf8.decode(appJson.bodyBytes)));
//           } else {
//             print("conffff 10");
//
//             // load local config
//             var path = 'lib/config/config_$langCode.json';
//             try {
//               print("conffff 11");
//
//             //  final appJson = await rootBundle.loadString(path);
//             // appConfig = AppConfig.fromJson(convert.jsonDecode(appJson));
//               appConfig = AppConfig.fromJson(kkkkkk);
//             } catch (e) {
//               print("conffff 12");
//
//               // final appJson = await rootBundle.loadString(kAppConfig);
//             //  appConfig = AppConfig.fromJson(convert.jsonDecode(appJson));
//               appConfig = AppConfig.fromJson(kkkkkk);
//             }
//           }
//         }
//       }
//
//       /// apply App Caching if isCaching is enable
//       /// not use for Fluxbuilder
//       if (!ServerConfig().isBuilder) {
//         await Services().widget.onLoadedAppConfig(langCode, (configCache) {
//           appConfig = AppConfig.fromJson(configCache);
//         });
//       }
//
//       /// Load categories config for the Tabbar menu
//       /// User to sort the category Setting
//       final categoryTab = appConfig!.tabBar.toList().firstWhereOrNull(
//           (e) => e.layout == 'category' || e.layout == 'vendors');
//       if (categoryTab != null) {
//         if (categoryTab.categories != null) {
//           categories = List<String>.from(categoryTab.categories ?? []);
//         }
//         if (categoryTab.images != null) {
//           categoriesIcons =
//               categoryTab.images is Map ? Map.from(categoryTab.images) : null;
//         }
//         if (categoryTab.remapCategories != null) {
//           remapCategories = categoryTab.remapCategories;
//         }
//         categoryLayout = categoryTab.categoryLayout;
//       }
//
//       if (appConfig?.settings.tabBarConfig.alwaysShowTabBar != null) {
//         Configurations().setAlwaysShowTabBar(
//             appConfig?.settings.tabBarConfig.alwaysShowTabBar ?? false);
//       }
//       isLoading = false;
//
//       notifyListeners();
//       printLog('[Debug] Finish Load AppConfig', startTime);
//       return appConfig;
//     } catch (err, trace) {
//       printLog('🔴 AppConfig JSON loading error');
//       printLog(err);
//       printLog(trace);
//       isLoading = false;
//       notifyListeners();
//       return null;
//     }
//   }

  Future<void> loadCurrency({Function(Map<String, dynamic>)? callback}) async {
    /// Load the Rate for Product Currency
    var rates = await Services().api.getCurrencyRate();
    print("currencyRate "+rates.toString());

    if (rates != null) {
      print("currencyRate "+currencyRate.toString());
      currencyRate = rates;
      callback?.call(rates);
    }else{
      rates={"USD":0.37 , "ر.س":1.0 };
      currencyRate = rates;
      callback?.call(rates);
    }
  }

  void updateProductListLayout(layout) {
    appConfig!.settings =
        appConfig!.settings.copyWith(productListLayout: layout);
    notifyListeners();
  }

  void raiseNotify() {
    notifyListeners();
  }
}
