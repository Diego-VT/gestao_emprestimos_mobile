class Equipamento {
  const Equipamento({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.status,
  });

  final int id;
  final String nome;
  final String categoria;
  final String status;

  bool get disponivel => status.toLowerCase().startsWith('dispon');
}
