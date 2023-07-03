import 'package:flutter/material.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  // when creating login page, pass auth parameter to login page create an instance of abstract class
  LoginPage({required this.auth, required this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum FormType { login, register }

// private calss not accessible from other
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    print('validateAndSubmit: ${validateAndSave()}');
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          print('FormType.login. _email: $_email, password: $_password');
          final userId =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in user.uid: $userId');
        } else if (_formType == FormType.register) {
          final userId = await widget.auth
              .createUserWithEmailAndPassword(_email, _password);
          print('Registered user: $userId');
        }
        widget.onSignedIn();
      } catch (e) {
        print('Error: ${e.toString()}');
      }
    }
  }

  void moveToRegister() {
    _formKey.currentState!.reset();
    // setStateが呼ばれるとbuildが走る
    setState(() => _formType = FormType.register);
  }

  void moveToLogin() {
    setState(() => _formType = FormType.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter login demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons(),
            )),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        onSaved: (value) => _email = value!,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email can\'t be empty';
          }
          return null;
        },
      ),
      TextFormField(
        onSaved: (value) => _password = value!,
        decoration: InputDecoration(labelText: 'password'),
        obscureText: true,
        validator: (value) => value!.isEmpty ? 'Passwod can\'t be empty' : null,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple)),
          onPressed: validateAndSubmit,
          child: Text('login'),
        ),
        TextButton(
          onPressed: moveToRegister,
          child: Text('create an account'),
        ),
      ];
    } else {
      return [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple)),
          onPressed: validateAndSubmit,
          child: Text('create an account'),
        ),
        TextButton(
          onPressed: moveToLogin,
          child: Text('Have an account? Login'),
        ),
      ];
    }
  }
}
