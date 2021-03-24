import 'package:universal_pck_audio_extractor/universal_pck_audio_extractor.dart'
    as universal_pck_audio_extractor;
import 'package:universal_pck_audio_extractor/Config.dart';
import 'package:universal_pck_audio_extractor/RequirementInstaller.dart';

void main(List<String> arguments) async {
  // Initialize Config
  await Config.init();

  // Ensure Requirements;
  var requirementInstaller = RequirementInstaller(Config.platform);
  var ready = requirementInstaller.ensure();

  if (ready) {
    print('Yay everything is ready for decoding');
  } else {
    print('Oh no you dont have everything ready for decoding');
  }
}
