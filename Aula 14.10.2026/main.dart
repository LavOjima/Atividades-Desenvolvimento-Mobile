import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:testa_ai/helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Apenas 3 controladores para usar nas abas
  TextEditingController controlaId = TextEditingController();
  TextEditingController controlaNome = TextEditingController();
  TextEditingController controlaIdade = TextEditingController();

  // Função da Aba 1: Salvar
  Future<void> salvarNoBanco() async {
    Map<String, dynamic> novoCao = {
      'nome': controlaNome.text,
      'idade': int.tryParse(controlaIdade.text) ?? 0,
    };

    await DatabaseHelper.inserirCao(novoCao);
    print('${controlaNome.text} salvo com sucesso!');

    setState(() {
      controlaNome.clear();
      controlaIdade.clear();
    });
  }

  // Função da Aba 3: Atualizar
  Future<void> atualizarNoBanco() async {
    Map<String, dynamic> caoAtualizado = {
      'id': int.tryParse(controlaId.text) ?? 0,
      'nome': controlaNome.text,
      'idade': int.tryParse(controlaIdade.text) ?? 0,
    };

    await DatabaseHelper.atualizarCao(caoAtualizado);
    print('Pet ID ${controlaId.text} atualizado!');

    setState(() {
      controlaId.clear();
      controlaNome.clear();
      controlaIdade.clear();
    });
  }

  // Função da Aba 4: Apagar
  Future<void> apagarNoBanco() async {
    int id = int.tryParse(controlaId.text) ?? 0;

    await DatabaseHelper.apagarCao(id);
    print('Pet ID $id apagado!');

    setState(() {
      controlaId.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4, // Define as 4 abas
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pets'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Salvar'),
                Tab(text: 'Listar'),
                Tab(text: 'Atualizar'),
                Tab(text: 'Apagar'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // ABA 1: SALVAR (Nome e Idade)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaIdade,
                      decoration: const InputDecoration(
                        labelText: 'Idade do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      salvarNoBanco();
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),

              // ABA 2: LISTAR (Exatamente igual ao seu código original)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.buscarTodos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar dados: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum pet cadastrado.'),
                    );
                  }

                  final listaPets = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      children: listaPets.map((pet) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('ID: ${pet['id']}'),
                              Text('Pet: ${pet['nome']}'),
                              Text('Idade: ${pet['idade']}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              // ABA 3: ATUALIZAR (ID, Nome e Idade)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaId,
                      decoration: const InputDecoration(
                        labelText: 'ID do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaIdade,
                      decoration: const InputDecoration(
                        labelText: 'Idade do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      atualizarNoBanco();
                    },
                    child: const Text('Atualizar'),
                  ),
                ],
              ),

              // ABA 4: APAGAR (Apenas ID)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controlaId,
                      decoration: const InputDecoration(
                        labelText: 'ID do pet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      apagarNoBanco();
                    },
                    child: const Text('Apagar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}