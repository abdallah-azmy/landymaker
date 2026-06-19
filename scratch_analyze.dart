import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Error: lib directory not found.');
    return;
  }

  // 1. Find all dart files
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  print('Found ${dartFiles.length} Dart files.');

  final filePaths = dartFiles.map((f) => f.path.replaceAll('\\', '/')).toList();
  final fileContents = <String, String>{};
  for (final file in dartFiles) {
    final cleanPath = file.path.replaceAll('\\', '/');
    fileContents[cleanPath] = file.readAsStringSync();
  }

  // Helper to resolve imports
  String resolveImport(String currentFile, String importUri) {
    if (importUri.startsWith('package:landymaker/')) {
      return importUri.replaceFirst('package:landymaker/', 'lib/');
    }
    if (importUri.startsWith('package:') || importUri.startsWith('dart:')) {
      return ''; // External package or dart SDK
    }
    // Relative path
    final parts = currentFile.split('/');
    parts.removeLast(); // Remove filename
    final importParts = importUri.split('/');
    for (final part in importParts) {
      if (part == '.') {
        continue;
      } else if (part == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(part);
      }
    }
    return parts.join('/');
  }

  // 2. Build dependency graph
  final graph = <String, Set<String>>{};
  final importRegex = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');

  for (final path in filePaths) {
    graph[path] = {};
    final content = fileContents[path]!;
    final matches = importRegex.allMatches(content);
    for (final match in matches) {
      final uri = match.group(1)!;
      final resolved = resolveImport(path, uri);
      if (resolved.isNotEmpty && fileContents.containsKey(resolved)) {
        graph[path]!.add(resolved);
      }
    }
  }

  // 3. Find reachable files from main.dart
  final reachable = <String>{};
  void dfs(String file) {
    if (reachable.contains(file)) return;
    reachable.add(file);
    final imports = graph[file] ?? {};
    for (final imp in imports) {
      dfs(imp);
    }
  }

  // Start DFS from main.dart
  final mainFile = 'lib/main.dart';
  if (fileContents.containsKey(mainFile)) {
    dfs(mainFile);
  }

  final unusedFiles = filePaths.where((f) => !reachable.contains(f)).toList();
  print('Reachable files: ${reachable.length}');
  print('Unused files: ${unusedFiles.length}');

  // 4. Find classes and their bounds
  final classToDefs = <String, ClassDef>{}; // className -> ClassDef
  final classRegex = RegExp(r'\b(?:class|mixin|enum|extension)\s+([A-Za-z0-9_]+)\b');
  
  for (final file in reachable) {
    final content = fileContents[file]!;
    final cleanContent = cleanComments(content);
    
    // Find all class declarations in this file
    var offset = 0;
    while (offset < cleanContent.length) {
      final match = classRegex.firstMatch(cleanContent.substring(offset));
      if (match == null) break;
      
      final className = match.group(1)!;
      final matchStart = offset + match.start;
      final declEnd = offset + match.end;
      
      if (!className.startsWith('_')) {
        // Find class body boundaries by tracking braces `{` and `}`
        int bodyStart = cleanContent.indexOf('{', declEnd);
        if (bodyStart != -1) {
          int braceCount = 1;
          int i = bodyStart + 1;
          while (i < cleanContent.length && braceCount > 0) {
            if (cleanContent[i] == '{') braceCount++;
            if (cleanContent[i] == '}') braceCount--;
            i++;
          }
          classToDefs[className] = ClassDef(
            name: className,
            filePath: file,
            startOffset: matchStart,
            endOffset: i,
          );
        } else {
          // If no body (e.g. enum/class without body, or mixin/extension on a single line)
          classToDefs[className] = ClassDef(
            name: className,
            filePath: file,
            startOffset: matchStart,
            endOffset: declEnd,
          );
        }
      }
      
      offset = declEnd;
    }
  }

  // Check if class is used outside its own declaration body
  final unusedClasses = <String, String>{}; // className -> filePath
  for (final entry in classToDefs.entries) {
    final className = entry.key;
    final def = entry.value;
    bool isUsed = false;

    final classUsageRegex = RegExp('\\b$className\\b');
    for (final file in reachable) {
      final content = fileContents[file]!;
      final cleanContent = cleanComments(content);
      
      if (file == def.filePath) {
        // Search outside the class body
        final prefix = cleanContent.substring(0, def.startOffset);
        final suffix = cleanContent.substring(def.endOffset);
        if (classUsageRegex.hasMatch(prefix) || classUsageRegex.hasMatch(suffix)) {
          isUsed = true;
          break;
        }
      } else {
        if (classUsageRegex.hasMatch(cleanContent)) {
          isUsed = true;
          break;
        }
      }
    }
    
    if (!isUsed) {
      unusedClasses[className] = def.filePath;
    }
  }

  // 5. Find methods / functions in reachable files
  // Let's search inside classes and top-level for:
  // ReturnType methodName(args) { ... } or methodName(args) => ...;
  // We match signatures that end with `{` or `=>`.
  final methodToDefs = <String, List<String>>{}; // methodName -> [filePath, className]
  
  final methodDeclRegex = RegExp(
    r'(?:@override\s+)?(?:\b[a-zA-Z0-9_<>]+\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)\s*(?:async\s*)?(?:\{|=>)'
  );

  final reservedKeywords = {
    'if', 'for', 'while', 'switch', 'catch', 'super', 'print', 'assert', 'sync',
    'async', 'yield', 'await', 'return', 'with', 'in', 'is', 'as', 'new', 'this',
    'class', 'void', 'get', 'set', 'main', 'test', 'expect', 'group', 'setUp',
    'tearDown', 'toString', 'hashCode', 'runtimeType', 'noSuchMethod', 'identical',
    'build', 'initState', 'dispose', 'didUpdateWidget', 'didChangeDependencies',
    'createState', 'fromJson', 'toJson', 'copyWith', 'map', 'when', 'maybeWhen',
    'orElse', 'equals', 'toStringShort', 'debugDescribeChildren', 'debugFillProperties',
    'any', 'where', 'forEach', 'reduce', 'fold', 'firstWhere', 'lastWhere',
    'singleWhere', 'join', 'asMap', 'toList', 'toSet', 'clear', 'add', 'addAll',
    'remove', 'removeAt', 'removeLast', 'insert', 'insertAll', 'indexOf', 'lastIndexOf',
    'contains', 'sort', 'shuffle', 'sublist', 'getRange', 'setRange', 'removeRange',
    'replaceRange', 'fillRange', 'setAll', 'any', 'every', 'take', 'takeWhile',
    'skip', 'skipWhile', 'first', 'last', 'single', 'isEmpty', 'isNotEmpty', 'length',
    'keys', 'values', 'entries', 'containsKey', 'containsValue', 'putIfAbsent',
    'update', 'updateAll', 'removeWhere', 'clear', 'cast', 'retype', 'execute',
    'then', 'catchError', 'whenComplete', 'asStream', 'timeout', 'listen',
    'cancel', 'pause', 'resume', 'addError', 'close', 'hasListener', 'isPaused',
    'addStream', 'drain', 'handleError', 'expand', 'transform', 'pipe', 'flush',
    'write', 'writeAll', 'writeCharCode', 'writeln', 'addSlice', 'close',
  };

  for (final file in reachable) {
    final content = fileContents[file]!;
    final cleanContent = cleanComments(content);

    // Let's identify the current class if any
    final lines = cleanContent.split('\n');
    String currentClass = '';
    
    for (final line in lines) {
      final classMatch = classRegex.firstMatch(line);
      if (classMatch != null) {
        currentClass = classMatch.group(1)!;
      }
      
      final methodMatch = methodDeclRegex.firstMatch(line);
      if (methodMatch != null) {
        final methodName = methodMatch.group(1)!;
        
        // Skip private, constructor, reserved keywords, overrides
        if (methodName.startsWith('_')) continue;
        if (methodName == currentClass) continue;
        if (reservedKeywords.contains(methodName)) continue;
        if (line.contains('@override')) continue;
        
        methodToDefs[methodName] = [file, currentClass];
      }
    }
  }

  // Count references to methods across all reachable files
  final unusedMethods = <String, List<String>>{}; // methodName -> [filePath, className]
  for (final entry in methodToDefs.entries) {
    final methodName = entry.key;
    final defFile = entry.value[0];
    int usageCount = 0;

    final methodUsageRegex = RegExp('\\b$methodName\\b');
    for (final file in reachable) {
      final cleanContent = cleanComments(fileContents[file]!);
      if (file == defFile) {
        // Within the same file, check if it's called somewhere.
        // We find all matches. If matches > 1, it might be called.
        // Let's be precise: count matches. The definition counts as 1.
        final allMatches = methodUsageRegex.allMatches(cleanContent).length;
        if (allMatches > 1) {
          usageCount++;
          break;
        }
      } else {
        if (methodUsageRegex.hasMatch(cleanContent)) {
          usageCount++;
          break; // Found external usage
        }
      }
    }

    if (usageCount == 0) {
      unusedMethods[methodName] = entry.value;
    }
  }

  // Output results to a JSON file and report
  print('\nUnused Files:');
  for (final f in unusedFiles) {
    print('  - $f');
  }

  print('\nUnused Classes (never referenced externally):');
  unusedClasses.forEach((cls, file) {
    print('  - Class $cls in $file');
  });

  print('\nUnused Methods (never referenced anywhere):');
  unusedMethods.forEach((method, info) {
    print('  - Method $method in ${info[0]} (Class: ${info[1]})');
  });

  // Write a markdown report
  final reportFile = File('unused_report.md');
  final reportContent = StringBuffer();
  reportContent.writeln('# تقرير الملفات والفئات والوظائف غير المستخدمة في المشروع (نسخة دقيقة)');
  reportContent.writeln('\nتم إجراء فحص شامل للمشروع لتحديد الأكواد والملفات غير المستخدمة.');
  
  reportContent.writeln('\n## 1. الملفات غير المستخدمة (Unused Files) - العدد: ${unusedFiles.length}');
  if (unusedFiles.isEmpty) {
    reportContent.writeln('لا يوجد ملفات غير مستخدمة.');
  } else {
    for (final f in unusedFiles) {
      reportContent.writeln('- [`$f`](file://${Directory.current.path}/$f)');
    }
  }

  reportContent.writeln('\n## 2. الفئات (Classes) غير المستخدمة - العدد: ${unusedClasses.length}');
  if (unusedClasses.isEmpty) {
    reportContent.writeln('لا يوجد فئات غير مستخدمة.');
  } else {
    unusedClasses.forEach((cls, file) {
      reportContent.writeln('- الفئة `$cls` في الملف [`${file.split('/').last}`](file://${Directory.current.path}/$file)');
    });
  }

  reportContent.writeln('\n## 3. الدوال / الطرق (Methods) غير المستخدمة - العدد: ${unusedMethods.length}');
  if (unusedMethods.isEmpty) {
    reportContent.writeln('لا يوجد دوال غير مستخدمة.');
  } else {
    unusedMethods.forEach((method, info) {
      final file = info[0];
      final cls = info[1].isNotEmpty ? ' (الفئة: `${info[1]}`)' : '';
      reportContent.writeln('- الدالة `$method` في الملف [`${file.split('/').last}`](file://${Directory.current.path}/$file)$cls');
    });
  }

  reportFile.writeAsStringSync(reportContent.toString());
  print('\nReport written to unused_report.md');
}

class ClassDef {
  final String name;
  final String filePath;
  final int startOffset;
  final int endOffset;

  ClassDef({
    required this.name,
    required this.filePath,
    required this.startOffset,
    required this.endOffset,
  });
}

String cleanComments(String content) {
  // Simple comment clean
  // Single line
  var result = content.replaceAll(RegExp(r'//.*'), '');
  // Multi line
  result = result.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return result;
}
