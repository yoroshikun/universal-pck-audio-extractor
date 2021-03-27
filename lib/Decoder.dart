import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:universal_pck_audio_extractor/command_pool.dart';

import 'Config.dart';

class Decoder {
  String name = '';
  String path = '';
  String processingDir = '';
  String wavDir = '';
  String flacDir = '';
  String mp3Dir = '';
  List<Map> files = [];

  Decoder(String path) {
    this.path = path;

    var dir = basenameWithoutExtension(path);

    name = dir;
    processingDir = join('resources', 'processing', dir);
    wavDir = join('resources', 'output', 'wav', dir);
    flacDir = join('resources', 'output', 'flac', dir);
    mp3Dir = join('resources', 'output', 'mp3', dir);
  }

  Future<void> decodewem() async {
    var script =
        join('resources', 'lib', 'quickbms', 'scripts', Config.bms_script);
    var quickbms = absolute('resources/lib/quickbms/quickbms');

    if (!exists(processingDir)) {
      createDir(processingDir, recursive: true);
    }

    if (Platform.isWindows) {
      start('$quickbms.exe $script $path $processingDir');
    } else {
      start('$quickbms $script $path $processingDir');
    }

    find('*.wav', root: processingDir).toList().forEach((element) {
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

  Future<void> encodewav() async {
    if (!exists(wavDir)) {
      createDir(wavDir, recursive: true);
    }

    var vgmstream_cli = absolute('resources/lib/vgmstream/vgmstream_cli.exe');
    var commands = <String>[];

    files.forEach((file) {
      if (Platform.isWindows) {
        commands.add('$vgmstream_cli -o ${file['wavPath']} ${file['wemPath']}');
      } else {
        commands.add('vgmstream_cli -o ${file['wavPath']} ${file['wemPath']}');
      }
    });

    await command_pool(commands, name, 'wav');
  }

  Future<void> encodeflac() async {
    if (!exists(flacDir)) {
      createDir(flacDir, recursive: true);
    }

    var ffmpeg = absolute('resources/lib/ffmpeg/ffmpeg.exe');
    var commands = <String>[];

    files.forEach((file) {
      if (Platform.isWindows) {
        commands.add(
            '$ffmpeg -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      } else {
        commands.add(
            'ffmpeg -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      }
    });

    await command_pool(commands, name, 'flac');
  }

  Future<void> encodemp3() async {
    if (!exists(mp3Dir)) {
      createDir(mp3Dir, recursive: true);
    }

    var ffmpeg = absolute('resources/lib/ffmpeg/ffmpeg.exe');
    var commands = <String>[];

    files.forEach((file) {
      if (Platform.isWindows) {
        commands.add(
            '$ffmpeg -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['mp3Path']}');
      } else {
        commands.add(
            'ffmpeg -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['mp3Path']}');
      }
    });

    await command_pool(commands, name, 'mp3');
  }
}
