import 'package:dcli/dcli.dart';
import 'package:universal_pck_audio_extractor/Config.dart';
import 'package:universal_pck_audio_extractor/DecodeManager.dart';
import 'package:universal_pck_audio_extractor/RequirementInstaller.dart';

Future<void> main(List<String> arguments) async {
  // Initialize Config
  Config.init();

  // Ensure Requirements;
  var requirementInstaller = RequirementInstaller();
  var ready = requirementInstaller.ensure();

  if (ready) {
    print('Requirement check passed');
  } else {
    print('Requirement check failed, please restart the program');
    return;
  }

  var sw = Stopwatch()..start();
  // Decoding
  var decodeManager = DecodeManager();

  if (decodeManager.decoders.isEmpty) {
    print(
        'There is nothing to decode in the input folder, please add something');
    return;
  }

  await decodeManager.decodewem();
  await decodeManager.encodewav();

  if (Config.flac['encode']) {
    await decodeManager.encodeflac();
  }

  if (Config.mp3['encode']) {
    await decodeManager.encodemp3();
  }

  if (Config.cleanup) {
    deleteDir('resources/processing/');
    deleteDir('resources/output/wav/');
  }

  sw.stop();

  print('elapsedTime: ${sw.elapsedMilliseconds}');
}
