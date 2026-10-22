import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MySpotsApp()));
}

class MySpotsApp extends StatelessWidget {
  const MySpotsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySpots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const Scaffold(
        appBar: null,
        body: Center(child: Text('Welcome to MySpots!')),
      ),
    );
  }
}
