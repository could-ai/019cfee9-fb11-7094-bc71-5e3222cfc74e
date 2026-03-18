import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CyberMeritApp());
}

class CyberMeritApp extends StatelessWidget {
  const CyberMeritApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '电子功德：好运敲敲',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Serif', // Using default serif for the vibe
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

// --- Data Models & Constants ---

class Phrase {
  final String text;
  final Color color;
  final int tier; // 1: Common, 2: Rare, 3: Legendary

  Phrase(this.text, this.color, this.tier);
}

final List<Phrase> commonPhrases = [
  Phrase("功德 +1", Colors.white70, 1),
  Phrase("烦恼 -1", Colors.white70, 1),
  Phrase("摸鱼 +1", Colors.white70, 1),
  Phrase("发量 +1根", Colors.white70, 1),
  Phrase("卡路里 -10", Colors.white70, 1),
  Phrase("早睡 +1天", Colors.white70, 1),
  Phrase("情绪稳定 +1", Colors.white70, 1),
  Phrase("颈椎放松 +1", Colors.white70, 1),
  Phrase("需求减少 +1", Colors.white70, 1),
  Phrase("代码无错 +1", Colors.white70, 1),
];

final List<Phrase> rarePhrases = [
  Phrase("脂肪 -2斤", Colors.amberAccent, 2),
  Phrase("Bug 自动消失", Colors.amberAccent, 2),
  Phrase("发际线 +1cm", Colors.amberAccent, 2),
  Phrase("带薪拉屎 +1次", Colors.amberAccent, 2),
  Phrase("周末不加班", Colors.amberAccent, 2),
  Phrase("方案一次过", Colors.amberAccent, 2),
  Phrase("灵感爆棚", Colors.amberAccent, 2),
  Phrase("水逆退散", Colors.amberAccent, 2),
];

final List<Phrase> legendaryPhrases = [
  Phrase("工资翻倍", Colors.purpleAccent.shade100, 3),
  Phrase("前任释怀", Colors.purpleAccent.shade100, 3),
  Phrase("老板失声", Colors.purpleAccent.shade100, 3),
  Phrase("好运暴击", Colors.purpleAccent.shade100, 3),
  Phrase("财富自由", Colors.purpleAccent.shade100, 3),
  Phrase("一夜暴富", Colors.purpleAccent.shade100, 3),
];

final List<String> zenQuotes = [
  "只要我躺得够平，困难就砸不到我。",
  "世上无难事，只要肯放弃。",
  "万事开头难，中间难，结尾也难。",
  "努力不一定成功，但不努力一定很轻松。",
  "做人最重要的是开心，如果开心很难，那就祝你平安。",
  "不要因为一次挫折就放弃，你还有很多次挫折。",
  "今天解决不了的事情，别着急，明天也解决不了。",
];

Phrase getRandomPhrase() {
  final rand = Random().nextInt(100);
  if (rand < 70) {
    return commonPhrases[Random().nextInt(commonPhrases.length)];
  } else if (rand < 95) {
    return rarePhrases[Random().nextInt(rarePhrases.length)];
  } else {
    return legendaryPhrases[Random().nextInt(legendaryPhrases.length)];
  }
}

String getRandomZenQuote() {
  return zenQuotes[Random().nextInt(zenQuotes.length)];
}

// --- Main Screen ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _meritCount = 0;
  final List<Widget> _floatingLabels = [];
  int _labelIdCounter = 0;

  void _handleTap(TapDownDetails details) {
    // Haptic feedback for the "knock" feel
    HapticFeedback.mediumImpact();

    setState(() {
      _meritCount++;
    });

    _showFloatingLabel(details.globalPosition);

    if (_meritCount > 0 && _meritCount % 100 == 0) {
      _showAchievementCard();
    }
  }

  void _showFloatingLabel(Offset position) {
    final phrase = getRandomPhrase();
    final id = _labelIdCounter++;
    
    // Add a slight random offset to the starting position so they don't overlap perfectly
    final randomOffsetX = (Random().nextDouble() - 0.5) * 40;
    final startPos = Offset(position.dx + randomOffsetX, position.dy - 50);

    final labelWidget = FloatingLabel(
      key: ValueKey(id),
      phrase: phrase,
      startPosition: startPos,
      onComplete: () {
        if (mounted) {
          setState(() {
            _floatingLabels.removeWhere((w) => w.key == ValueKey(id));
          });
        }
      },
    );

    setState(() {
      _floatingLabels.add(labelWidget);
    });
  }

  void _showAchievementCard() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return AchievementDialog(quote: getRandomZenQuote());
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Aurora Background with Frosted Glass
          const AuroraBackground(),
          
          // 2. Floating Labels Layer
          ..._floatingLabels,

          // 3. Top Right Counter
          Positioned(
            top: 60,
            right: 24,
            child: MeritCounter(count: _meritCount),
          ),

          // 4. Center Glowing Core
          Center(
            child: GlowingCore(
              onTapDown: _handleTap,
            ),
          ),

          // 5. Bottom Share Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Placeholder for actual screenshot sharing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('截图已生成，快去分享你的功德吧！'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.ios_share, size: 18, color: Colors.white70),
                label: const Text(
                  '截图分享',
                  style: TextStyle(color: Colors.white70, letterSpacing: 2),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark gray
        Container(color: const Color(0xFF1A1A1A)),
        
        // Animated Aurora Gradients
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -200 + (_controller.value * 100),
                  left: -100 - (_controller.value * 50),
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.teal.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 - (_controller.value * 80),
                  right: -50 + (_controller.value * 100),
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        // Frosted Glass Effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class GlowingCore extends StatefulWidget {
  final void Function(TapDownDetails) onTapDown;

  const GlowingCore({super.key, required this.onTapDown});

  @override
  State<GlowingCore> createState() => _GlowingCoreState();
}

class _GlowingCoreState extends State<GlowingCore> with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _tapController;
  late Animation<double> _breathAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    // Breathing animation
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _breathAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOutSine),
    );

    // Tap spring animation
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.elasticOut, // Spring effect
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward(from: 0.0).then((_) => _tapController.reverse());
    widget.onTapDown(details);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathController, _tapController]),
        builder: (context, child) {
          final scale = _breathAnimation.value * _tapAnimation.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3 * _breathAnimation.value),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingLabel extends StatefulWidget {
  final Phrase phrase;
  final Offset startPosition;
  final VoidCallback onComplete;

  const FloatingLabel({
    super.key,
    required this.phrase,
    required this.startPosition,
    required this.onComplete,
  });

  @override
  State<FloatingLabel> createState() => _FloatingLabelState();
}

class _FloatingLabelState extends State<FloatingLabel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dyAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dyAnimation = Tween<double>(begin: 0, end: -150).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine text style based on tier
    double fontSize = 18;
    FontWeight fontWeight = FontWeight.w600;
    List<Shadow>? shadows;

    if (widget.phrase.tier == 2) {
      fontSize = 22;
      fontWeight = FontWeight.bold;
      shadows = [Shadow(color: widget.phrase.color.withOpacity(0.5), blurRadius: 8)];
    } else if (widget.phrase.tier == 3) {
      fontSize = 26;
      fontWeight = FontWeight.w900;
      shadows = [
        Shadow(color: widget.phrase.color, blurRadius: 12),
        const Shadow(color: Colors.white, blurRadius: 4),
      ];
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx - 100, // Center horizontally
          top: widget.startPosition.dy + _dyAnimation.value,
          width: 200,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Center(
                child: Text(
                  widget.phrase.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.phrase.color,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    shadows: shadows,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MeritCounter extends StatelessWidget {
  final int count;

  const MeritCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          '累计功德',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Text(
            '$count',
            key: ValueKey<int>(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ],
    );
  }
}

class AchievementDialog extends StatelessWidget {
  final String quote;

  const AchievementDialog({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              '功德圆满',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '你已超越 99% 的打工人',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '今日禅语',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.withOpacity(0.2),
                foregroundColor: Colors.amber,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('继续修行', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
