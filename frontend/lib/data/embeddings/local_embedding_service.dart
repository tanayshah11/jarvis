import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

const String _logName = 'LocalEmbeddingService';

/// On-device embedding service using TensorFlow Lite
/// Uses Universal Sentence Encoder QA On-Device (6MB, 100 dimensions)
/// Optimized for semantic similarity and Q&A tasks
class LocalEmbeddingService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Model configuration for USE-QA-OnDevice
  static const String modelAsset = 'assets/models/use_lite.tflite';
  static const int embeddingDimension = 100; // USE-QA outputs 100-dim vectors
  static const int maxQueryLength = 192; // Maximum query length in bytes

  /// Initialize the embedding model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final modelPath = await _getModelPath();

      if (modelPath != null) {
        // Load with specific options for this model
        final options = InterpreterOptions()..threads = 2;
        _interpreter = Interpreter.fromFile(File(modelPath), options: options);
        _isInitialized = true;

        developer.log(
          'USE-QA model loaded successfully',
          name: _logName,
        );

        // Log model details
        developer.log(
          'Input tensors: ${_interpreter!.getInputTensors().map((t) => '${t.name}: ${t.shape}')}',
          name: _logName,
        );
        developer.log(
          'Output tensors: ${_interpreter!.getOutputTensors().map((t) => '${t.name}: ${t.shape}')}',
          name: _logName,
        );
      } else {
        developer.log(
          'Model not available - using fallback embeddings',
          name: _logName,
          level: 800,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load model: $e',
        name: _logName,
        level: 900,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get the model path, copying from assets if needed
  Future<String?> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/models/use_lite.tflite');

    if (await modelFile.exists()) {
      return modelFile.path;
    }

    // Copy from assets
    try {
      final byteData = await rootBundle.load(modelAsset);
      await modelFile.parent.create(recursive: true);
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await modelFile.writeAsBytes(bytes);
      developer.log(
        'Model copied to: ${modelFile.path}',
        name: _logName,
      );
      return modelFile.path;
    } catch (e) {
      developer.log(
        'Could not load model from assets: $e',
        name: _logName,
        level: 800,
      );
      return null;
    }
  }

  /// Generate embedding for text
  /// Returns 100-dimensional vector (USE-QA output)
  Future<List<double>> embed(String text) async {
    if (!_isInitialized || _interpreter == null) {
      return _fallbackEmbed(text);
    }

    try {
      // USE-QA-OnDevice expects the raw text as bytes input
      // Prepare the query text (trim to max length)
      final queryText = text.length > maxQueryLength
          ? text.substring(0, maxQueryLength)
          : text;

      // Convert text to bytes for input
      final inputBytes = Uint8List.fromList(queryText.codeUnits);

      // Pad to consistent length
      final paddedInput = Uint8List(maxQueryLength);
      for (int i = 0; i < inputBytes.length && i < maxQueryLength; i++) {
        paddedInput[i] = inputBytes[i];
      }

      // Prepare input as [1, maxQueryLength] shaped tensor
      final input = [paddedInput];

      // Prepare output buffer [1, 100]
      final output = List.generate(
        1,
        (_) => List<double>.filled(embeddingDimension, 0),
      );

      // Run inference
      _interpreter!.run(input, output);

      // Normalize and return
      return _normalize(output[0]);
    } catch (e, stackTrace) {
      developer.log(
        'Embedding failed, using fallback: $e',
        name: _logName,
        level: 800,
        error: e,
        stackTrace: stackTrace,
      );
      return _fallbackEmbed(text);
    }
  }

  /// Batch embed multiple texts
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      results.add(await embed(text));
    }
    return results;
  }

  /// Normalize vector to unit length
  List<double> _normalize(List<double> vector) {
    double norm = 0;
    for (final v in vector) {
      norm += v * v;
    }
    norm = _sqrt(norm);

    if (norm == 0) return vector;

    return vector.map((v) => v / norm).toList();
  }

  /// Fallback embedding when model is not available
  /// Uses improved hash-based approach with word-level features
  List<double> _fallbackEmbed(String text) {
    final embedding = List<double>.filled(embeddingDimension, 0);
    final textLower = text.toLowerCase();
    final words = textLower.split(RegExp(r'\s+'));

    // Character n-grams for better coverage
    for (int i = 0; i < textLower.length - 2; i++) {
      final ngram = textLower.substring(i, i + 3);
      final hash = ngram.hashCode;
      final idx = hash.abs() % embeddingDimension;
      final sign = (hash % 2 == 0) ? 1.0 : -1.0;
      embedding[idx] += sign * 0.05;
    }

    // Word-level features
    for (final word in words) {
      if (word.isEmpty) continue;

      final hash1 = word.hashCode;
      final hash2 = '${word}_'.hashCode;

      // Distribute across multiple dimensions
      for (int i = 0; i < 5; i++) {
        final idx = (hash1 + i * hash2).abs() % embeddingDimension;
        final sign = ((hash1 * (i + 1)) % 2 == 0) ? 1.0 : -1.0;
        embedding[idx] += sign * 0.1;
      }
    }

    return _normalize(embedding);
  }

  /// Compute cosine similarity between two embeddings
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same length');
    }

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;

    return dotProduct / (_sqrt(normA) * _sqrt(normB));
  }

  /// Simple sqrt implementation
  double _sqrt(double x) {
    if (x < 0) throw ArgumentError('Cannot compute sqrt of negative');
    if (x == 0) return 0;

    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }

  /// Check if model is loaded (not using fallback)
  bool get isModelLoaded => _isInitialized && _interpreter != null;

  /// Get embedding dimension
  int get dimension => embeddingDimension;
}
