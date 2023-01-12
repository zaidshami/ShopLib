

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gms_check/gms_check.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import 'MainModel.dart';
import 'appFiles/app.dart';
import 'appFiles/common/config.dart';
import 'appFiles/common/constants.dart';
import 'appFiles/env.dart';
import 'appFiles/models/order_type/LocalOrder.dart';
import 'appFiles/modules/webview/index.dart';
import 'appFiles/services/dependency_injection.dart';
import 'appFiles/services/locale_service.dart';
import 'appFiles/services/services.dart';




