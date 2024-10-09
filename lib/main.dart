import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const DemoApp(),
    );
  }
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedPlay(),
      ),
    );
  }
}

class AnimatedPlay extends StatefulWidget {
  const AnimatedPlay({super.key});

  @override
  State<AnimatedPlay> createState() => _AnimatedPlayState();
}

class _AnimatedPlayState extends State<AnimatedPlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String word = 'Next Episode';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
      reverseDuration: const Duration(seconds: 6),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.value = 0;
        }
        if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 55,
        width: 220,
        color: Colors.grey,
        child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      heightFactor: 1,
                      widthFactor: _animation.value,
                      child: const ColoredBox(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadedText(
                          delay: 0.7,
                          controller: _animationController,
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ...List.generate(word.length, (index) {
                          return ShadedText(
                            text: word[index],
                            controller: _animationController,
                            delay: 1.6 + index * 0.28,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class ShadedText extends StatefulWidget {
  final String? text;
  final double delay;
  final AnimationController controller;
  final Widget? child;
  const ShadedText({
    super.key,
    this.text,
    required this.delay,
    required this.controller,
    this.child,
  });

  @override
  State<ShadedText> createState() => _ShadedTextState();
}

class _ShadedTextState extends State<ShadedText> {
  ValueNotifier<double> fraction = ValueNotifier(0);
  late Timer _timer;
  double timeKeeper = 0.0;

  @override
  void initState() {
    super.initState();

    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _timer.cancel();
        fraction.value = 0;
        timeKeeper = 0;
        _callTimer();
      }
    });
    _callTimer();
  }

  void _callTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      timeKeeper += 0.1;
      if (timeKeeper >= widget.delay) {
        _fireAnimation();
      }
    });
  }

  void _fireAnimation() {
    fraction.value = fraction.value + 0.11;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: fraction,
        builder: (context, frac, _) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: const [Colors.black, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [frac, 0],
                tileMode: TileMode.decal,
              ).createShader(bounds);
            },
            child: widget.child ??
                Text(
                  widget.text!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
          );
        });
  }
}
