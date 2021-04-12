import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class TextEditor extends StatefulWidget {
  final String fileName;
  final String content;
  TextEditor({this.fileName, this.content});
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  ScrollController _scrollController = ScrollController();
  String language;
  @override
  void initState() {
    String ext = widget.fileName.split(".").last;
    switch (ext) {
      case "py":
        language = "python";
        break;
      case "php":
        language = "php";
        break;
      case "html":
        language = "html";
        break;
      case "xml":
        language = "xml";
        break;
      case "txt":
        language = "plaintext";
        break;
      case "sql":
        language = "sql";
        break;
      case "sh":
        language = "shell";
        break;
      case "json":
        language = "json";
        break;
      case "css":
        language = "css";
        break;
      case "scss":
        language = "scss";
        break;
      case "java":
        language = "java";
        break;
      case "js":
        language = "javascript";
        break;
      case "kt":
        language = "kotlin";
        break;
      case "md":
        language = "markdown";
        break;
      default:
        language = "plaintext";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("查看文件"),
      ),
      body: DraggableScrollbar.semicircle(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          children: [
            HighlightView(
              // The original code to be highlighted
              widget.content,

              // Specify language
              // It is recommended to give it a value for performance
              language: language,
              // Specify highlight theme
              // All available themes are listed in `themes` folder
              theme: githubTheme,

              // Specify padding
              padding: EdgeInsets.all(12),
            )
          ],
        ),
      ),
    );
  }
}
