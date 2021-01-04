import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/theme/terminal_theme.dart';
import 'package:xterm/theme/terminal_themes.dart';
import 'package:xterm/xterm.dart';
import 'package:dartssh/client.dart';

class Ssh extends StatefulWidget {
  @override
  _SshState createState() => _SshState();
}

class _SshState extends State<Ssh> {
  Terminal terminal;
  SSHClient client;
  String host = "http://192.168.0.233:22";
  String username = "root";
  String password = "yaoshuwei123";
  @override
  void initState() {
    terminal = Terminal(onInput: onInput, theme: TerminalThemes.whiteOnBlack);
    connect();
    super.initState();
  }

  @override
  void dispose() {
    terminal.close();
    super.dispose();
  }

  void onInput(String input) {
    client?.sendChannelData(utf8.encode(input));
  }

  void connect() {
    terminal.write('连接中 $host...');
    client = SSHClient(
      hostport: Uri.parse(host),
      login: username,
      print: print,
      termWidth: 80,
      termHeight: 25,
      termvar: 'xterm-256color',
      getPassword: () => utf8.encode(password),
      response: (transport, data) {
        terminal.write(data);
      },
      success: () {
        terminal.write('连接成功.\n');
      },
      disconnected: () {
        terminal.write('断开连接.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("终端"),
      ),
      body: TerminalView(
        terminal: terminal,
        onResize: (width, height) {
          client?.setTerminalWindowSize(width, height);
        },
      ),
    );
  }
}
