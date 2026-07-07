import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/email_tag.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class ResourcesDetail extends ConsumerStatefulWidget {
  const ResourcesDetail({super.key, this.resource});
  final ResourcesModel? resource;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResourcesDetailState();
}

class _ResourcesDetailState extends ConsumerState<ResourcesDetail> {
  final nameCtrl = TextEditingController();
  final imgUrlCtrl = TextEditingController();
  final linkCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  @override
  void initState() {
    if (widget.resource != null) {
      nameCtrl.text = widget.resource!.name!;
      imgUrlCtrl.text = widget.resource!.imgUrl!;
      linkCtrl.text = widget.resource!.link!;
      tags = widget.resource!.tags!;
    }
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    imgUrlCtrl.dispose();
    linkCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  List tags = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomText(
            '${widget.resource == null ? 'Create' : 'Update'} Resource',
            color: AppColors.primaryColorPurple,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700),
        leading: const CustomBackButton(),
        actions: [
          widget.resource == null
              ? 1.pw
              : ref.watch(resourcesProvider).delStatus == Loader.loading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () async {
                        final response = await ref
                            .read(resourcesProvider.notifier)
                            .deleteResources(widget.resource!.id!);

                        if (response.successMessage.isNotEmpty) {
                          getAlert(response.successMessage, isWarning: false);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else if (response.responseMessage!.isNotEmpty) {
                          getAlert(response.responseMessage!);
                        } else {
                          getAlert(response.errorMessage);
                        }
                      },
                    )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.ph,
              CustomTextField(
                filled: true,
                title: "Resource Name",
                hintText: "Enter the name",
                controller: nameCtrl,
                valdator: (value) {
                  if (value!.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              CustomTextField(
                filled: true,
                title: "Resource Image Url",
                hintText: "Enter image url",
                controller: imgUrlCtrl,
                valdator: (value) {
                  if (value!.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              CustomTextField(
                filled: true,
                title: "Resource Link",
                hintText: "Enter resource link",
                controller: linkCtrl,
                valdator: (value) {
                  if (value!.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              Visibility(
                visible: tags.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    15.ph,
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 15.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10)),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: List.generate(tags.length, (index) {
                          return Tag(
                              email: tags[index],
                              isCancel: true,
                              onTap: () {
                                setState(() {
                                  tags.removeAt(index);
                                });
                              });
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              10.ph,
              CustomTextField(
                title: 'Tags',
                hintText: 'Enter Tag',
                controller: tagsCtrl,
                filled: true,
              ),
              Center(
                child: CurvedButton(
                  text: 'Add Tag',
                  height: 35.h,
                  color: AppColors.primaryColorPurple,
                  onPressed: () {
                    if (tagsCtrl.text.isEmpty) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        getAlert('Tag can\'t be empty');
                      });
                      return;
                    }
                    if (tagsCtrl.text.isNotEmpty) {
                      tags.add(tagsCtrl.text);
                      tagsCtrl.clear();
                    }
                    setState(() {});
                  },
                  width: 200.w,
                ),
              ),
              40.ph,
              CurvedButton(
                loading:
                    ref.watch(resourcesProvider).postStatus == Loader.loading,
                text: widget.resource == null ? 'Create' : 'Update',
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      imgUrlCtrl.text.isEmpty ||
                      linkCtrl.text.isEmpty) {
                    getAlert('no fields should be empty');

                    return;
                  }
                  final response = (widget.resource != null)
                      ? await ref
                          .read(resourcesProvider.notifier)
                          .updateResources(nameCtrl.text, imgUrlCtrl.text,
                              linkCtrl.text, tags, widget.resource!.id!)
                      : await ref
                          .read(resourcesProvider.notifier)
                          .createResources(nameCtrl.text, imgUrlCtrl.text,
                              linkCtrl.text, tags);
                  if (response.successMessage.isNotEmpty) {
                    getAlert(response.successMessage, isWarning: false);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else if (response.responseMessage!.isNotEmpty) {
                    getAlert(response.responseMessage!);
                  } else {
                    getAlert(response.errorMessage);
                  }
                },
              ),
              40.ph
            ],
          ),
        ),
      ),
    );
  }
}
