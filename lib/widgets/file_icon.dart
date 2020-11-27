import 'package:file_station/util/function.dart';
import 'package:file_station/widgets/cupertino_image.dart';
import 'package:flutter/material.dart';

class FileIcon extends StatelessWidget {
  final FileType fileType;
  final String thumb;
  FileIcon(this.fileType, {this.thumb});
  @override
  Widget build(BuildContext context) {
    if (fileType == FileType.folder) {
      return Image.asset(
        "assets/icons/folder.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.music) {
      return Icon(Icons.music_note_rounded);
    } else if (fileType == FileType.movie) {
      return Image.asset(
        "assets/icons/movie.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.image) {
      return CupertinoExtendedImage(
        Util.baseUrl + "/webapi/entry.cgi?path=$thumb&size=small&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true",
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      );
    } else if (fileType == FileType.word) {
      return Image.asset(
        "assets/icons/word.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.ppt) {
      return Image.asset(
        "assets/icons/ppt.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.excel) {
      return Image.asset(
        "assets/icons/excel.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.pdf) {
      return Image.asset(
        "assets/icons/pdf.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.zip) {
      return Image.asset(
        "assets/icons/zip.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.ps) {
      return Image.asset(
        "assets/icons/psd.png",
        width: 40,
        height: 40,
      );
    } else if (fileType == FileType.text) {
      return Image.asset(
        "assets/icons/txt.png",
        width: 40,
        height: 40,
      );
    } else {
      return Image.asset(
        "assets/icons/other.png",
        width: 40,
        height: 40,
      );
    }
  }
}
