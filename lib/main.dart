import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/enhanced_todo_list_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'services/todo_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize the TodoService
  final todoService = TodoService();
  await todoService.loadTodos();

  runApp(MyApp(todoService: todoService));
}

class MyApp extends StatefulWidget {
  final TodoService todoService;

  const MyApp({super.key, required this.todoService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    // Simulate loading time for splash screen
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  void _openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SettingsScreen(
              themeMode: _themeMode,
              onThemeChanged: (mode) => setState(() => _themeMode = mode),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home:
          _isLoading
              ? const SplashScreen()
              : TodoListScreen(
                todoService: widget.todoService,
                openSettings: _openSettings,
              ),
    );
  }
}
