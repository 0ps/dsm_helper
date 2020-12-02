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
}
