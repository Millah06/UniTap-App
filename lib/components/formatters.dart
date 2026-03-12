
import 'dart:io';

import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppLinkHandler {
  static String _appLink = "";
  static int _buildNumber = 0;
  static String _version = '';

  // Initialize the app link with dynamic package name
  static Future<void> init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appLink = "https://play.google.com/store/apps/details?id=${packageInfo.packageName}";
    _buildNumber = int.parse(packageInfo.buildNumber);
    _version = packageInfo.version;
  }

  // Get the app link
  static String get appLink => _appLink;
  static int get buildNumber => _buildNumber;
  static String get currentVersion => _version;

  // Method to copy app link to clipboard
  static Future<void> copyAppLink() async {
    await Clipboard.setData(ClipboardData(text: _appLink));
  }

  // Method to share app link using native share dialog
  static Future<void> shareAppLink() async {
    try {
      final ByteData bytes = await rootBundle.load('images/FRAME 5.png');
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/frame.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files:  [XFile(file.path)],
          title: 'NexPay App Share',
          text : ' ❤️Check out this amazing app!\n\n🔥🔥NexPay isn’t just top-ups — '
              'it lets you create stunning Airtime Gifts 🎁\n\nA platform — where '
              'thousands create and share moments like this every day.\n\nTry it → $appLink  '

        ),
      );
    }
    catch (e) {
      print(e);
    }
  }

  // Method to open app in Play Store
  static Future<void> openInPlayStore() async {
    final Uri url = Uri.parse(_appLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

class MyFormatManager {

  static String formatMyDate(DateTime myDate, String formatterString) {
    String rowDate = DateFormat(formatterString).format(myDate);
    String req = rowDate.split(' ')[1].split(',').first;
    String formatted = '';
    if (req.endsWith('11') || req.endsWith('12') || req.endsWith('13')) {
      formatted = '${req}th';
    }
    else if (req.endsWith('1')) {
      formatted = '${req}st';
    }
    else if (req.endsWith('2')) {
      formatted = '${req}nd';
    }
    else if (req.endsWith('3')) {
      formatted = '${req}rd';
    }
    else {
      formatted = '${req}th';
    }
    return DateFormat(formatterString).format(myDate).replaceFirst(req, formatted);
  }

  static List<String> getUnavailableServices(Map<String, bool> services) {
    return services.entries
        .where((e) => e.value == false) // pick only false ones
        .map((e) => e.key)              // keep the keys
        .toList();
  }

  static String formatUnavailable(List<String> items, String provider) {
    if (items.isEmpty) return '';

    if (items.length == 1) return '${items[0]} $provider';

    // join all except the last with commas
    final allButLast = items.sublist(0, items.length - 1).join(', ');
    final last = items.last;

    return '$allButLast and $last $provider';
  }


}