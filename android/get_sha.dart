import 'dart:io';

void main() {
  final result = Process.runSync('gradlew.bat', ['signingReport'], runInShell: true);
  final match = RegExp(r'SHA1: ([0-9A-F:]+)').firstMatch(result.stdout.toString());
  print(match?.group(1) ?? 'Not found');
}
