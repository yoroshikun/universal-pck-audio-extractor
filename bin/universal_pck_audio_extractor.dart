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
    print('Yay everything is ready for decoding');
  } else {
    print('Oh no you dont have everything ready for decoding');
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
