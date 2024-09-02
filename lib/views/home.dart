import 'package:flutter/material.dart';
import 'package:appcontabancaria/models/conta_bancaria.dart';
import 'package:appcontabancaria/models/conta_corrente.dart';
import 'package:appcontabancaria/models/conta_poupanca.dart';

// Classe para representar uma transação
class Transacao {
  final String descricao;
  final double valor;
  final DateTime data;

  Transacao({required this.descricao, required this.valor, required this.data});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<ContaBancaria> _contas = [];
  final List<Transacao> _transacoes = [];
  final _numeroContaController = TextEditingController();
  final _saldoController = TextEditingController();
  String _tipoConta = 'Corrente';

  void _adicionarConta() {
    final String numeroConta = _numeroContaController.text;
    final double saldo = double.tryParse(_saldoController.text) ?? 0.0;

    if (numeroConta.isNotEmpty) {
      setState(() {
        if (_tipoConta == 'Corrente') {
          _contas.add(ContaBancaria<ContaCorrente>(
            tipoDeConta: ContaCorrente(numeroConta),
            saldo: saldo,
          ));
        } else {
          _contas.add(ContaBancaria<ContaPoupanca>(
            tipoDeConta: ContaPoupanca(numeroConta),
            saldo: saldo,
          ));
        }

        // Adiciona a transação de criação da conta ao histórico
        _transacoes.add(Transacao(
          descricao: 'Criação da Conta $numeroConta',
          valor: saldo,
          data: DateTime.now(),
        ));
      });

      _numeroContaController.clear();
      _saldoController.clear();
    }
  }

  void _depositar(int index, double valor) {
    setState(() {
      _contas[index].depositar(valor);

      // Adiciona a transação de depósito ao histórico
      _transacoes.add(Transacao(
        descricao: 'Depósito na Conta ${_contas[index].toString()}',
        valor: valor,
        data: DateTime.now(),
      ));
    });
  }

  void _sacar(int index, double valor) {
    try {
      setState(() {
        _contas[index].sacar(valor);

        // Adiciona a transação de saque ao histórico
        _transacoes.add(Transacao(
          descricao: 'Saque na Conta ${_contas[index].toString()}',
          valor: valor,
          data: DateTime.now(),
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicação Bancária'),
        centerTitle: true,
        backgroundColor: Colors.green[800], // Cor de fundo do AppBar
      ),
      body: DefaultTabController(
        length: 2, // Número de abas
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_balance), text: 'Contas'),
                Tab(icon: Icon(Icons.history), text: 'Histórico'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Aba de Contas Bancárias
                  _buildContasTab(),
                  // Aba de Histórico de Transações
                  _buildHistoricoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContasTab() {
    return Container(
      color: Colors.green[50], // Fundo verde claro
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForm(),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _contas.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      _contas[index].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900], // Texto verde escuro
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.green[700], // Ícone verde para depósito
                          onPressed: () => _showDialog(
                            context,
                            'Depositar',
                            (valor) => _depositar(index, valor),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.red[700], // Ícone vermelho para saque
                          onPressed: () => _showDialog(
                            context,
                            'Sacar',
                            (valor) => _sacar(index, valor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.green[800]),
                SizedBox(width: 10),
                Text(
                  'Adicionar Conta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800], // Título com cor verde escuro
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _tipoConta,
              decoration: InputDecoration(
                labelText: 'Tipo de Conta',
                prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.green[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _tipoConta = newValue!;
                });
              },
              items: <String>['Corrente', 'Poupança']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _numeroContaController,
              decoration: InputDecoration(
                labelText: 'Número da Conta',
                prefixIcon: Icon(Icons.numbers, color: Colors.green[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _saldoController,
              decoration: InputDecoration(
                labelText: 'Saldo Inicial',
                prefixIcon: Icon(Icons.attach_money, color: Colors.green[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _adicionarConta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // Cor verde para o botão
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Adicionar Conta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Texto branco
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricoTab() {
    return Container(
      color: Colors.green[50], // Fundo verde claro
      padding: const EdgeInsets.all(16.0),
      child: _transacoes.isEmpty
          ? Center(
              child: Text(
                'Nenhuma transação realizada.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[800],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _transacoes.length,
              itemBuilder: (context, index) {
                final transacao = _transacoes[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      transacao.descricao,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900], // Texto verde escuro
                      ),
                    ),
                    subtitle: Text(
                      '${transacao.data.toLocal()}',
                      style: TextStyle(
                        color: Colors.green[700], // Texto verde para a data
                      ),
                    ),
                    trailing: Text(
                      '${transacao.valor.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transacao.valor >= 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDialog(
      BuildContext context, String title, Function(double) onConfirm) {
    final _valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final double valor =
                    double.tryParse(_valorController.text) ?? 0.0;
                onConfirm(valor);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}