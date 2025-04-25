import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatelessWidget {
  const Loader({super.key, this.width = 150});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/loading.json', width: width);
  }
}
