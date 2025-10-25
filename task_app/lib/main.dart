import 'package:flutter/material.dart';
import 'package:task_app/screens/main_screen.dart';
import 'package:task_app/services/database_service.dart';

// 1. Importa el inicializador de formato de fechas
import 'package:intl/date_symbol_data_local.dart';

// 2. Importa los delegados de localización
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base de datos SQLite
  await DatabaseService().initDB();

  // 3. ¡LA LÍNEA CLAVE! Inicializa los datos del idioma español
  // Esto soluciona el LocaleDataException
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasker App (SQLite)',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
      ),

      // 4. Agrega los delegados y locales soportados
      // Esto hace que toda la app (como los DatePickers) también usen español
      locale: const Locale('es', 'ES'), // Establece el idioma por defecto
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (opcional, como fallback)
      ],

      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
