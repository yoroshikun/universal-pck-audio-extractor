import 'dart:io';

import 'package:dcli/dcli.dart';

import 'Config.dart';

class Decoder {
  String path = '';
  String wemDir = '';
  String wavDir = '';
  String flacDir = '';
  String mp3Dir = '';
  List<Map> files = [];

  Decoder(String path) {
    this.path = path;

    var dir = basenameWithoutExtension(path);

    wemDir = join('resources', 'processing', dir);
    wavDir = join('resources', 'output', 'wav', dir);
    flacDir = join('resources', 'output', 'flac', dir);
    mp3Dir = join('resources', 'output', 'mp3', dir);
  }

  void decodewem() {
    var script =
        join('resources', 'lib', 'quickbms', 'scripts', Config.bms_script);
    var quickbms = absolute('resources/lib/quickbms/quickbms');

    if (!exists(wemDir)) {
      createDir(wemDir, recursive: true);
    }

    if (Platform.isWindows) {
      start('$quickbms.exe $script $path $wemDir');
    } else {
      start('$quickbms $script $path $wemDir');
    }

    find('*.wav', root: wemDir).toList().forEach((element) {
      var fileName = basenameWithoutExtension(element);
      var wavPath = join(wavDir, fileName + '.wav');
      var flacPath = join(flacDir, fileName + '.flac');
      var mp3Path = join(mp3Dir, fileName + '.mp3');

      files.add({
        'wemPath': element,
        'wavPath': wavPath,
        'flacPath': flacPath,
        'mp3Path': mp3Path
      });
    });
  }

  void encodewav() {
    if (!exists(wavDir)) {
      createDir(wavDir, recursive: true);
    }

    // List<String> commandList = [];

    files.forEach((file) {
      // Isolate.spawn(run_isolate_command,
      //     'resources/lib/vgmstream/vgmstream_cli.exe -o ${file['wavPath']} ${file['wemPath']}');
      if (Platform.isWindows) {
        start(
            'resources/lib/vgmstream/vgmstream_cli.exe -o ${file['wavPath']} ${file['wemPath']}');
      } else {
        start('vgmstream_cli -o ${file['wavPath']} ${file['wemPath']}');
      }
      // if (Platform.isWindows) {
      //   commandList.add(
      //       'resources/lib/vgmstream/vgmstream_cli.exe -o ${file['wavPath']} ${file['wemPath']}');
      // } else {
      //   commandList
      //       .add('vgmstream_cli -o ${file['wavPath']} ${file['wemPath']}');
      // }
    });

    // await isolate_command_chunk(commandList);
  }

  void encodeflac() {
    if (!exists(flacDir)) {
      createDir(flacDir, recursive: true);
    }

    files.forEach((file) {
      if (Platform.isWindows) {
        start(
            'resources/lib/ffmpeg/ffmpeg.exe -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      } else {
        start(
            'ffmpeg -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      }
    });
  }

  void encodemp3() {
    if (!exists(mp3Dir)) {
      createDir(mp3Dir, recursive: true);
    }

    files.forEach((file) {
      if (Platform.isWindows) {
        start(
            'resources/lib/ffmpeg/ffmpeg.exe -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['mp3Path']}');
      } else {
        start(
            'ffmpeg -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['flacPath']}');
      }
    });
  }
}
