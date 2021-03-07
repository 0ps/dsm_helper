import 'dart:async';
import 'function.dart';

class MomentsApi {
  static Future<Map> timeline() async {
    Map<String, dynamic> data = {
      "timeline_group_unit": '"day"',
      "api": '"SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Browse.Timeline"',
      "method": '"get"',
      "version": Util.version == 7 ? 2 : 1,
      "_sid": Util.sid,
    };
    var res = await Util.post("entry.cgi", data: data);
    return res;
  }

  //offset=0&limit=5000&additional=%5B%22thumbnail%22%2C%22resolution%22%2C%22orientation%22%2C%22video_convert%22%2C%22video_meta%22%5D&start_time=1575417600&end_time=1577231999&api=%22SYNO.Photo.Browse.Item%22&method=%22list%22&version=3
  static Future<Map> photos({int year, int month, int day, int albumId}) async {
    Map<String, dynamic> data = {
      "offset": 0,
      "limit": 5000,
      "additional": '["thumbnail","resolution","orientation","video_convert","video_meta","address"]',
      "api": '"SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Browse.Item"',
      "method": '"list"',
      "version": Util.version == 7 ? 1 : 2,
      "_sid": Util.sid,
    };
    if (year != null && month != null && day != null) {
      int start = DateTime(year, month, day, 8).secondsSinceEpoch;
      int end = start + 60 * 60 * 24;
      data['start_time'] = start;
      data['end_time'] = end;
    }
    if (albumId != null) {
      data['album_id'] = albumId;
    }
    var res = await Util.post("entry.cgi", data: data);
    return res;
  }

  static Future<Map> category() async {
    Map<String, dynamic> data = {
      "api": '"SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Browse.Category"',
      "method": '"get"',
      "version": 1,
      "_sid": Util.sid,
    };
    var res = await Util.post("entry.cgi", data: data);
    return res;
  }

  static Future<Map> album({
    int offset: 0,
    int limit: 5000,
    String sortBy: "create_time",
    String sortDirection: "desc",
    bool shared: false,
  }) async {
    Map<String, dynamic> data = {
      "additional": '["thumbnail"]',
      "offset": offset,
      "limit": limit,
      "shared": shared,
      "sort_by": '"$sortBy"',
      "sort_direction": '"$sortDirection"',
      "api": '"SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Browse.Album"',
      "method": '"list"',
      "version": Util.version == 7 ? 1 : 2,
      "_sid": Util.sid,
    };
    var res = await Util.post("entry.cgi", data: data);
    return res;
  }

  //start_time=1577145600&end_time=1577231999&api=%22SYNO.Photo.Browse.Timeline%22&method=%22get_geocoding%22&version=1
  static Future<Map> location(int year, int month, int day) async {
    int start = DateTime(year, month, day, 8).secondsSinceEpoch;
    int end = start + 60 * 60 * 24 - 1;
    Map<String, dynamic> data = {
      "start_time": start,
      "end_time": end,
      "api": '"SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Browse.Timeline"',
      "method": '"get_geocoding"',
      "version": 1,
      "_sid": Util.sid,
    };
    var res = await Util.post("entry.cgi", data: data);
    return res;
  }
}
