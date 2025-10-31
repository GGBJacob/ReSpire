import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/services/TrainingJsonConverter.dart';

class TrainingImportExportService {
  
  static Future<bool> exportTraining(Training training, {String? fileName}) async {
    try {
      final String defaultFileName = fileName ?? 
          '${training.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}_training.json';
      
      final String jsonString = TrainingJsonConverter.toJson(training);
      
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Zapisz trening',
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

  static Future<Training?> importTraining() async {
    try {
      // Otwórz okno wyboru pliku
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return null;
      }
      
      final String? filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }
      
      final File file = File(filePath);
      final String jsonString = await file.readAsString();
      
      final Training training = TrainingJsonConverter.fromJson(jsonString);
      
      return training;
    } catch (e) {
      debugPrint('Error during trainingimport: $e');
      return null;
    }
  }

  static Future<Training?> importTrainingFromPath(String filePath) async {
    try {
      final File file = File(filePath);
      final String jsonString = await file.readAsString();
      
      final Training training = TrainingJsonConverter.fromJson(jsonString);
      
      return training;
    } catch (e) {
      debugPrint('Error during training import from file $filePath: $e');
      return null;
    }
  }
}
