import '../models/equipamento.dart';

class EquipamentoRepository {
  static const List<Equipamento> _equipamentos = [
    Equipamento(
      id: 1,
      nome: 'Notebook Dell Latitude',
      categoria: 'Notebook',
      status: 'Disponível',
    ),
    Equipamento(
      id: 2,
      nome: 'Projetor Epson PowerLite',
      categoria: 'Projetor',
      status: 'Disponível',
    ),
    Equipamento(
      id: 3,
      nome: 'Tablet Samsung Galaxy Tab',
      categoria: 'Tablet',
      status: 'Disponível',
    ),
    Equipamento(
      id: 4,
      nome: 'Câmera Logitech C920',
      categoria: 'Câmera',
      status: 'Disponível',
    ),
    Equipamento(
      id: 5,
      nome: 'Microfone Fifine USB',
      categoria: 'Áudio',
      status: 'Em manutenção',
    ),
    Equipamento(
      id: 6,
      nome: 'Kit Adaptadores HDMI/USB-C',
      categoria: 'Acessório',
      status: 'Disponível',
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
