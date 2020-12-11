import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'function.dart';

class Api {
  static Future<Map> update(String buildNumber) async {
    if (Platform.isAndroid) {
      var res = await Util.get("http://api.fir.im/apps/latest/5fcf8485b2eb465f9ccc279a?api_token=80aa8eeb47ff77e2d713c17b8aff25f8");
      if (res != null) {
        if (int.parse(buildNumber) < int.parse(res['build'])) {
          return {
            "code": 1,
            "msg": "版本更新",
            "data": {
              "note": res['changelog'],
              "url": res['install_url'],
              "update_time": res['updated_at'],
              "size": res['binary']['fsize'],
              "build": res['build'],
              "version": res['versionShort'],
            },
          };
        } else {
          return {
            "code": 0,
            "msg": "已是最新版本",
          };
        }
      }
      return {
        "code": 0,
        "msg": "已是最新版本",
      };
    } else {
      return {
        "code": 0,
        "msg": "已是最新版本",
      };
    }
//    var res = await Util.post("base/update", data: {"platform": Platform.isAndroid ? "android" : "ios", "build": buildNumber});
  }

  static Future<Map> login({String host, String account, String password}) async {
    var data = {
      "account": account,
      "passwd": password,
      "version": 6,
      "api": "SYNO.API.Auth",
      "method": "login",
      "session": "FileStation",
    };
    return await Util.get("auth.cgi", host: host, data: data);
  }

  static Future<Map> shareList() async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.List"',
      "method": '"list_share"',
      "version": 2,
      "_sid": Util.sid,
      "offset": 0,
      "limit": 1000,
      "sort_by": '"name"',
      "sort_direction": '"asc"',
      "additional": '["perm", "time", "size"]',
    });
  }

  static Future<Map> fileList(String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.List"',
      "method": '"list"',
      "version": 2,
      "_sid": Util.sid,
      "offset": 0,
      "folder_path": path,
      "filetype": '"all"',
      "limit": 1000,
      "sort_by": '"name"',
      "sort_direction": '"asc"',
      "additional": '["perm", "time", "size"]',
    });
  }

  ///webapi/FileStation/file_delete.cgi?api=SYNO.FileStation.Delete&version=1&method=start&path=%2Fvideo%2Fdel_folder
  static Future<Map> deleteTask(List<String> path) async {
    var data = {
      "api": '"SYNO.FileStation.Delete"',
      "method": '"start"',
      "accurate_progress": "true",
      // "recursive": "true",
      "version": 2,
      "_sid": Util.sid,
      "path": json.encode(path),
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> deleteResult(String taskId) async {
    return await Util.post("entry.cgi", data: {
      "taskid": taskId,
      "api": '"SYNO.FileStation.Delete"',
      "method": '"status"',
      "version": 2,
      "_sid": Util.sid,
    });
  }

  static Future<Map> compressTask(
    List<String> path,
    String destPath, {
    String level: "normal",
    String mode: "replace",
    String format: "zip",
    String password,
    String codepage,
  }) async {
    var data = {
      "api": '"SYNO.FileStation.Compress"',
      "method": '"start"',
      "version": 3,
      "_sid": Util.sid,
      "path": json.encode(path),
      "dest_file_path": "$destPath",
      "level": "$level",
      "mode": "$mode",
      "format": "$format",
      "password": password,
      "codepage": codepage,
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> compressResult(String taskId) async {
    return await Util.post("entry.cgi", data: {
      "taskid": taskId,
      "api": '"SYNO.FileStation.Compress"',
      "method": '"status"',
      "version": 2,
      "_sid": Util.sid,
    });
  }

  static Future<Map> copyMoveTask(List<String> path, String destFolderPath, bool remove) async {
    return await Util.post("entry.cgi", data: {
      "overwrite": "true",
      "dest_folder_path": destFolderPath,
      "api": '"SYNO.FileStation.CopyMove"',
      "remove_src": remove,
      "accurate_progress": "true",
      "method": '"start"',
      "version": 3,
      "_sid": Util.sid,
      "path": jsonEncode(path),
    });
  }

  static Future<Map> copyMoveResult(String taskId) async {
    return await Util.post("entry.cgi", data: {
      "taskid": taskId,
      "api": '"SYNO.FileStation.CopyMove"',
      "method": '"status"',
      "version": 3,
      "_sid": Util.sid,
    });
  }

  static Future<Map> dirSizeTask(String path) async {
    var task = await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.DirSize"',
      "method": '"start"',
      "version": 1,
      "_sid": Util.sid,
      "path": path,
    });
    return task;
  }

  static Future<Map> dirSizeResult(String taskId) async {
    var result = await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.DirSize"',
      "method": '"status"',
      "version": 1,
      "_sid": Util.sid,
      "taskid": taskId,
    });
    return result;
  }

  static Future<Map> extractTask(String filePath, String folderPath) async {
    var data = {
      "api": '"SYNO.FileStation.Extract"',
      "overwrite": "false",
      "method": '"start"',
      "version": 2,
      "_sid": Util.sid,
      "file_path": filePath,
      "dest_folder_path": folderPath,
      "keep_dir": "true",
      "create_subfolder": "false",
    };
    print(data);
    var task = await Util.post("entry.cgi", data: data);
    return task;
  }

  static Future<Map> extractResult(String taskId) async {
    var result = await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Extract"',
      "method": '"status"',
      "version": 1,
      "_sid": Util.sid,
      "taskid": taskId,
    });
    return result;
  }

  static Future<Map> systemInfo() async {
    List apis = [
      {
        "api": "SYNO.Core.System.Utilization",
        "method": "get",
        "version": 1,
        "type": "current",
        "resource": ["cpu", "memory", "network", "disk"]
      },
      {
        "api": "SYNO.Storage.CGI.Storage",
        "method": "load_info",
        "version": 1,
      },
      {
        "api": "SYNO.Core.CurrentConnection",
        "method": "list",
        "sort_direction": "DESC",
        "sort_by": "time",
        "version": 1,
      },
      {
        "api": "SYNO.Core.System",
        "method": "info",
        "version": 1,
      }
    ];
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"parallel"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> kickConnection(Map connection) async {
    var result = await Util.post("entry.cgi", data: {
      "api": '"SYNO.Core.CurrentConnection"',
      "method": '"kick_connection"',
      "version": 1,
      "_sid": Util.sid,
      "http_conn": jsonEncode(connection),
      "service_conn": "[]",
    });
    return result;
  }

  static Future<Map> initData() async {
    var result = await Util.post("entry.cgi", data: {
      "launch_app": "null",
      "api": '"SYNO.Core.Desktop.Initdata"',
      "method": '"get"',
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> info() async {
    var result = await Util.get("http://pan.fmtol.com:5000/webman/modules/SystemInfoApp/SystemInfo.cgi?_dc=${DateTime.now().millisecond}&SynoToken=iu1Hd4LhasRz2&query=systemHealth");
    return result;
  }

  static Future<Map> checkPermission(String uploadPath, String filePath) async {
    File file = File(filePath);
    var data = {
      "api": '"SYNO.FileStation.CheckPermission"',
      "method": '"write"',
      "version": 3,
      "overwrite": "false",
      "filename": filePath.split("/").last,
      "path": uploadPath,
      "size": await file.length(),
      "_sid": Util.sid,
    };
    var result = await Util.post("entry.cgi", data: data);
    return result;
  }

  static Future<Map> createFolder(String path, String name) async {
    var data = {
      "api": '"SYNO.FileStation.CreateFolder"',
      "method": '"create"',
      "version": 2,
      "force_parent": "false",
      "folder_path": path,
      "name": name,
      "_sid": Util.sid,
    };
    var result = await Util.get("entry.cgi", data: data);
    return result;
  }

  static Future<Map> rename(String path, String name) async {
    var data = {
      "api": '"SYNO.FileStation.Rename"',
      "method": '"rename"',
      "version": 2,
      "path": path,
      "name": name,
      "_sid": Util.sid,
    };
    var result = await Util.get("entry.cgi", data: data);
    return result;
  }

  static Future<Map> upload(String uploadPath, String filePath, CancelToken cancelToken, Function(int, int) onSendProgress) async {
    File file = File(filePath);
    // var permission = await checkPermission(uploadPath, filePath);
    MultipartFile multipartFile = MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last);
    print(multipartFile.length);
    print(filePath.split("/").last);

    var url = "entry.cgi?api=SYNO.FileStation.Upload&method=upload&version=2"; //&_sid=${Util.sid}
    // var url = "entry.cgi";
    // var data = {
    //   "api": "SYNO.FileStation.Upload",
    //   "version": 2,
    //   "method": "upload",
    //   "_sid": Util.sid,
    //   "overwrite": "false",
    //   "path": uploadPath,
    //   "mtime": DateTime.now().millisecondsSinceEpoch,
    //   "size": await file.length(),
    //   "file": MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last, contentType: MediaType.parse("image/png")),
    // };
    var data = {
      "_sid": Util.sid,
      "mtime": DateTime.now().millisecondsSinceEpoch,
      "overwrite": "true",
      "path": uploadPath,
      "size": await file.length(),
      "file": MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last, contentType: MediaType.parse("image/png")),
    };
    var result = await Util.upload(url, data: data, cancelToken: cancelToken, onSendProgress: onSendProgress);
    // print(result);
    return result;
  }
}
