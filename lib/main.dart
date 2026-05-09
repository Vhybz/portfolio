import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'receipt_page.dart';
import 'resume_page.dart';
import 'responsive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kyeremeh Clifford - Tech Raven',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFE50914),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFE50914),
          surface: Color(0xFF121212),
        ),
        useMaterial3: true,
      ),
      home: PortfolioPage(onThemeToggle: _toggleTheme),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const PortfolioPage({super.key, required this.onThemeToggle});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _profilePicKey = GlobalKey();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: AppDrawer(
        onThemeToggle: widget.onThemeToggle,
        onItemTap: (key) {
          _scrollTo(key);
          Navigator.pop(context);
        },
        keys: {
          'Home': _homeKey,
          'About': _aboutKey,
          'Skills': _skillsKey,
          'Projects': _projectsKey,
          'Services': _servicesKey,
          'Contact': _contactKey,
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.5,
            colors: isDark 
              ? [const Color(0xFF150202), const Color(0xFF050505)]
              : [const Color(0xFFFEF2F2), const Color(0xFFF9FAFB)],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Navbar(
                    scaffoldKey: _scaffoldKey,
                    onItemTap: _scrollTo,
                    onThemeToggle: widget.onThemeToggle,
                    keys: {
                      'Home': _homeKey,
                      'About': _aboutKey,
                      'Skills': _skillsKey,
                      'Projects': _projectsKey,
                      'Services': _servicesKey,
                      'Contact': _contactKey,
                    },
                  ),
                  Center(
                    child: Column(
                      children: [
                        HeroSection(
                          key: _homeKey, 
                          profilePicKey: _profilePicKey,
                          onViewProjects: () => _scrollTo(_projectsKey),
                        ),
                        AboutAndSkillsSection(aboutKey: _aboutKey, skillsKey: _skillsKey),
                        const ProcessSection(),
                        ProjectsSection(key: _projectsKey),
                        ServicesSection(key: _servicesKey),
                        const TestimonialsSection(),
                        const TechnologiesSection(),
                        ContactSection(key: _contactKey),
                        const Footer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RealisticRaven(
              targetKey: _profilePicKey,
              scrollController: _scrollController,
            ),
          ],
        ),
      ),
    );
  }
}

class RealisticRaven extends StatefulWidget {
  final GlobalKey targetKey;
  final ScrollController scrollController;
  const RealisticRaven({super.key, required this.targetKey, required this.scrollController});

  @override
  State<RealisticRaven> createState() => _RealisticRavenState();
}

class _RealisticRavenState extends State<RealisticRaven> with TickerProviderStateMixin {
  late AnimationController _flapController;
  late AnimationController _moveController;
  late AnimationController _bobController;
  Offset _currentPos = const Offset(-150, 100);
  bool _isStanding = false;
  bool _isGliding = false;
  double _headTurn = 0.0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _flapController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this)..repeat(reverse: true);
    _moveController = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _bobController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..repeat(reverse: true);
    
    _startFlightCycle();
    widget.scrollController.addListener(_updatePositionIfStanding);
  }

  void _updatePositionIfStanding() {
    if (_isStanding && mounted) {
      setState(() {
        _currentPos = _getTargetPosition();
      });
    }
  }

  Offset _getTargetPosition() {
    if (widget.targetKey.currentContext != null) {
      final RenderBox box = widget.targetKey.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      return Offset(position.dx + box.size.width / 2 - 50, position.dy - 82);
    }
    return _currentPos;
  }

  void _startFlightCycle() async {
    while (mounted) {
      await _flyTo(Offset(_random.nextDouble() * 400 + 100, _random.nextDouble() * 200 + 100), duration: 3);
      
      setState(() => _isGliding = true);
      _flapController.duration = const Duration(milliseconds: 600);
      await _flyTo(Offset(_currentPos.dx + 200, _currentPos.dy + 20), duration: 2);
      setState(() => _isGliding = false);
      _flapController.duration = const Duration(milliseconds: 250);

      if (widget.targetKey.currentContext != null) {
        _flapController.duration = const Duration(milliseconds: 150);
        await _flyTo(_getTargetPosition(), duration: 2);
        
        if (!mounted) return;
        setState(() {
          _isStanding = true;
          _isGliding = false;
        });
        _flapController.stop();
        _bobController.duration = const Duration(seconds: 1);
        
        for (int i = 0; i < 4; i++) {
          await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));
          if (!mounted) return;
          setState(() {
            _headTurn = (_random.nextDouble() - 0.5) * 0.4;
          });
        }
        
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        setState(() {
          _isStanding = false;
          _headTurn = 0.0;
        });
        _flapController.duration = const Duration(milliseconds: 100);
        _flapController.repeat(reverse: true);
        await _flyTo(Offset(_currentPos.dx, _currentPos.dy - 100), duration: 1);
        _flapController.duration = const Duration(milliseconds: 250);
      }
      
      await _flyTo(Offset(MediaQuery.of(context).size.width + 200, 150), duration: 3);
      _currentPos = const Offset(-200, 200);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> _flyTo(Offset target, {required int duration}) async {
    final start = _currentPos;
    _moveController.duration = Duration(seconds: duration);
    _moveController.reset();
    
    final Animation<Offset> anim = Tween<Offset>(begin: start, end: target).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic),
    );

    _moveController.addListener(() {
      if (mounted && !_isStanding) {
        double jitterX = _isGliding ? 0 : math.sin(_moveController.value * 50) * 1.5;
        double jitterY = math.cos(_moveController.value * 30) * 2.0;
        setState(() {
          _currentPos = anim.value + Offset(jitterX, jitterY);
        });
      }
    });

    await _moveController.forward();
  }

  @override
  void dispose() { 
    _flapController.dispose(); 
    _moveController.dispose(); 
    _bobController.dispose();
    widget.scrollController.removeListener(_updatePositionIfStanding);
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentPos.dx, 
      top: _currentPos.dy, 
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          double bob = _isStanding ? math.sin(_bobController.value * math.pi) * 2 : 0;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.scale(
              scale: 0.4,
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(100, 80), 
                painter: RavenPainter(
                  flapValue: _isStanding ? 0.2 : (_isGliding ? 0.1 : _flapController.value), 
                  isStanding: _isStanding,
                  headTurn: _headTurn,
                  isGliding: _isGliding,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RavenPainter extends CustomPainter {
  final double flapValue;
  final bool isStanding;
  final double headTurn;
  final bool isGliding;
  final bool isDark;
  RavenPainter({
    required this.flapValue, 
    required this.isStanding, 
    required this.headTurn,
    required this.isGliding,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = isDark ? const Color(0xFF151515) : Colors.black..style = PaintingStyle.fill;
    final legPaint = Paint()..color = isDark ? const Color(0xFF151515) : Colors.black..style = PaintingStyle.stroke..strokeWidth = 3;
    final eyePaint = Paint()..color = const Color(0xFF00B2FF)..style = PaintingStyle.fill;

    final path = Path();
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    path.addOval(Rect.fromCircle(center: Offset(headTurn * 15, -20), radius: 15));
    
    final beakPath = Path();
    beakPath.moveTo(headTurn * 25 - 5, -25);
    beakPath.lineTo(headTurn * 25 + 5, -25);
    beakPath.lineTo(headTurn * 35, -15);
    beakPath.close();
    path.addPath(beakPath, Offset.zero);

    path.addOval(Rect.fromCenter(center: const Offset(0, 5), width: 40, height: 50));

    double flap = (flapValue - 0.5) * 2;
    if (isStanding) flap = 0.8;
    if (isGliding) flap = -0.1;

    final leftWing = Path();
    leftWing.moveTo(-20, 0);
    leftWing.quadraticBezierTo(-50, -10 + (flap * 50), -80, 10 + (flap * 30));
    leftWing.quadraticBezierTo(-50, 30, -20, 10);
    path.addPath(leftWing, Offset.zero);

    final rightWing = Path();
    rightWing.moveTo(20, 0);
    rightWing.quadraticBezierTo(50, -10 + (flap * 50), 80, 10 + (flap * 30));
    rightWing.quadraticBezierTo(50, 30, 20, 10);
    path.addPath(rightWing, Offset.zero);

    if (isStanding) {
      canvas.drawLine(const Offset(-10, 30), const Offset(-15, 45), legPaint);
      canvas.drawLine(const Offset(10, 30), const Offset(15, 45), legPaint);
    }

    canvas.drawPath(path, bodyPaint);

    double eyeOffsetX = headTurn * 15;
    canvas.drawCircle(Offset(eyeOffsetX - 6, -22), 2.5, eyePaint);
    canvas.drawCircle(Offset(eyeOffsetX + 6, -22), 2.5, eyePaint);
    
    final glowPaint = Paint()
      ..color = const Color(0xFF00B2FF).withAlpha(40)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(eyeOffsetX - 6, -22), 5, glowPaint);
    canvas.drawCircle(Offset(eyeOffsetX + 6, -22), 5, glowPaint);

    canvas.restore();
  }
  @override
  bool shouldRepaint(RavenPainter oldDelegate) => true;
}

class Navbar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(GlobalKey) onItemTap;
  final VoidCallback onThemeToggle;
  final Map<String, GlobalKey> keys;
  const Navbar({super.key, required this.scaffoldKey, required this.onItemTap, required this.onThemeToggle, required this.keys});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withAlpha(20))),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildLogo()),
              if (!isMobile) ...[
                const Spacer(),
                Flexible(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavItems(),
                        const SizedBox(width: 20),
                        _buildThemeToggle(context),
                        const SizedBox(width: 15),
                        _buildCVButton(context),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
                _buildThemeToggle(context, small: true),
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onItemTap(keys['Home']!),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/rev.jpg', height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Color(0xFFE50914), size: 24)),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'TECH RAVEN', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItems() {
    return Row(
      children: keys.entries
          .where((e) => e.key != 'Home')
          .map((e) => _navItem(e.key, e.value))
          .toList(),
    );
  }

  Widget _buildThemeToggle(BuildContext context, {bool small = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (small) {
      return IconButton(
        icon: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
        onPressed: onThemeToggle,
        color: const Color(0xFFE50914),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onThemeToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE50914).withAlpha(15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE50914).withAlpha(40)),
          ),
          child: Row(
            children: [
              Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 16, color: const Color(0xFFE50914)),
              const SizedBox(width: 10),
              Text(
                isDark ? "DARK" : "LIGHT",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE50914), letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCVButton(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => _showAuthDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE50914),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            side: const BorderSide(color: Color(0xFFE50914)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Receipts', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ResumePage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE50914),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showAuthDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Access Restricted', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please enter the administrative ID to access the Receipt Generator.'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Admin ID',
                filled: true,
                fillColor: Theme.of(context).dividerColor.withAlpha(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == 'kkrasta') {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReceiptPage()));
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid ID. Access Denied.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Access'),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, GlobalKey key) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onItemTap(key),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      );
}

class AppDrawer extends StatelessWidget {
  final Function(GlobalKey) onItemTap;
  final Map<String, GlobalKey> keys;
  final VoidCallback onThemeToggle;
  const AppDrawer({super.key, required this.onItemTap, required this.keys, required this.onThemeToggle});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const DrawerHeader(child: Center(child: Text('TECH RAVEN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFE50914), letterSpacing: 3)))),
                ...keys.entries.map((e) => ListTile(title: Text(e.key), onTap: () => onItemTap(e.value))),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFFE50914)),
                  title: const Text('Generate Receipt'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAuthDialog(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListTile(
              leading: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode),
              title: Text(Theme.of(context).brightness == Brightness.dark ? "Dark Mode" : "Light Mode"),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (_) => onThemeToggle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Access Restricted', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please enter the administrative ID to access the Receipt Generator.'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Admin ID',
                filled: true,
                fillColor: Theme.of(context).dividerColor.withAlpha(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == 'kkrasta') {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReceiptPage()));
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid ID. Access Denied.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Access'),
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final GlobalKey profilePicKey;
  final VoidCallback onViewProjects;
  const HeroSection({super.key, required this.profilePicKey, required this.onViewProjects});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.08, 
        vertical: isMobile ? 80 : (isTablet ? 100 : 150)
      ),
      child: Responsive(
        mobile: Column(
          children: [
            _buildImage(context, isMobile),
            const SizedBox(height: 60),
            _buildText(context, isMobile, isTablet),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(flex: 3, child: _buildText(context, isMobile, isTablet)),
            const SizedBox(width: 50),
            Expanded(flex: 2, child: _buildImage(context, isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, bool isMobile, bool isTablet) {
    return FadeInAnimation(
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withAlpha(20),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE50914).withAlpha(40)),
            ),
            child: const Text('👋 Hello, I\'m', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE50914))),
          ),
          const SizedBox(height: 24),
          Text.rich(
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            TextSpan(
              text: 'Kyeremeh ',
              style: TextStyle(
                fontSize: isMobile ? 42 : (isTablet ? 60 : 80),
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1.1,
              ),
              children: const [
                TextSpan(
                  text: 'Clifford',
                  style: TextStyle(
                    color: Color(0xFFE50914),
                    shadows: [Shadow(color: Color(0xFFE50914), blurRadius: 40)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Founder & CEO of Tech Raven | Full Stack Architect',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(200),
            ),
          ),
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Founder and CEO of Tech Raven, leading the vision for high-performance digital ecosystems. I specialize in architecting elite applications that transform visionary ideas into industry-leading solutions.',
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200),
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _ActionButton(
                label: 'View My Projects',
                onPressed: onViewProjects,
                isPrimary: true,
              ),
              _ActionButton(
                label: 'Contact Me',
                onPressed: () async {
                  final uri = Uri.parse('https://wa.me/233559650921');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                isPrimary: false,
                icon: Icons.chat_bubble_outline,
              ),
            ],
          ),
          const SizedBox(height: 48),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 15,
            runSpacing: 15,
            children: const [
              SocialIconButton(icon: Icons.code, url: 'https://github.com/Vhybz'),
              SocialIconButton(icon: Icons.chat_bubble_outline, url: 'https://wa.me/233559650921'),
              SocialIconButton(icon: Icons.link, url: 'https://linkedin.com'),
              SocialIconButton(icon: Icons.email_outlined, url: 'mailto:techraven11@gmail.com'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, bool isMobile) {
    final size = MediaQuery.of(context).size;
    final imageSize = isMobile ? size.width * 0.7 : math.min(size.width * 0.3, 420.0);
    
    return FadeInAnimation(
      delay: 300,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _glowCircle(imageSize * 1.3, 0.1),
            _glowCircle(imageSize * 1.15, 0.05),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE50914).withAlpha(30), width: 2),
              ),
              child: Container(
                key: profilePicKey,
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE50914), width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE50914).withAlpha(80),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/pic.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 100, color: Colors.white10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(double s, double o) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE50914).withValues(alpha: o),
              Colors.transparent,
            ],
          ),
        ),
      );
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.icon,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFE50914).withAlpha(60),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary ? const Color(0xFFE50914) : Colors.transparent,
            foregroundColor: widget.isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 40, vertical: 24),
            elevation: 0,
            side: widget.isPrimary ? null : BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(100)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null && _isHovered) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutAndSkillsSection extends StatelessWidget {
  final GlobalKey aboutKey, skillsKey;
  const AboutAndSkillsSection({super.key, required this.aboutKey, required this.skillsKey});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: isMobile ? 60 : 100),
      child: Column(
        children: [
          if (isMobile) ...[
            _buildAbout(context),
            const SizedBox(height: 30),
            _buildSkills(context),
            const SizedBox(height: 30),
            _buildHighlights(context),
          ] else if (isTablet) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildAbout(context)),
                const SizedBox(width: 30),
                Expanded(flex: 1, child: _buildSkills(context)),
              ],
            ),
            const SizedBox(height: 30),
            _buildHighlights(context),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildAbout(context)),
                const SizedBox(width: 30),
                Expanded(flex: 2, child: _buildSkills(context)),
                const SizedBox(width: 30),
                Expanded(flex: 1, child: _buildHighlights(context)),
              ],
            ),
          ],
        ],
      ),
    );
  }  Widget _buildAbout(BuildContext context) {
    return _card(
      context: context,
      key: aboutKey,
      icon: Icons.person_outline,
      title: 'About Me',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'As the Founder and CEO of Tech Raven, I lead the technical vision and strategy for high-impact mobile and web applications. I am dedicated to building products that not only function flawlessly but also redefine industry benchmarks.',
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(180),
            ),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: const Color(0xFFE50914),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Read More', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(BuildContext context) {
    return _card(
      context: context,
      key: skillsKey,
      icon: Icons.code,
      title: 'Top Skills',
      content: Column(
        children: [
          _sBar('Flutter & Dart', 1.0),
          _sBar('Backend (Supabase/Firebase)', 0.95),
          _sBar('Full Stack Architecture', 0.98),
          _sBar('UI/UX Design', 0.92),
          _sBar('Cloud Infrastructure', 0.85),
        ],
      ),
    );
  }

  Widget _buildHighlights(BuildContext context) {
    return _card(
      context: context,
      icon: Icons.star_outline,
      title: 'Highlights',
      content: SizedBox(
        width: double.infinity,
        child: Wrap(
          runSpacing: 25,
          spacing: 25,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            _StatItem(v: '5+', l: 'Years Exp'),
            _StatItem(v: '100+', l: 'Projects'),
            _StatItem(v: '50+', l: 'Clients'),
          ],
        ),
      ),
    );
  }

  Widget _card({required BuildContext context, Key? key, required IconData icon, required String title, required Widget content}) {
    final isSmall = MediaQuery.of(context).size.width < 1200;
    return Container(
        key: key,
        padding: EdgeInsets.all(isSmall ? 24 : 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFE50914), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: -0.5,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            content,
          ],
        ),
      );
  }

  Widget _sBar(String s, double l) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s, 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(l * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: l,
                backgroundColor: const Color(0xFFE50914).withAlpha(40),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE50914)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
}

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: isMobile ? 60 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PORTFOLIO', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Featured Projects', style: TextStyle(fontSize: isMobile ? 32 : (isTablet ? 40 : 48), fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
              ),
              if (!isMobile)
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('View All Projects', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_right_alt, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 60),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width > 1200 ? 3 : (width > 700 ? 2 : 1),
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: isMobile ? 0.95 : (isTablet ? 1.1 : 1.25),
            ),
            itemCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final p = [
                {'t': 'Meat Shop POS', 'g': ['Flutter', 'MySQL', 'Node.js'], 'i': Icons.shopping_cart},
                {'t': 'Pet Care App', 'g': ['Flutter', 'Firebase', 'Cloud Functions'], 'i': Icons.pets},
                {'t': 'News Portal', 'g': ['PHP', 'MySQL', 'Rest API'], 'i': Icons.article},
                {'t': 'Attendance System', 'g': ['Flutter', 'SQLite', 'Biometrics'], 'i': Icons.fingerprint},
                {'t': 'Analytics Dashboard', 'g': ['Flutter', 'Charts', 'Supabase'], 'i': Icons.dashboard},
              ];
              return _PCard(
                title: p[index]['t'] as String,
                tags: p[index]['g'] as List<String>,
                icon: p[index]['i'] as IconData,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PCard extends StatefulWidget {
  final String title;
  final List<String> tags;
  final IconData icon;
  const _PCard({required this.title, required this.tags, required this.icon});
  @override State<_PCard> createState() => _PCardState();
}

class _PCardState extends State<_PCard> {
  bool h = false;
  @override Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return MouseRegion(
      onEnter: (_) => setState(() => h = true),
      onExit: (_) => setState(() => h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: h ? (Matrix4.identity()..setTranslationRaw(0.0, -10.0, 0.0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: h ? const Color(0xFFE50914).withAlpha(100) : Theme.of(context).dividerColor.withAlpha(15)),
          boxShadow: h ? [BoxShadow(color: const Color(0xFFE50914).withAlpha(40), blurRadius: 40, offset: const Offset(0, 20))] : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).dividerColor.withAlpha(10),
                child: Icon(widget.icon, color: h ? const Color(0xFFE50914) : Theme.of(context).dividerColor.withAlpha(20), size: 80),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t, 
                        style: const TextStyle(fontSize: 11, color: Color(0xFFE50914), fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: isMobile ? 60 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SERVICES', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
          const SizedBox(height: 8),
          Text('What I Offer', style: TextStyle(fontSize: isMobile ? 32 : (isTablet ? 40 : 48), fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 60),
          GridView.count(
            crossAxisCount: width > 1200 ? 3 : (width > 700 ? 2 : 1),
            shrinkWrap: true,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            childAspectRatio: isMobile ? 1.1 : 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _SCard(i: Icons.smartphone, t: 'App Development', d: 'High-performance native and cross-platform mobile apps.'),
              _SCard(i: Icons.auto_awesome, t: 'UI/UX Design', d: 'Modern, clean, and intuitive user interface designs.'),
              _SCard(i: Icons.cloud, t: 'Cloud Solutions', d: 'Scalable backend architectures using Supabase & Firebase.'),
              _SCard(i: Icons.code, t: 'Web Development', d: 'Responsive and SEO-optimized web applications.'),
              _SCard(i: Icons.security, t: 'Security Audit', d: 'Ensuring your digital products are safe and reliable.'),
              _SCard(i: Icons.rocket, t: 'MVP Development', d: 'Turning your startup ideas into working prototypes fast.'),
            ],
          ),
        ],
      ),
    );
  }
}class _SCard extends StatelessWidget {
  final IconData i;
  final String t, d;
  const _SCard({required this.i, required this.t, required this.d});
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(i, color: const Color(0xFFE50914), size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            t, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            d, 
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(200), height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TechnologiesSection extends StatelessWidget {
  const TechnologiesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 60),
      child: Column(
        children: [
          Text(
            'TRUSTED BY TOOLS & TECHNOLOGIES',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor.withAlpha(150),
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 40,
            children: [
              _tech(Icons.flutter_dash, 'Flutter', context),
              _tech(Icons.storage, 'Supabase', context),
              _tech(Icons.fireplace, 'Firebase', context),
              _tech(Icons.code, 'Dart', context),
              _tech(Icons.terminal, 'Git/GitHub', context),
              _tech(Icons.layers, 'Clean Arch', context),
              _tech(Icons.web, 'Web Dev', context),
              _tech(Icons.android, 'Android', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tech(IconData i, String l, BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(10)),
              ),
              child: Icon(i, color: Theme.of(context).hintColor.withAlpha(200), size: 32),
            ),
            const SizedBox(height: 12),
            Text(l, style: TextStyle(color: Theme.of(context).hintColor.withAlpha(200), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: isMobile ? 60 : 100),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 30 : 80),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(isMobile ? 32 : 40),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(15)),
        ),
        child: Responsive(
          mobile: Column(
            children: [
              _buildContactText(context, isMobile),
              const SizedBox(height: 60),
              _buildContactInfo(context),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(flex: 3, child: _buildContactText(context, isMobile)),
              const SizedBox(width: 80),
              Expanded(flex: 2, child: _buildContactInfo(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showConversationOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Start a Conversation', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE50914).withAlpha(20), shape: BoxShape.circle),
                child: const Icon(Icons.email_outlined, color: Color(0xFFE50914), size: 20),
              ),
              title: const Text('Email Me', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('techraven11@gmail.com', style: TextStyle(fontSize: 12)),
              onTap: () async {
                final uri = Uri.parse('mailto:techraven11@gmail.com');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE50914).withAlpha(20), shape: BoxShape.circle),
                child: const Icon(Icons.chat_bubble_outline, color: Color(0xFFE50914), size: 20),
              ),
              title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('0559650921', style: TextStyle(fontSize: 12)),
              onTap: () async {
                final uri = Uri.parse('https://wa.me/233559650921');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactText(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text('GET IN TOUCH', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 24),
        Text(
          'Ready to build something amazing?',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: isMobile ? 32 : 56, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'I\'m currently available for freelance work and full-time opportunities. Let\'s turn your vision into reality.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18, 
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(150), 
              height: 1.6
            ),
          ),
        ),
        const SizedBox(height: 48),
        _ActionButton(
          label: 'Start a Conversation', 
          onPressed: () => _showConversationOptions(context), 
          isPrimary: true
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      children: const [
        _CTile(i: Icons.email_outlined, t: 'Email Me', v: 'techraven11@gmail.com'),
        SizedBox(height: 20),
        _CTile(i: Icons.phone_outlined, t: 'Call Me', v: '+233 559 650 921 / +233 503 574 865'),
        SizedBox(height: 20),
        _CTile(i: Icons.chat_bubble_outline, t: 'WhatsApp', v: '0559650921'),
        SizedBox(height: 20),
        _CTile(i: Icons.location_on_outlined, t: 'Location', v: 'Sunyani, Ghana'),
      ],
    );
  }
}

class _CTile extends StatelessWidget {
  final IconData i; final String t, v;
  const _CTile({required this.i, required this.t, required this.v});
  @override Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          Uri? uri;
          if (t == 'Email Me') uri = Uri.parse('mailto:$v');
          if (t == 'Call Me') uri = Uri.parse('tel:${v.split(' / ').first}');
          if (t == 'WhatsApp') uri = Uri.parse('https://wa.me/233559650921');
          
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withAlpha(5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(i, color: const Color(0xFFE50914), size: 24),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String v, l; const _StatItem({required this.v, required this.l});
  @override
  Widget build(BuildContext context) { 
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE50914))), 
        Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor))
      ]
    ); 
  }
}

class SocialIconButton extends StatelessWidget {
  final IconData icon; 
  final String? url;
  const SocialIconButton({super.key, required this.icon, this.url});

  @override build(BuildContext context) { 
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (url != null) {
            final uri = Uri.parse(url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12), 
          decoration: BoxDecoration(color: Theme.of(context).dividerColor.withAlpha(8), shape: BoxShape.circle), 
          child: Icon(icon, size: 20)
        ),
      ),
    ); 
  }
}

class ProcessSection extends StatelessWidget {
  const ProcessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OUR PROCESS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
          const SizedBox(height: 8),
          Text('How We Bring Ideas to Life', style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 60),
          Responsive(
            mobile: Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                _buildStep(context, '01', 'Discovery', 'Deep dive into your goals and research.', Icons.search),
                _buildStep(context, '02', 'Strategy', 'Defining the roadmap and architecture.', Icons.insights),
                _buildStep(context, '03', 'Execution', 'High-speed development with precision.', Icons.code),
                _buildStep(context, '04', 'Optimization', 'Scaling and refining for peak performance.', Icons.speed),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: _buildStep(context, '01', 'Discovery', 'Goals & Research', Icons.search)),
                _arrow(),
                Expanded(child: _buildStep(context, '02', 'Strategy', 'Roadmap & Design', Icons.insights)),
                _arrow(),
                Expanded(child: _buildStep(context, '03', 'Execution', 'Agile Development', Icons.code)),
                _arrow(),
                Expanded(child: _buildStep(context, '04', 'Optimization', 'Testing & Launch', Icons.speed)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String num, String title, String desc, IconData icon) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE50914).withAlpha(30)),
            ),
            child: Center(child: Text(num, style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w900, fontSize: 20))),
          ),
          const SizedBox(height: 24),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor.withAlpha(150), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _arrow() => Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Icon(Icons.keyboard_double_arrow_right_rounded, color: const Color(0xFFE50914).withAlpha(50), size: 30),
      );
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 100),
      child: Column(
        children: [
          const Text('TESTIMONIALS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
          const SizedBox(height: 8),
          Text('What Our Partners Say', style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: const [
              _TestimonialCard(
                quote: "Tech Raven transformed our outdated system into a high-performance machine. Their speed and precision are unmatched.",
                author: "Sarah Johnson",
                role: "CEO, Streamline Corp",
              ),
              _TestimonialCard(
                quote: "Kyeremeh Clifford is a visionary leader. He doesn't just build apps; he builds businesses. Highly recommended.",
                author: "David Chen",
                role: "Founder, Fintech Solutions",
              ),
              _TestimonialCard(
                quote: "The best agency I've ever worked with. The communication and delivery exceed expectations every single time.",
                author: "Michael Peters",
                role: "Product Manager, Global Tech",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote, author, role;
  const _TestimonialCard({required this.quote, required this.author, required this.role});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      constraints: BoxConstraints(maxWidth: width < 480 ? width * 0.9 : 400),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: Color(0xFFE50914), size: 40),
          const SizedBox(height: 20),
          Text(
            quote,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
                child: Center(child: Text(author[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(role, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override build(BuildContext context) { 
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40), 
      child: Center(
        child: Text(
          '© 2024 TECH RAVEN. POWERED BY KYEREMEH CLIFFORD.', 
          style: TextStyle(color: Theme.of(context).hintColor.withAlpha(100), fontSize: 10, letterSpacing: 2)
        )
      )
    ); 
  }
}

class FadeInAnimation extends StatelessWidget {
  final Widget child; final int delay;
  const FadeInAnimation({super.key, required this.child, this.delay = 0});
  @override build(BuildContext context) {
    return TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: 1), duration: const Duration(milliseconds: 1000), curve: Curves.easeOutQuart, builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child)), child: child);
  }
}
