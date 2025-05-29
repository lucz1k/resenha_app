import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResenhaFinalPage extends StatelessWidget {
  final String textoResenha;

  const ResenhaFinalPage({Key? key, required this.textoResenha}) : super(key: key);

  String formatarHorario(String texto) {
    final regex = RegExp(r"\b(\d{1,2}):(\d{2})\b");
    return texto.replaceAllMapped(regex, (match) {
      int h = int.parse(match[1]!);
      int m = int.parse(match[2]!);
      final ajustado = DateTime(2000, 1, 1, h, m).subtract(Duration(hours: 3));
      return '${ajustado.hour.toString().padLeft(2, '0')}:${ajustado.minute.toString().padLeft(2, '0')}';
    });
  }

  String formatarOrdinais(String texto) {
    return texto
        .replaceAllMapped(RegExp(r'\b(\d{1,2}) Cia\b'), (m) => '${m[1]}\u00aa Cia')
        .replaceAllMapped(RegExp(r'\b(\d{1,2}) BPM\b'), (m) => '${m[1]}\u00ba BPM')
        .replaceAllMapped(RegExp(r'\b(\d{1,2}) Btl\b'), (m) => '${m[1]}\u00ba Btl')
        .replaceAllMapped(RegExp(r'\b(\d{1,2}) Pel\b'), (m) => '${m[1]}\u00ba Pel');
  }

  String formatarTitulos(String texto) {
    final titulos = [
      'SECRETARIA DA SEGURANÇA PÚBLICA',
      'POLÍCIA MILITAR DO ESTADO DE SÃO PAULO',
      'CPA/M-', 'BPM/M', 'CIA', 'PEL', 'NATUREZA:',
      'BOPM:', 'BOPC:', 'DATA:', 'HORÁRIO:', 'ENDEREÇO:',
      'EQUIPE', 'APOIO', 'AUTORIDADE:',
      'SOLICITANTE', 'VÍTIMA', 'AUTORES', 'VEÍCULOS',
      'ARMAMENTO', 'OUTROS DADOS', 'HISTÓRICO:',
      'VAMOS TODOS JUNTOS, NINGUÉM FICA PARA TRÁS'
    ];

    for (final t in titulos) {
      texto = texto.replaceAllMapped(
          RegExp(r'^(' + RegExp.escape(t) + r')', caseSensitive: false, multiLine: true),
              (m) => '**${m[1]}**'
      );
    }

    return texto;
  }

  Future<void> _limparCamposSalvos(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final dadosPadrao = prefs.getString('resenhaApp_padrao_dadosIniciais');
    final equipePadrao = prefs.getString('resenhaApp_padrao_equipe');

    await prefs.clear();

    if (dadosPadrao != null) {
      await prefs.setString('resenhaApp_padrao_dadosIniciais', dadosPadrao);
    }
    if (equipePadrao != null) {
      await prefs.setString('resenhaApp_padrao_equipe', equipePadrao);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campos limpos com sucesso. Padrões mantidos.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textoCorrigido = formatarTitulos(
      formatarOrdinais(
          formatarHorario(textoResenha)
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Resenha Final"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  textoCorrigido,
                  style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back),
                  label: Text("Voltar"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: textoCorrigido));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Resenha copiada para a área de transferência')),
                    );
                  },
                  icon: Icon(Icons.copy),
                  label: Text("Copiar"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _limparCamposSalvos(context),
                  icon: Icon(Icons.restart_alt),
                  label: Text("Resetar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
