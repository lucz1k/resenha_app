import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:resenha_app/screens/dados_iniciais.dart';
import 'package:resenha_app/screens/equipe_apoios.dart';
import 'package:resenha_app/screens/envolvidos.dart';
import 'package:resenha_app/screens/veiculos_outros.dart';
import 'package:resenha_app/screens/historico.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    await dotenv.testLoad(
      fileInput: 'OPENAI_API_KEY=${const String.fromEnvironment('OPENAI_API_KEY')}',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resenha App',
      initialRoute: '/',
      routes: {
        '/': (context) => const DadosIniciaisPage(),
        '/equipe_apoios': (context) => const EquipeApoiosPage(),
        '/envolvidos': (context) => const EnvolvidosPage(),
        '/veiculos_outros': (context) => const VeiculosOutrosPage(),
        '/historico': (context) => const HistoricoPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
