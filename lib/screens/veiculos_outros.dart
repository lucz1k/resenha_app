import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class VeiculosOutrosPage extends StatefulWidget {
  @override
  _VeiculosOutrosPageState createState() => _VeiculosOutrosPageState();
}

class _VeiculosOutrosPageState extends State<VeiculosOutrosPage> {
  List<Map<String, TextEditingController>> veiculos = [];
  List<Map<String, TextEditingController>> armamentos = [];
  List<TextEditingController> outrosDados = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _carregarRascunho();
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('resenhaApp_rascunho_veiculosOutros');
    if (data != null) {
      final json = jsonDecode(data);
      setState(() {
        veiculos = List<Map<String, dynamic>>.from(json['veiculos'] ?? []).map((e) {
          return {
            'modelo': TextEditingController(text: e['modelo'] ?? ''),
            'placa': TextEditingController(text: e['placa'] ?? ''),
          };
        }).toList();

        armamentos = List<Map<String, dynamic>>.from(json['armamentos'] ?? []).map((e) {
          return {
            'modelo': TextEditingController(text: e['modelo'] ?? ''),
            'numero': TextEditingController(text: e['numero'] ?? ''),
            'calibre': TextEditingController(text: e['calibre'] ?? ''),
            'disparos': TextEditingController(text: e['disparos'] ?? ''),
            'municoes': TextEditingController(text: e['municoes'] ?? ''),
          };
        }).toList();

        outrosDados = List<String>.from(json['outrosDados'] ?? []).map((e) => TextEditingController(text: e)).toList();
      });
    }
  }

  void _onChangeDebounced() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _salvarRascunho();
    });
  }

  Future<void> _salvarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'veiculos': veiculos.map((e) => {
        'modelo': e['modelo']!.text,
        'placa': e['placa']!.text,
      }).toList(),
      'armamentos': armamentos.map((e) => {
        'modelo': e['modelo']!.text,
        'numero': e['numero']!.text,
        'calibre': e['calibre']!.text,
        'disparos': e['disparos']!.text,
        'municoes': e['municoes']!.text,
      }).toList(),
      'outrosDados': outrosDados.map((e) => e.text).toList(),
    };
    await prefs.setString('resenhaApp_rascunho_veiculosOutros', jsonEncode(data));
  }

  Widget _buildVeiculoCard(int index) {
    final item = veiculos[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: item['modelo'],
              decoration: InputDecoration(labelText: 'Marca/Modelo'),
              onChanged: (_) => _onChangeDebounced(),
            ),
            SizedBox(height: 8),
            TextField(
              controller: item['placa'],
              decoration: InputDecoration(labelText: 'Placa'),
              onChanged: (_) => _onChangeDebounced(),
            ),
            if (veiculos.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      veiculos.removeAt(index);
                    });
                    _salvarRascunho();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildArmaCard(int index) {
    final item = armamentos[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: item['modelo'], decoration: InputDecoration(labelText: 'Marca/Modelo'), onChanged: (_) => _onChangeDebounced()),
            SizedBox(height: 8),
            TextField(controller: item['numero'], decoration: InputDecoration(labelText: 'Número'), onChanged: (_) => _onChangeDebounced()),
            SizedBox(height: 8),
            TextField(controller: item['calibre'], decoration: InputDecoration(labelText: 'Calibre'), onChanged: (_) => _onChangeDebounced()),
            SizedBox(height: 8),
            TextField(controller: item['disparos'], decoration: InputDecoration(labelText: 'Disparos'), keyboardType: TextInputType.number, onChanged: (_) => _onChangeDebounced()),
            SizedBox(height: 8),
            TextField(controller: item['municoes'], decoration: InputDecoration(labelText: 'Munições Intactas'), keyboardType: TextInputType.number, onChanged: (_) => _onChangeDebounced()),
            if (armamentos.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      armamentos.removeAt(index);
                    });
                    _salvarRascunho();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildOutrosCard(int index) {
    final controller = outrosDados[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Outros Dados'),
              onChanged: (_) => _onChangeDebounced(),
            ),
            if (outrosDados.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      outrosDados.removeAt(index);
                    });
                    _salvarRascunho();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (var v in veiculos) {
      v.values.forEach((c) => c.dispose());
    }
    for (var a in armamentos) {
      a.values.forEach((c) => c.dispose());
    }
    for (var o in outrosDados) {
      o.dispose();
    }
    super.dispose();
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
        title: Text("Veículos e Outros Dados"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("VEÍCULOS", style: TextStyle(fontWeight: FontWeight.bold)),
            ...veiculos.asMap().entries.map((e) => _buildVeiculoCard(e.key)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  veiculos.add({
                    'modelo': TextEditingController(),
                    'placa': TextEditingController(),
                  });
                });
                _salvarRascunho();
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text("Adicionar Veículo"),
            ),
            Divider(),
            Text("ARMAMENTOS", style: TextStyle(fontWeight: FontWeight.bold)),
            ...armamentos.asMap().entries.map((e) => _buildArmaCard(e.key)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  armamentos.add({
                    'modelo': TextEditingController(),
                    'numero': TextEditingController(),
                    'calibre': TextEditingController(),
                    'disparos': TextEditingController(),
                    'municoes': TextEditingController(),
                  });
                });
                _salvarRascunho();
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text("Adicionar Armamento"),
            ),
            Divider(),
            Text("OUTROS DADOS", style: TextStyle(fontWeight: FontWeight.bold)),
            ...outrosDados.asMap().entries.map((e) => _buildOutrosCard(e.key)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  outrosDados.add(TextEditingController());
                });
                _salvarRascunho();
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text("Adicionar Outro Dado"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _salvarRascunho();
                Navigator.pushNamed(context, '/historico');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text("Avançar para Histórico", style: TextStyle(fontSize: 16)),
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
