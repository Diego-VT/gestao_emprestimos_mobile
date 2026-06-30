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

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: _intValue(json['id'] ?? json['solicitacao_id']),
      equipamento: (json['equipamento'] ?? '').toString(),
      solicitante: _solicitanteValue(json),
      status: (json['status'] ?? 'Pendente').toString(),
      dataSolicitacao: _dateValue(
        json['dataSolicitacao'] ??
            json['data_solicitacao'] ??
            json['created_at'] ??
            json['data'],
      ),
      justificativa: (json['justificativa'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipamento': equipamento,
      'solicitante': solicitante,
      'status': status,
      'data_solicitacao': dataSolicitacao.toIso8601String(),
      'justificativa': justificativa,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'equipamento': equipamento,
      'justificativa': justificativa,
    };
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _dateValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static String _solicitanteValue(Map<String, dynamic> json) {
    final solicitante = json['solicitante'];
    if (solicitante is Map<String, dynamic>) {
      return (solicitante['nome'] ?? solicitante['name'] ?? '').toString();
    }
    return (solicitante ?? json['solicitante_nome'] ?? '').toString();
  }
}
