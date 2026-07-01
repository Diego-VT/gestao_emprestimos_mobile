import '../models/equipamento.dart';

class EquipamentoRepository {
  static const List<Equipamento> _equipamentos = [
    Equipamento(
      id: 1,
      nome: 'Notebook Dell Latitude',
      categoria: 'Notebook',
      status: 'Disponivel',
    ),
    Equipamento(
      id: 2,
      nome: 'Projetor Epson PowerLite',
      categoria: 'Projetor',
      status: 'Disponivel',
    ),
    Equipamento(
      id: 3,
      nome: 'Tablet Samsung Galaxy Tab',
      categoria: 'Tablet',
      status: 'Disponivel',
    ),
    Equipamento(
      id: 4,
      nome: 'Camera Logitech C920',
      categoria: 'Camera',
      status: 'Disponivel',
    ),
    Equipamento(
      id: 5,
      nome: 'Microfone Fifine USB',
      categoria: 'Audio',
      status: 'Em manutencao',
    ),
    Equipamento(
      id: 6,
      nome: 'Kit Adaptadores HDMI/USB-C',
      categoria: 'Acessorio',
      status: 'Disponivel',
    ),
  ];

  Future<List<Equipamento>> listar() async {
    return List<Equipamento>.unmodifiable(_equipamentos);
  }

  Future<List<Equipamento>> listarDisponiveis() async {
    return _equipamentos
        .where((equipamento) => equipamento.disponivel)
        .toList(growable: false);
  }
}
