import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResourceWebView extends ConsumerStatefulWidget {
  const ResourceWebView({super.key, required this.url});
  final String url;
  @override
  ConsumerState<ResourceWebView> createState() => _ResourceWebViewState();
}

class _ResourceWebViewState extends ConsumerState<ResourceWebView> {
  bool isLoading = true;
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.contains('')) {
            //   SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {});
            //   Navigator.of(context).pop();
            // }
            // if (request.url == 'https://standard.paystack.co/close') {
            //   Navigator.of(context).pop(); //close webview
            // }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text('Resource',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColorPurple)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: AppLoader(),
            ),
          )
        ],
      ),
    );
  }
}
