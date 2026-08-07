import 'package:app_exe_testes/app_exe_testes.dart' as app_exe_testes;
import 'package:app_exe_testes/models/viacep.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'app_exe_testes_test.mocks.dart';

// A anotação @GenerateMocks instrui o pacote build_runner a criar uma classe de Mock
// baseada na classe [MockViaCEP], permitindo simular comportamentos em testes.
@GenerateMocks([MockViaCEP])
void main() {
  // A função [test] define um caso de teste unitário.
  // Verifica se a função calcularDesconto retorna o valor correto sem percentual.
  test('Calcula o desconto do produto sem percentual', () {
    double resultado = app_exe_testes.calcularDesconto(200.0, 50.0, false);
    // [expect] compara o resultado obtido com o valor esperado (matcher).
    expect(resultado, 150.0);
  });

  // Verifica se a função lança uma exceção [ArgumentError] quando o valor do produto é zero.
  test('Verificar o valor zero do produto', () {
    expect(
      () => app_exe_testes.calcularDesconto(0.0, 50.0, false),
      throwsA(TypeMatcher<ArgumentError>()),
    );
    //
  });

  // Verifica o cálculo do desconto quando a opção de percentual é verdadeira.
  test('Calcula o desconto do produto com percentual', () {
    double resultado = app_exe_testes.calcularDesconto(200.0, 10.0, true);
    expect(resultado, 180.0);
  });

  // Verifica se a função lança exceção ao receber desconto zero.
  test('Verificar o valor zero do desconto', () {
    expect(
      () => app_exe_testes.calcularDesconto(200.0, 0.0, false),
      throwsA(TypeMatcher<ArgumentError>()),
    );
    //
  });

  // Teste de manipulação de strings: verifica a conversão para maiúsculas.
  test('Converter texto para maiúsculo', () {
    expect(app_exe_testes.convertToUpper("rauni"), equals("RAUNI"));
  });

  // Utiliza o matcher [equalsIgnoringCase] para comparar strings ignorando caixa alta/baixa.
  test('Converter texto para maiúsculo', () {
    expect(app_exe_testes.convertToUpper("rauni"), equalsIgnoringCase("Rauni"));
  });

  // Verifica se o retorno é exatamente igual a 10.
  test('Retornar valor maior 10', () {
    expect(app_exe_testes.returnavalor(), equals(10));
  });

  // Utiliza o matcher [greaterThanOrEqualTo] para validar intervalos numéricos.
  test('Retornar valor maior 10', () {
    expect(app_exe_testes.returnavalor(), greaterThanOrEqualTo(0));
  });

  // [group] agrupa testes relacionados. Aqui utilizamos Data-Driven Testing (testes baseados em dados).
  group('Calcula o valor do produto com desconto', () {
    var valuesToTest = {
      {'valor': 300, 'desconto': 50, 'percentual': false}: 250,
      {'valor': 300, 'desconto': 100, 'percentual': false}: 200,
      {'valor': 300, 'desconto': 10, 'percentual': true}: 290,
    };

    valuesToTest.forEach((values, expected) {
      test('Entrada: $values, Esperado: $expected', () {
        expect(
          app_exe_testes.calcularDesconto(
            double.parse(values["valor"].toString()),
            double.parse(values["desconto"].toString()),
            values["percentual"] == 'true',
          ),
          equals(expected),
        );
      });
    });
  });

  /*
///Testes para a função retornarCEP

  test('Retornar o CEP informado', () async {
    var body = await app_exe_testes.retornarCEP('01001000');
    print(body);
  });

///Testes para a função consultaCEP com verificação do campo localidade
  test('Consultar o CEP informado', () async {
    var body = await app_exe_testes.consultaCEP('14410000');
    print(body);
    expect(body["localidade"], equals("Franca"));
  });

*/
  //Testes para a função consultaCEP com verificação do campo localidade utiliando Classe
  /*
 test('Consultar o CEP informado', () async {
    Viacep viacep = Viacep();

    var body = await viacep.consultaCEP('14410000');
    expect(body["localidade"], equals("Franca"));
    
  });

*/

  // Teste utilizando Mockito para simular a API ViaCEP.
  // Isso isola o teste de dependências externas e latência de rede.
  test('Consultar o CEP informado', () async {
    MockMockViaCEP viacep = MockMockViaCEP();

    // [when] define o comportamento do mock. Quando consultaCEP for chamado, retorna um Future com dados fixos.
    when(viacep.consultaCEP('14410000')).thenAnswer(
      (realInvocation) => Future.value({
        "cep": "14410-000",
        "logradouro": "Avenida Major Nicácio",
        "complemento": "",
        "bairro": "Vila Frezzarim",
        "localidade": "Franca",
        "uf": "SP",
        "ibge": "3516408",
        "gia": "5570",
        "ddd": "16",
        "siafi": "6221",
      }),
    );

    var body = await viacep.consultaCEP('14410000');
    expect(body["localidade"], equals("Franca"));
  });

  //Fim main
}

// Criação de uma classe Mock que implementa a interface da classe original [Viacep].
// Necessário para o funcionamento do Mockito.
class MockViaCEP extends Mock implements Viacep {}
