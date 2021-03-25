import 'package:dcli/dcli.dart';

import 'Config.dart';
import 'Decoder.dart';

class DecodeManager {
  List<Decoder> decoders = [];

  DecodeManager() {
    var files = find('resources/input/*.pck').toList();

    files.forEach((element) {
      decoders.add(Decoder(element));
    });
  }

  void decode() {
    // Default decoding
    decoders.forEach((element) => element.decodewem());
    decoders.forEach((element) => element.encodewav());

    if (Config.flac['enabled']) {
      decoders.forEach((element) => element.encodeflac());
    }

    if (Config.mp3['enabled']) {
      decoders.forEach((element) => element.encodemp3());
    }

    if (Config.cleanup) {
      deleteDir('resources/processing/');
      deleteDir('resources/output/wav/');
    }
  }
}
