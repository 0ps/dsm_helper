import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'function.dart';

class Api {
  static Future<Map> login({String host, String account, String password}) async {
    var data = {
      "account": account,
      "passwd": password,
      "version": 6,
      "api": "SYNO.API.Auth",
      "method": "login",
      "session": "FileStation",
    };
    print(data);
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
  static Future<Map> deleteTask(String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Delete"',
      "method": '"start"',
      "accurate_progress": "true",
      "recursive": "true",
      "version": 2,
      "_sid": Util.sid,
      "path": path,
    });
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

  static Future<Map> upload(String uploadPath, String filePath) async {
    File file = File(filePath);
    var permission = await checkPermission(uploadPath, filePath);
    MultipartFile multipartFile = MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last);
    print(multipartFile.length);
    print(filePath.split("/").last);

    // var url = "entry.cgi?api=SYNO.FileStation.Upload&method=upload&version=2&_sid=${Util.sid}";
    var url = "entry.cgi";
    var data = {
      "api": "SYNO.FileStation.Upload",
      "version": 2,
      "method": "upload",
      "_sid": Util.sid,
      "overwrite": "false",
      "path": uploadPath,
      "mtime": DateTime.now().millisecondsSinceEpoch,
      "size": await file.length(),
      "file": MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last, contentType: MediaType.parse("image/png")),
    };
    // var data = {
    //   "overwrite": "false",
    //   "path": MultipartFile.fromString(uploadPath),
    //   // "create_parents": true,
    //   // "path": uploadPath,
    //   "mtime": DateTime.now().millisecondsSinceEpoch,
    //   // "create_parents": false,
    //   "size": await file.length(),
    //   "file": MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last, contentType: MediaType.parse("image/png")),
    // };
    print(data);
    var result = await Util.upload(url, data: data);
    print(result);
    return permission;
  }
}
