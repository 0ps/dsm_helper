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

  static Future<Map> stareList() async {
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
}
