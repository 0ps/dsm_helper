import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cool_ui/cool_ui.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:dsm_helper/pages/download/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:dsm_helper/util/api.dart';
export 'package:dsm_helper/extensions/datetime.dart';
export 'package:dsm_helper/extensions/string.dart';
export 'package:dsm_helper/extensions/int.dart';

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
  pdf,
  apk,
}

class Util {
  static String sid = "";
  static String baseUrl = "";
  static String smid = "";
  static GlobalKey<DownloadState> downloadKey = GlobalKey<DownloadState>();
  static toast(String text) {
    Fluttertoast.showToast(
      msg: text,
      gravity: ToastGravity.CENTER,
    );
  }

  static String parseOpTime(String optime) {
    List items = optime.split(":");
    int days = int.parse(items[0]) ~/ 24;
    items[0] = (int.parse(items[0]) % 24).toString();
    return "$days天 ${items.join(":")}";
  }

  static Map timeLong(int ticket) {
    int seconds = ticket % 60;
    int minutes = ticket ~/ 60 % 60;
    int hours = ticket ~/ 60 ~/ 60;
    return {
      "hours": hours,
      "minutes": minutes,
      "seconds": seconds,
    };
  }

  static FileType fileType(String name) {
    List<String> image = ["png", "jpg", "jpeg", "gif", "bmp", "ico"];
    List<String> movie = ["mov", "rmvb", "ts", "mp4", "mkv"];
    List<String> music = ["mp3"];
    List<String> ps = ["psd"];
    List<String> html = ["html", "htm", "shtml", "url"];
    List<String> word = ["doc", "docx"];
    List<String> ppt = ["ppt", "pptx"];
    List<String> excel = ["xls", "xlsx"];
    List<String> text = ["txt"];
    List<String> zip = ["zip", "gz", "tar", "rar", "7z"];
    List<String> code = ["py", "php", "c", "java", "jsp", "js", "css", "sql"];
    List<String> pdf = ["pdf"];
    List<String> apk = ["apk"];
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
      return FileType.code;
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
    } else if (pdf.contains(ext)) {
      return FileType.pdf;
    } else if (apk.contains(ext)) {
      return FileType.apk;
    } else {
      return FileType.other;
    }
  }

  static Future<dynamic> get(String url, {Map<String, dynamic> data, bool login: true, String host, Map<String, dynamic> headers}) async {
    if (headers == null) {
      headers = {
        "Cookie": Util.smid,
      };
    } else {
      headers['Cookie'] = Util.smid;
    }
    headers['Cookie'] = "stay_login=0; id=BIFddxkGGt2V-E4EKVq_LxbCfTyaN2smTvZYv7Xoi08XRY-BkHcveWaPYRXIpSk1JPo-sArEdVp0OqVaFU0k5E; smid=xcvrJH3afyzy9uCWeWZFIkeoxwUt6ssvhw23IXxEoyqXb0GfN9Qj7AUgnyuhFd6D5e4zwO7snLcfEMqgjRiQnA";
    print(headers);
    Dio dio = new Dio(
      BaseOptions(
        baseUrl: (host ?? baseUrl) + "/webapi/",
        headers: headers,
      ),
    );
    Response response;
    try {
      response = await dio.get(url, queryParameters: data);
      if (response.headers.map['set-cookie'] != null && response.headers.map['set-cookie'].length > 0) {
        List cookies = [];
        for (int i = 0; i < response.headers.map['set-cookie'].length; i++) {
          Cookie cookie = Cookie.fromSetCookieValue(response.headers.map['set-cookie'][i]);
          cookies.add("${cookie.name}=${cookie.value}");
        }
        Util.smid = cookies.join("; ");
        setStorage("smid", Util.smid);
      }

      if (response.data is String) {
        return json.decode(response.data);
      } else if (response.data is Map) {
        return response.data;
      }
    } on DioError catch (error) {
      print("请求出错:$url");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
    }
  }

  static Future<dynamic> post(String url, {Map<String, dynamic> data, bool login: true, String host}) async {
    Dio dio = new Dio(
      new BaseOptions(
        baseUrl: (host ?? baseUrl) + "/webapi/",
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.1.159:8888";
    //   };
    // };
    Response response;
    try {
      response = await dio.post(
        url,
        data: data,
      );

      return response.data;
    } on DioError catch (error) {
      print("请求出错:$url 请求内容:$data");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
    }
  }

  static Future<dynamic> upload(String url, {Map<String, dynamic> data, bool login: true, String host}) async {
    Map<String, dynamic> headers = {
      "Cookie": "smid=dyE16uD1L3UOaJEKtlaalOibn7L9ANxzMbnPsUBQbUiPF2BcZw_LayqU19AnBwJYkgyizeAeLLa5tdDYjenz1Q; _ga=GA1.2.134020749.1583224437; stay_login=1; photo_remember_me=1; id=5cug6W1ujYmZ6VTI62EHFZ8CE0; PHPSESSID=nn0on2743en89dlcrqia3bhs51; SID=R5yNfiSxi16mWzm1p2uRCG/Sj4ZPehhS",
    };
    print(data);
    Dio dio = new Dio(
      new BaseOptions(
        baseUrl: (host ?? baseUrl) + "/webapi/",
        headers: headers,
      ),
    );
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      // config the http client
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return "PROXY 192.168.1.159:8888";
      };
      // you can also create a new HttpClient to dio
      // return new HttpClient();
    };
    FormData formData = FormData.fromMap(data);
    print(formData.toString());
    Response response;

    try {
      response = await dio.post(
        url,
        data: formData,
      );
      FormData requestData = response.request.data;
      print("fields");
      print(requestData.fields);
      return response.data;
    } on DioError catch (error) {
      print("请求出错:$url 请求内容:$data");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
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

  static Future<String> getLocalPath() async {
    final directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> download(String saveName, String url) async {
    //检查权限
    bool permission = false;
    permission = await Permission.storage.request().isGranted;
    if (!permission) {
      Util.toast("请先授权APP访问存储");
      return "";
    }
    String savePath = await getLocalPath() + "/Download";
    if (!Directory(savePath).existsSync()) {
      Directory(savePath).create();
    }
    String taskId = await FlutterDownloader.enqueue(url: url, fileName: saveName, savedDir: savePath, showNotification: true, openFileFromNotification: true);
    return taskId;
  }

  static String formatSize(int size) {
    if (size < 1024) {
      return "${size}B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)} KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / 1024 / 1024).toStringAsFixed(2)} MB";
    } else if (size < 1024 * 1024 * 1024 * 1024) {
      return "${(size / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
    } else {
      return "${(size / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)} TB";
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
        print(permission);
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
      bool result = await GallerySaver.saveImage(save.path, albumName: "FileStation");
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
