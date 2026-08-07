import 'package:exemplo_tela_login/pages/home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Variaveis
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");

  bool isobscureText = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //SafeArea evita que elementos do sistema operacional interfiram na interface
      child: Scaffold(
        //Scaffold é a estrutura base de uma tela
        backgroundColor: const Color.fromARGB(255, 211, 211, 223),
        body: SingleChildScrollView(
          //ConstrainedBox -
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),

            child: Column(
              //Column organiza seus filhos em uma coluna vertical
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Alinhamento horizontal ao centro do Logotipo
                Row(
                  children: [
                    Expanded(child: Container()), //Espaçador à esquerda
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(top: 100),
                        child: Image.network(
                          'https://images.builderservices.io/s/cdn/v1.0/i/m?url=https%3A%2F%2Fstorage.googleapis.com%2Fproduction-hostgator-brasil-v1-0-7%2F637%2F1123637%2FMrhXaHw1%2F72bd2d32a9bb447cb320ec99cd73381e&methods=resize%2C500%2C5000',
                        ),
                      ),
                    ),
                    Expanded(child: Container()), //Espaçador à direita
                  ],
                ),
                //Espaçamento vertical
                //
                SizedBox(height: 15),
                Column(
                  children: [
                    Text(
                      'Bem-vindo !',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Faça login para continuar',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                //Campos de Email e Senha
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: const Color.fromARGB(255, 246, 247, 248),
                      height: 30,
                      alignment: Alignment.center,

                      child: TextField(
                        controller: emailController,
                        onChanged: (value) => debugPrint(value),

                        style: TextStyle(),
                        keyboardType: TextInputType.emailAddress,
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: const Color.fromARGB(255, 246, 247, 248),
                      height: 30,
                      alignment: Alignment.center,

                      child: TextField(
                        onChanged: (value) => debugPrint(value),
                        controller: passwordController,

                        style: TextStyle(),
                        keyboardType: TextInputType.visiblePassword,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        obscureText: isobscureText,

                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          border: InputBorder.none,
                          hintText: 'Senha',
                          //Ou utilizar InkWell
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isobscureText = !isobscureText;
                              });
                            },
                            child: Icon(
                              isobscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,

                      child: TextButton(
                        onPressed: () {
                          //Teste de login
                          if (emailController.text != "" &&
                              passwordController.text != "") {
                           
                           
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login realizado com sucesso!"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Preencha todos os campos!"),
                              ),
                            );
                          }

                          //Prints dos valores dos campos de texto
                          debugPrint(emailController.text);
                          debugPrint(passwordController.text);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 240, 67, 67),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                        ),
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 185, 183, 183),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 250),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
