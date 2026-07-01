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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: usuarios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _UsuarioCard(usuario: usuarios[index]);
                },
              ),
            ),
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

class _UsuarioCard extends StatelessWidget {
  const _UsuarioCard({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 420;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              child: Text(usuario.nome.substring(0, 1).toUpperCase()),
            ),
            title: Text(
              usuario.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: compacto
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _PerfilChip(perfil: usuario.perfil),
                      ],
                    )
                  : Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            trailing: compacto ? null : _PerfilChip(perfil: usuario.perfil),
          ),
        );
      },
    );
  }
}

class _PerfilChip extends StatelessWidget {
  const _PerfilChip({required this.perfil});

  final String perfil;

  @override
  Widget build(BuildContext context) {
    return Chip(visualDensity: VisualDensity.compact, label: Text(perfil));
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
