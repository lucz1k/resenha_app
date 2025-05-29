import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resenha_app/screens/dados_iniciais.dart';
import 'package:resenha_app/screens/equipe_apoios.dart';
import 'package:resenha_app/screens/envolvidos.dart';
import 'package:resenha_app/screens/veiculos_outros.dart';
import 'package:resenha_app/screens/historico.dart';

void main() {
  runApp(MyApp());
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
