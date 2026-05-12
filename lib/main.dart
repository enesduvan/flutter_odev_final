import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/todo_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF2EC4C7),
      onPrimary: Color(0xFF031A21),
      primaryContainer: Color(0xFF114C5A),
      onPrimaryContainer: Color(0xFFAEEFF1),
      secondary: Color(0xFF6EC9FF),
      onSecondary: Color(0xFF04243A),
      secondaryContainer: Color(0xFF143650),
      onSecondaryContainer: Color(0xFFCEE9FF),
      tertiary: Color(0xFF2CD3AA),
      onTertiary: Color(0xFF03261D),
      tertiaryContainer: Color(0xFF145445),
      onTertiaryContainer: Color(0xFFB8FCE5),
      error: Color(0xFFFF8B8B),
      onError: Color(0xFF3B0002),
      errorContainer: Color(0xFF5D1B1E),
      onErrorContainer: Color(0xFFFFDAD8),
      surface: Color(0xFF0E1624),
      onSurface: Color(0xFFDFE8F6),
      surfaceContainerHighest: Color(0xFF263141),
      onSurfaceVariant: Color(0xFFB6C3D8),
      outline: Color(0xFF4B5C76),
      outlineVariant: Color(0xFF314058),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE7EEF9),
      onInverseSurface: Color(0xFF121B2A),
      inversePrimary: Color(0xFF0E6F79),
      surfaceTint: Color(0xFF2EC4C7),
    );

    return ChangeNotifierProvider(
      create: (_) => TodoProvider()..initialize(),
      child: MaterialApp(
        title: 'Görev Hatırlatıcı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
          ),
          scaffoldBackgroundColor: const Color(0xFF09111E),
          cardTheme: CardThemeData(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.3),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
