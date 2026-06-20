import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../models/app_state.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  int _secondsRemaining = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  int _selectedDuration = 25; // 25, 45, 60 minutes
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Sound controls
  bool _soundEnabled = false;
  String _activeSound = 'Synthwave Focus';
  final List<String> _soundTracks = ['Synthwave Focus', 'Space Ambient', 'Deep Rain', 'Cyberpunk Lofi'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _secondsRemaining = _selectedDuration * 60;
        });
        
        // Add reward to hero for focusing (level-up ditangani konsisten).
        final state = Provider.of<AppState>(context, listen: false);
        state.completeFocusSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDuration * 60;
    });
  }

  void _changeDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _selectedDuration = minutes;
      _secondsRemaining = minutes * 60;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final progress = _secondsRemaining / (_selectedDuration * 60);

    return Scaffold(
      backgroundColor: const Color(0xFF070710),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('FOCUS ORB'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.t2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Minimal instructions
              Text(
                'Masuk ke hyper-focus mode. Selesaikan sesi untuk mendapatkan XP bonus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.t2, height: 1.5),
              ),
              
              const Spacer(),
              
              // Pulse & Glow Timer
              ScaleTransition(
                scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F0F26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: _isRunning ? 0.35 : 0.15),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withValues(alpha: _isRunning ? 0.15 : 0.05),
                        blurRadius: 20,
                        spreadRadius: -4,
                      ),
                    ],
                    border: Border.all(
                      color: _isRunning ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring progress
                      SizedBox(
                        width: 216,
                        height: 216,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFFF)),
                        ),
                      ),
                      
                      // Text & Timer
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.heroClass(state.hero.heroClass),
                            size: 32,
                            color: AppColors.accent2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_secondsRemaining),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.t1,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning ? 'FOCUSING' : 'IDLE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _isRunning ? const Color(0xFF00FFFF) : AppColors.t3,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Sound wave visualization if enabled
              if (_soundEnabled && _isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 3,
                      height: 15.0 + (index % 3 == 0 ? 12 : (index % 2 == 0 ? 8 : 4)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFFF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    );
                  }),
                )
              else
                const SizedBox(height: 27),
              
              const SizedBox(height: 16),
              
              // Mode Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [25, 45, 60].map((mins) {
                  final sel = _selectedDuration == mins;
                  return GestureDetector(
                    onTap: () => _changeDuration(mins),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent.withValues(alpha: 0.15) : AppColors.c1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border,
                          width: sel ? 1 : 0.5,
                        ),
                      ),
                      child: Text(
                        '$mins Min',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? AppColors.accent2 : AppColors.t2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sound Toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _soundEnabled = !_soundEnabled;
                      });
                      state.addNotification(_soundEnabled ? "Soundscape aktif: $_activeSound" : "Soundscape dimatikan");
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Icon(
                        _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: _soundEnabled ? const Color(0xFF00FFFF) : AppColors.t3,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Main Play/Pause
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Reset Button
                  GestureDetector(
                    onTap: _resetTimer,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Icon(
                        Icons.replay_rounded,
                        color: AppColors.t2,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sound Selection Dropdown Drawer
              if (_soundEnabled)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.c2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soundscape:',
                        style: TextStyle(fontSize: 11, color: AppColors.t2, fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<String>(
                        value: _activeSound,
                        dropdownColor: AppColors.c2,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.accent),
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 11, color: AppColors.t1, fontWeight: FontWeight.w600),
                        items: _soundTracks.map((String sound) {
                          return DropdownMenuItem<String>(
                            value: sound,
                            child: Text(sound),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _activeSound = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}