import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                              child: _DeviceMark(size: compacto ? 72 : 80),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Gestão de Empréstimos',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Equipamentos de TI',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIconColor: AppColors.textSecondary,
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
                                prefixIconColor: AppColors.textSecondary,
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
                                    color: AppColors.textSecondary,
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
                                  foregroundColor: AppColors.primary,
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
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary
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
      return 'E-mail ou senha inválidos.';
    }
    return 'Não foi possível entrar. Tente novamente.';
  }
}

class _DeviceMark extends StatelessWidget {
  const _DeviceMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.analysisSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: size * 0.15,
            top: size * 0.24,
            child: Container(
              width: size * 0.52,
              height: size * 0.34,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            left: size * 0.11,
            top: size * 0.60,
            child: Container(
              width: size * 0.60,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            right: size * 0.16,
            top: size * 0.30,
            child: Container(
              width: size * 0.25,
              height: size * 0.42,
              decoration: BoxDecoration(
                color: AppColors.analysisSoft,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
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
                      return 'As senhas não conferem.';
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
      return 'Usuário não encontrado.';
    }
    return 'Não foi possível redefinir a senha.';
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
