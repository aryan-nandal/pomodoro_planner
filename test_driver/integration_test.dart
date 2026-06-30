import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> imageBytes, [Map<String, Object?>? args]) async {
      final baseDir = Directory('/workspace').existsSync() ? '/workspace/screenshots' : 'screenshots';
      final File image = File('$baseDir/$name.png');
      await image.create(recursive: true);
      await image.writeAsBytes(imageBytes);
      print('Screenshot saved: ${image.absolute.path}');
      return true;
    },
  );
}
