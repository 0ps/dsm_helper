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
      return Icon(Icons.movie);
    } else if (fileType == FileType.image) {
      return CupertinoExtendedImage(
        Util.baseUrl + "/webapi/entry.cgi?path=$thumb&size=small&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=tBc5W9PrhHSCMVTI62EHFZ8CE0&animate=true",
        width: 50,
        height: 50,
        fit: BoxFit.contain,
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
