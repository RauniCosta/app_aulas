import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //SafeArea evita que elementos do sistema operacional interfiram na interface
      child: Scaffold(
        //Scaffold é a estrutura base de uma tela
        backgroundColor: const Color.fromARGB(255, 211, 211, 223),
        body: Container(
          width: double.infinity,
          //Container é um widget de layout que pode conter outros widgets
          child: Column(
            //Column organiza seus filhos em uma coluna vertical
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Icon(Icons.person, size: 150, color: Colors.blue),
              ),
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.blue,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.blue,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  'Senha',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 350),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                color: Color.fromARGB(255, 20, 124, 16),
                height: 30,
                width: 120,
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                color: const Color.fromARGB(255, 211, 211, 223),
                height: 30,
                width: 120,
                alignment: Alignment.center,
                child: Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
