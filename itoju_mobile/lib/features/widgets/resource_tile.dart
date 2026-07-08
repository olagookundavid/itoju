import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/widgets/cached_image.dart';

class ResourcesTile extends StatelessWidget {
  const ResourcesTile({super.key, required this.onTap, required this.resource});
  final Function onTap;
  final ResourcesModel resource;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          height: 200.h,
          width: 180.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedImageHelper(url: resource.imgUrl!),
          ),
        ),
      ),
    );
  }
}
