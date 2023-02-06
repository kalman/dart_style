import 'dart:convert';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:dart_style/dart_style.dart';

class Extractor {
  LineInfo _lineInfo;
  List<Extraction> _extractions = [];

  Extractor(this._lineInfo);

  void extractMethodInvocation(SourceCode source, MethodInvocation method) {
    var methodName = method.methodName.toSource();
    if (methodName == "\$_") {
      var lineInfo = this._lineInfo.getLocation(method.offset);
      var rowCol = lineInfo.lineNumber.toString() +
          ":" +
          lineInfo.columnNumber.toString();
      var arguments = method.argumentList.arguments;
      if (arguments.length == 0) {
        print("Warning:" + rowCol + ": no arguments");
      } else if (!(arguments[0] is StringLiteral)) {
        print("Warning:" +
            rowCol +
            ": first argument " +
            arguments[0].toSource() +
            " must be a string literal");
      } else {
        _extractions.add(new Extraction(
            source.uri,
            lineInfo.lineNumber,
            lineInfo.columnNumber,
            (arguments[0] as StringLiteral).stringValue));
      }
    }
  }

  String toJson([String file = ""]) {
    _extractions.sort((a, b) => a.string.compareTo(b.string));

    if (_extractions.isEmpty) {
      return "{}";
    }

    var buffer = new StringBuffer();
    buffer.write("{\n");

    for (var ex in _extractions) {
      writeIndent_(buffer, 2);
      buffer.write(JSON.encode(ex.string));
      buffer.write(": ");
      buffer.write(ex.toJson(2));
      if (ex != _extractions.last) {
        buffer.write(",");
      }
      buffer.write("\n");
    }

    buffer.write("}");
    return buffer.toString();
  }
}

class Extraction {
  Extraction(this.file, this.line, this.column, this.string);
  String file;
  int line;
  int column;
  String string;

  String toJson([int indent = 0]) {
    var buffer = new StringBuffer();
    buffer.write("{\n");
    writeIndent_(buffer, indent * 2);
    buffer.write("\"file\": " + JSON.encode(file) + ",\n");
    writeIndent_(buffer, indent * 2);
    buffer.write("\"line\": " + line.toString() + ",\n");
    writeIndent_(buffer, indent * 2);
    buffer.write("\"column\": " + column.toString() + "\n");
    writeIndent_(buffer, indent);
    buffer.write("}");
    return buffer.toString();
  }
}

void writeIndent_(StringBuffer buffer, int indent) {
  for (int i = 0; i < indent; i++) {
    buffer.write(" ");
  }
}
