import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ChatbotService {
  late Interpreter _interpreter;
  late Map<String, dynamic> _intents;
  late List<String> _words;
  late List<String> _labels;

  final Random _random = Random();

  Future<void> init() async {
    // Load AI model
    _interpreter = await Interpreter.fromAsset('assets/AI.tflite');

    // Load intents.json
    final jsonStr = await rootBundle.loadString('assets/intents.json');
    _intents = json.decode(jsonStr);

    // Load metadata.json
    final metaStr = await rootBundle.loadString('assets/metadata.json');
    final meta = json.decode(metaStr);
    _words = List<String>.from(meta["words"]);
    _labels = List<String>.from(meta["labels"]);
  }

  /// Convert input into bag-of-words
  List<double> _bagOfWords(String sentence) {
    final tokens = sentence.toLowerCase().split(RegExp(r"[^a-zA-Z0-9]+"));
    final bag = List<double>.filled(_words.length, 0);

    for (var token in tokens) {
      for (int i = 0; i < _words.length; i++) {
        if (_words[i] == token) {
          bag[i] = 1.0;
        }
      }
    }
    return bag;
  }

  /// Predict intent + return response
  String getResponse(String userInput) {
    final input = _bagOfWords(userInput);
    final inputTensor = [input]; // batch of 1

    // Output buffer [1, labels.length]
    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    _interpreter.run(inputTensor, output);

    // Find max probability
    int maxIdx = 0;
    double maxVal = 0;
    for (int i = 0; i < _labels.length; i++) {
      if (output[0][i] > maxVal) {
        maxVal = output[0][i];
        maxIdx = i;
      }
    }

    final predictedTag = _labels[maxIdx];
    final intent = _intents["intents"].firstWhere(
      (it) => it["tag"] == predictedTag,
      orElse: () => null,
    );

    if (intent != null) {
      final responses = List<String>.from(intent["responses"]);
      return responses[_random.nextInt(responses.length)];
    }

    return "Sorry, I didn’t understand that.";
  }
}
