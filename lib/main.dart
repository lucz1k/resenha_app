// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importe o pacote dotenv

// Importações das suas telas
import 'package:resenha_app/screens/dados_iniciais.dart';
import 'package:resenha_app/screens/equipe_apoios.dart';
import 'package:resenha_app/screens/envolvidos.dart';
import 'package:resenha_app/screens/veiculos_outros.dart';
import 'package:resenha_app/screens/historico.dart';

// Faça o main async para poder usar await aqui
Future<void> main() async {
  // Garanta que os WidgetsBinding estão inicializados antes de carregar o dotenv
  // especialmente se você for usar algo do Flutter antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Carregue as variáveis de ambiente
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resenha App',
      initialRoute: '/', // Rota inicial

      routes: {
        // Rota para a tela de Dados Iniciais
        '/': (context) => DadosIniciaisPage(),

        // Rota para a tela de Equipe e Apoios
        '/equipe_apoios': (context) => EquipeApoiosPage(),

        // Rota para a tela de Envolvidos
        '/envolvidos': (context) => EnvolvidosPage(),

        // Rota para a tela de Veículos (e Outros)
        '/veiculos_outros': (context) => VeiculosOutrosPage(),

        // Rota para a tela de Histórico
        '/historico': (context) => HistoricoPage(),

        // Adicione outras rotas principais aqui se necessário
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Você pode adicionar mais configurações de tema aqui, como:
        // scaffoldBackgroundColor: Colors.grey[100],
        // textTheme: TextTheme(
        //   bodyMedium: TextStyle(fontSize: 16.0),
        // ),
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.blue, // Cor de fundo padrão para ElevatedButton
        //     foregroundColor: Colors.white, // Cor do texto padrão para ElevatedButton
        //   ),
        // ),
      ),
    );
  }
}

// REMOVA A CLASSE EnvolvidosPage DUMMY DESTE ARQUIVO se você já tem 'envolvidos.dart'
// // class EnvolvidosPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Envolvidos")),
// //       body: Center(child: Text("Página de Envolvidos")),
// //     );
// //   }
// // }