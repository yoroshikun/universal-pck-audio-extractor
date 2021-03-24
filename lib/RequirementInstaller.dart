import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class RequirementInstaller {
  double _downloadProgress = 0.0;
  bool _shouldDownloadBMSScripts = false;
  bool _shouldDownloadVGMStream = false;
  bool _shouldDownloadFFMPEG = false;
  bool _shouldDownloadBMS = false;

  RequirementInstaller() {
    _check();
  }

  bool ensure() {
    if (_shouldDownloadBMSScripts) {
      _downloadAndExtract([
        FetchUrl(
            url: 'https://aluigi.altervista.org/bms/quickbms_scripts.zip',
            saveToPath: 'temp/quickbms_scripts.zip',
            progress: _showProgress)
      ], 'resources/lib/quickbms/scripts/');
    }

    if (Platform.isWindows) {
      if (_shouldDownloadVGMStream) {
        _downloadAndExtract([
          FetchUrl(
              url: 'https://f.losno.co/vgmstream-win32-deps.zip',
              saveToPath: 'temp/vgmstream-win32-deps.zip',
              progress: _showProgress),
          FetchUrl(
              url:
                  'https://vgmstream-builds.s3-us-west-1.amazonaws.com/70d20924341e1df3e4f76b4c4a6e414981950f8e/windows/test.zip',
              saveToPath: 'temp/vgmstream_cli.zip')
        ], 'resources/lib/vgmstream/');

        move('resources/lib/vgmstream/test.exe',
            'resources/lib/vgmstream/vgmstream_cli.exe');
      }

      if (_shouldDownloadFFMPEG) {
        _downloadAndExtract([
          FetchUrl(
              url:
                  'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip',
              saveToPath: 'temp/ffmpeg-release-essentials.zip',
              progress: _showProgress)
        ], 'resources/lib/ffmpeg/');

        var results = find('ffmpeg.exe').toList();
        move(results.first, 'resources/lib/ffmpeg/ffmpeg.exe');
        deleteDir(results.first.replaceFirst('bin/ffmpeg.exe', ''),
            recursive: true);
      }

      if (_shouldDownloadBMS) {
        _downloadAndExtract([
          FetchUrl(
              url: 'https://aluigi.altervista.org/papers/quickbms.zip',
              saveToPath: 'temp/quickbms.zip',
              progress: _showProgress)
        ], 'resources/lib/quickbms/');
      }
    }

    if (Platform.isMacOS) {
      if (_shouldDownloadVGMStream) {
        run('brew install vgmstream');
      }

      if (_shouldDownloadFFMPEG) {
        run('brew install ffmpeg');
      }

      if (_shouldDownloadBMS) {
        _downloadAndExtract([
          FetchUrl(
              url: 'https://aluigi.altervista.org/papers/quickbms_macosx.zip',
              saveToPath: 'temp/quickbms_macosx.zip',
              progress: _showProgress)
        ], 'resources/lib/quickbms/');
      }
    }

    if (Platform.isLinux) {
      if (_shouldDownloadVGMStream) {
        run('brew install vgmstream');
      }

      if (_shouldDownloadFFMPEG) {
        run('brew install ffmpeg');
      }

      if (_shouldDownloadBMS) {
        _downloadAndExtract([
          FetchUrl(
              url: 'https://aluigi.altervista.org/papers/quickbms_linux.zip',
              saveToPath: 'temp/quickbms_linux.zip',
              progress: _showProgress)
        ], 'resources/lib/quickbms/');
      }
    }

    if (exists('temp')) {
      deleteDir('temp', recursive: true);
    }

    return _check();
  }

  bool _check() {
    _shouldDownloadBMSScripts = !exists('resources/lib/quickbms/scripts/');

    if (Platform.isWindows) {
      _shouldDownloadVGMStream = !exists('resources/lib/vgmstream/');
      _shouldDownloadFFMPEG = !exists('resources/lib/ffmpeg/');
      _shouldDownloadBMS = !exists('resources/lib/quickbms/quickbms.exe');
    }

    if (Platform.isMacOS || Platform.isLinux) {
      if (which('brew').notfound) {
        print('You must install brew to use this script');
        exit(0);
      }

      _shouldDownloadVGMStream = which('vgmstream123').notfound;
      _shouldDownloadFFMPEG = which('ffmpeg').notfound;
      _shouldDownloadBMS = !exists('resources/lib/quickbms/quickbms');
    }

    if (!_shouldDownloadBMSScripts &&
        !_shouldDownloadVGMStream &&
        !_shouldDownloadFFMPEG & !_shouldDownloadBMS) {
      return true;
    }

    return false;
  }

  void _downloadAndExtract(List<FetchUrl> urls, String extractedPath) {
    urls.forEach((element) {
      var dirSplitList = element.saveToPath.split('/');
      dirSplitList.removeLast();
      var dir = dirSplitList.join();

      if (!exists(dir)) {
        createDir(dir, recursive: true);
      }
    });

    fetchMultiple(urls: urls);

    urls.forEach((element) {
      _extract(element.saveToPath, extractedPath);
      delete(element.saveToPath);
    });
  }

  void _extract(String path, String toPath) {
    if (!exists(toPath)) {
      createDir(toPath, recursive: true);
    }

    final bytes = File(path).readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;

      if (file.isFile) {
        final data = file.content as List<int>;
        File(toPath + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(toPath + filename).create(recursive: true);
      }
    }
  }

  void _showProgress(FetchProgress progress) {
    if (progress.progress >= _downloadProgress + 0.05 ||
        progress.progress <= _downloadProgress - 0.05 ||
        progress.progress == 1.0) {
      print('Downloading ' +
          progress.fetch.url +
          ': ' +
          (progress.progress * 100).toStringAsFixed(2) +
          '% | ' +
          (progress.downloaded / 1000000).toStringAsFixed(2) +
          'MB');

      _downloadProgress = progress.progress;
    }
  }
}
