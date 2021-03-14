// import 'package:flutter/material.dart';
// import 'package:flutter_phone_state/flutter_phone_state.dart';
// import 'package:neumorphic/neumorphic.dart';
// import 'package:dsm_helper/util/function.dart';
// import 'package:call_log/call_log.dart';
//
// class Test extends StatefulWidget {
//   @override
//   _TestState createState() => _TestState();
// }
//
// class _TestState extends State<Test> {
//   List<PhoneCall> phoneCalls = [];
//
//   waitForCompletion(PhoneCall phoneCall) async {
//     await phoneCall.done;
//     setState(() {
//       phoneCalls.add(phoneCall);
//       getCallTime(phoneCall.startTime);
//     });
//   }
//   // watchEvents(PhoneCall phoneCall) {
//   //   phoneCall.eventStream.forEach((PhoneCallEvent event) async {
//   //     await phoneCall.done;
//   //     setState(() {
//   //       print(event);
//   //       events.add(event);
//   //     });
//   //   });
//   //   print("Call is complete");
//   //
//   //   // IMPORT PACKAGE
//   // }
//
//   getCallTime(DateTime startTime) async {
//     print("获取实际通话时间");
// // QUERY CALL LOG (ALL PARAMS ARE OPTIONAL)
//     int from = startTime.subtract(Duration(seconds: 10)).millisecondsSinceEpoch;
//     int to = DateTime.now().subtract(Duration(seconds: -10)).millisecondsSinceEpoch;
//     Iterable<CallLogEntry> entries = await CallLog.query(
//       dateFrom: from,
//       dateTo: to,
//       number: '10000',
//       type: CallType.outgoing,
//     );
//     entries.forEach((element) {
//       print("${element.duration}秒");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("拨号状态监听"),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(20),
//         children: [
//           NeuButton(
//             decoration: NeumorphicDecoration(
//               color: Theme.of(context).scaffoldBackgroundColor,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             bevel: 20,
//             onPressed: () {
//               final phoneCall = FlutterPhoneState.startPhoneCall("10000");
//               waitForCompletion(phoneCall);
//             },
//             child: Text("拨号"),
//           ),
//           ...phoneCalls
//               .map(
//                 (call) => ListTile(
//                   title: Text(call.phoneNumber),
//                   subtitle: Text("${call.startTime.format("H:i:s")}"),
//                   trailing: Text("${call.duration.inSeconds}秒"),
//                 ),
//               )
//               .toList(),
//         ],
//       ),
//     );
//   }
// }
