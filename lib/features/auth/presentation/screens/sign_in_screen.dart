import 'package:any_animated_button/any_animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hospital_patient/core/error/failures.dart';
import 'package:hospital_patient/core/helper/validators.dart';
import 'package:hospital_patient/core/navigator/navigator.dart';
import 'package:hospital_patient/core/presentation/buttons/filled_button.dart';
import 'package:hospital_patient/core/presentation/buttons/reverted_button.dart';
import 'package:hospital_patient/core/presentation/widgets/notifications.dart';
import 'package:hospital_patient/core/presentation/widgets/textfields/basic_outlined_textfield.dart';
import 'package:hospital_patient/core/style/colors.dart';
import 'package:hospital_patient/core/style/paddings.dart';
import 'package:hospital_patient/core/style/text_styles.dart';
import 'package:hospital_patient/features/auth/domain/entities/auth_params.dart';
import 'package:hospital_patient/features/auth/domain/entities/token.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_in_form_bloc/sign_in_form_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:hospital_patient/injection_container.dart';

class SignInScreen extends StatefulWidget with NavigatedScreen {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();

  @override
  String get routeName => 'sign_in_screen';
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;

  late final SignInFormBloc _signInFormBloc;
  late final SignInBloc _signInBloc;

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _loginController = TextEditingController();
    _passwordController = TextEditingController();

    _signInFormBloc = sl();
    _signInBloc = sl();

    _formKey = GlobalKey<FormState>();

    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();

    _signInFormBloc.close();
    _signInBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        AnyAnimatedButtonBlocListener<AuthParams, Token, Failure>(
          bloc: _signInBloc,
          onErrorStart: (failure) => Notifications.error(failure: failure),
          onSuccessEnd: (data) => sl<AuthBloc>().add(AuthEvent.signIn(data)),
        ),
      ],
      child: Scaffold(
        backgroundColor: CustomColors.white,
        body: SafeArea(
          child: Padding(
            padding: Paddings.horizontal24,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80.0),
                  Text('Patient app', style: roboto.s36.w700.blueColor),
                  const SizedBox(height: 120.0),
                  BasicOutlinedTextfield(
                    controller: _loginController,
                    hint: 'Login',
                    validator: LoginValidator().errorMessage,
                    onChanged: (value) => _signInFormBloc.add(SignInFormEvent.changeLogin(value)),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),
                  BasicOutlinedTextfield(
                    controller: _passwordController,
                    hint: 'Password',
                    obscure: true,
                    showObscureSwitch: true,
                    validator: PasswordValidator().errorMessage,
                    onChanged: (value) => _signInFormBloc.add(SignInFormEvent.changePassword(value)),
                  ),
                  const Expanded(child: SizedBox(height: 16.0)),
                  BlocBuilder(
                    bloc: _signInFormBloc,
                    builder: (BuildContext context, SignInFormState state) {
                      return FilledButton(
                        text: 'Sign in',
                        bloc: _signInBloc,
                        enabled: state.valid,
                        onTap: () => _onSignInTap(state.params),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  RevertedButton(
                    text: 'Sign up',
                    onTap: () => const SignUpScreen().setAsBaseScreen(),
                  ),
                  const SizedBox(height: 22.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSignInTap(AuthParams params) {
    if (_formKey.currentState?.validate() ?? false) {
      _signInBloc.add(TriggerAnyAnimatedButtonEvent(params));
    }
  }
}
