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

    var dir = path.split('/').removeLast().replaceFirst('.pck', '/');

    wemDir = 'resources/processing/wem/$dir/';
    wavDir = 'resources/output/wav/$dir/';
    flacDir = 'resources/output/flac/$dir/';
    mp3Dir = 'resources/output/mp3/$dir/';
  }

  void decodewem() {
    var script = Config.bms_script;

    if (Platform.isWindows) {
      run('resources/lib/quickbms/quickbms.exe $script $path $wemDir');
    } else {
      run('resources/lib/quickbms/quickbms $script $path $wemDir');
    }

    find('$wemDir/*.wem').toList().forEach((element) {
      var fileName = element.split('/').removeLast().replaceFirst('.wem', '');
      var wavPath = '$wavDir${fileName.replaceFirst('wem', 'wav')}';
      var flacPath = '$flacDir${fileName.replaceFirst('wav', 'flac')}';
      var mp3Path = '$mp3Dir${fileName.replaceFirst('wav', 'mp3')}';

      files.add({
        'wemPath': element,
        'wavPath': wavPath,
        'flacPath': flacPath,
        'mp3Path': mp3Path
      });
    });
  }

  void encodewav() {
    files.forEach((file) {
      if (Platform.isWindows) {
        run('resources/lib/vgmstream/vgmstream_cli.exe -o ${file['wavPath']} ${file['wemPath']}');
      } else {
        run('vgmstream_cli -o ${file['wavPath']} ${file['wemPath']}');
      }
    });
  }

  void encodeflac() {
    files.forEach((file) {
      if (Platform.isWindows) {
        run('resources/lib/ffmpeg/ffmpeg.exe -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      } else {
        run('ffmpeg -i ${file['wavPath']} -y -af aformat=s${Config.flac['bit_depth']}:${Config.flac['sample_rate']} ${file['flacPath']}');
      }
    });
  }

  void encodemp3() {
    files.forEach((file) {
      if (Platform.isWindows) {
        run('resources/lib/ffmpeg/ffmpeg.exe -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['mp3Path']}');
      } else {
        run('ffmpeg -i ${file['wavPath']} -y -ar ${Config.mp3['sample_rate']} -b:a ${Config.mp3['bit_rate']}K ${file['flacPath']}');
      }
    });
  }

  // Isolates
}
