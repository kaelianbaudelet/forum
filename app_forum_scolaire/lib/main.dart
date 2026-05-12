import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forum_detail_screen.dart';
import 'screens/write_message_screen.dart';
import 'screens/users_screen.dart';
import 'providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/link.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env.local");
  runApp(
    kIsWeb
        ? const WebLandingPage()
        : DevicePreview(enabled: false, builder: (context) => const AppRoot()),
  );
}

/// Base of the application containing providers.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    );
  }
}

/// A premium landing page for the Web version.
class WebLandingPage extends StatefulWidget {
  const WebLandingPage({super.key});

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
  Future<void> _checkFirstTime(BuildContext context) async {
    final isDemoMode = dotenv.env['APP_DEMO'] == 'true';
    if (!isDemoMode) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenDemoModal') ?? false;

    if (!hasSeen) {
      if (mounted) {
        showDemoModal(context, isFirstTime: true);
      }
    }
  }

  void showDemoModal(BuildContext context, {bool isFirstTime = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Text(
                  "Mode Démonstration",
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Bienvenue sur Forum. Explorez l'app avec ce compte de test.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Credential Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "TEST",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Text(
                              "COMPTE DE TEST",
                              style: GoogleFonts.lexend(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "EMAIL",
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SelectableText(
                              "test@demo.fr",
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "MOT DE PASSE",
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SelectableText(
                              "test",
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isFirstTime) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasSeenDemoModal', true);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isFirstTime ? "Accéder à la démo" : "Continuer",
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.lexendTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
      ),
      home: Builder(
        builder: (context) {
          final isDemoMode = dotenv.env['APP_DEMO'] == 'true';

          // Trigger the check once the builder is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkFirstTime(context);
          });

          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Demo Banner
                  if (isDemoMode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFFCD34D),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFF92400E),
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Vous consultez une version de démonstration de Forum.",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF92400E),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Header Row (AppBar style)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Image.asset('assets/logo.png', height: 30),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                "Situation n°2 de l'épreuve E6 du BTS SIO",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              Link(
                                uri: Uri.parse(
                                  "https://github.com/kaelianbaudelet/forum",
                                ),
                                target: LinkTarget.blank,
                                builder: (context, followLink) => IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.github,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  onPressed: followLink,
                                  tooltip: "GitHub du projet",
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                tooltip: "Plus d'options",
                                onSelected: (value) {
                                  if (value == 'fiche') {
                                    launchUrl(
                                      Uri.parse(
                                        "https://docs.google.com/document/d/1PfRzr-XzlBp5sigpyj1XkWHlQsOTAKWKbIZqYVUGtUI/edit?usp=sharing",
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else if (value == 'api') {
                                    launchUrl(
                                      Uri.parse(
                                        dotenv.env['API_BASE_URL'] ??
                                            "http://localhost:8000/api",
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else if (value == 'test') {
                                    showDemoModal(context);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (isDemoMode)
                                    const PopupMenuItem(
                                      value: 'test',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 12),
                                          Text("Compte de test"),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'fiche',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 12),
                                        Text("Fiche situation"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'api',
                                    child: Row(
                                      children: [
                                        Icon(Icons.api, color: Colors.black),
                                        SizedBox(width: 12),
                                        Text("API Forum"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // App Preview Section
                  Expanded(
                    child: DevicePreview(
                      enabled: true,
                      isToolbarVisible: false,
                      backgroundColor: Colors.white,
                      tools: const [],
                      defaultDevice: Devices.ios.iPhone13,
                      builder: (context) => const AppRoot(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forum',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forum-detail': (context) => const ForumDetailScreen(),
        '/write-message': (context) => const WriteMessageScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
