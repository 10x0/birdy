import 'dart:io';
import 'package:birdy/ai/classifier.dart';
import 'package:birdy/ai/classifier_quant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class RecognizeButtons extends StatefulWidget {
  // final Function setLoading;

  const RecognizeButtons({
    Key? key,
  }) : super(key: key);

  @override
  State<RecognizeButtons> createState() => _RecognizeButtonsState();
}

class _RecognizeButtonsState extends State<RecognizeButtons> {
  late Classifier _classifier;

  File? _image;

  final picker = ImagePicker();

  img.Image? fox;

  Category? category;

  Image? _imageWidget;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  Future pickImage() async {
    final image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
      _imageWidget = Image.file(_image!);
    });
    _predict();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);

      _predict();
    });
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      category = pred;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recognize bird species",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x220095FF),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await pickImage();
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/Camera.svg',
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                const Text("Open camera")
              ],
            ),
            Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x220095FF),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await getImage();
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) =>
                      //         ClassfiedBirdPage(image: _image)));
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/Gallery.svg',
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                const Text("Open gallery")
              ],
            ),
          ],
        ),
      ],
    );
  }
}
