import 'dart:io' show File;
import 'dart:convert' show json;
import 'package:dcli/dcli.dart' show printerr;

/// Static class to handle loading and parsing of application config
class Config {
  static bool cleanup;
  static Map flac;
  static Map mp3;
  static String bms_script;

  static void init() {
    final configFile = File('resources/config.json');

    try {
      if (!configFile.existsSync()) {
        throw 'File does not exist at: $configFile';
      }

      final configAsString = configFile.readAsStringSync();
      final decoded = json.decode(configAsString);

      cleanup = decoded['cleanup'];
      flac = decoded['flac'];
      mp3 = decoded['mp3'];
      bms_script = decoded['bms_script'];
    } catch (err) {
      printerr('Error loading config file: $err');
    }
  }
}
