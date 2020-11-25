import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cool_ui/cool_ui.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_station/util/api.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:file_station/util/api.dart';
export 'package:file_station/extensions/datetime.dart';
export 'package:file_station/extensions/string.dart';

enum FileType {
  folder,
  image,
  movie,
  music,
  ps,
  html,
  word,
  ppt,
  excel,
  text,
  zip,
  code,
  other,
}

class Util {
  static String sid = "";
  static String baseUrl = "";

  static toast(String text) {
    Fluttertoast.showToast(
      msg: text,
      gravity: ToastGravity.CENTER,
    );
  }

  static FileType fileType(String name) {
    List<String> image = ["png", "jpg", "gif", "bmp"];
    List<String> movie = ["mov", "rmvb", "ts", "mp4"];
    List<String> music = ["mp3"];
    List<String> ps = ["psd"];
    List<String> html = ["html", "htm", "shtml", "url"];
    List<String> word = ["doc", "docx"];
    List<String> ppt = ["ppt", "pptx"];
    List<String> excel = ["xls", "xlsx"];
    List<String> text = ["txt"];
    List<String> zip = ["zip", "gz", "tar", "rar", "7z"];
    List<String> code = ["py", "php", "c", "java", "jsp", "js", "css"];
    String ext = name.split(".").last.toLowerCase();
    if (image.contains(ext)) {
      return FileType.image;
    } else if (movie.contains(ext)) {
      return FileType.movie;
    } else if (music.contains(ext)) {
      return FileType.music;
    } else if (ps.contains(ext)) {
      return FileType.ps;
    } else if (html.contains(ext)) {
      return FileType.ps;
    } else if (ps.contains(html)) {
      return FileType.ps;
    } else if (word.contains(ext)) {
      return FileType.word;
    } else if (ppt.contains(ext)) {
      return FileType.ppt;
    } else if (excel.contains(ext)) {
      return FileType.excel;
    } else if (text.contains(ext)) {
      return FileType.text;
    } else if (zip.contains(ext)) {
      return FileType.zip;
    } else if (code.contains(ext)) {
      return FileType.code;
    } else {
      return FileType.other;
    }
  }

  static Future<dynamic> get(String url, {Map<String, dynamic> data, bool login: true, String host}) async {
    Dio dio = new Dio(
      BaseOptions(
        baseUrl: (host ?? baseUrl) + "/webapi/",
      ),
    );
    Response response;
    try {
      response = await dio.get(url, queryParameters: data);
      if (response.data is String) {
        return json.decode(response.data);
      } else if (response.data is Map) {
        return response.data;
      }
    } catch (error) {
      print(error);
      print("请求出错:$url");
      return {"success": false, "msg": "加载失败", "data": null};
    }
  }

  static Future<dynamic> post(String url, {Map<String, dynamic> data, bool login: true, String host}) async {
    Dio dio = new Dio(
      new BaseOptions(
        baseUrl: (host ?? baseUrl) + "/webapi/",
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    print(data);
    Response response;
    try {
      response = await dio.post(
        url,
        data: data,
      );
      print(response.request.contentType);
      return response.data;
    } on DioError catch (error) {
      print(error.request.uri);
      print(error.error);
      print("请求出错:$url 请求内容:$data");
      return {"success": false, "msg": "加载失败", "data": null};
    }
  }

  static Future<String> fileExist(String fileName) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    if (await File(tempPath + "/" + fileName).exists()) {
      return tempPath + "/" + fileName;
    } else {
      return null;
    }
  }

  static Future<dynamic> download(String saveName, String url, onReceiveProgress, CancelToken cancelToken) async {
    Dio dio = new Dio();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    Response response;

    try {
      response = await dio.download(url, tempPath + "/" + saveName, deleteOnError: true, onReceiveProgress: onReceiveProgress, cancelToken: cancelToken);
      print(response);
      return {"code": 1, "msg": "下载完成", "data": tempPath + "/" + saveName};
    } on DioError catch (error) {
      print(error);
      print("请求出错:$url");
      if (error.type == DioErrorType.CANCEL) {
        return {"code": 0, "msg": "下载已取消", "data": null};
      } else {
        return {"code": 0, "msg": "网络错误", "data": null};
      }
    }
  }

  static String formatSize(int size) {
    if (size < 1024) {
      return "${size}B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)} KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / 1024 / 1024).toStringAsFixed(2)} MB";
    } else {
      return "${(size / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
    }
  }

//   static checkUpdate(bool showMsg, BuildContext context) async {
//     var hide;
//     if (showMsg) {
//       hide = showWeuiLoadingToast(context: context, message: Text("检查更新中"), alignment: Alignment.center);
//     }
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     var res = await Api.update(packageInfo.buildNumber); //packageInfo.buildNumber
//     if (showMsg) {
//       hide();
//     }
//     if (res['code'] == 1) {
//       showCupertinoDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return CupertinoAlertDialog(
//             title: Text(
//               '版本更新',
//             ),
//             content: Text(
//               res['data']['note'],
//               textAlign: TextAlign.start,
//             ),
//             actions: <Widget>[
//               CupertinoDialogAction(
//                 child: Text(
//                   '取消',
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               CupertinoDialogAction(
//                 isDestructiveAction: true,
//                 child: Text(
//                   '立即更新',
//                 ),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
//                     return Update(res['data']);
//                   }));
// //                  toast("开始下载更新");
// //                  var path = await download(res['data']['url']);
// //                  toast("开始安装更新");
// //                  OpenFile.open(path);
// //                  Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       if (showMsg) {
//         toast(res['msg']);
//       }
//     }
//   }

  static Future<bool> setStorage(String name, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(name, value);
  }

  static Future<String> getStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name);
  }

  static Future<bool> removeStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(name);
  }

//  static Future<bool> checkPermission(PermissionGroup permission) async {
//    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(permission);
//    if (permissionStatus != PermissionStatus.granted) {
//      return await requestPermission(permission);
//    } else {
//      return true;
//    }
//  }
//
//  static Future<bool> requestPermission(PermissionGroup permission) async {
//    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
//    final Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions(permissions);
//
//    return permissionRequestResult[permission] == PermissionStatus.granted;
//  }
  static Future<Map> saveImage(String url, {BuildContext context, bool showLoading: true}) async {
    var hide;
    try {
      bool permission = false;
      if (Platform.isAndroid) {
        permission = await Permission.storage.request().isGranted;
      } else {
        permission = await Permission.photos.request().isGranted;
      }
      if (!permission) {
        return {
          "code": 2,
          "msg": "permission",
        };
      }
      if (showLoading) {
        hide = showWeuiLoadingToast(context: context, message: Text("保存中"));
      }
      File image = await getCachedImageFile(url);
      File save = await image.copy(image.path + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
      bool result = await GallerySaver.saveImage(save.path, albumName: "File Station");
      if (showLoading) {
        hide();
      }
      if (result) {
        return {
          "code": 1,
          "msg": "success",
        };
      } else {
        return {
          "code": 0,
          "msg": "error",
        };
      }
    } catch (e) {
      if (hide != null) {
        hide();
      }
      return {
        "code": 0,
        "msg": "error",
      };
    }
  }

  static String rand() {
    var r = Random().nextInt(2147483646);
    return r.toString();
  }
}
