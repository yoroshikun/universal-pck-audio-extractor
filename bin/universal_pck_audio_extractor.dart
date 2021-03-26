import 'package:universal_pck_audio_extractor/Config.dart';
import 'package:universal_pck_audio_extractor/DecodeManager.dart';
import 'package:universal_pck_audio_extractor/RequirementInstaller.dart';

void main(List<String> arguments) {
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

  // Decoding
  var decodeManager = DecodeManager();

  if (decodeManager.decoders.isEmpty) {
    print(
        'There is nothing to decode in the input folder, please add something');
    return;
  }

  decodeManager.decode();
}
