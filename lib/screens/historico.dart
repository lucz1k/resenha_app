import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'dart:async';
import 'resenha_final.dart';

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final TextEditingController _historicoController = TextEditingController();
  Timer? _debounceTimer;
  bool _gerando = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _carregarRascunho();
    _initSpeech();
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final historico = prefs.getString('resenhaApp_rascunho_historico');
    if (historico != null) {
      setState(() {
        _historicoController.text = historico;
      });
    }
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint("🎤 Status: $status"),
      onError: (error) => debugPrint("❌ Erro no speech: $error"),
    );

    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reconhecimento de voz não disponível')),
      );
    }
  }

  void _salvarRascunhoComDebounce() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('resenhaApp_rascunho_historico', _historicoController.text);
    });
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _historicoController.text += (result.recognizedWords + ' ');
        });
        _salvarRascunhoComDebounce();
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<String> _corrigirPortugues(String textoOriginal) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("❌ API KEY ausente ou inválida.");
      throw Exception("Chave da API OpenAI não encontrada.");
    }

    if (textoOriginal.trim().length < 20) {
      throw Exception("O texto é muito curto para correção.");
    }

    debugPrint("🔄 Enviando texto para correção:\n$textoOriginal");

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "Corrija o português do texto policial mantendo a estrutura original e a capitalização natural das palavras. Não utilize caixa alta, exceto quando gramaticalmente necessário (como nomes próprios, inícios de frase ou siglas). Não remova nenhuma informação do texto."
        },
        {
          "role": "user",
          "content": textoOriginal
        }
      ],
      "temperature": 0.5,
      "max_tokens": 1000,
    });

    final response = await http.post(url, headers: headers, body: body);

    debugPrint("🔁 Status: ${response.statusCode}");
    debugPrint("🔁 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      final erro = jsonDecode(response.body);
      throw Exception("Erro da API: ${erro['error']['message'] ?? response.body}");
    }
  }

  Future<void> _gerarResenha() async {
    final texto = _historicoController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _gerando = true;
    });

    try {
      final historicoCorrigido = await _corrigirPortugues(texto);
      final prefs = await SharedPreferences.getInstance();

      final dadosIniciais = jsonDecode(prefs.getString('resenhaApp_rascunho_dadosIniciais') ?? '{}');
      final equipesApoios = jsonDecode(prefs.getString('resenhaApp_rascunho_equipeApoio') ?? '{}');
      final envolvidos = jsonDecode(prefs.getString('resenhaApp_rascunho_envolvidos') ?? '{}');
      final veiculos = jsonDecode(prefs.getString('resenhaApp_rascunho_veiculosOutros') ?? '{}');

      final buffer = StringBuffer();
      buffer.writeln("*SECRETARIA DA SEGURANÇA PÚBLICA*");
      buffer.writeln("*POLÍCIA MILITAR DO ESTADO DE SÃO PAULO*");
      buffer.writeln("*${dadosIniciais['grandeComando'] ?? ''}*");
      buffer.writeln("*${dadosIniciais['batalhao'] ?? ''}*");
      buffer.writeln("*${dadosIniciais['companhia'] ?? ''}*");
      buffer.writeln("*${dadosIniciais['pelotao'] ?? ''}*\n");

      buffer.writeln("*NATUREZA:* ${dadosIniciais['natureza'] ?? ''}");
      buffer.writeln("*BOPM:* ${dadosIniciais['bopm'] ?? ''}");
      if ((dadosIniciais['bopc'] ?? '').isNotEmpty) {
        buffer.writeln("*BOPC:* ${dadosIniciais['bopc']}");
      }

      buffer.writeln("\n*DATA:* ${dadosIniciais['data'] ?? ''}");
      buffer.writeln("*HORÁRIO:* ${_formatarHorario(dadosIniciais['horario'])}");
      buffer.writeln("*ENDEREÇO:* ${dadosIniciais['endereco'] ?? ''}\n");

      if ((equipesApoios['equipes'] ?? []).isNotEmpty) {
        buffer.writeln("*EQUIPE*");
        for (var equipe in equipesApoios['equipes']) {
          buffer.writeln("*VIATURA:* ${equipe['prefixo'] ?? ''}");
          for (var p in equipe['policiais'] ?? []) {
            buffer.writeln("${p['posto']} ${p['nome']}");
          }
          buffer.writeln("");
        }
      }

      if ((equipesApoios['apoios'] ?? []).isNotEmpty) {
        buffer.writeln("*APOIO*");
        for (var apoio in equipesApoios['apoios']) {
          buffer.writeln("*VIATURA:* ${apoio['prefixo'] ?? ''}");
          if (apoio['isAutoridade'] == true) {
            buffer.writeln("${apoio['funcaoAutoridade'] ?? ''}");
          } else {
            for (var p in apoio['policiais'] ?? []) {
              buffer.writeln("${p['posto']} ${p['nome']}");
            }
          }
          buffer.writeln("");
        }
      }

      void listarEnvolvidos(String titulo, List lista) {
        if (lista.isNotEmpty) {
          buffer.writeln("*${titulo.toUpperCase()}*");
          for (var item in lista) {
            if (item['pm'] == true) {
              final isReserva = item['reserva'] == true;
              if (isReserva) {
                buffer.writeln("${item['posto']} ${item['re']} ${item['nome']}, da reserva, última unidade ${item['unidade']}");
              } else {
                buffer.writeln("${item['posto']} ${item['re']} ${item['nome']} da ${item['companhia']} Cia do ${item['unidade']}");
              }
            } else {
              buffer.writeln("${item['nome']} (RG/CPF: ${item['documento']})");
            }
          }
          buffer.writeln("");
        }
      }

      listarEnvolvidos("Vítima", envolvidos['vitimas'] ?? []);
      listarEnvolvidos("Autores", envolvidos['autores'] ?? []);
      listarEnvolvidos("Solicitantes", envolvidos['solicitantes'] ?? []);
      listarEnvolvidos("Outros Envolvidos", envolvidos['outros'] ?? []);

      if ((veiculos['veiculos'] ?? []).isNotEmpty) {
        buffer.writeln("*VEÍCULOS*");
        for (var v in veiculos['veiculos']) {
          buffer.writeln("${v['modelo']} (${v['placa']})");
        }
        buffer.writeln("");
      }

      if ((veiculos['armamentos'] ?? []).isNotEmpty) {
        buffer.writeln("*ARMAMENTO*");
        for (var a in veiculos['armamentos']) {
          buffer.writeln("${a['modelo']} - ${a['calibre']} - N° ${a['numero']}, ${a['disparos']} disparos, ${a['municoes']} intactas");
        }
        buffer.writeln("");
      }

      if ((veiculos['outrosDados'] ?? []).isNotEmpty) {
        buffer.writeln("*OUTROS DADOS*");
        for (var d in veiculos['outrosDados']) {
          buffer.writeln(d);
        }
        buffer.writeln("");
      }

      buffer.writeln("*HISTÓRICO:*");
      buffer.writeln(historicoCorrigido);
      buffer.writeln("\n*VAMOS TODOS JUNTOS, NINGUÉM FICA PARA TRÁS*");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResenhaFinalPage(textoResenha: buffer.toString()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar resenha: $e')),
      );
    } finally {
      setState(() {
        _gerando = false;
      });
    }
  }

  String _formatarHorario(String? horarioOriginal) {
    if (horarioOriginal == null || horarioOriginal.isEmpty) return '';
    try {
      final time = TimeOfDay(
        hour: int.parse(horarioOriginal.split(':')[0]),
        minute: int.parse(horarioOriginal.split(':')[1]),
      );
      final dt = DateTime(2023, 1, 1, time.hour, time.minute);
      final gmt3 = dt.subtract(Duration(hours: 3));
      return "${gmt3.hour.toString().padLeft(2, '0')}:${gmt3.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return horarioOriginal;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _historicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            _salvarRascunhoComDebounce();
            Navigator.of(context).pop();
          },
        ),
        title: Text("Histórico"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _historicoController,
              decoration: InputDecoration(
                labelText: "Descreva o histórico da ocorrência",
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              onChanged: (_) => _salvarRascunhoComDebounce(),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  label: Text(_isListening ? "Parar" : "Ditado por voz"),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                ElevatedButton.icon(
                  icon: _gerando
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Icon(Icons.auto_fix_high),
                  label: Text("Gerar Resenha Corrigida"),
                  onPressed: _gerando ? null : _gerarResenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
