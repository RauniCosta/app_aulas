import 'dart:convert';
import 'dart:io';

class ConsoleUtils {

// Métodos estáticos para leitura de dados do console
  static String lerStringComTxt (String Texto){
    print(Texto);
    return lerString(); 
  }


  static String lerString(){
    return stdin.readLineSync(encoding: utf8) ?? "";

  }

  static double? lerDouble(){
    var entrada = lerString();
    try {
      return double.parse(entrada);
    } catch (e) {
      return null;
    } 
  }

  static double? lerDoubleComTxt (String Texto){
    print(Texto);
    var entrada = lerString();
    try {
      return double.parse(entrada);
    } catch (e) {
      return null;
    } 
  }

  static double? lerDoubleComSaida(String Texto){
    var valor = lerString();
    if (valor == "sair"){
      return null;
    }
    try {
      return double.parse(valor);
    } catch (e) {
      return null;
    } 
  }
    
}