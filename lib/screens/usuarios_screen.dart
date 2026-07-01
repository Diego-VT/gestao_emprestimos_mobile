import 'package:flutter/material.dart';

import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  static const routeName = '/usuarios';

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _usuarioRepository = UsuarioRepository();
  late Future<List<Usuario>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _usuarioRepository.listarTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: FutureBuilder<List<Usuario>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MensagemEstado(
              icone: Icons.lock_outline,
              mensagem: _mensagemErro(snapshot.error),
            );
          }

          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return const _MensagemEstado(
              icone: Icons.people_outline,
              mensagem: 'Nenhum usuario cadastrado.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: usuarios.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(usuario.nome.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(usuario.nome),
                  subtitle: Text(usuario.email),
                  trailing: Chip(label: Text(usuario.perfil)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _mensagemErro(Object? error) {
    if (error is ApiException && error.statusCode == 403) {
      return 'Apenas administradores podem consultar usuarios.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'Nao foi possivel carregar os usuarios.';
  }
}

class _MensagemEstado extends StatelessWidget {
  const _MensagemEstado({required this.icone, required this.mensagem});

  final IconData icone;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
