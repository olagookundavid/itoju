import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class CachedImageHelper extends StatelessWidget {
  const CachedImageHelper({
    super.key,
    required this.url,
  });
  final String url;

  @override
  Widget build(BuildContext context) {
    return FastCachedImage(
      url: url,
      fit: BoxFit.fill,
      fadeInDuration: const Duration(seconds: 1),
      errorBuilder: (context, exception, stacktrace) {
        return Stack(
          children: [
            Center(
                child: Text(
              url.isEmpty ? 'Please pass a valid Url' : 'Couldn\'t load image',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.red),
            ))
          ],
        );
      },
      loadingBuilder: (context, progress) {
        // debugPrint(
        //     'Progress: ${progress.isDownloading} ${progress.downloadedBytes} / ${progress.totalBytes}');
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColorPurple)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  backgroundColor: AppColors.primaryColorPurple,
                  value: progress.progressPercentage.value),
            ],
          ),
        );
      },
    );
  }
}
