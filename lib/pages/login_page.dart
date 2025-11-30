// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:study_planner/helpers/toast_helper.dart';
import 'package:study_planner/models/auth_model.dart';
import 'package:study_planner/pages/signup_form.dart';
import 'package:study_planner/theme/app_theme.dart';
import 'package:study_planner/types/login.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Controllers e variáveis de exemplo
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final List<String> _localeCodes = ['en', 'pt_br'];

  bool _passwordVisibility = false;
  LoginMode _mode = LoginMode.signIn;

  // Validação simples
  String? _validateNotEmpty(String? value) {
    return (value == null || value.isEmpty)
        ? translate('mandatory-field')
        : null;
  }

  Future<void> _changeLanguage(int index) async {
    setState(() {
      changeLocale(context, _localeCodes[index]);
    });
  }

  // Lista de idiomas para o dropdown
  final List<bool> selectedLanguage = <bool>[true, false];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    // Tamanhos da tela
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Cores do tema customizado (usando o Theme.of(context))
    final primaryColor = Theme.of(ctx).colorScheme.primary;
    final secondaryColor = Theme.of(ctx).colorScheme.secondary;
    final alternateColor = Theme.of(ctx).colorScheme.alternate;
    final primaryText = Theme.of(ctx).colorScheme.primaryText;
    final secondaryText = Theme.of(ctx).colorScheme.secondaryText;
    final primaryBackground = Theme.of(ctx).colorScheme.primaryBackground;
    final secondaryBackground = Theme.of(ctx).colorScheme.secondaryBackground;
    final errorColor = Theme.of(ctx).colorScheme.error;

    Future<void> handleLogin() async {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Validate mandatory fields
        if (email.isEmpty) {
          showErrorToast(
            context: context,
            title: translate("error"),
            content: 'Email é obrigatório',
          );
          return;
        }

        if (password.isEmpty) {
          showErrorToast(
            context: context,
            title: translate("error"),
            content: 'Senha é obrigatória',
          );
          return;
        }

        // Validate email format
        final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        if (!emailRegex.hasMatch(email)) {
          showErrorToast(
            context: context,
            title: translate("error"),
            content: 'Email inválido',
          );
          return;
        }

        var user = await AuthModel().sign(
          email: email,
          password: password,
          mode: _mode,
          ref: ref,
        );

        if (user != null) {
          showSuccessToast(
            context: context,
            title: translate("success"),
            content: 'Login realizado com sucesso!',
          );

          // Navigate to main after successful login
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/main');
          }
        } else {
          showErrorToast(
            context: context,
            title: translate("error"),
            content: 'Email ou senha inválidos. Verifique seus dados.',
          );
        }
      } on FirebaseAuthException catch (authError) {
        String errorMessage = 'Erro ao fazer login';

        if (authError.code == 'user-not-found') {
          errorMessage = 'Usuário não encontrado. Faça o cadastro primeiro.';
        } else if (authError.code == 'wrong-password') {
          errorMessage = 'Senha incorreta. Tente novamente.';
        } else if (authError.code == 'invalid-email') {
          errorMessage = 'Email inválido.';
        } else if (authError.code == 'user-disabled') {
          errorMessage = 'Usuário desativado. Entre em contato com o suporte.';
        } else if (authError.code == 'too-many-requests') {
          errorMessage = 'Muitas tentativas de login. Tente mais tarde.';
        }

        showErrorToast(
          context: context,
          title: translate("error"),
          content: errorMessage,
        );
      } catch (e) {
        if (kDebugMode) print("Error during authentication: $e");

        showErrorToast(
          context: context,
          title: translate("error"),
          content: 'Erro ao conectar: ${e.toString()}',
        );
      }
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.directional(top: 100),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              spacing: 32,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 113,
                  height: 113,
                  padding: EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5,
                        color: Color.fromARGB(33, 0, 0, 0),
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset("assets/images/logo.png"),
                ),
                SizedBox(
                  width: 250,
                  child: Column(
                    spacing: 12,
                    children: [
                      Text(
                        "Study Planner",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: primaryText,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mais que um planner, seu aliado na jornada acadêmica.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  height: height,
                  padding: EdgeInsets.all(34),
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5,
                        color: Color.fromARGB(33, 0, 0, 0),
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(32),
                    border: BoxBorder.all(
                      color: Theme.of(context).colorScheme.alternate,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 30,
                    children: [
                      Text(
                        _mode == LoginMode.signIn
                            ? "Entrar com"
                            : "Cadastre-se",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: primaryText,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_mode == LoginMode.signIn)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: width,
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  style: TextStyle(color: primaryText),
                                  cursorColor: primaryText,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Email',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: secondaryText),
                                    filled: true,
                                    fillColor: secondaryBackground,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: alternateColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: alternateColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: errorColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.email,
                                      color: secondaryText,
                                    ),
                                  ),
                                  validator: _validateNotEmpty,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: width,
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: !_passwordVisibility,
                                  style: TextStyle(color: primaryText),
                                  cursorColor: primaryText,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Senha',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: secondaryText),
                                    filled: true,
                                    fillColor: secondaryBackground,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: alternateColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: alternateColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: errorColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisibility =
                                              !_passwordVisibility;
                                        });
                                      },
                                      icon: Icon(
                                        _passwordVisibility
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: secondaryText,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  validator: _validateNotEmpty,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const SignUpForm(),
                      if (_mode == LoginMode.signIn)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: OutlinedButton(
                                onPressed: handleLogin,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  side: const BorderSide(
                                    color: Color(0xFF2FD1C5),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    Text(
                                      'Entrar',
                                      style: TextStyle(
                                        color: secondaryBackground,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _mode = _mode == LoginMode.signIn
                                  ? LoginMode.signUp
                                  : LoginMode.signIn;
                            });
                          },
                          child: Text(
                            _mode == LoginMode.signIn
                                ? 'Não tem uma conta? Cadastre-se'
                                : 'Já tem uma conta? Entrar',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        // Cabeçalho com texto gradiente e subtítulo
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TuneIn',
                              style: Theme.of(context).textTheme.headlineLarge!
                                  .copyWith(
                                    fontFamily: 'Oswald',
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              translate("music-for-everyone"),
                              // Utilizando bodyMedium (em vez de bodyText2)
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    color: secondaryText,
                                  ),
                            ),
                          ],
                        ),
                        // Formulário
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_mode == LoginMode.signUp)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: SizedBox(
                                  width: width * 0.2,
                                  child: TextFormField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    style: TextStyle(color: primaryText),
                                    cursorColor: primaryText,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: translate("username"),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: secondaryText),
                                      filled: true,
                                      fillColor: primaryBackground,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: primaryText,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: errorColor,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Icon(
                                        Icons.person,
                                        color: secondaryText,
                                      ),
                                    ),
                                    validator: _validateNotEmpty,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: width * 0.2,
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  style: TextStyle(color: primaryText),
                                  cursorColor: primaryText,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Email',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: secondaryText),
                                    filled: true,
                                    fillColor: primaryBackground,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primaryText,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: errorColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.email,
                                      color: secondaryText,
                                    ),
                                  ),
                                  validator: _validateNotEmpty,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: width * 0.2,
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: !_passwordVisibility,
                                  style: TextStyle(color: primaryText),
                                  cursorColor: primaryText,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: translate("password"),
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: secondaryText),
                                    filled: true,
                                    fillColor: primaryBackground,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primaryText,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: errorColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisibility =
                                              !_passwordVisibility;
                                        });
                                      },
                                      child: Icon(
                                        _passwordVisibility
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: secondaryText,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  validator: _validateNotEmpty,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.2,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _mode == LoginMode.signIn
                                      ? 'SIGN IN'
                                      : 'SIGN UP',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: primaryBackground,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Linha separadora com "OR"
                        if (_mode == LoginMode.signIn)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                constraints: BoxConstraints(maxHeight: 2),
                                decoration: BoxDecoration(color: secondaryText),
                              ),
                              Text(
                                translate("or"),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontFamily: 'Inter',
                                      color: secondaryText,
                                    ),
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                constraints: BoxConstraints(maxHeight: 2),
                                decoration: BoxDecoration(color: secondaryText),
                              ),
                            ],
                          ),
                        // Botão "Continue with Google" (apenas no signIn)
                        if (_mode == LoginMode.signIn)
                          SizedBox(
                            width: width * 0.2,
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                print('Continue with Google');
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.google,
                                size: 15,
                                color: primaryText,
                              ),
                              label: Text(translate("continue-w-google")),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryText,
                                side: BorderSide(color: primaryText, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        // RichText com link para alternar entre signIn/signUp
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  fontFamily: 'Inter',
                                  letterSpacing: 1,
                                  color: secondaryText,
                                ),
                            children: [
                              TextSpan(
                                text: _mode == LoginMode.signIn
                                    ? translate("dont-have-account")
                                    : translate("already-have-account"),
                              ),
                              TextSpan(
                                text: _mode == LoginMode.signIn
                                    ? 'SIGN UP'
                                    : 'SIGN IN',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: primaryColor,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _mode = _mode == LoginMode.signIn
                                          ? LoginMode.signUp
                                          : LoginMode.signIn;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                        if (_mode == LoginMode.signIn)
                          ToggleButtons(
                            onPressed: (int index) {
                              _changeLanguage(index);
                              setState(() {
                                for (
                                  int i = 0;
                                  i < selectedLanguage.length;
                                  i++
                                ) {
                                  selectedLanguage[i] = i == index;
                                }
                              });
                            },
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            selectedBorderColor: primaryBackground,
                            selectedColor: secondaryBackground,
                            fillColor: primaryText,
                            color: Colors.white,
                            constraints: const BoxConstraints(
                              minHeight: 40.0,
                              minWidth: 80.0,
                            ),
                            isSelected: selectedLanguage,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Image.network(
                                          'https://flagcdn.com/w80/us.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' English (US)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedLanguage[0]
                                              ? primaryBackground
                                              : primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Image.network(
                                          'https://flagcdn.com/w80/br.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Portuguese (BR)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedLanguage[1]
                                              ? primaryBackground
                                              : primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_mode == LoginMode.signIn)
                          Text(
                            'Copyright © 2025 - Erik e Thiago',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontFamily: 'Inter',
                                  color: secondaryText,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
*/
