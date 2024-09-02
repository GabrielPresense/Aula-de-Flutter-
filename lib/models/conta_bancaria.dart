class ContaBancaria<T> {
  T tipoDeConta;
  double saldo;

  ContaBancaria({required this.tipoDeConta, this.saldo = 0.0});

  void depositar(double valor) {
    saldo += valor;
  }

  void sacar(double valor) {
    if (valor <= saldo) {
      saldo -= valor;
    } else {
      throw Exception('Saldo insuficiente!');
    }
  }

  @override
  String toString() {
    return 'Tipo de Conta: $tipoDeConta, Saldo: R\$ $saldo';
  }
}