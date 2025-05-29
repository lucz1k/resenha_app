import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:resenha_app/screens/dados_iniciais.dart';
import 'package:resenha_app/screens/equipe_apoios.dart';
import 'package:resenha_app/screens/envolvidos.dart';
import 'package:resenha_app/screens/veiculos_outros.dart';
import 'package:resenha_app/screens/historico.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env carregado com sucesso");
  } catch (e) {
    debugPrint("⚠️ Erro ao carregar .env: $e");
    dotenv.testLoad(
      fileInput: 'OPENAI_API_KEY=${const String.fromEnvironment('OPENAI_API_KEY')}',
    );
  }

  runApp(MyApp());
  debugPrint("🚀 runApp foi chamado");
}

class MyApp extends StatelessWidget {
  MyApp({super.key}); // ✅ removido const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resenha App',
      initialRoute: '/',
      routes: {
        '/': (context) => DadosIniciaisPage(),
        '/equipe_apoios': (context) => EquipeApoiosPage(),
        '/envolvidos': (context) => EnvolvidosPage(),
        '/veiculos_outros': (context) => VeiculosOutrosPage(),
        '/historico': (context) => HistoricoPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
