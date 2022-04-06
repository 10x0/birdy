import 'dart:io';
import 'package:birdy/ai/classifier.dart';
import 'package:birdy/ai/classifier_quant.dart';
import 'package:birdy/screens/info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class RecognizeButtons extends StatefulWidget {
  const RecognizeButtons({Key? key}) : super(key: key);

  @override
  State<RecognizeButtons> createState() => _RecognizeButtonsState();
}

class _RecognizeButtonsState extends State<RecognizeButtons> {
  late Classifier _classifier;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  Future pickImage() async {
    final image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recognize bird species",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x220095FF),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await pickImage();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InfoScreen(
                                image: _image, classifier: _classifier)),
                      );
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/Camera.svg',
                        width: 24,
                      ),
                    ),
                  ),
                ),
                const Text("Open camera")
              ],
            ),

            // GALLERY
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x220095FF),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await getImage();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InfoScreen(
                                image: _image, classifier: _classifier)),
                      );
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/Gallery.svg',
                        width: 24,
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
