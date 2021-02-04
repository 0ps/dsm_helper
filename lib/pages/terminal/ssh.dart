import 'dart:convert';

import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/theme/terminal_themes.dart';
import 'package:xterm/xterm.dart';
import 'package:dartssh/client.dart';

class Ssh extends StatefulWidget {
  final String host;
  final String port;
  final String username;
  final String password;
  Ssh(this.host, this.port, this.username, this.password);
  @override
  _SshState createState() => _SshState();
}

class _SshState extends State<Ssh> {
  Terminal terminal;
  SSHClient client;
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
    terminal.write('连接中 ${widget.host}:${widget.port}...');
    try {
      client = SSHClient(
        hostport: Uri.parse("http://${widget.host}:${widget.port}"),
        login: widget.username,
        print: print,
        termWidth: 80,
        termHeight: 25,
        termvar: 'xterm-256color',
        getPassword: () => utf8.encode(widget.password),
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
    } catch (e) {
      terminal.write('连接失败 $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          context,
          color: Colors.black,
          iconColor: Colors.white,
        ),
        title: Text(
          "终端",
          style: TextStyle(color: Colors.white),
        ),
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
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
