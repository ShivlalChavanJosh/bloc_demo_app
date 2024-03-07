import 'package:bloc_demo_app/presentation/screens/login/bloc/login_bloc.dart';
import 'package:bloc_demo_app/presentation/screens/login/bloc/login_event.dart';
import 'package:bloc_demo_app/presentation/screens/login/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/TextInputWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _userNameTextController;
  TextEditingController? _passwordTextController;

  @override
  void initState() {
    _userNameTextController = TextEditingController(text: null);
    _passwordTextController = TextEditingController(text: null);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<LoginBloc,LoginState>(
        builder: (BuildContext blocContext, state) {
          if(state is  LoginInitialState){
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextFieldWidget(
                          textController: _userNameTextController,
                          labeltext: 'UserName',
                          errorMsg: 'Username cannot be empty.',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFieldWidget(
                          textController: _passwordTextController,
                          labeltext: 'Password',
                          errorMsg: 'Password cannot be empty.',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            if(_formKey.currentState!.validate()){
                              blocContext.read<LoginBloc>()
                                  .add(LoginWithCredentials(
                                  email: _userNameTextController!.text.toString(),
                                  password: _passwordTextController!.text.toString())
                              );
                            }
                          },
                          child: Container(
                            height: 56.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                'Login'.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          else if (state is LoginLoading){
            return const Center(child:CircularProgressIndicator(),);
          }
          else if (state is LoginCompleted){
            return const Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,color: Colors.green,),
                  Text('Login Success',),
                ],
              ),
            );
            
          }
          else{
            return const  Center(child: Text('Appp is In Center'),);
          }
        },
        listener: (BuildContext context, Object? state) {
         if(state is LoginCompleted){
           _formKey.currentState?.reset();
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
             content: Text('Login Successfull!!',),
             backgroundColor: Colors.green,
           ));
         }
      },
    );
  }
}
