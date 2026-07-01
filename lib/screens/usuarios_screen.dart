import 'package:flutter/material.dart';

import '../core/utils/api_exception.dart';
import '../core/utils/input_validators.dart';
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

  void _recarregar() {
    setState(() {
      _usuariosFuture = _usuarioRepository.listarTodos();
    });
  }

  Future<void> _abrirCadastroUsuario() async {
    final cadastrou = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _UsuarioDialog(usuarioRepository: _usuarioRepository),
    );

    if (!mounted || cadastrou != true) {
      return;
    }

    _recarregar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario cadastrado com sucesso.')),
    );
  }

  Future<void> _abrirAlterarSenha(Usuario usuario) async {
    final alterou = await showDialog<bool>(
      context: context,
      builder: (context) => _AlterarSenhaUsuarioDialog(
        usuario: usuario,
        usuarioRepository: _usuarioRepository,
      ),
    );

    if (!mounted || alterou != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroUsuario,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Cadastrar'),
      ),
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
                  return _UsuarioCard(
                    usuario: usuarios[index],
                    onAlterarSenha: () => _abrirAlterarSenha(usuarios[index]),
                  );
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
  const _UsuarioCard({required this.usuario, required this.onAlterarSenha});

  final Usuario usuario;
  final VoidCallback onAlterarSenha;

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
            trailing: PopupMenuButton<_UsuarioAcao>(
              tooltip: 'Acoes',
              onSelected: (acao) {
                if (acao == _UsuarioAcao.alterarSenha) {
                  onAlterarSenha();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _UsuarioAcao.alterarSenha,
                  child: ListTile(
                    leading: Icon(Icons.password_outlined),
                    title: Text('Alterar senha'),
                  ),
                ),
              ],
              child: compacto
                  ? const Icon(Icons.more_vert)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PerfilChip(perfil: usuario.perfil),
                        const SizedBox(width: 4),
                        const Icon(Icons.more_vert),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

enum _UsuarioAcao { alterarSenha }

class _UsuarioDialog extends StatefulWidget {
  const _UsuarioDialog({required this.usuarioRepository});

  final UsuarioRepository usuarioRepository;

  @override
  State<_UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<_UsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  String _perfil = 'Cliente';
  bool _salvando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await widget.usuarioRepository.criarUsuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        perfil: _perfil,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensagemErro(erro))));
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar usuario'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => InputValidators.textoObrigatorio(
                    value,
                    nomeCampo: 'o nome',
                    maxLength: 120,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: InputValidators.email,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _perfil,
                  decoration: const InputDecoration(
                    labelText: 'Perfil',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                    DropdownMenuItem(
                      value: 'Atendente',
                      child: Text('Atendente'),
                    ),
                    DropdownMenuItem(
                      value: 'Administrador',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: _salvando
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _perfil = value);
                          }
                        },
                ),
                const SizedBox(height: 12),
                _CampoSenha(
                  controller: _senhaController,
                  labelText: 'Senha',
                  visivel: _senhaVisivel,
                  onAlternarVisibilidade: () {
                    setState(() => _senhaVisivel = !_senhaVisivel);
                  },
                ),
                const SizedBox(height: 12),
                _CampoSenha(
                  controller: _confirmarSenhaController,
                  labelText: 'Confirmar senha',
                  visivel: _confirmarSenhaVisivel,
                  onAlternarVisibilidade: () {
                    setState(
                      () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel,
                    );
                  },
                  validator: (value) {
                    final erro = InputValidators.senha(value);
                    if (erro != null) {
                      return erro;
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas nao conferem.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  String _mensagemErro(ApiException erro) {
    if (erro.statusCode == 409) {
      return 'Ja existe usuario com este e-mail.';
    }
    if (erro.statusCode == 403) {
      return 'Apenas administradores podem cadastrar usuarios.';
    }
    return 'Nao foi possivel cadastrar o usuario.';
  }
}

class _AlterarSenhaUsuarioDialog extends StatefulWidget {
  const _AlterarSenhaUsuarioDialog({
    required this.usuario,
    required this.usuarioRepository,
  });

  final Usuario usuario;
  final UsuarioRepository usuarioRepository;

  @override
  State<_AlterarSenhaUsuarioDialog> createState() =>
      _AlterarSenhaUsuarioDialogState();
}

class _AlterarSenhaUsuarioDialogState
    extends State<_AlterarSenhaUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _salvando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await widget.usuarioRepository.alterarSenhaUsuario(
        email: widget.usuario.email,
        novaSenha: _senhaController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensagemErro(erro))));
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar senha'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(widget.usuario.nome.substring(0, 1)),
                  ),
                  title: Text(widget.usuario.nome),
                  subtitle: Text(widget.usuario.email),
                ),
                const SizedBox(height: 12),
                _CampoSenha(
                  controller: _senhaController,
                  labelText: 'Nova senha',
                  visivel: _senhaVisivel,
                  onAlternarVisibilidade: () {
                    setState(() => _senhaVisivel = !_senhaVisivel);
                  },
                ),
                const SizedBox(height: 12),
                _CampoSenha(
                  controller: _confirmarSenhaController,
                  labelText: 'Confirmar nova senha',
                  visivel: _confirmarSenhaVisivel,
                  onAlternarVisibilidade: () {
                    setState(
                      () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel,
                    );
                  },
                  validator: (value) {
                    final erro = InputValidators.senha(value);
                    if (erro != null) {
                      return erro;
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas nao conferem.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  String _mensagemErro(ApiException erro) {
    if (erro.statusCode == 403) {
      return 'Apenas administradores podem alterar senhas.';
    }
    return 'Nao foi possivel alterar a senha.';
  }
}

class _CampoSenha extends StatelessWidget {
  const _CampoSenha({
    required this.controller,
    required this.labelText,
    required this.visivel,
    required this.onAlternarVisibilidade,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final bool visivel;
  final VoidCallback onAlternarVisibilidade;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visivel,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: visivel ? 'Ocultar senha' : 'Mostrar senha',
          onPressed: onAlternarVisibilidade,
          icon: Icon(
            visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: validator ?? InputValidators.senha,
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
