class Solicitacao {
  const Solicitacao({
    required this.id,
    required this.equipamento,
    required this.solicitante,
    required this.status,
    required this.dataSolicitacao,
    required this.justificativa,
  });

  final int id;
  final String equipamento;
  final String solicitante;
  final String status;
  final DateTime dataSolicitacao;
  final String justificativa;

  String get numero => id.toString().padLeft(4, '0');
}
