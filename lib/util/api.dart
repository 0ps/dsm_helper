import 'dart:async';

import 'function.dart';

class Api {
  static Future<Map> login({String host, String account, String password}) async {
    return await Util.get("auth.cgi", host: host, data: {
      "account": account,
      "passwd": password,
      "version": 6,
      "api": "SYNO.API.Auth",
      "method": "login",
    });
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
  static Future<Map> delete(String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Delete"',
      "method": '"start"',
      "version": 2,
      "_sid": Util.sid,
      "path": path,
    });
  }

  static Future<Map> dirSizeTask(String path) async {
    Timer timer;
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
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"parallel"',
      "compound": '[{"api":"SYNO.Core.System.Utilization","method":"get","version":1,"type":"current","resource":["cpu","memory","network","disk"]},{"api":"SYNO.Core.System","method":"info","version":1,"type":"storage"},{"api":"SYNO.Core.CurrentConnection","method":"list","sort_direction":"DESC","sort_by":"time","version":1}]',
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }
}
