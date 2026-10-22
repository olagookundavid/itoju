import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Firebase/Google Sign-In breaks silently when the app's ids drift apart across
/// the files that each hold a copy (Gradle, Xcode, google-services.json,
/// GoogleService-Info.plist, Info.plist, firebase_options.dart). This pins them to
/// one another so a rename or a re-download can't leave a stale id behind.
void main() {
  String read(String path) => File(path).readAsStringSync();

  // `<key>NAME</key>\n<string>VALUE</string>` from a plist.
  String plistString(String plist, String key) {
    final m = RegExp('<key>$key</key>\\s*<string>([^<]*)</string>').firstMatch(plist);
    expect(m, isNotNull, reason: 'missing $key');
    return m!.group(1)!;
  }

  final options = read('lib/firebase_options.dart');
  String option(String platformBlock, String field) {
    final block = RegExp('static const FirebaseOptions $platformBlock = FirebaseOptions\\(([\\s\\S]*?)\\);')
        .firstMatch(options)!
        .group(1)!;
    final m = RegExp("$field: '([^']*)'").firstMatch(block);
    expect(m, isNotNull, reason: '$platformBlock.$field missing');
    return m!.group(1)!;
  }

  group('Android', () {
    final gradle = read('android/app/build.gradle');
    final applicationId = RegExp('applicationId "([^"]+)"').firstMatch(gradle)!.group(1)!;
    final json = jsonDecode(read('android/app/google-services.json')) as Map;
    final client = (json['client'] as List).first as Map;

    test('google-services.json is for the same package as the Gradle applicationId', () {
      expect(client['client_info']['android_client_info']['package_name'], applicationId);
    });

    test('firebase_options.dart uses the same Android app id and project', () {
      expect(option('android', 'appId'), client['client_info']['mobilesdk_app_id']);
      expect(option('android', 'projectId'), json['project_info']['project_id']);
    });

    test('at least two signing certificates (debug + upload) are registered for sign-in', () {
      final hashes = [
        for (final o in client['oauth_client'] as List)
          if (o['android_info'] != null) o['android_info']['certificate_hash']
      ];
      expect(hashes.toSet().length, greaterThanOrEqualTo(2));
    });
  });

  group('iOS', () {
    final info = read('ios/Runner/GoogleService-Info.plist');
    final appInfo = read('ios/Runner/Info.plist');
    final pbx = read('ios/Runner.xcodeproj/project.pbxproj');

    test('the plist, Xcode and firebase_options agree on the bundle id', () {
      final bundle = plistString(info, 'BUNDLE_ID');
      expect(pbx, contains('PRODUCT_BUNDLE_IDENTIFIER = $bundle;'));
      expect(option('ios', 'iosBundleId'), bundle);
    });

    test('firebase_options.dart uses the plist\'s app id, project and Google client id', () {
      expect(option('ios', 'appId'), plistString(info, 'GOOGLE_APP_ID'));
      expect(option('ios', 'projectId'), plistString(info, 'PROJECT_ID'));
      expect(option('ios', 'iosClientId'), plistString(info, 'CLIENT_ID'),
          reason: 'a stale iosClientId makes Google Sign-In fail on iPhone');
    });

    test('Info.plist registers the plist\'s REVERSED_CLIENT_ID as a URL scheme', () {
      // Google hands control back to the app through this scheme; if it differs
      // from the plist, sign-in opens and never returns on iPhone.
      expect(appInfo, contains('<string>${plistString(info, 'REVERSED_CLIENT_ID')}</string>'));
    });
  });
}
