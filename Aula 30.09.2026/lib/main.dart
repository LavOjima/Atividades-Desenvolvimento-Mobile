import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Função externa retornando o Future, seguindo a estrutura do primeiro exercício
Future<Endereco> buscaCep(String cep) async {
  // Limpa o texto para garantir que só passem números
  final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

  final resposta = await http.get(
    Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode == 200) {
    // status 200 resposta OK
    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    if (json.containsKey('erro')) {
      throw Exception('CEP não encontrado.');
    }
    return Endereco.fromJson(json);
  } else {
    // status != 200 é erro!
    throw Exception('Falha ao carregar endereço.');
  }
}

// 2. Classe de modelo usando a sintaxe de switch expression para JSON
class Endereco {
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  const Endereco({
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'logradouro': String logradouro,
        'bairro': String bairro,
        'localidade': String localidade,
        'uf': String uf
      } =>
        Endereco(
          logradouro: logradouro,
          bairro: bairro,
          localidade: localidade,
          uf: uf,
        ),
      _ => throw const FormatException('Falha no carregamento...'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Controlador para o input, iniciando com um CEP de exemplo
  final TextEditingController _cepController =
      TextEditingController(text: '01001000');

  // Mesma variável late Future do seu código
  late Future<Endereco> enderecoFuturo;

  @override
  void initState() {
    super.initState();
    // Inicializa a primeira busca com o valor padrão
    enderecoFuturo = buscaCep(_cepController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscando CEP',
      home: Scaffold(
        appBar: AppBar(title: const Text('Buscando CEP via FutureBuilder')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Campo de texto para substituir a lógica do contador
                TextField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Digite o CEP',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // FutureBuilder seguindo exatamente o modelo original
                FutureBuilder<Endereco>(
                  future: enderecoFuturo,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Text('Rua: ${snapshot.data!.logradouro}'),
                          Text('Bairro: ${snapshot.data!.bairro}'),
                          Text('Cidade: ${snapshot.data!.localidade}'),
                          Text('Estado: ${snapshot.data!.uf}'),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        '${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    return const CircularProgressIndicator(); // Substituindo o Text('Carregando...')
                  },
                ),
                const SizedBox(height: 32),

                // Botão recarregando o FutureBuilder com base no TextField
                ElevatedButton(
                  onPressed: () {
                    print('Buscando CEP...');
                    setState(() {
                      enderecoFuturo = buscaCep(_cepController.text);
                    });
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }
}
