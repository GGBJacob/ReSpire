import 'package:flutter/material.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';

class PreloadingScreen extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int loadedCount;
  final int totalCount;
  final String? currentlyLoading;
  final bool finalizing;

  const PreloadingScreen({
    super.key,
    required this.progress,
    required this.loadedCount,
    required this.totalCount,
    required this.finalizing,
    this.currentlyLoading,
  });

  @override
  Widget build(BuildContext context) {
    final translationProvider = TranslationProvider();
    
    return Scaffold(
      backgroundColor: darkerblue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  translationProvider.getTranslation("BreathingPage.PreloadingScreen.title"),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  translationProvider.getTranslation("BreathingPage.PreloadingScreen.subtitle"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Progress bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Progress text
                Visibility(
                  visible: !finalizing,
                  child:Text(
                  '$loadedCount / ${totalCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
                const SizedBox(height: 8),
                
                // Currently loading file
                if (currentlyLoading != null || finalizing)
                  Text(
                    finalizing ? translationProvider.getTranslation("BreathingPage.PreloadingScreen.finalizing") : currentlyLoading!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
