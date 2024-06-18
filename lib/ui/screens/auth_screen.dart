import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/screens/home.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _cacheManager = GetIt.instance.get<CacheManager>();
  final _apiProvider = GetIt.instance.get<QRCodeApiRepository>();
  final _loginTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final _loginFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _hidePassword = true;
  bool isError = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _loginTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onNextFieldFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100,
                ),
                Image.asset(
                  'assets/images/DV-rybak-logo-cropped.png',
                  height: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: LoginFormWidget(),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget LoginFormWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Form(
        child: Column(children: [
          if (errorMessage != null)
            Text(errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          TextFormField(
            controller: _loginTextFieldController,
            focusNode: _loginFocus,
            autofocus: true,
            onFieldSubmitted: (_) {
              _onNextFieldFocus(context, _loginFocus, _passwordFocus);
            },
            style: const TextStyle(fontSize: 20, color: Colors.black, decoration: TextDecoration.none),
            cursorColor: AppColors.backgroundMain3,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.backgroundMain3, width: 2.5),
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.5),
              ),
              labelText: 'Логин',
              labelStyle: TextStyle(fontSize: 22, color: AppColors.backgroundMain3),
              prefixIcon: const Icon(Icons.person),
              prefixIconColor: AppColors.backgroundMain3,
              focusColor: AppColors.backgroundMain3,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordTextFieldController,
            focusNode: _passwordFocus,
            obscureText: _hidePassword,
            style: const TextStyle(fontSize: 20, color: Colors.black, decoration: TextDecoration.none),
            cursorColor: AppColors.backgroundMain3,
            decoration: InputDecoration(
              labelText: 'Пароль',
              labelStyle: TextStyle(fontSize: 22, color: AppColors.backgroundMain3),
              prefixIcon: const Icon(Icons.lock),
              prefixIconColor: AppColors.backgroundMain3,
              focusColor: AppColors.backgroundMain3,
              suffixIcon: GestureDetector(
                child:
                    Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: (){
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => ResetPasswordScreen())
              // );
            },
            child: SizedBox(
              child: Text(
                'Забыли пароль?',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.backgroundMain3,
                  fontSize: 14
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.backgroundMain3,
              minimumSize: const Size.fromHeight(45),
            ),
            onPressed: () async {
              if (isLoading) {
                print("Login in progress");
                return;
              }
              try {
                setState(() {
                  isLoading = true;
                  isError = false;
                });
                FocusManager.instance.primaryFocus?.unfocus();
                final token = await _apiProvider.login(
                    email: _loginTextFieldController.text.trim(),
                    password: _passwordTextFieldController.text.trim()
                );
                print("Token: $token");
                await _cacheManager.setToken(token);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Home())
                );
              } catch (err, stack) {
                print("Login error: $err\r\n$stack");
                setState(() {
                  isLoading = false;
                  isError = true;
                });
              }
            },
            child: isLoading
              ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white, backgroundColor: Colors.white24),
              )
              : const Text(
                'Войти',
                style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
