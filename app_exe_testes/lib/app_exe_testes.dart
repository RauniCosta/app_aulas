import 'dart:convert';


double calcularDesconto (double valor, double desconto, bool percentual) {
  if (valor <= 0) {
    throw ArgumentError('O valor do produto deve ser maior que zero.');
  }
  if (desconto <= 0) {
    throw ArgumentError('O desconto deve ser maior que zero.');
  } 
  if (percentual) {
    return valor - (valor * desconto / 100);
  } else {
    return valor - desconto;
  }

}

String convertToUpper(String texto){
  return texto.toUpperCase();
}

double returnavalor(){
  return 10.0;
}

