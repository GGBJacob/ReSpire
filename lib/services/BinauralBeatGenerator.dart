import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class BinauralBeatGenerator {
  static final BinauralBeatGenerator _instance = BinauralBeatGenerator._internal();
  factory BinauralBeatGenerator() => _instance;
  
  BinauralBeatGenerator._internal();

  AudioPlayer? _leftPlayer;
  AudioPlayer? _rightPlayer;
  bool _isPlaying = false;
  StreamController<Uint8List>? _leftStreamController;
  StreamController<Uint8List>? _rightStreamController;

  static const int sampleRate = 44100;
  static const int bufferSize = 4096;
  static const double amplitude = 0.5;

  Future<void> start(double leftFrequency, double rightFrequency, {double? durationSeconds}) async {
    if (_isPlaying && _leftPlayer != null && _rightPlayer != null) {
      dev.log('Binaural beats already playing, resuming if needed');
      await _leftPlayer!.resume();
      await _rightPlayer!.resume();
      return;
    }

    if (_isPlaying) {
      await stop();
    }

    dev.log('Starting binaural beats: Left=$leftFrequency Hz, Right=$rightFrequency Hz, Duration=${durationSeconds ?? "infinite"}s');

    _leftPlayer = AudioPlayer();
    _rightPlayer = AudioPlayer();

    await _leftPlayer!.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));

    await _rightPlayer!.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));

    if (durationSeconds == null) {
      await _leftPlayer!.setReleaseMode(ReleaseMode.loop);
      await _rightPlayer!.setReleaseMode(ReleaseMode.loop);
    } else {
      await _leftPlayer!.setReleaseMode(ReleaseMode.stop);
      await _rightPlayer!.setReleaseMode(ReleaseMode.stop);
    }

    await _leftPlayer!.setVolume(1.0);
    await _rightPlayer!.setVolume(1.0);

    await _leftPlayer!.setBalance(-1.0);
    await _rightPlayer!.setBalance(1.0);

    final leftTone = _generateTone(leftFrequency, durationSeconds);
    final rightTone = _generateTone(rightFrequency, durationSeconds);

    dev.log('Generated tone data: Left=${leftTone.length} bytes, Right=${rightTone.length} bytes');

    final leftWav = _createWavFile(leftTone);
    final rightWav = _createWavFile(rightTone);

    dev.log('Created WAV files: Left=${leftWav.length} bytes, Right=${rightWav.length} bytes');

    try {
      final tempDir = await getTemporaryDirectory();
      final leftFile = File('${tempDir.path}/binaural_left.wav');
      final rightFile = File('${tempDir.path}/binaural_right.wav');
      
      await leftFile.writeAsBytes(leftWav);
      await rightFile.writeAsBytes(rightWav);
      
      dev.log('Saved WAV files: Left=${leftFile.path}, Right=${rightFile.path}');
      
      dev.log('Attempting to play left channel...');
      await _leftPlayer!.play(DeviceFileSource(leftFile.path));
      dev.log('Left channel playing');
      
      dev.log('Attempting to play right channel...');
      await _rightPlayer!.play(DeviceFileSource(rightFile.path));
      dev.log('Right channel playing');
      
      _isPlaying = true;
      dev.log('Binaural beats started successfully');
    } catch (e, stackTrace) {
      dev.log('Error starting binaural beats: $e\n$stackTrace');
      await stop();
      rethrow;
    }
  }

  Uint8List _generateTone(double frequency, double? durationSeconds) {
    final duration = durationSeconds ?? 60.0;

    final numCycles = (duration * frequency).round();
    final samplesPerCycle = sampleRate / frequency;
    final numSamples = (samplesPerCycle * numCycles).round();
    
    final samples = Float32List(numSamples);
    
    for (int i = 0; i < numSamples; i++) {
      final phase = 2 * pi * frequency * i / sampleRate;
      samples[i] = amplitude * sin(phase);
    }

    final pcmData = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      pcmData[i] = (samples[i] * 32767).toInt().clamp(-32768, 32767);
    }

    return pcmData.buffer.asUint8List();
  }

  Uint8List _createWavFile(Uint8List pcmData) {
    final int dataSize = pcmData.length;
    final int fileSize = 44 + dataSize;
    
    final ByteData header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize - 8, Endian.little);
    
    // WAVE header
    header.setUint8(8, 0x57);  // 'W'
    header.setUint8(9, 0x41);  // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'
    
    // fmt subchunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    header.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    header.setUint16(22, 1, Endian.little);  // NumChannels (1 for mono)
    header.setUint32(24, sampleRate, Endian.little); // SampleRate
    header.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    header.setUint16(32, 2, Endian.little);  // BlockAlign
    header.setUint16(34, 16, Endian.little); // BitsPerSample
    
    // data subchunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataSize, Endian.little);
    
    // Combine header and data
    final result = Uint8List(fileSize);
    result.setRange(0, 44, header.buffer.asUint8List());
    result.setRange(44, fileSize, pcmData);
    
    return result;
  }

  Future<void> pause() async {
    if (_isPlaying && _leftPlayer != null && _rightPlayer != null) {
      await _leftPlayer!.pause();
      await _rightPlayer!.pause();
      dev.log('Binaural beats paused');
    }
  }

  Future<void> resume() async {
    if (!_isPlaying && _leftPlayer != null && _rightPlayer != null) {
      await _leftPlayer!.resume();
      await _rightPlayer!.resume();
      dev.log('Binaural beats resumed');
    }
  }

  Future<void> stop() async {
    dev.log('Stopping binaural beats');
    
    if (_leftPlayer != null) {
      await _leftPlayer!.stop();
      await _leftPlayer!.dispose();
      _leftPlayer = null;
    }
    
    if (_rightPlayer != null) {
      await _rightPlayer!.stop();
      await _rightPlayer!.dispose();
      _rightPlayer = null;
    }
    
    _isPlaying = false;
    
    await _leftStreamController?.close();
    await _rightStreamController?.close();
    _leftStreamController = null;
    _rightStreamController = null;
    
    dev.log('Binaural beats stopped');
  }

  bool get isPlaying => _isPlaying;
}
