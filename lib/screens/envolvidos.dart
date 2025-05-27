import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EnvolvidosPage extends StatefulWidget {
  @override
  _EnvolvidosPageState createState() => _EnvolvidosPageState();
}

class _EnvolvidosPageState extends State<EnvolvidosPage> {
  final List<String> categorias = ['solicitantes', 'vitimas', 'autores', 'outros'];
  Map<String, List<Map<String, dynamic>>> envolvidos = {
    'solicitantes': [],
    'vitimas': [],
    'autores': [],
    'outros': []
  };

  @override
  void initState() {
    super.initState();
    _carregarRascunho();
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('resenhaApp_rascunho_envolvidos');
    if (data != null) {
      final json = jsonDecode(data);
      setState(() {
        for (var cat in categorias) {
          envolvidos[cat] = List<Map<String, dynamic>>.from(json[cat] ?? []);
        }
      });
    }
  }

  Future<void> _salvarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('resenhaApp_rascunho_envolvidos', jsonEncode(envolvidos));
  }

  void _adicionarEnvolvido(String categoria) {
    setState(() {
      envolvidos[categoria]!.add({'pm': false, 'nome': '', 'documento': ''});
    });
    _salvarRascunho();
  }

  void _removerEnvolvido(String categoria, int index) {
    setState(() {
      envolvidos[categoria]!.removeAt(index);
    });
    _salvarRascunho();
  }

  Widget _buildEnvolvidoCard(String categoria, int index) {
    final item = envolvidos[categoria]![index];
    final isPM = item['pm'] == true;
    final daReserva = item['reserva'] == true;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${categoria[0].toUpperCase()}${categoria.substring(1)} ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                  onPressed: () => _removerEnvolvido(categoria, index),
                )
              ],
            ),
            SwitchListTile(
              title: Text("É PM?"),
              value: isPM,
              onChanged: (val) {
                setState(() {
                  item['pm'] = val;
                  item['reserva'] = false;
                  if (val) {
                    item.remove('documento');
                    item['posto'] = '';
                    item['re'] = '';
                    item['companhia'] = '';
                    item['unidade'] = '';
                  } else {
                    item.remove('posto');
                    item.remove('re');
                    item.remove('companhia');
                    item.remove('unidade');
                    item.remove('reserva');
                    item['documento'] = '';
                  }
                });
                _salvarRascunho();
              },
            ),
            TextFormField(
              initialValue: item['nome'],
              decoration: InputDecoration(labelText: "Nome"),
              onChanged: (val) {
                item['nome'] = val;
                _salvarRascunho();
              },
            ),
            SizedBox(height: 8),
            if (!isPM)
              TextFormField(
                initialValue: item['documento'],
                decoration: InputDecoration(labelText: "Documento (RG/CPF)"),
                onChanged: (val) {
                  item['documento'] = val;
                  _salvarRascunho();
                },
              )
            else ...[
              SwitchListTile(
                title: Text("Da Reserva"),
                value: daReserva,
                onChanged: (val) {
                  setState(() {
                    item['reserva'] = val;
                    if (val) item['companhia'] = '';
                  });
                  _salvarRascunho();
                },
              ),
              TextFormField(
                initialValue: item['posto'],
                decoration: InputDecoration(labelText: "Posto/Graduação"),
                onChanged: (val) {
                  item['posto'] = val;
                  _salvarRascunho();
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: item['re'],
                decoration: InputDecoration(labelText: "RE"),
                onChanged: (val) {
                  item['re'] = val;
                  _salvarRascunho();
                },
              ),
              SizedBox(height: 8),
              if (!daReserva)
                TextFormField(
                  initialValue: item['companhia'],
                  decoration: InputDecoration(labelText: "Companhia"),
                  onChanged: (val) {
                    item['companhia'] = val;
                    _salvarRascunho();
                  },
                ),
              if (!daReserva) SizedBox(height: 8),
              TextFormField(
                initialValue: item['unidade'],
                decoration: InputDecoration(labelText: "Unidade (ex: 10º BPM/M)"),
                onChanged: (val) {
                  item['unidade'] = val;
                  _salvarRascunho();
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGrupo(String categoria, String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...envolvidos[categoria]!.asMap().entries.map((e) => _buildEnvolvidoCard(categoria, e.key)).toList(),
        TextButton.icon(
          onPressed: () => _adicionarEnvolvido(categoria),
          icon: Icon(Icons.add_circle_outline),
          label: Text("Adicionar ${titulo.split(' ')[0]}"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            _salvarRascunho();
            Navigator.of(context).pop();
          },
        ),
        title: Text("Envolvidos"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGrupo('solicitantes', 'Solicitantes'),
            _buildGrupo('vitimas', 'Vítimas'),
            _buildGrupo('autores', 'Autores'),
            _buildGrupo('outros', 'Outros Envolvidos'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _salvarRascunho();
                Navigator.pushNamed(context, '/veiculos_outros');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text("Avançar para Veículos", style: TextStyle(fontSize: 16)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
