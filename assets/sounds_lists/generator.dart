import 'dart:io';
import 'package:respire/utils/TextUtils.dart';

void main() async {
  final longDir = Directory('./sounds/long_sounds');
  final shortDir = Directory('./sounds/short_sounds');

  final longFiles = longDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.mp3'))
      .map((f) => f.uri.pathSegments.last.replaceAll('.mp3', ''))
      .toList();

  final shortFiles = shortDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.mp3'))
      .map((f) => f.uri.pathSegments.last.replaceAll('.mp3', ''))
      .toList();

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE')
    ..writeln('// dart run sounds_lists/generator.dart')
    ..writeln('class SoundAssets {')
    ..writeln('  static final Map<String, String> longSounds = {');

  for (var name in longFiles) {
    buffer.writeln('    "${TextUtils.capitalizeAndRemoveTextSeparators(name)}": "./sounds/long_sounds/$name.mp3",');
  }
  buffer.writeln('  };\n');
  buffer.writeln('  static final Map<String, String> shortSounds = {');
  for (var name in shortFiles) {
    buffer.writeln('    "${TextUtils.capitalizeAndRemoveTextSeparators(name)}": "./sounds/short_sounds/$name.mp3",');
  }
  buffer.writeln('  };');
  buffer.writeln('}');

  File('./sounds_lists/sounds_lists.g.dart').writeAsStringSync(buffer.toString());

  print('Generated sounds_lists.g.dart with ${longFiles.length + shortFiles.length} entries.');
}
