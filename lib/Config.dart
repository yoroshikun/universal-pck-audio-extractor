import 'dart:io' show File, Platform;
import 'dart:convert' show json;
import 'package:dcli/dcli.dart' show printerr;

String determinePlatform() {
  if (Platform.isWindows) {
    return 'windows';
  }

  if (Platform.isMacOS) {
    return 'macos';
  }

  if (Platform.isLinux) {
    return 'linux';
  }

  return 'unsupported';
}

/// Static class to handle loading and parsing of application config
class Config {
  static bool cleanup;
  static Map flac;
  static Map mp3;
  static String bms_script;
  static String platform = determinePlatform();

  Future<void> _init() async {
    final configFile = File('resources/config.json');

    try {
      if (!await configFile.exists()) {
        throw 'File does not exist at: $configFile';
      }

      final configAsString = await configFile.readAsString();
      final decoded = json.decode(configAsString);

      cleanup = decoded['cleanup'];
      flac = decoded['flac'];
      mp3 = decoded['mp3'];
      bms_script = decoded['bms_script'];
    } catch (err) {
      printerr('Error loading config file: $err');
    }
  }

  static Future<void> init() async {
    var initialConfig = Config();

    await initialConfig._init();
  }
}
