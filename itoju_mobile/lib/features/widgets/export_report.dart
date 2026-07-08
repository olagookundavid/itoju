// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: unused_import
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart' as p;

class ExportReport extends StatelessWidget {
  const ExportReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CustomBackButton()),
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: AppColors.splash_underlay,
                ),
                child: Text(
                  'Export Report',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColorPurple),
                ))
          ]),
        ),
      ),
    );
  }
}

final pdf = pw.Document();
Future downloadPdf() async {
  // createReceipt();

  String name = generateRandomString(5);
  // Directory documentDirectory = await getApplicationDocumentsDirectory();
  // dev.debugPrint(documentDirectory.path);
  String documentPath = "/storage/emulated/0/Documents";
  if (Platform.isIOS) {
    Directory documentDirectory = await p.getApplicationDocumentsDirectory();
    documentPath = documentDirectory.path;
  }
  //var storagePerm = await Permission.manageExternalStorage.request();
  await Permission.accessMediaLocation.request();

  await Permission.storage.request();
  File file = File("$documentPath/$name.pdf");
  file.writeAsBytesSync(await pdf.save());

  XFile xFile = XFile("$documentPath/$name.pdf");
  final result = await Share.shareXFiles([xFile],
      subject: "My Accion Receipt", text: "Receipt");
  if (result.status == ShareResultStatus.success) {
    debugPrint("download success");
  }
}

Future savePdf() async {
  // createReceipt();
  String name = generateRandomString(5);
  try {
    debugPrint('Creating PDF file...');

    // Request storage permissions
    await Permission.storage.request();
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      debugPrint('Storage permission not granted');
      return;
    }

    // Get the documents directory
    Directory documentDirectory = await p.getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;

    File file = File("$documentPath/$name.pdf");

    // Write the PDF file
    await file.writeAsBytes(await pdf.save());

    debugPrint('PDF file saved at $documentPath/$name.pdf');
  } catch (e) {
    debugPrint('Error saving PDF file: $e');
  }
}

String generateRandomString(int len) {
  var r = Random.secure();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

Future<File?> downloadFile(String url, String name) async {
  final appStorage = await p.getApplicationDocumentsDirectory();
  final file = File('${appStorage.path}/$name');
  try {
    Response response = await Dio().get(url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ));

    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();

    return file;
  } catch (e) {
    return null;
  }
}
