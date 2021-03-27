import 'dart:async' show Future;

import 'package:dcli/dcli.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

Future<void> command_pool(
    List<String> commands, String name, String type) async {
  var sw = Stopwatch()..start();
  var concurrency = 4; // min(Platform.numberOfProcessors ~/ 2, 4);

  await par_run_commands(commands, concurrency);

  sw.stop();

  print('Convert to - $type - on - $name - took: ${sw.elapsedMilliseconds}ms');
}

// Compute all commands
Future<List<bool>> par_run_commands(List<String> commands, int parallelity) {
  return LoadBalancer.create(parallelity, IsolateRunner.spawn)
      .then((LoadBalancer pool) {
    var limit = commands.length - 1;
    var commandfutures = List<Future<bool>>.filled(commands.length, null);
    // todo: use file size to
    // Schedule all calls with exact load value and the heaviest task
    // assigned first.
    void schedule(a, b, i) {
      if (i < limit) {
        schedule(a + b, a, i + 1);
      }
      commandfutures[i] = pool.run<bool, String>(run_command, commands[i],
          load: 100); // use real load
    }

    schedule(0, 1, 0);
    // And wait for them all to complete.
    return Future.wait(commandfutures).whenComplete(pool.close);
  });
}

bool run_command(String command) {
  var process = start(command); // catch any error here
  if (process.exitCode == 0) {
    return true;
  } else {
    print(process.includeStderr);
    return false;
  }
}
