import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

class DadosIniciaisPage extends StatefulWidget {
  const DadosIniciaisPage({super.key});
  @override
  _DadosIniciaisPageState createState() => _DadosIniciaisPageState();
}

class _DadosIniciaisPageState extends State<DadosIniciaisPage> {
  final _formKey = GlobalKey<FormState>();

  final _ctrl = {
    'grandeComando': TextEditingController(),
    'batalhao': TextEditingController(),
    'companhia': TextEditingController(),
    'pelotao': TextEditingController(),
    'natureza': TextEditingController(),
    'bopm': TextEditingController(),
    'bopc': TextEditingController(),
    'data': TextEditingController(),
    'horario': TextEditingController(),
    'endereco': TextEditingController(),
  };

  Timer? _debounce;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _carregarRascunho();
    _carregarPadroes();
  }

  String aplicarOrdinal(String valor, String tipo) {
    final numero = int.tryParse(valor.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numero == null) return valor;
    if (tipo == 'cia') return '${numero}ª Cia';
    if (tipo == 'bpm') return '${numero}º BPM/M';
    if (tipo == 'pel') return '${numero}º Pel';
    return valor;
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('resenhaApp_rascunho_dadosIniciais');
    if (data != null) {
      final json = jsonDecode(data);
      json.forEach((key, value) {
        final controller = _ctrl[key];
        if (controller != null) {
          controller.text = value ?? '';
          if (key == 'data' && value != null && value.isNotEmpty) {
            try {
              _selectedDate = DateFormat('dd/MM/yyyy').parse(value);
            } catch (_) {}
          } else if (key == 'horario' && value != null && value.isNotEmpty) {
            try {
              final parts = value.split(':');
              if (parts.length == 2) {
                _selectedTime = TimeOfDay(
                    hour: int.parse(parts[0]), minute: int.parse(parts[1]));
              }
            } catch (_) {}
          }
        }
      });
      if (_selectedDate != null) {
        _ctrl['data']!.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      }
      if (_selectedTime != null) {
        _ctrl['horario']!.text = _selectedTime!.format(context);
      }
      setState(() {});
    }
  }

  Future<void> _carregarPadroes() async {
    final prefs = await SharedPreferences.getInstance();
    final padrao = prefs.getString('resenhaApp_padrao_dadosIniciais');
    if (padrao != null) {
      final json = jsonDecode(padrao);
      ['grandeComando', 'batalhao', 'companhia', 'pelotao'].forEach((key) {
        if (_ctrl[key]!.text.isEmpty) {
          _ctrl[key]!.text = json[key] ?? '';
        }
      });
      setState(() {});
    }
  }

  void _onCampoChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () => _salvarRascunho());
  }

  Future<void> _salvarRascunho({bool showSnackbar = false}) async {
    _ctrl['batalhao']!.text = aplicarOrdinal(_ctrl['batalhao']!.text, 'bpm');
    _ctrl['companhia']!.text = aplicarOrdinal(_ctrl['companhia']!.text, 'cia');
    _ctrl['pelotao']!.text = aplicarOrdinal(_ctrl['pelotao']!.text, 'pel');

    final prefs = await SharedPreferences.getInstance();
    final dados = Map.fromEntries(
      _ctrl.entries.map((e) => MapEntry(e.key, e.value.text)),
    );
    await prefs.setString('resenhaApp_rascunho_dadosIniciais', jsonEncode(dados));

    if (showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rascunho salvo com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _salvarPadroes() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosPadrao = {
      'grandeComando': _ctrl['grandeComando']!.text,
      'batalhao': _ctrl['batalhao']!.text,
      'companhia': _ctrl['companhia']!.text,
      'pelotao': _ctrl['pelotao']!.text,
    };
    await prefs.setString('resenhaApp_padrao_dadosIniciais', jsonEncode(dadosPadrao));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Padrões salvos com sucesso!')),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Widget _campo(String label, String key,
      {bool obrigatorio = false, TextInputType? teclado}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _ctrl[key],
        keyboardType: teclado,
        onChanged: (_) => _onCampoChanged(),
        decoration: InputDecoration(
          labelText: label + (obrigatorio ? " *" : ""),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (obrigatorio && (value == null || value.trim().isEmpty)) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _ctrl['data']!.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _salvarRascunho();
    }
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _ctrl['horario']!.text = picked.format(context);
      });
      _salvarRascunho();
    }
  }

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      _salvarRascunho(showSnackbar: true);
      Navigator.pushNamed(context, '/equipe_apoios');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dados Iniciais"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt, color: Colors.white),
            tooltip: 'Salvar como Padrão',
            onPressed: _salvarPadroes,
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "ResenhaApp - Desenvolvido por Asp Of PM Artigiani",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                _campo("Grande Comando", "grandeComando", obrigatorio: true),
                _campo("Batalhão", "batalhao", obrigatorio: true),
                _campo("Companhia", "companhia", obrigatorio: true),
                _campo("Pelotão", "pelotao", obrigatorio: true),
                _campo("Natureza", "natureza", obrigatorio: true),
                _campo("BOPM", "bopm", obrigatorio: true, teclado: TextInputType.number),
                _campo("BOPC (opcional)", "bopc", teclado: TextInputType.number),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Data *", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            SizedBox(height: 4),
                            TextFormField(
                              controller: _ctrl['data'],
                              decoration: InputDecoration(
                                hintText: 'Selecione a data',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                filled: true,
                                fillColor: Colors.grey[100],
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selecionarData(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma data';
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Horário *", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            SizedBox(height: 4),
                            TextFormField(
                              controller: _ctrl['horario'],
                              decoration: InputDecoration(
                                hintText: 'Selecione o horário',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                filled: true,
                                fillColor: Colors.grey[100],
                                suffixIcon: Icon(Icons.access_time),
                              ),
                              readOnly: true,
                              onTap: () => _selecionarHorario(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione um horário';
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _campo("Endereço", "endereco", obrigatorio: true),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _avancar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Avançar", style: TextStyle(fontSize: 16)),
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
        ),
      ),
    );
  }
}
