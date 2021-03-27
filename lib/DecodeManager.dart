import 'package:dcli/dcli.dart';

import 'Decoder.dart';

class DecodeManager {
  List<Decoder> decoders = [];

  DecodeManager() {
    var files = find('*.pck', root: 'resources/input/').toList();

    files.forEach((file) {
      decoders.add(Decoder(file));
    });
  }

  Future<void> decodewem() async {
    List<Future<void>> futures = [];

    decoders.forEach((decoder) {
      futures.add(decoder.decodewem());
    });

    await Future.wait(futures);
  }

  Future<void> encodewav() async {
    List<Future<void>> futures = [];

    decoders.forEach((decoder) {
      futures.add(decoder.encodewav());
    });

    await Future.wait(futures);
  }

  Future<void> encodeflac() async {
    List<Future<void>> futures = [];

    decoders.forEach((decoder) {
      futures.add(decoder.encodeflac());
    });

    await Future.wait(futures);
  }

  Future<void> encodemp3() async {
    List<Future<void>> futures = [];

    decoders.forEach((decoder) {
      futures.add(decoder.encodemp3());
    });

    await Future.wait(futures);
  }
}
