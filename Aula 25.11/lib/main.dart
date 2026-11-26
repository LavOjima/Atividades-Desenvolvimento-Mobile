import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.106.76.9/uai';

void main() {
  runApp(const UaiAtividadesApp());
}

class UaiAtividadesApp extends StatelessWidget {
  const UaiAtividadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uai - Atividades',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaAtividades(),
    );
  }
}

class TelaAtividades extends StatefulWidget {
  const TelaAtividades({super.key});

  @override
  State<TelaAtividades> createState() => _TelaAtividadesState();
}

class _TelaAtividadesState extends State<TelaAtividades> {
  final diaController = TextEditingController();
  final atividadeController = TextEditingController();

  int anoSelecionado = DateTime.now().year;
  int mesSelecionado = DateTime.now().month;

  List<dynamic> atividades = [];
  bool carregando = false;
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    diaController.text =
        '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
    carregarAtividades();
  }

  String formatarMesAno(int ano, int mes) {
    return '${mes.toString().padLeft(2, '0')}/$ano';
  }

  Future<void> carregarAtividades() async {
    setState(() {
      carregando = true;
      mensagem = '';
    });

    try {
      final url = Uri.parse(
        '$baseUrl/listar_atividades.php?ano=$anoSelecionado&mes=$mesSelecionado',
      );
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        setState(() {
          atividades = jsonDecode(resp.body) as List<dynamic>;
        });
      } else {
        setState(() {
          mensagem = 'Erro ao carregar atividades (HTTP ${resp.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro de conexão: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> salvarAtividade() async {
    final dia = diaController.text.trim();
    final atividade = atividadeController.text.trim();

    if (dia.isEmpty || atividade.isEmpty) {
      setState(() {
        mensagem = 'Preencha o dia e a atividade.';
      });
      return;
    }

    setState(() {
      mensagem = '';
    });

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/salvar_atividade.php'),
        body: {
          'dia': dia,
          'atividade': atividade,
        },
      );

      final dados = jsonDecode(resp.body) as Map<String, dynamic>;

      if (dados['sucesso'] == true) {
        atividadeController.clear();
        // Se o dia salvo for de outro mês, ajusta o filtro para ver o mês salvo
        final partes = dia.split('-');
        if (partes.length == 3) {
          final ano = int.tryParse(partes[0]);
          final mes = int.tryParse(partes[1]);
          if (ano != null && mes != null) {
            anoSelecionado = ano;
            mesSelecionado = mes;
          }
        }
        await carregarAtividades();
      } else {
        setState(() {
          mensagem = dados['mensagem']?.toString() ?? 'Falha ao salvar.';
        });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro de conexão: $e';
      });
    }
  }

  void mesAnterior() {
    setState(() {
      if (mesSelecionado == 1) {
        mesSelecionado = 12;
        anoSelecionado--;
      } else {
        mesSelecionado--;
      }
    });
    carregarAtividades();
  }

  void proximoMes() {
    setState(() {
      if (mesSelecionado == 12) {
        mesSelecionado = 1;
        anoSelecionado++;
      } else {
        mesSelecionado++;
      }
    });
    carregarAtividades();
  }

  @override
  void dispose() {
    diaController.dispose();
    atividadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uai - Atividades do Dia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: diaController,
              decoration: const InputDecoration(
                labelText: 'Dia (AAAA-MM-DD)',
                hintText: 'Ex.: 2026-11-25',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: atividadeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Atividade desenvolvida',
                hintText: 'Digite a atividade do dia...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: salvarAtividade,
              child: const Text('Salvar Atividade'),
            ),
            if (mensagem.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(mensagem, style: const TextStyle(color: Colors.red)),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: mesAnterior,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Mês anterior'),
                ),
                Text(
                  'Mês: ${formatarMesAno(anoSelecionado, mesSelecionado)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: proximoMes,
                  child: const Row(
                    children: [
                      Text('Próximo mês'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : atividades.isEmpty
                      ? const Center(child: Text('Nenhuma atividade neste mês.'))
                      : ListView.builder(
                          itemCount: atividades.length,
                          itemBuilder: (context, index) {
                            final item = atividades[index] as Map<String, dynamic>;
                            return Card(
                              child: ListTile(
                                title: Text(item['descricao'].toString()),
                                subtitle: Text('Dia: ${item['dia']}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}