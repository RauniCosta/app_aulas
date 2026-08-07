import 'package:exemplo_tela_login/pages/cadastro_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Menu"),
                ),
                onTap: () {},
              ),
              // SizedBox(height: 20),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Cadastrar"),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: 
                    (context) => CadastroPage()
                    ),
                  );
                },
              ),
              // SizedBox(height: 20),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Relatorio"),
                ),
                onTap: () {},
              ),
              // SizedBox(height: 20),
              Divider(),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Sair"),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
