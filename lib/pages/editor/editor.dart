import 'package:flutter/material.dart';
import 'package:rich_code_editor/exports.dart';
import 'DummySyntaxHighlighter.dart';

class Editor extends StatefulWidget {
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  RichCodeEditingController _rec;
  SyntaxHighlighterBase _syntaxHighlighterBase;

  @override
  void initState() {
    _syntaxHighlighterBase = DummySyntaxHighlighter();
    _rec = RichCodeEditingController(_syntaxHighlighterBase);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑器"),
      ),
      body: RichCodeField(
        autofocus: true,
        controller: _rec,
        textCapitalization: TextCapitalization.none,
        decoration: null,
        syntaxHighlighter: _syntaxHighlighterBase,
        maxLines: null,
        onChanged: (String s) {},
        onBackSpacePress: (TextEditingValue oldValue) {},
        onEnterPress: (TextEditingValue oldValue) {
          var result = _syntaxHighlighterBase.onEnterPress(oldValue);
          if (result != null) {
            _rec.value = result;
          }
        },
      ),
    );
  }
}
