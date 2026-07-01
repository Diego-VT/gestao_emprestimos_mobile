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

  Future<void> _abrirEsqueceuSenha() async {
    final alterou = await showDialog<bool>(
      context: context,
      builder: (context) => _EsqueceuSenhaDialog(
        authRepository: _authRepository,
        emailInicial: _emailController.text.trim(),
      ),
    );

    if (!mounted || alterou != true) {
      return;
    }

    _senhaController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha redefinida com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulCorporativo = Color(0xFF0F2A44);
    const fundoTela = Color(0xFFF4F7FB);
    const bordaCampo = Color(0xFFD7E0EA);
    const textoSecundario = Color(0xFF607086);

    return Scaffold(
      backgroundColor: fundoTela,
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
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE4EAF2)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compacto ? 20 : 28,
                        vertical: compacto ? 24 : 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: compacto ? 64 : 72,
                                height: compacto ? 64 : 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF1F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.devices_other,
                                  size: compacto ? 34 : 38,
                                  color: azulCorporativo,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Gestao de Emprestimos',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: azulCorporativo,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Equipamentos de TI',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: textoSecundario),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIconColor: textoSecundario,
                                prefixIcon: Icon(Icons.email_outlined),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: bordaCampo),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: azulCorporativo,
                                    width: 1.4,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(),
                                focusedErrorBorder: OutlineInputBorder(),
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
                                filled: true,
                                fillColor: Colors.white,
                                prefixIconColor: textoSecundario,
                                prefixIcon: const Icon(Icons.lock_outline),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: bordaCampo),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: azulCorporativo,
                                    width: 1.4,
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(),
                                focusedErrorBorder: const OutlineInputBorder(),
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
                                    color: textoSecundario,
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
                                    : _abrirEsqueceuSenha,
                                style: TextButton.styleFrom(
                                  foregroundColor: azulCorporativo,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                ),
                                child: const Text('Alterar senha'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _carregando ? null : _entrar,
                                style: FilledButton.styleFrom(
                                  backgroundColor: azulCorporativo,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: azulCorporativo
                                      .withValues(alpha: 0.45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: _carregando
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: const Text('Entrar'),
                              ),
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

class _EsqueceuSenhaDialog extends StatefulWidget {
  const _EsqueceuSenhaDialog({
    required this.authRepository,
    required this.emailInicial,
  });

  final AuthRepository authRepository;
  final String emailInicial;

  @override
  State<_EsqueceuSenhaDialog> createState() => _EsqueceuSenhaDialogState();
}

class _EsqueceuSenhaDialogState extends State<_EsqueceuSenhaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _salvando = false;
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
      await widget.authRepository.redefinirSenha(
        email: _emailController.text.trim(),
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
      title: const Text('Esqueceu a senha?'),
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
    return 'Nao foi possivel redefinir a senha.';
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
