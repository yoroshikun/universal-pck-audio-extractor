import 'dart:async';
import 'dart:isolate';
import 'package:dcli/dcli.dart';

void run_isolated_command(String command) {
  start(command);
}

// THIS DOES NOT WORK YET
Future<void> isolate_command_chunk(List<String> commands) async {
  var ports = [];
  var completers = [];

  commands.forEach((command) {
    var port = ReceivePort();
    var completer = Completer();

    port.listen((_) {
      port.close();
    }, onDone: () => completer.complete());

    ports.add(port);
    completers.add(completer);

    Isolate.spawn(run, command, onExit: port.sendPort);
  });

  List<Future> futures = [];

  completers.forEach((completer) {
    futures.add(completer.future);
  });

  // Waiting for all streams to complete
  await Future.wait(futures);
}
