import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/hadith_reader_screen.dart';
import 'widgets/app_drawer.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications with deep-link navigation
  try {
    await NotificationService().initialize(
      onSelectHadith: (hadithId) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => HadithReaderScreen(initialHadithId: hadithId),
          ),
        );
      },
    );
  } catch (e) {
    debugPrint('NotificationService initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const AlfuHadithApp(),
    ),
  );
}

class AlfuHadithApp extends StatelessWidget {
  const AlfuHadithApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '1001 Authentic Hadith',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF0D9488),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          elevation: 0,
          foregroundColor: Color(0xFF0F172A),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D9488),
          secondary: Color(0xFFF59E0B),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A101D),
        primaryColor: const Color(0xFF14B8A6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A101D),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF14B8A6),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF111B2D),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({Key? key}) : super(key: key);

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.requestPermissionsOnAppStart();
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookmarksScreen(),
    AboutScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'أَلْفُ حَدِيثٍ وَحَدِيثٌ',
    'Search Hadiths',
    'Bookmarks',
    'About Compendium',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 24),
          tooltip: 'Open Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontFamily: _currentIndex == 0 ? 'Amiri' : null,
            fontSize: _currentIndex == 0 ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: _currentIndex == 0 ? const Color(0xFF14B8A6) : null,
          ),
        ),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_outline_rounded),
              tooltip: 'Bookmarks',
              onPressed: () => setState(() => _currentIndex = 2),
            ),
          ] else if (_currentIndex != 4) ...[
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () {
                provider.setThemeMode(
                  isDark ? AppThemeMode.light : AppThemeMode.dark,
                );
              },
            ),
          ],
        ],
      ),
      drawer: AppDrawer(
        currentTabIndex: _currentIndex,
        onSelectTab: (idx) => setState(() => _currentIndex = idx),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: const Color(0xFF0D9488).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF14B8A6)),
            label: 'Chapters',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Color(0xFF14B8A6)),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark, color: Color(0xFFF59E0B)),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info, color: Color(0xFF14B8A6)),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded, color: Color(0xFF14B8A6)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
