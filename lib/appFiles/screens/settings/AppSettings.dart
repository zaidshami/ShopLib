import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools/flash.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/notification_model.dart';
import '../../services/service_config.dart';
import '../../widgets/common/index.dart' show FluxImage;
import '../common/app_bar_mixin.dart';
import '../index.dart';

class AppSettings extends StatefulWidget {
  @override
  State<AppSettings> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<AppSettings> with AppBarMixin {
  bool isUpdating = false;
var ll=["notifications",
  "language",
 // "currencies",
  "darkTheme",];
  @override
  Widget build(BuildContext context) {

    return renderScaffold(
      routeName: RouteList.appSettings,
      body: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(
            S.of(context).settings,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          leading: isUpdating
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox.square(
              dimension: 24.0,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            ),
          )
              : Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                ll.length,
                    (index) {
                  var item = ll[index];
                  var isTitle = item.contains('title');
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTitle ? 0.0 : itemPadding,
                    ),
                    child: renderItem(item),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderItem(value) {
    IconData? icon;
    String? title;
    Widget? trailing;
    Function()? onTap;

    switch (value) {

      case 'notifications':
        {
          return Consumer<NotificationModel>(builder: (context, model, child) {
            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: SwitchListTile(
                    secondary: Icon(
                      CupertinoIcons.bell,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    value: model.enable,
                    activeColor: const Color(0xFF0066B4),
                    onChanged: (bool enableNotification) {
                      if (enableNotification) {
                        model.enableNotification();
                      } else {
                        model.disableNotification();
                      }
                    },
                    title: Text(
                      S.of(context).getNotification,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black12,
                  height: 1.0,
                  indent: 75,
                  //endIndent: 20,
                ),
                if (model.enable) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    elevation: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteList.notify);
                      },
                      child: ListTile(
                        leading: Icon(
                          CupertinoIcons.list_bullet,
                          size: 22,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(S.of(context).listMessages),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: kGrey600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black12,
                    height: 1.0,
                    indent: 75,
                    //endIndent: 20,
                  ),
                ],
              ],
            );
          });
        }
      case 'language':
        {
          return Selector<AppModel, String?>(
            selector: (context, model) => model.langCode,
            builder: (context, langCode, _) {
              final languages = getLanguages();
              return SettingItem(
                icon: CupertinoIcons.globe,
                title: S.of(context).language,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languages.firstWhere(
                              (element) => langCode == element['code'])['text'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: kGrey600,
                    )
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(RouteList.language);
                },
              );
            },
          );
        }
      case 'currencies':
        {
          if (ServerConfig().isListingType) {
            return const SizedBox();
          }
          return Selector<AppModel, String?>(
            selector: (context, model) => model.currency,
            builder: (context, currency, _) {
              return SettingItem(
                icon: CupertinoIcons.money_dollar_circle,
                title: S.of(context).currencies,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currency',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: kGrey600,
                    )
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(RouteList.currencies);
                },
              );
            },
          );
        }
      case 'darkTheme':
        {
          return Selector<AppModel, bool>(
            selector: (context, model) => model.darkTheme,
            builder: (context, darkTheme, _) {
              return SettingItem(
                icon: darkTheme ? CupertinoIcons.moon : CupertinoIcons.sun_min,
                title: S.of(context).appearance,
                trailing: Text(
                  darkTheme
                      ? S.of(context).darkTheme
                      : S.of(context).lightTheme,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onTap: () {
                  context.read<AppModel>().updateTheme(!darkTheme);
                },
              );
            },
          );
        }
      default:
    return SettingItem(
      icon: icon,
      title: title,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
}
