import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EquipeApoiosPage extends StatefulWidget {
  const EquipeApoiosPage({super.key});
  @override
  _EquipeApoiosPageState createState() => _EquipeApoiosPageState();
}

class _EquipeApoiosPageState extends State<EquipeApoiosPage> {
  List<Map<String, dynamic>> equipes = [];
  List<Map<String, dynamic>> apoios = [];

  final List<String> funcoesAutoridade = [
    'Cmt CPA/CPI', 'Cmt Btl', 'Superior de Sobreaviso',
    'Subcmt Btl', 'CoordOp Btl', 'Supervisor Regional',
    'Subarea I', 'Subarea II', 'Subarea III',
    'Subarea IV', 'Subarea V', 'Subarea VI', 'Subarea VII',
    'CFP I', 'CFP II', 'CFP III', 'CFP IV',
    'CGP I', 'CGP II', 'CGP III', 'CGP IV', 'CGP V', 'CGP VI', 'CGP VII',
    'GCM', 'ROTA', 'CHOQUE'
  ];

  @override
  void initState() {
    super.initState();
    _carregarRascunho();
    _carregarEquipePadrao();
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('resenhaApp_rascunho_equipeApoio');
    if (dataString != null) {
      final data = jsonDecode(dataString);
      setState(() {
        equipes = List<Map<String, dynamic>>.from(data['equipes'] ?? []);
        for (var equipe in equipes) {
          equipe['prefixoController'] = TextEditingController(text: equipe['prefixo'] ?? '');
          equipe['policiais'] = List<Map<String, dynamic>>.from(equipe['policiais'] ?? []).map((p) => {
            'postoController': TextEditingController(text: p['posto'] ?? ''),
            'nomeController': TextEditingController(text: p['nome'] ?? '')
          }).toList();
        }

        apoios = List<Map<String, dynamic>>.from(data['apoios'] ?? []);
        for (var apoio in apoios) {
          apoio['prefixoController'] = TextEditingController(text: apoio['prefixo'] ?? '');
          apoio['isAutoridade'] = apoio['isAutoridade'] ?? false;
          if (apoio['isAutoridade']) {
            apoio['funcaoAutoridade'] = apoio['funcaoAutoridade'];
          } else {
            apoio['policiais'] = List<Map<String, dynamic>>.from(apoio['policiais'] ?? []).map((p) => {
              'postoController': TextEditingController(text: p['posto'] ?? ''),
              'nomeController': TextEditingController(text: p['nome'] ?? '')
            }).toList();
          }
        }
      });
    }
  }

  Future<void> _carregarEquipePadrao() async {
    final prefs = await SharedPreferences.getInstance();
    final padrao = prefs.getString('resenhaApp_padrao_equipe1');
    if (padrao != null && equipes.isEmpty) {
      final json = jsonDecode(padrao);
      setState(() {
        equipes.add({
          'prefixoController': TextEditingController(text: json['prefixo'] ?? ''),
          'policiais': List<Map<String, dynamic>>.from(json['policiais'] ?? []).map((p) => {
            'postoController': TextEditingController(text: p['posto'] ?? ''),
            'nomeController': TextEditingController(text: p['nome'] ?? '')
          }).toList()
        });
      });
    }
  }

  Future<void> _salvarPadraoEquipe1() async {
    if (equipes.isEmpty) return;
    final equipe = equipes[0];
    final data = {
      'prefixo': equipe['prefixoController'].text,
      'policiais': equipe['policiais'].map((p) => {
        'posto': p['postoController'].text,
        'nome': p['nomeController'].text
      }).toList()
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('resenhaApp_padrao_equipe1', jsonEncode(data));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipe 1 salva como padrão com sucesso!')),
      );
    }
  }

  Future<void> _salvarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'equipes': equipes.map((e) => {
        'prefixo': e['prefixoController'].text,
        'policiais': e['policiais'].map((p) => {
          'posto': p['postoController'].text,
          'nome': p['nomeController'].text
        }).toList()
      }).toList(),
      'apoios': apoios.map((a) => {
        'prefixo': a['prefixoController'].text,
        'isAutoridade': a['isAutoridade'],
        if (a['isAutoridade'])
          'funcaoAutoridade': a['funcaoAutoridade']
        else
          'policiais': a['policiais'].map((p) => {
            'posto': p['postoController'].text,
            'nome': p['nomeController'].text
          }).toList()
      }).toList()
    };
    await prefs.setString('resenhaApp_rascunho_equipeApoio', jsonEncode(data));
  }

  void _adicionarEquipe() {
    setState(() {
      equipes.add({
        'prefixoController': TextEditingController(),
        'policiais': [
          {'postoController': TextEditingController(), 'nomeController': TextEditingController()}
        ],
      });
    });
  }

  void _adicionarApoio() {
    setState(() {
      apoios.add({
        'prefixoController': TextEditingController(),
        'isAutoridade': false,
        'policiais': [
          {'postoController': TextEditingController(), 'nomeController': TextEditingController()}
        ]
      });
    });
  }

  Widget _buildPoliciais(List<Map<String, dynamic>> policiais, VoidCallback onAdd, Function(int) onRemove) {
    return Column(
      children: [
        ...policiais.asMap().entries.map((entry) {
          int idx = entry.key;
          var p = entry.value;
          return Row(
            children: [
              Expanded(child: TextFormField(controller: p['postoController'], decoration: InputDecoration(labelText: 'Posto/Graduação'))),
              SizedBox(width: 8),
              Expanded(child: TextFormField(controller: p['nomeController'], decoration: InputDecoration(labelText: 'Nome de Guerra'))),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => onRemove(idx),
              )
            ],
          );
        }),
        TextButton.icon(
          icon: Icon(Icons.add_circle_outline),
          label: Text("Adicionar Policial"),
          onPressed: onAdd,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Equipe e Apoios"),
        leading: BackButton(onPressed: () {
          _salvarRascunho();
          Navigator.pop(context);
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt),
            tooltip: 'Salvar Equipe 1 como Padrão',
            onPressed: _salvarPadraoEquipe1,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("EQUIPES", style: Theme.of(context).textTheme.headlineSmall),
            ...equipes.asMap().entries.map((entry) {
              int i = entry.key;
              var equipe = entry.value;
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
                          Text("Equipe ${i + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => setState(() => equipes.removeAt(i)),
                          )
                        ],
                      ),
                      TextFormField(
                        controller: equipe['prefixoController'],
                        decoration: InputDecoration(labelText: "Prefixo da Viatura"),
                      ),
                      SizedBox(height: 8),
                      _buildPoliciais(equipe['policiais'], () {
                        setState(() {
                          equipe['policiais'].add({
                            'postoController': TextEditingController(),
                            'nomeController': TextEditingController()
                          });
                        });
                      }, (idx) {
                        setState(() {
                          equipe['policiais'].removeAt(idx);
                        });
                      })
                    ],
                  ),
                ),
              );
            }).toList(),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Adicionar Equipe"),
              onPressed: _adicionarEquipe,
            ),
            SizedBox(height: 24),
            Text("APOIOS / AUTORIDADES", style: Theme.of(context).textTheme.headlineSmall),
            ...apoios.asMap().entries.map((entry) {
              int i = entry.key;
              var apoio = entry.value;
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
                          Text("Apoio ${i + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => setState(() => apoios.removeAt(i)),
                          )
                        ],
                      ),
                      TextFormField(
                        controller: apoio['prefixoController'],
                        decoration: InputDecoration(labelText: "Prefixo da Viatura"),
                      ),
                      SwitchListTile(
                        title: Text("É Autoridade?"),
                        value: apoio['isAutoridade'],
                        onChanged: (val) {
                          setState(() {
                            apoio['isAutoridade'] = val;
                            if (!val) {
                              apoio['policiais'] = [
                                {'postoController': TextEditingController(), 'nomeController': TextEditingController()}
                              ];
                            } else {
                              apoio.remove('policiais');
                            }
                          });
                        },
                      ),
                      if (apoio['isAutoridade'])
                        DropdownButtonFormField<String>(
                          value: apoio['funcaoAutoridade'],
                          decoration: InputDecoration(labelText: "Função da Autoridade"),
                          items: funcoesAutoridade.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                          onChanged: (val) => setState(() => apoio['funcaoAutoridade'] = val),
                        )
                      else
                        _buildPoliciais(apoio['policiais'], () {
                          setState(() {
                            apoio['policiais'].add({
                              'postoController': TextEditingController(),
                              'nomeController': TextEditingController()
                            });
                          });
                        }, (idx) => setState(() => apoio['policiais'].removeAt(idx)))
                    ],
                  ),
                ),
              );
            }).toList(),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Adicionar Apoio"),
              onPressed: _adicionarApoio,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _salvarRascunho();
                Navigator.pushNamed(context, '/envolvidos');
              },
              child: Text("Avançar para Envolvidos"),
            )
          ],
        ),
      ),
    );
  }
}
