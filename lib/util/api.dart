import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'function.dart';
import 'package:http_parser/http_parser.dart';

class Api {
  static Future<Map> update(String buildNumber) async {
    if (Platform.isAndroid) {
      var res = await Util.get("https://dsm.flutter.fit/version", host: "https://dsm.flutter.fit");
      if (res != null) {
        if (int.parse(buildNumber) < res['data']['build']) {
          return {
            "code": 1,
            "msg": "版本更新",
            "data": res['data'],
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

  static Future<Map> payment() async {
    var res = await Util.get("https://dsm.flutter.fit/payment", host: "https://dsm.flutter.fit");
    return res;
  }

  static Future<Map> login({String host, String account, String password, String otpCode: "", CancelToken cancelToken, bool rememberDevice: false, String cookie}) async {
    var data = {
      "account": account,
      "passwd": password,
      "otp_code": otpCode,
      "version": 4,
      "api": "SYNO.API.Auth",
      "method": "login",
      "session": "webui",
      "enable_device_token": rememberDevice ? "yes" : "no",
    };
    return await Util.get("auth.cgi", host: host, data: data, cancelToken: cancelToken, cookie: cookie);
  }

  static Future<Map> shareList({List<String> additional = const ["perm", "time", "size"], CancelToken cancelToken, String sid, bool checkSsl, String cookie, String host}) async {
    print(host);
    return await Util.post(
      "entry.cgi",
      data: {
        "api": '"SYNO.FileStation.List"',
        "method": '"list_share"',
        "version": 2,
        "_sid": sid ?? Util.sid,
        "offset": 0,
        "limit": 1000,
        "sort_by": '"name"',
        "sort_direction": '"asc"',
        "additional": jsonEncode(additional),
      },
      cancelToken: cancelToken,
      cookie: cookie,
      host: host,
      checkSsl: checkSsl,
    );
  }

  static Future<Map> shareCore({List<String> additional = const []}) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.Core.Share"',
      "method": '"list"',
      "version": 1,
      "_sid": Util.sid,
      "shareType": '"all"',
      "additional": jsonEncode(additional),
    });
  }

  static Future<Map> addSharedFolder(
    String name,
    String volPath,
    String desc, {
    bool encryption = false,
    String password = "",
    bool recycleBin = false,
    bool recycleBinAdminOnly = false,
    bool hidden: false,
    bool hideUnreadable: false,
    bool enableShareCow: false,
    bool enableShareCompress: false,
    bool enableShareQuota: false,
    String shareQuota: "",
  }) async {
    //"{"name":"test","vol_path":"/volume3","desc":"test","hidden":true,"enable_recycle_bin":true,"recycle_bin_admin_only":true,"hide_unreadable":true,"enable_share_cow":true,"enable_share_compress":true,"share_quota":1024,"name_org":""}"
    Map shareInfo = {
      "name": "$name",
      "vol_path": volPath,
      "desc": desc,
      "name_org": "",
    };
    if (encryption) {
      shareInfo['encryption'] = true;
      shareInfo['enc_passwd'] = password;
    }
    if (recycleBin) {
      shareInfo['enable_recycle_bin'] = true;
    }
    if (recycleBinAdminOnly) {
      shareInfo['recycle_bin_admin_only'] = true;
    }
    if (hidden) {
      shareInfo['hidden'] = true;
    }
    if (hideUnreadable) {
      shareInfo['hide_unreadable'] = true;
    }
    if (enableShareCow) {
      shareInfo['enable_share_cow'] = true;
      if (enableShareCompress) {
        shareInfo['enable_share_compress'] = true;
      }
    }
    if (enableShareQuota) {
      shareInfo['share_quota'] = num.parse(shareQuota);
    }
    print(shareInfo);
    //"{"name":"testc","vol_path":"/volume3","desc":"bjxjbddb","enable_share_cow":true,"enable_share_compress":true,"share_quota":1024,"encryption":true,"enc_passwd":""}"
    var data = {
      "api": '"SYNO.Core.Share"',
      "method": '"create"',
      "version": 1,
      "_sid": Util.sid,
      "name": name,
      "shareinfo": jsonEncode(shareInfo),
    };
    return await Util.post("entry.cgi", data: data);
  }

  // api: SYNO.Core.User.PasswordConfirm
  // method: auth
  // version: 1
  // __cIpHeRtExT: {"rsa":"DgxTALmFkPtaeA0Koo7ZT6WO0rObNh+AnHCfsN/AHcLh1JnInMNfVbXIDyWVDbPYUtlFh/mzdJCXh1/i/IPoMo3aR17zyJ89FJ/fVhT3/Hcw4kaNP6cZDTW259EZiJ61HCJ+UWsTRLfafhuCZtu+5wMyEzelgcf9nipu5PdNv6tDjeYpL2q3z36OJL70BK0+m+R9ogaua6yMIk+0soPHUlqLJ6pq77ZoYFob1u08v9mNGKIUPanfFk8VZcxbKCZOWquHFYmKf+fry0/Ip4Zn7FhzDVZdQD/Vu0zP66Sf4cdUgjmepxedonFkiVW79DqssnQUqprriFOosQISZlZjSuLTfLEN9SvZB3WCGeoy8NVu/PfN4uOUqktNPB1nre0S5lERbnDpHl2DVAry8MouGNnNSrJOakU3QRCtXwwhFnw2aHZ0uzAY9+Rybb6hSMMnoYyiwAb/rmRq+OlGOx9GdAnNMS1Ddhs61+YCMoYXcdyPqyHR5VrjTiPptej9KXzwIio9U+InCJXseRqvhIVOJWaJrz7Nw5rxrvJUC4llV48QdMRX0y0GFeQyFUkqMwvX8KQn/6EtNUVzNrm+NmPBVTlwhGcryUMMlrLLNzzUiOBTWVYcJxSljRSMhlgm5tP2E8l6Wp1660AizbspCI7lvYCYHGG4EjTcjIhkAUh/USs=","aes":"U2FsdGVkX18vXNyLWW8eyi8S8CEgOStKeKSsEBYXFStQM0JcSH2K7TKTiQHa270bzwuTUDwxxOIsRVNFnvGXrQlBl7+KdPfqy/pIFTu1UKg="}
  static Future<Map> deleteSharedFolder(List<String> name) async {
    var data = {
      "api": '"SYNO.Core.Share"',
      "method": '"delete"',
      "version": 1,
      "_sid": Util.sid,
      "name": json.encode(name),
    };
    return await Util.post("entry.cgi", data: data);
  }

  // static Future<Map> fileStationInfo(String taskId) async {
  //   return await Util.post("entry.cgi", data: {
  //     "taskid": taskId,
  //     "api": '"SYNO.FileStation.Delete"',
  //     "method": '"status"',
  //     "version": 2,
  //     "_sid": Util.sid,
  //   });
  // }

  static Future<Map> fileList(String path, {String sortBy = "name", String sortDirection = "asc"}) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.List"',
      "method": '"list"',
      "version": 2,
      "_sid": Util.sid,
      "offset": 0,
      "folder_path": path,
      "filetype": '"all"',
      "limit": 1000,
      "sort_by": '"$sortBy"',
      "sort_direction": '"$sortDirection"',
      "additional": '["perm", "time", "size","mount_point_type","real_path"]',
    });
  }

  static Future<Map> virtualFolder() async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.VirtualFolder"',
      "method": '"list"',
      "version": 2,
      "_sid": Util.sid,
      "node": "fm_rf_root",
      "type": '["cifs","nfs"]',
      // "status_filter": '"all"',
      "additional": '["real_path","owner","time","perm","mount_point_type","volume_status"]',
    });
  }

  static Future<Map> unmountFolder(String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Mount"',
      "method": '"unmount"',
      "version": 1,
      "_sid": Util.sid,
      "mount_point": '"$path"',
      "is_mount_point": true,
      // "status_filter": '"all"',
      "mount_type": '"remote"',
    });
  }

  static Future<Map> favoriteList() async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Favorite"',
      "method": '"list"',
      "version": 2,
      "_sid": Util.sid,
      "offset": 0,
      "limit": 1000,
      // "status_filter": '"all"',
      "additional": '["perm", "time", "size","real_path"]',
    });
  }

  static Future<Map> favoriteAdd(String name, String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Favorite"',
      "method": '"add"',
      "version": 2,
      "_sid": Util.sid,
      "name": name,
      "path": path,
      "index": -1,
    });
  }

  static Future<Map> favoriteRename(String path, String name) async {
    var data = {
      "api": '"SYNO.FileStation.Favorite"',
      "method": '"edit"',
      "version": 2,
      "path": path,
      "name": name,
      "index": -1,
      "_sid": Util.sid,
    };
    var result = await Util.get("entry.cgi", data: data);
    return result;
  }

  static Future<Map> favoriteDelete(String path) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.Favorite"',
      "method": '"delete"',
      "version": 2,
      "_sid": Util.sid,
      "path": path,
    });
  }

  ///webapi/FileStation/file_delete.cgi?api=SYNO.FileStation.Delete&version=1&method=start&path=%2Fvideo%2Fdel_folder
  static Future<Map> deleteTask(List path) async {
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

//searchType: simple,dir,file,advance
  //doc:docx,wri,rtf,xla,xlb,xlc,xld,xlk,xll,xlm,xlt,xlv,xlw,xlsx,xlsm,xlsb,xltm,xlam,pptx,pps,ppsx,pdf,txt,doc,xls,ppt,odt,ods,odp,odg,odc,odf,odb,odi,odm,ott,ots,otp,otg,otc,otf,oti,oth,potx,pptm,ppsm,potm,dotx,dot,pot,ppa,xltx,docm,dotm,eml,msgc,c,cc,cpp,cs,cxx,ada,coffee,cs,css,js,json,lisp,markdown,ocaml,pl,py,rb,sass,scala,r,tex,conf,csv,sub,srt,md,log
  //video: 3gp,3g2,asf,dat,divx,dvr-ms,m2t,m2ts,m4v,mkv,mp4,mts,mov,qt,tp,trp,ts,vob,wmv,xvid,ac3,amr,rm,rmvb,ifo,mpeg,mpg,mpe,m1v,m2v,mpeg1,mpeg2,mpeg4,ogv,webm,flv,avi,swf,f4v,
  //image:ico,tif,tiff,ufo,raw,arw,srf,sr2,dcr,k25,kdc,cr2,crw,nef,mrw,ptx,pef,raf,3fr,erf,mef,mos,orf,rw2,dng,x3f,jpg,jpg,jpeg,png,gif,bmp,psd,
  //audio:aac,flac,m4a,m4b,aif,ogg,pcm,wav,cda,mid,mp2,mka,mpc,ape,ra,ac3,dts,wma,mp3,mp1,mp2,mpa,ram,m4p,aiff,dsf,dff,m3u,wpl,aiff,
  //web:html,htm,css,actproj,ad,akp,applescript,as,asax,asc,ascx,asm,asmx,asp,aspx,asr,jsx,xml,xhtml,mhtml,cs,js
  //exe,
  //iso:bin,img,mds,nrg,daa,iso,
  //zip:7z,bz2,gz,zip,tgz,tbz,rar,tar
  static Future<Map> searchTask(List<String> paths, String pattern, {bool recursive: true, bool searchContent: false, String searchType: "simple"}) async {
    var data = {
      "folder_path": json.encode(paths),
      "api": "SYNO.FileStation.Search",
      "method": '"start"',
      "pattern": pattern,
      "recursive": recursive,
      "search_content": searchContent,
      "search_type": '"$searchType"',
      "version": 2,
      "_sid": Util.sid,
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> searchResult(String taskId) async {
    var data = {
      "additional": json.encode(["real_path", "size", "owner", "time", "perm", "type"]),
      "taskid": taskId,
      "offset": 0,
      "limit": 1000,
      "filetype": "all",
      "api": '"SYNO.FileStation.Search"',
      "method": '"list"',
      "version": 2,
      "_sid": Util.sid,
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
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

  static Future<Map> copyMoveTask(List path, String destFolderPath, bool remove) async {
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

  static Future<Map> createShare(
    List<String> path, {
    bool fileRequest = false,
    String requestName,
    String requestInfo,
  }) async {
    var data = {
      "api": '"SYNO.FileStation.Sharing"',
      "method": '"create"',
      "version": 3,
      "_sid": Util.sid,
      "path": jsonEncode(path),
    };
    if (fileRequest) {
      data['file_request'] = true;
      data['request_name'] = requestName;
      data['request_info'] = requestInfo;
    }
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> editShare(
    String path,
    List<String> id,
    List<String> url,
    DateTime dateExpired,
    DateTime dateAvailabe,
    String expireTimes, {
    bool fileRequest = false,
    String requestName,
    String requestInfo,
  }) async {
    var data = {
      "path": path,
      "url": jsonEncode(url),
      "protect_type_enable": '"false"',
      "date_expired": dateExpired == null ? "" : '"${dateExpired.format("Y-m-d H:i:s")}"',
      "expire_times": expireTimes ?? "",
      "protect_type": "none",
      "redirect_uri": null,
      "id": jsonEncode(id),
      "date_available": dateAvailabe == null ? "" : '"${dateAvailabe.format("Y-m-d H:i:s")}"',
      "api": '"SYNO.FileStation.Sharing"',
      "method": '"edit"',
      "version": 3,
      "_sid": Util.sid,
    };
    if (fileRequest) {
      data['file_request'] = true;
      data['request_name'] = requestName;
      data['request_info'] = requestInfo;
    }
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> listShare() async {
    var data = {
      "offset": 0,
      "limit": 100,
      "filter_type": "SYNO.SDS.App.FileStation3.Instance,SYNO.SDS.App.SharingUpload.Application",
      "api": '"SYNO.FileStation.Sharing"',
      "method": '"list"',
      "version": 3,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> deleteShare(
    List<String> id,
  ) async {
    var data = {
      "id": jsonEncode(id),
      "api": '"SYNO.FileStation.Sharing"',
      "method": '"delete"',
      "version": 3,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
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

  static Future<Map> extractTask(String filePath, String folderPath, {String password}) async {
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
    if (password != null) {
      data['password'] = '"$password"';
    }
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

  static Future<Map> systemInfo(List widgets) async {
    List apis = [];
    if (widgets.contains("SYNO.SDS.ResourceMonitor.Widget")) {
      apis.add({
        "api": "SYNO.Core.System.Utilization",
        "method": "get",
        "version": 1,
        "type": "current",
        "resource": ["cpu", "memory", "network", "disk"]
      });
      if (widgets.contains("SYNO.SDS.SystemInfoApp.StorageUsageWidget")) {
        apis.add({
          "api": "SYNO.Storage.CGI.Storage",
          "method": "load_info",
          "version": 1,
        });
      }
      if (widgets.contains("SYNO.SDS.SystemInfoApp.ConnectionLogWidget")) {
        apis.add({
          "api": "SYNO.Core.CurrentConnection",
          "method": "list",
          "sort_direction": "DESC",
          "sort_by": "time",
          "version": 1,
        });
      }
      if (widgets.contains("SYNO.SDS.TaskScheduler.TaskSchedulerWidget")) {
        apis.add({
          "api": "SYNO.Core.TaskScheduler",
          "sort_by": "next_trigger_time",
          "sort_direction": "ASC",
          "start": 0,
          "limit": 50,
          "method": "list",
          "version": 1,
        });
      }
      if (widgets.contains("SYNO.SDS.SystemInfoApp.RecentLogWidget")) {
        apis.add({
          "api": "SYNO.Core.SyslogClient.Status",
          "start": 0,
          "limit": 50,
          "widget": true,
          "dir": "desc",
          "method": "latestlog_get",
          "version": 1,
        });
      }
      if (widgets.contains("SYNO.SDS.SystemInfoApp.FileChangeLogWidget")) {
        apis.add({
          "start": 0,
          "limit": 50,
          "target": "LOCAL",
          "logtype": "ftp,filestation,webdav,cifs,tftp,afp",
          "dir": "desc",
          "api": "SYNO.Core.SyslogClient.Log",
          "method": "list",
          "version": 1,
        });
      }
    }
    apis.add({
      "api": "SYNO.Core.System",
      "method": "info",
      "version": 1,
    });
    apis.add({
      "action": "load",
      "lastRead": DateTime.now().secondsSinceEpoch,
      "lastSeen": DateTime.now().secondsSinceEpoch,
      "api": "SYNO.Core.DSMNotify",
      "method": "notify",
      "version": 1,
    });
    apis.add({
      "api": "SYNO.Core.AppNotify",
      "method": "get",
      "version": 1,
    });
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

  static Future<Map> notifyStrings() async {
    var result = await Util.post("entry.cgi", data: {
      "pkgName": '""',
      "api": "SYNO.Core.DSMNotify.Strings",
      "method": "get",
      "version": 1,
    });
    return result;
  }

  static Future<Map> notify() async {
    var result = await Util.post("entry.cgi", data: {
      "action": "load",
      "lastRead": DateTime.now().secondsSinceEpoch,
      "lastSeen": DateTime.now().secondsSinceEpoch,
      "api": "SYNO.Core.DSMNotify",
      "method": "notify",
      "version": 1,
    });
    return result;
  }

  static Future<Map> storage() async {
    var result = await Util.post("entry.cgi", data: {
      "api": "SYNO.Storage.CGI.Storage",
      "method": "load_info",
      "version": 1,
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

  static Future<Map> clearNotify() async {
    var result = await Util.post("entry.cgi", data: {
      "api": '"SYNO.Core.DSMNotify"',
      "method": '"notify"',
      "version": 1,
      "_sid": Util.sid,
      "action": '"apply"',
      "clean": '"all"',
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

  static Future<Map> info({String query}) async {
    Map<String, dynamic> data = {
      "_dc": DateTime.now().millisecond,
    };
    if (query != null) {
      data['query'] = query;
    }

    var result = await Util.get("http://pan.fmtol.com:5000/webman/modules/SystemInfoApp/SystemInfo.cgi", data: data);
    return result;
  }

  static Future<Map> networkInfo() async {
    var result = await Util.post("entry.cgi", data: {
      "api": '"SYNO.Core.System"',
      "method": '"info"',
      "version": 1,
      "type": "network",
      "_sid": Util.sid,
    });
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

  static Future<Map> power(String method, bool force) async {
    var data = {
      "api": '"SYNO.Core.System"',
      "force": force,
      "local": true,
      "version": 1,
      "method": method,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> setTerminal(bool ssh, bool telnet, String sshPort) async {
    var data = {
      "api": '"SYNO.Core.Terminal"',
      "enable_telnet": telnet,
      "enable_ssh": ssh,
      "ssh_port": sshPort,
      "version": 3,
      "method": "set",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> terminalInfo() async {
    var data = {
      "api": "SYNO.Core.Terminal",
      "version": 3,
      "method": "get",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> upload(String uploadPath, String filePath, CancelToken cancelToken, Function(int, int) onSendProgress) async {
    File file = File(filePath);
    // var permission = await checkPermission(uploadPath, filePath);
    MultipartFile multipartFile = MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last);
    // var url = "entry.cgi?api=SYNO.FileStation.Upload&method=upload&version=2&_sid=${Util.sid}";
    var url = "entry.cgi";
    var data = {
      "api": "SYNO.FileStation.Upload",
      "method": "upload",
      "version": 3,
      "path": uploadPath,
      "create_parents": false,
      "size": file.lengthSync(),
      "mtime": file.lastModifiedSync().millisecondsSinceEpoch,
      "overwrite": "overwrite",
      "file": multipartFile,
      // "_sid": Util.sid,
    };
    // var data = {
    //   "_sid": Util.sid,
    //   "mtime": DateTime.now().millisecondsSinceEpoch,
    //   "overwrite": true,
    //   "path": uploadPath,
    //   "size": file.lengthSync(),
    //   "file": multipartFile,
    // };
    var result = await Util.upload(url, data: data, cancelToken: cancelToken, onSendProgress: onSendProgress);
    // print(result);
    return result;
  }

  static Future<Map> uploadWeb(String uploadPath, String filePath, CancelToken cancelToken, Function(int, int) onSendProgress) async {
    File file = File(filePath);
    MultipartFile multipartFile = MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last);
    var url = "entry.cgi?api=SYNO.FileStation.Upload&method=upload&version=2";
    var data = {
      "mtime": file.lastModifiedSync().millisecondsSinceEpoch,
      "overwrite": true,
      "path": uploadPath, //使用英文路径成功，中文路径失败
      "size": file.lengthSync(),
      "file": multipartFile,
    };
    var result = await Util.upload(url, data: data, cancelToken: cancelToken, onSendProgress: onSendProgress);
    return result;
  }

  static Future<Map> volumes() async {
    var data = {
      "limit": -1,
      "offset": 0,
      "location": '"internal"',
      "api": "SYNO.Core.Storage.Volume",
      "version": 1,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> packages({bool others = false, int version: 1}) async {
    var data = {
      "updateSprite": true,
      "blforcereload": false,
      "blloadothers": others,
      "api": "SYNO.Core.Package.Server",
      "version": version,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> installedPackages({int version: 1}) async {
    List<String> additional = [
      "description",
      "description_enu",
      "beta",
      "distributor",
      "distributor_url",
      "maintainer",
      "maintainer_url",
      "dsm_apps",
      "report_beta_url",
      "support_center",
      "startable",
      "installed_info",
      "support_url",
      "is_uninstall_pages",
      "install_type",
      "autoupdate",
      "silent_upgrade",
      "installing_progress",
      "ctl_uninstall",
      "status",
      "url",
    ];
    if (version == 2) {
      additional.add("updated_at");
    }
    var data = {
      "additional": jsonEncode(additional),
      "polling_interval": 15,
      // "force_set_params": true,
      "api": "SYNO.Core.Package",
      "version": version,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> launchedPackages() async {
    var data = {
      "action": "load",
      "load_disabled_port": true,
      "api": "SYNO.Core.Polling.Data",
      "version": 1,
      "method": "get",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> launchPackage(String id, String app, String method) async {
    var data = {
      "id": id,
      "api": "SYNO.Core.Package.Control",
      "version": 1,
      "method": method,
      "_sid": Util.sid,
    };
    if (method == "start") {
      data["dsm_apps"] = jsonEncode([app]);
    }
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> installPackageTask(String name, String path) async {
    var data = {
      "name": name,
      "blqinst": true,
      "volume_path": path,
      "is_syno": true,
      "beta": false,
      "installrunpackage": true,
      "api": "SYNO.Core.Package.Installation",
      "version": 1,
      "method": "install",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> installPackageStatus(String taskId) async {
    var data = {
      "task_id": taskId,
      "api": "SYNO.Core.Package.Installation",
      "version": 1,
      "method": "status",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  //pkgs: [{"pkg":"SynoFinder","beta":false}]
  // api: SYNO.Core.Package.Installation
  // method: get_queue
  // version: 1
  static Future<Map> installPackageQueue(String pkg) async {
    var data = {
      "pkgs": '[{"pkg":"$pkg","beta":false}]',
      "api": "SYNO.Core.Package.Installation",
      "version": 1,
      "method": "get_queue",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> uninstallPackageInfo(String id) async {
    var data = {
      "id": id,
      "additional": jsonEncode(["uninstall_pages"]),
      "api": "SYNO.Core.Package",
      "version": 1,
      "method": "get",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> uninstallPackageTask(String id, {Map extra}) async {
    var data = {
      "id": id,
      "api": "SYNO.Core.Package.Uninstallation",
      "version": 1,
      "method": "uninstall",
      "_sid": Util.sid,
    };
    if (extra != null) {
      String extraStr = jsonEncode(jsonEncode(extra));
      data['extra_values'] = extraStr;
    }

    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> taskScheduler() async {
    var data = {
      "api": "SYNO.Core.TaskScheduler",
      "offset": 0,
      "limit": -1,
      "sort_by": "next_trigger_time",
      "sort_direction": "DESC",
      "version": 1,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> taskRun(List<int> task) async {
    var data = {
      "api": "SYNO.Core.TaskScheduler",
      "version": 1,
      "method": "run",
      "task": jsonEncode(task),
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> taskRecord(int task) async {
    var data = {
      "api": "SYNO.Core.TaskScheduler",
      "version": 1,
      "offset": 0,
      "limit": 2,
      "method": "view",
      "id": task,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> taskEnable(int task, bool enable) async {
    var status = [
      {
        "id": task,
        "enable": enable,
      }
    ];
    var data = {
      "api": "SYNO.Core.TaskScheduler",
      "version": 1,
      "method": "set_enable",
      "status": jsonEncode(status),
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> users() async {
    var data = {
      "api": "SYNO.Core.User",
      "offset": 0,
      "limit": -1,
      "additional": jsonEncode(["email", "description", "expired"]),
      "version": 1,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> userGroups() async {
    var data = {
      "api": "SYNO.Core.Group",
      "offset": 0,
      "limit": -1,
      "name_only": false,
      "version": 1,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> userSetting(Map save) async {
    String dataStr = jsonEncode(jsonEncode(save));
    var data = {
      "api": "SYNO.Core.UserSettings",
      "data": dataStr, //r'"{\"SYNO.SDS._Widget.Instance\":{\"modulelist\":[\"SYNO.SDS.SystemInfoApp.SystemHealthWidget\",\"SYNO.SDS.SystemInfoApp.ConnectionLogWidget\",\"SYNO.SDS.ResourceMonitor.Widget\"]}}"',
      "method": "apply",
      "version": 1,
      "_sid": Util.sid,
    };
    print(dataStr);
    print(data['data']);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> mediaConverter(String method, {int hours}) async {
    var data = {"api": "SYNO.Core.MediaIndexing.MediaConverter", "method": method, "version": 1};
    if (hours != null) {
      data['delay_hours'] = hours;
    }
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> utilization({String sid, bool checkSsl, String cookie, String host}) async {
    var data = {
      "api": "SYNO.Core.System.Utilization",
      "method": "get",
      "version": 1,
      "type": "current",
      "resource": ["cpu", "memory", "network", "lun", "disk", "space"],
      "_sid": sid ?? Util.sid,
    };
    return await Util.post("entry.cgi", data: data, checkSsl: checkSsl, cookie: cookie, host: host);
  }

  //SYNO.Core.System.Process
  static Future<Map> process() async {
    var data = {
      "api": "SYNO.Core.System.Process",
      "method": "list",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> processGroup() async {
    var data = {
      "api": "SYNO.Core.System.ProcessGroup",
      "method": "service_info",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> cluster(String method) async {
    var data = {
      "api": "SYNO.Virtualization.Cluster",
      "method": method,
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> checkPowerOn(String guestId) async {
    var data = {
      "api": '"SYNO.Virtualization.Guest.Action"',
      "method": '"check_poweron"',
      "guest_id": '"$guestId"',
      "version": 1,
      "_sid": Util.sid,
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> vmmPower(String guestId, String action) async {
    var data = {
      "api": '"SYNO.Virtualization.Guest.Action"',
      "method": '"pwr_ctl"',
      "guest_id": '"$guestId"',
      "action": action,
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> dockerContainerInfo() async {
    List apis = [
      {"api": "SYNO.Docker.Container", "method": "list", "version": 1, "limit": -1, "offset": 0, "type": "all"},
      {"api": "SYNO.Docker.Container.Resource", "method": "get", "version": 1},
      {"api": "SYNO.Core.System.Utilization", "method": "get", "version": 1},
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

  static Future<Map> dockerImageInfo() async {
    List apis = [
      {"api": "SYNO.Docker.Image", "method": "list", "version": 1, "limit": -1, "offset": 0, "show_dsm": false},
      {"api": "SYNO.Docker.Registry", "method": "get", "version": 1, "limit": -1, "offset": 0}
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

  static Future<Map> dockerDetail(String name, String method) async {
    var data = {
      "api": 'SYNO.Docker.Container',
      "method": method,
      "name": '"$name"',
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> dockerLog(String name, String method, {String date}) async {
    var data = {
      "api": 'SYNO.Docker.Container.Log',
      "method": method,
      "name": '"$name"',
      "version": 1,
      "_sid": Util.sid,
    };
    if (method == "get") {
      data['sort_dir'] = '"ASC"';
      data['date'] = '"$date"';
      data['limit'] = 1000;
      data['offset'] = 0;
    }
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> dockerPower(String name, String action, {bool preserveProfile}) async {
    var data = {
      "api": 'SYNO.Docker.Container',
      "method": action,
      "name": '"$name"',
      "version": 1,
      "_sid": Util.sid,
    };
    if (action == "signal") {
      data['signal'] = 9;
    }
    if (action == "delete") {
      data['preserve_profile'] = preserveProfile;
    }
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> lastLog(int start, int limit) async {
    var data = {
      "api": 'SYNO.Core.SyslogClient.Status',
      "start": start,
      "limit": limit,
      "method": "latestlog_get",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> log(
    int start,
    int limit, {
    String target: "LOCAL",
    String logType: "system,netbackup",
    int dateFrom: 0,
    int dateTo: 0,
    String keyword: "",
    String level: "",
  }) async {
    var data = {
      "api": 'SYNO.Core.SyslogClient.Log',
      "start": start,
      "limit": limit,
      "method": "list",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> logHistory() async {
    var data = {
      "api": 'SYNO.LogCenter.History',
      "offset": 0,
      "limit": 50,
      "method": "list",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> reward() async {
    return await Util.get("https://dsm.flutter.fit/reward", host: "https://dsm.flutter.fit");
  }

  static Future<Map> downloadStationInfo() async {
    List apis = [
      {
        "api": "SYNO.DownloadStation2.Task",
        "method": "list",
        "version": 2,
        "limit": 25,
        "offset": 0,
        "sort_by": "task_id",
        "order": "ASC",
        "additional": ["detail", "transfer"],
        "type": ["emule"],
        "type_inverse": true,
      },
      {
        "api": "SYNO.DownloadStation2.Task.Statistic",
        "method": "get",
        "version": 1,
        "type": ["emule"],
        "type_inverse": true,
      },
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

  //id: ["dbid_39"]
  // api: SYNO.DownloadStation2.Task
  // method: pause
  // version: 2
  static Future<Map> downloadTaskAction(List id, String action) async {
    var data = {
      "id": json.encode(id),
      "api": 'SYNO.DownloadStation2.Task',
      "method": action,
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadLocation() async {
    var data = {
      "api": 'SYNO.DownloadStation2.Settings.Location',
      "method": "get",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  //delete_condition  delete
  static Future<Map> downloadTaskCreate(String destination, String type, {String url, String filePath}) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task',
      "method": "create",
      "version": 2,
    };
    if (type == "file") {
      MultipartFile torrent = MultipartFile.fromFileSync(filePath, filename: filePath.split("/").last, contentType: MediaType.parse("application/octet-stream"));
      data['file'] = json.encode(["-1891550746"]);
      data["type"] = '"$type"';
      data["create_list"] = true;

      data['destination'] = '"$destination"';
      data['-1891550746'] = torrent;
      return await Util.upload("entry.cgi", data: data);
    } else {
      List<String> urls = url.split("\n");
      List<String> validUrls = [];
      for (String url in urls) {
        if (url.trim().isNotBlank) {
          validUrls.add(url.trim());
        }
      }
      data['type'] = '"$type"';
      data["create_list"] = true;
      data["url"] = json.encode(validUrls);
      data['destination'] = '"$destination"';
      data['_sid'] = Util.sid;
      return await Util.post("entry.cgi", data: data);
    }
  }

  //SYNO.DownloadStation2.Task.List
  static Future<Map> downloadFileList(String listId) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task.List',
      "list_id": listId,
      "method": "get",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadCreate(String listId, String destination, List selectedFile) async {
    destination = destination.substring(1);
    var data = {
      "api": 'SYNO.DownloadStation2.Task.List.Polling',
      "destination": '"$destination"',
      "list_id": '"$listId"',
      "selected": json.encode(selectedFile),
      "method": "download",
      "create_subfolder": true,
      "version": 2,
      "_sid": Util.sid,
    };
    print(data);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadDetail(String id) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task',
      "id": json.encode([id]),
      "additional": json.encode(["detail", "transfer"]),
      "method": "get",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadTracker(String id) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task.BT.Tracker',
      "task_id": '"$id"',
      "method": "list",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadTrackerAdd(String id, List<String> trackers) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task.BT.Tracker',
      "task_id": '"$id"',
      "method": "add",
      "tracker": json.encode(trackers),
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadPeer(String id) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task.BT.Peer',
      "task_id": '"$id"',
      "method": "list",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> downloadFile(String id) async {
    var data = {
      "api": 'SYNO.DownloadStation2.Task.BT.File',
      "offset": 0,
      "limit": 50,
      "sort_by": "name",
      "order": "ASC",
      "query": "",
      "task_id": '"$id"',
      "method": "list",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> trustDevice(String method) async {
    var data = {
      "api": 'SYNO.Core.TrustDevice',
      "method": method,
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  //SYNO.Core.NormalUser
  static Future<Map> normalUser(String method, {Map<String, dynamic> changedData}) async {
    var data = {
      "api": 'SYNO.Core.NormalUser',
      "method": method,
      "version": method == "get" ? 1 : 2,
      "_sid": Util.sid,
    };
    if (changedData != null) {
      data.addAll(changedData);
    }
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> externalDevice() async {
    List apis = [
      // {
      //   "api": "SYNO.Core.ExternalDevice.Storage.USB",
      //   "method": "list",
      //   "version": 1,
      //   "additional": ["all"]
      // },
      {
        "api": "SYNO.Core.ExternalDevice.Storage.eSATA",
        "method": "list",
        "version": 1,
        "additional": ["all"]
      },
      // {"api": "SYNO.Core.ExternalDevice.Storage.EUnit", "method": "list", "version": 1},
    ];
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> ejectEsata(String id) async {
    var data = {
      "dev_id": '"$id"',
      "api": 'SYNO.Core.ExternalDevice.Storage.eSATA',
      "method": "eject",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> smart(String device) async {
    var data = {
      "device": '"$device"',
      "api": 'SYNO.Storage.CGI.Smart',
      "method": "get_health_info",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> diskTestLog(String device) async {
    var data = {
      "sort_by": '"time"',
      "sort_direction": '"DESC"',
      "offset": 0,
      "limit": 30,
      "type": '"all"',
      "device": '"$device"',
      "api": 'SYNO.Core.Storage.Disk',
      "method": "disk_test_log_get",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> smartTestLog(String device) async {
    var data = {
      "device": '"$device"',
      "api": 'SYNO.Core.Storage.Disk',
      "method": "get_smart_test_log",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> doSmartTest(String device, String type) async {
    var data = {
      "device": '"$device"',
      "type": '"$type"',
      "api": 'SYNO.Core.Storage.Disk',
      "method": "do_smart_test",
      "version": 1,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> saveMail(String mail) async {
    var data = {
      "mail": '"$mail"',
      "api": 'SYNO.Core.OTP',
      "method": "save_mail",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> getQrCode(String account) async {
    var data = {
      "account": '"$account"',
      "api": 'SYNO.Core.OTP',
      "method": "get_qrcode",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> authOtpCode(String code) async {
    var data = {
      "code": '"$code"',
      "api": 'SYNO.Core.OTP',
      "method": "auth_tmp_code",
      "version": 2,
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> currentConnect() async {
    var data = {
      "start": 0,
      "limit": 50,
      "offset": 0,
      "action": "enum",
      "api": "SYNO.Core.CurrentConnection",
      "method": "get",
      "sort_direction": "DESC",
      "sort_by": "time",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> userQuota() async {
    var data = {
      "api": "SYNO.Core.PersonalSettings",
      "method": "quota",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> fileService() async {
    List apis = [
      {"api": "SYNO.Core.FileServ.SMB", "method": "get", "version": 3},
      {"api": "SYNO.Core.FileServ.AFP", "method": "get", "version": 1},
      {"api": "SYNO.Core.FileServ.NFS", "method": "get", "version": 2},
      {"api": "SYNO.Core.FileServ.FTP", "method": "get", "version": 3},
      {"api": "SYNO.Core.FileServ.FTP.SFTP", "method": "get", "version": 1},
      {"api": "SYNO.Core.BandwidthControl.Protocol", "method": "get", "version": 1, "protocol": "FTP"},
      {"api": "SYNO.Core.TFTP", "method": "get", "version": 1},
      {"api": "SYNO.Backup.Service.NetworkBackup", "method": "get", "version": 1},
      {"api": "SYNO.Core.BandwidthControl.Protocol", "method": "get", "version": 1, "protocol": "NetworkBackup"},
      {"api": "SYNO.Core.Directory.Domain", "method": "get", "version": 1},
      {
        "api": "SYNO.Core.Share",
        "method": "list",
        "version": 1,
        "additional": ["is_service_share"],
        "shareType": ["dec", "local", "usb", "sata", "cluster"]
      },
      {"api": "SYNO.Core.Service", "method": "get", "version": 1, "service_id": "pgsql"},
      {"api": "SYNO.Core.SyslogClient.FileTransfer", "method": "get", "version": 1},
      {"api": "SYNO.Core.Network", "method": "get", "version": 1},
      {"api": "SYNO.Core.FileServ.ReflinkCopy", "method": "get", "version": 1},
      {"api": "SYNO.Core.Web.DSM", "method": "get", "version": 2},
      {"api": "SYNO.Core.ExternalDevice.Printer.BonjourSharing", "method": "get", "version": 1},
      {"api": "SYNO.Core.FileServ.ServiceDiscovery", "method": "get", "version": 1},
      {"api": "SYNO.Core.FileServ.ServiceDiscovery.WSTransfer", "method": "get", "version": 1}
    ];
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> fileServiceLog(String protocol) async {
    var data = {
      "protocol": '"$protocol"',
      "api": "SYNO.Core.SyslogClient.FileTransfer",
      "method": "get_level",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> fileServiceLogSave(String protocol, Map logLevel) async {
    var data = {
      "protocol": '"$protocol"',
      "loglevel": json.encode(logLevel),
      "api": "SYNO.Core.SyslogClient.FileTransfer",
      "method": "set_level",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> fileServiceSave(Map smb, Map syslogClient, Map afp, Map nfs) async {
    List apis = [
      {"api": "SYNO.Core.FileServ.SMB", "method": "set", "version": 3, "enable_samba": smb['enable_samba'], "workgroup": smb['workgroup'], "disable_shadow_copy": smb['disable_shadow_copy'], "smb_transfer_log_enable": syslogClient['cifs']},
      {"api": "SYNO.Core.FileServ.AFP", "method": "set", "version": 1, "enable_afp": afp['enable_afp'], "afp_transfer_log_enable": syslogClient['afp']},
      {"api": "SYNO.Core.FileServ.NFS", "method": "set", "version": 2, "enable_nfs": nfs['enable_nfs'], "enable_nfs_v4": nfs['enable_nfs_v4'], "enable_nfs_v4_1": nfs['enable_nfs_v4'], "nfs_v4_domain": nfs['nfs_v4_domain']},
      {"api": "SYNO.Core.SyslogClient.FileTransfer", "method": "set", "version": 1, "cifs": syslogClient['cifs'], "afp": syslogClient['afp']},
    ];
    print(apis);
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> securityRule() async {
    var data = {
      "items": '"ALL"',
      "api": "SYNO.Core.SecurityScan.Status",
      "method": "rule_get",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> securitySystem() async {
    var data = {
      "api": "SYNO.Core.SecurityScan.Status",
      "method": "system_get",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> mediaReindex() async {
    var data = {
      "api": "SYNO.Core.MediaIndexing",
      "method": "reindex",
      "version": 1,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> mediaIndexStatus() async {
    List apis = [
      {"api": "SYNO.Core.MediaIndexing.ThumbnailQuality", "method": "get", "version": 1},
      {"api": "SYNO.Core.MediaIndexing", "method": "status", "version": 1}
    ];
    if (Util.version == 6) {
      apis.add(
        {"api": "SYNO.Core.MediaIndexing.MobileEnabled", "method": "get", "version": 1},
      );
    }
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> mediaIndexSet(String thumbQuality, bool mobileEnabled) async {
    List apis = [
      {"api": "SYNO.Core.MediaIndexing.ThumbnailQuality", "method": "set", "version": "1", "thumbnail_quality": '$thumbQuality'},
    ];
    if (Util.version == 6) {
      apis.add({"api": "SYNO.Core.MediaIndexing.MobileEnabled", "method": "set", "version": "1", "mobile_profile_enabled": mobileEnabled});
    }
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> quickConnect(String connectConnectID, {String baseUrl: "global.quickconnect.cn"}) async {
    print("connect:" + baseUrl);
    Dio dio = new Dio(
      new BaseOptions(
        baseUrl: "https://$baseUrl/",
        contentType: "text/plain",
      ),
    );
    String data = '''{
    "version":1,
    "command":"get_server_info",
    "serverID":"$connectConnectID",
    "id":"dsm",
    "get_ca_fingerprints":true
}''';
    Response response;
    try {
      response = await dio.post("Serv.php", data: data);
      if (response.data is String) {
        return json.decode(response.data);
      } else if (response.data is Map) {
        return response.data;
      } else {
        return response.data;
      }
    } on DioError catch (error) {
      print("请求出错");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
    }
  }

  static Future<Map> quickConnectCn(String connectConnectID, {String baseUrl: "cnc.quickconnect.cn"}) async {
    print("connectCN:" + baseUrl);
    Dio dio = new Dio(
      new BaseOptions(
        baseUrl: "https://$baseUrl/",
        contentType: "text/plain",
      ),
    );
    String data = '''{"version":1,"command":"request_tunnel","serverID":"$connectConnectID","id":"dsm","location":"cn","platform":"Android 11"}''';
    Response response;
    try {
      response = await dio.post("Serv.php", data: data);
      if (response.data is String) {
        return json.decode(response.data);
      } else if (response.data is Map) {
        return response.data;
      } else {
        return response.data;
      }
    } on DioError catch (error) {
      print("请求出错");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
    }
  }

  static Future<void> pingpong(String host, Function callback) async {
    var res = await Util.get("${host}webman/pingpong.cgi");
    if (res['success']) {
      callback(host);
    } else {
      callback(null);
    }
  }

  static Future<Map> powerStatus() async {
    List apis = [
      {"api": "SYNO.Core.Hardware.ZRAM", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.PowerRecovery", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.BeepControl", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.FanSpeed", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.Led.Brightness", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.Hibernation", "method": "get", "version": 1},
      {"api": "SYNO.Core.ExternalDevice.UPS", "method": "get", "version": 1},
      {"api": "SYNO.Core.Hardware.PowerSchedule", "method": "load", "version": 1}
    ];
    var result = await Util.post("entry.cgi", data: {
      "stop_when_error": false,
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  //poweron_tasks: [{"enabled":true,"weekdays":"0,1,2,3,4,5,6","hour":0,"min":0}]
  // poweroff_tasks: [{"enabled":true,"weekdays":"0,1,2,3,4,5,6","hour":5,"min":0}]
  // api: SYNO.Core.Hardware.PowerSchedule
  // method: save
  // version: 1
  static Future<Map> powerScheduleSave(List powerOns, List powerOffs) async {
    var result = await Util.post("entry.cgi", data: {
      "poweron_tasks": json.encode(powerOns),
      "poweroff_tasks": json.encode(powerOffs),
      "api": 'SYNO.Core.Hardware.PowerSchedule',
      "method": 'save',
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> powerSet(bool enableZram, Map powerRecovery, Map beepControl, Map fanSpeed, Map led) async {
    List apis = [
      {"api": "SYNO.Core.Hardware.ZRAM", "method": "set", "version": "1", "enable_zram": enableZram},

      // {"api": "SYNO.Core.Hardware.Hibernation", "method": "set", "version": "1", "internal_hd_idletime": 20, "sata_deep_sleep": true, "ignore_netbios_broadcast": false, "usb_idletime": 0, "enable_log": false},
      // {"api": "SYNO.Core.ExternalDevice.UPS", "method": "set", "version": "1", "enable": false, "delay_time": "-1", "snmp_auth_key_dirty": false, "snmp_privacy_key_dirty": false}
    ];
    if (powerRecovery != null) {
      apis.add({"api": "SYNO.Core.Hardware.PowerRecovery", "method": "set", "version": "1", "rc_power_config": powerRecovery['rc_power_config'], "wol1": powerRecovery['wol1'] ?? false, "wol2": powerRecovery['wol2'] ?? false});
    }
    if (beepControl != null) {
      apis.add({
        "api": "SYNO.Core.Hardware.BeepControl",
        "method": "set",
        "version": "1",
        "fan_fail": beepControl['fan_fail'] ?? false,
        "volume_crash": beepControl['volume_crash'] ?? false,
        "ssd_cache_crash": beepControl["ssd_cache_crash"] ?? false,
        "poweron_beep": beepControl['poweron_beep'] ?? false,
        "poweroff_beep": beepControl['poweroff_beep'] ?? false
      });
    }
    if (fanSpeed != null) {
      apis.add({"api": "SYNO.Core.Hardware.FanSpeed", "method": "set", "version": "1", "dual_fan_speed": fanSpeed['dual_fan_speed']});
    }
    if (led != null) {
      apis.add({"api": "SYNO.Core.Hardware.Led.Brightness", "method": "set", "version": "1", "led_brightness": led['led_brightness'], "schedule": led['schedule']});
    }
    var result = await Util.post("entry.cgi", data: {
      "stop_when_error": false,
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> powerHibernationSave({int internalHdIdletime, bool sataDeepSleep, int usbIdletime, bool enableLog, bool autoPoweroffEnable, int autoPoweroffTime}) async {
    var result = await Util.post("entry.cgi", data: {
      "internal_hd_idletime": internalHdIdletime,
      "sata_deep_sleep": sataDeepSleep,
      "ignore_netbios_broadcast": false,
      "usb_idletime": usbIdletime,
      "enable_log": enableLog,
      "auto_poweroff_enable": autoPoweroffEnable,
      "auto_poweroff_time": autoPoweroffTime,
      "api": 'SYNO.Core.Hardware.Hibernation',
      "method": 'set',
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> userDetail(String name) async {
    print(name);
    List apis = [
      {
        "api": "SYNO.Core.User",
        "method": "get",
        "version": 1,
        "name": name,
        "additional": ["description", "email", "expired", "cannot_chg_passwd", "passwd_never_expire"]
      },
      {"api": "SYNO.Core.User.PasswordExpiry", "method": "get", "version": 1},
      {
        "api": "SYNO.Core.Share.Permission",
        "method": "list_by_user",
        "version": 1,
        "name": name,
        "user_group_type": "local_user",
        "share_type": ["dec", "local", "usb", "sata", "cluster", "cold_storage"],
        "additional": ["hidden", "encryption", "is_aclmode"]
      },
      {"api": "SYNO.Core.Storage.Volume", "method": "list", "version": 1, "offset": 0, "limit": -1, "location": "internal"},
      {"api": "SYNO.Core.BandwidthControl", "method": "get", "version": 2, "name": name, "owner_type": "local_user"},
      {"api": "SYNO.Core.OTP.Admin", "method": "get", "version": 1, "name": name},
      {"api": "SYNO.Core.FileServ.SMB", "method": "get", "version": 1},
      {"api": "SYNO.Core.Quota", "method": "get", "version": 1, "name": name, "support_share_quota": true}
    ];
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Entry.Request',
      "method": 'request',
      "mode": '"sequential"',
      "compound": jsonEncode(apis),
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> userGroup(String name) async {
    var result = await Util.post("entry.cgi", data: {
      "name_only": false,
      "user": '"$name"',
      "type": '"local"',
      "api": 'SYNO.Core.Group',
      "method": 'list',
      "version": 1,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> firmwareVersion() async {
    var result = await Util.post("entry.cgi", data: {
      "type": '"firmware"',
      "api": 'SYNO.Core.System',
      "method": 'info',
      "version": 3,
      "_sid": Util.sid,
    });
    return result;
  }

  static Future<Map> firmwareUpgrade() async {
    var result = await Util.post("entry.cgi", data: {
      "api": 'SYNO.Core.Upgrade.Server',
      "method": 'check',
      "version": 2,
      "user_reading": true,
      "need_auto_smallupdate": true,
      "need_promotion": true,
      "_sid": Util.sid,
    });
    return result;
  }
}
