// import 'package:adashe/src/utils/utills.dart';
// import 'package:adashe/src/widgets/button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:itoju_mobile/utils/utills.dart';

// Future<String> photoDecisionDialog(BuildContext context) async {
//   return await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10.r))),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             400.pw,
//             Text(
//               "Choose How You Want To Get The Photo",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
//             ),
//             20.ph,
//             CurvedButton(
//               onPressed: () {
//                 Navigator.pop(context, 'camera');
//               },
//               text: 'Camera',
//             ),
//             40.ph,
//             CurvedButton(
//               onPressed: () {
//                 Navigator.pop(context, 'gallery');
//               },
//               text: 'Gallery',
//             ),
//             20.ph,
//           ],
//         ),
//       );
//     },
//   );
// }
