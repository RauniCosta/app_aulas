import 'dart:math';

class GeradorAleatorio {
  static int gerarNumeroAleatorio(int limite) {
    Random numeroAleatorio = Random();
    return numeroAleatorio.nextInt(limite);
  }
}
