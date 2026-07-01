import 'package:flutter/material.dart';

import '../core/utils/api_exception.dart';
import '../core/utils/input_validators.dart';
import '../repositories/auth_repository.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _carregando = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _carregando = true);

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    } on ApiException catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensagemLogin(erro))));
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _abrirAlterarSenha() async {
    final alterou = await showDialog<bool>(
      context: context,
      builder: (context) => _AlterarSenhaDialog(
        authRepository: _authRepository,
        emailInicial: _emailController.text.trim(),
      ),
    );

    if (!mounted || alterou != true) {
      return;
    }

    _senhaController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 520;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compacto ? 16 : 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(compacto ? 20 : 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.devices_other,
                              size: compacto ? 56 : 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gestao de Emprestimos',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Equipamentos de TI',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 28),
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
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _senhaController,
                              obscureText: !_senhaVisivel,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _entrar(),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _senhaVisivel
                                      ? 'Ocultar senha'
                                      : 'Mostrar senha',
                                  onPressed: () {
                                    setState(
                                      () => _senhaVisivel = !_senhaVisivel,
                                    );
                                  },
                                  icon: Icon(
                                    _senhaVisivel
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: InputValidators.senha,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _carregando
                                    ? null
                                    : _abrirAlterarSenha,
                                child: const Text('Alterar senha'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: _carregando ? null : _entrar,
                              icon: _carregando
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _mensagemLogin(ApiException erro) {
    if (erro.statusCode == 401 || erro.statusCode == 403) {
      return 'E-mail ou senha invalidos.';
    }
    return 'Nao foi possivel entrar. Tente novamente.';
  }
}

class _AlterarSenhaDialog extends StatefulWidget {
  const _AlterarSenhaDialog({
    required this.authRepository,
    required this.emailInicial,
  });

  final AuthRepository authRepository;
  final String emailInicial;

  @override
  State<_AlterarSenhaDialog> createState() => _AlterarSenhaDialogState();
}

class _AlterarSenhaDialogState extends State<_AlterarSenhaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _salvando = false;
  bool _senhaAtualVisivel = false;
  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.emailInicial);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await widget.authRepository.alterarSenha(
        email: _emailController.text.trim(),
        senhaAtual: _senhaAtualController.text,
        novaSenha: _novaSenhaController.text,
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
              children: [
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
                _CampoSenha(
                  controller: _senhaAtualController,
                  labelText: 'Senha atual',
                  visivel: _senhaAtualVisivel,
                  onAlternarVisibilidade: () {
                    setState(() => _senhaAtualVisivel = !_senhaAtualVisivel);
                  },
                ),
                const SizedBox(height: 12),
                _CampoSenha(
                  controller: _novaSenhaController,
                  labelText: 'Nova senha',
                  visivel: _novaSenhaVisivel,
                  onAlternarVisibilidade: () {
                    setState(() => _novaSenhaVisivel = !_novaSenhaVisivel);
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
                    if (value != _novaSenhaController.text) {
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
    if (erro.statusCode == 404) {
      return 'Usuario nao encontrado.';
    }
    if (erro.statusCode == 401) {
      return 'Senha atual invalida.';
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
