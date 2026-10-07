import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CelebrationOverlay extends StatefulWidget {
  final String title;
  final String description;

  const CelebrationOverlay({super.key, required this.title, required this.description});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.1,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 120, color: Colors.amber),
              Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(widget.description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }
}