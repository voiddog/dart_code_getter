import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:dart_code_getter/dart_code_getter.dart' as dart_code_getter;
import 'package:vm_service/vm_service.dart';

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption('uri', abbr: 'u', help: 'vm service 地址');
  parser.addOption('package', abbr: 'p', help: '要导出的 package 名称');
  parser.addOption('output', abbr: 'o', help: '代码输出目录');

  final result = parser.parse(arguments);
  final uri = result['uri'] as String?;
  if (uri?.isNotEmpty != true) {
    throw '需要 vm service 地址（--uri ..）';
  }
  final package = result['package'] as String?;
  if (package?.isNotEmpty != true) {
    throw '需要包名';
  }
  final output = result['output'] as String?;
  if (output?.isNotEmpty != true) {
    throw '需要输出目录地址';
  }
  print('uri: $uri\n'
      'package: $package\n'
      'output: $output\n');
  dart_code_getter.fetchSourceCode(uri!, package!).listen((script) {
    _saveScriptToFile(output!, script);
  });
}

Future<void> _saveScriptToFile(String output, Script script) async {
  var outputDir = Directory(output);
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  final uri = script.uri!;
  final regExp = RegExp(r'package:(\w+)/(\S+)');
  final matchResult = regExp.firstMatch(uri);
  File outFile;
  if (matchResult == null) {
    // no package name, save file
    outFile = File(path.join(output, uri));
  } else {
    outFile =
        File(path.join(output, matchResult.group(1), matchResult.group(2)));
  }

  print('save code to: ${outFile.path}');
  if (!await outFile.parent.exists()) {
    await Directory(outFile.parent.path).create(recursive: true);
  }
  await outFile.writeAsString(script.source ?? '');
  return;
}
