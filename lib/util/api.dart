import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'function.dart';

class Api {
  static Future<Map> update(String buildNumber) async {
    if (Platform.isAndroid) {
      var res = await Util.get(utf8.decode(base64Decode("aHR0cDovL2FwaS5maXIuaW0vYXBwcy9sYXRlc3QvNWZjZjg0ODViMmViNDY1ZjljY2MyNzlhP2FwaV90b2tlbj04MGFhOGVlYjQ3ZmY3N2UyZDcxM2MxN2I4YWZmMjVmOA==")));
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

  static Future<Map> login({String host, String account, String password, String otpCode}) async {
    var data = {
      "account": account,
      "passwd": password,
      "otp_code": otpCode,
      "version": 6,
      "api": "SYNO.API.Auth",
      "method": "login",
      "session": "FileStation",
    };
    return await Util.get("auth.cgi", host: host, data: data);
  }

  static Future<Map> shareList({List<String> additional = const ["perm", "time", "size"]}) async {
    return await Util.post("entry.cgi", data: {
      "api": '"SYNO.FileStation.List"',
      "method": '"list_share"',
      "version": 2,
      "_sid": Util.sid,
      "offset": 0,
      "limit": 1000,
      "sort_by": '"name"',
      "sort_direction": '"asc"',
      "additional": jsonEncode(additional),
    });
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

  // static Future<Map> deleteSharedFolderResult(String taskId) async {
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
      "additional": '["perm", "time", "size","real_path"]',
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
      },
      {
        "api": "SYNO.Core.TaskScheduler",
        "sort_by": "next_trigger_time",
        "sort_direction": "ASC",
        "start": 0,
        "limit": 50,
        "method": "list",
        "version": 1,
      },
      {
        "api": "SYNO.Core.SyslogClient.Status",
        "start": 0,
        "limit": 50,
        "widget": true,
        "dir": "desc",
        "method": "latestlog_get",
        "version": 1,
      },
      {
        "action": "load",
        "lastRead": DateTime.now().secondsSinceEpoch,
        "lastSeen": DateTime.now().secondsSinceEpoch,
        "api": "SYNO.Core.DSMNotify",
        "method": "notify",
        "version": 1,
      },
      {
        "api": "SYNO.Core.AppNotify",
        "method": "get",
        "version": 1,
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

  static Future<Map> info() async {
    var result = await Util.get("http://pan.fmtol.com:5000/webman/modules/SystemInfoApp/SystemInfo.cgi?_dc=${DateTime.now().millisecond}&SynoToken=iu1Hd4LhasRz2&query=systemHealth");
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

  static Future<Map> packages({bool others = false}) async {
    var data = {
      "updateSprite": true,
      "blforcereload": false,
      "blloadothers": others,
      "api": "SYNO.Core.Package.Server",
      "version": 2,
      "method": "list",
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> installedPackages() async {
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
      "updated_at",
      "status",
      "url",
    ];
    var data = {
      "additional": jsonEncode(additional),
      "polling_interval": 15,
      "force_set_params": true,
      "api": "SYNO.Core.Package",
      "version": 2,
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
      "data":
          dataStr, //r'"{\"SYNO.SDS._Widget.Instance\":{\"modulelist\":[\"SYNO.SDS.SystemInfoApp.SystemHealthWidget\",\"SYNO.SDS.SystemInfoApp.ConnectionLogWidget\",\"SYNO.SDS.ResourceMonitor.Widget\"]}}"',
      "method": "apply",
      "version": 1,
      "_sid": Util.sid,
    };
    print(dataStr);
    print(data['data']);
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> mediaConverter() async {
    var data = {"api": "SYNO.Core.MediaIndexing.MediaConverter", "method": "status", "version": 1};
    return await Util.post("entry.cgi", data: data);
  }

  static Future<Map> utilization() async {
    var data = {
      "api": "SYNO.Core.System.Utilization",
      "method": "get",
      "version": 1,
      "type": "current",
      "resource": ["cpu", "memory", "network", "lun", "disk", "space"],
      "_sid": Util.sid,
    };
    return await Util.post("entry.cgi", data: data);
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
}
