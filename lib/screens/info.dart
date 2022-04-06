import 'dart:convert';
import 'dart:io';

import 'package:birdy/ai/classifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class InfoScreen extends StatefulWidget {
  final File? image;
  final Classifier classifier;
  const InfoScreen({Key? key, required this.image, required this.classifier})
      : super(key: key);

  @override
  State<InfoScreen> createState() =>
      _InfoScreenState(image: image, classifier: classifier);
}

class _InfoScreenState extends State<InfoScreen> {
  File? image;
  Classifier classifier;
  Category? _category;
  bool loading = false;
  String? _species;
  double? _confidence;
  String? _description;
  bool showMore = false;

  _InfoScreenState({required this.image, required this.classifier});

  @override
  void initState() {
    super.initState();
    loading = true;
    _predict();
    loading = false;
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(image!.readAsBytesSync())!;
    var pred = classifier.predict(imageInput);

    setState(() {
      _category = pred;
      _species = _category!.label;
      _confidence = _category!.score;
    });
    await loadJson();
  }

  Future<void> loadJson() async {
    String response = await rootBundle.loadString('assets/ml/data.json');
    final data = await json.decode(response);

    String desc = data[_species] as String;

    setState(() {
      _description = desc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const CircularProgressIndicator(color: Colors.blueAccent)
            : Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0x220095FF),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svgs/back.svg',
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 2.41,
                                )),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _species!,
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                CircularPercentIndicator(
                                                  radius: 25,
                                                  lineWidth: 5,
                                                  animation: true,
                                                  animationDuration: 2000,
                                                  percent: _confidence!,
                                                  progressColor:
                                                      Colors.blueAccent,
                                                  center: Text(
                                                    '${(_confidence! * 100).round()}%',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Confidence',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: true
                                            ? Text(
                                                _description!,
                                                textAlign: TextAlign.justify,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            : RichText(
                                                textAlign: TextAlign.justify,
                                                text: TextSpan(
                                                    text: _description!
                                                        .split('\n')[0],
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black54,
                                                    ),
                                                    children: const [
                                                      TextSpan(
                                                          text: 'See more',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ))
                                                    ]),
                                              ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
              ),
      ),
    );
  }
}
