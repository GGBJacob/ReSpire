import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/services/TrainingJsonConverter.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/utils/TextUtils.dart';

class TrainingImportExportService {
  
  static Future<bool> exportTraining(Training training, {String? fileName}) async {
    try {
      final String defaultFileName = fileName ??
          '${TextUtils.sanitizeFileName(training.title)}_training.json';
      
      final String jsonString = TrainingJsonConverter.toJson(training);
      
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: TranslationProvider().getTranslation("FilePicker.save_training"),
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      
      if (outputPath == null) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during training export: $e');
      return false;
    }
  }

  static Future<bool> exportMultipleTrainings(List<Training> trainings) async {
    if (trainings.isEmpty) {
      return false;
    }

    try {
      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final String defaultFileName = 'respire_trainings_$timestamp.json';

      final String jsonString = TrainingJsonConverter.toJsonMultiple(trainings);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: TranslationProvider().getTranslation("FilePicker.save_trainings"),
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      return outputPath != null;
    } catch (e) {
      debugPrint('Error during multiple trainings export: $e');
      return false;
    }
  }

  static Future<Training?> importTraining() async {
    final trainings = await importTrainings();
    if (trainings == null || trainings.isEmpty) {
      return null;
    }
    return trainings.first;
  }

  static Future<List<Training>?> importTrainings() async {
    try {
      // Open file choosing window
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return null;
      }
      
      final PlatformFile file = result.files.single;

      String? jsonString;
      if (file.bytes != null) {
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        jsonString = await File(file.path!).readAsString();
      }

      if (jsonString == null) {
        return null;
      }

      return TrainingJsonConverter.fromJsonMultiple(jsonString);
    } catch (e) {
      debugPrint('Error during trainingimport: $e');
      return null;
    }
  }

  static Future<Training?> importTrainingFromPath(String filePath) async {
    try {
      final File file = File(filePath);
      final String jsonString = await file.readAsString();
      final trainings = TrainingJsonConverter.fromJsonMultiple(jsonString);
      return trainings.isNotEmpty ? trainings.first : null;
    } catch (e) {
      debugPrint('Error during training import from file $filePath: $e');
      return null;
    }
  }
}
