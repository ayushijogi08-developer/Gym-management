import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  static Future<void> shareOrDownloadFile({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      // WEB DOWNLOAD LOGIC
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      return;
    }

    // MOBILE/DESKTOP LOGIC
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);

    if (Platform.isAndroid || Platform.isIOS) {
      await Share.shareXFiles([XFile(file.path)], text: 'Gym Backup File');
    } else {
      print('File saved: ${file.path}');
    }
  }
}