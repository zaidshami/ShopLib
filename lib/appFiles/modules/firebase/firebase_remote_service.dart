import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:inspireui/utils/logs.dart';

class FirebaseRemoteServices {
  static Future<FirebaseRemoteConfig?> loadRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
      await remoteConfig.setConfigSettings(RemoteConfigSettings(minimumFetchInterval:Duration(seconds: 1), fetchTimeout: Duration(seconds: 30) ));

      return remoteConfig;
    } catch (e) {
      printLog('Unable to fetch remote config. Default value will be used. $e');
    }
    return null;
  }
}
