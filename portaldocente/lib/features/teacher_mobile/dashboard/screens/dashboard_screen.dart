import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], //Color de fundo
      //1. HEADER (Cabeçalho) personalizado
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // Altura do AppBar
        child: Container(
          padding: const EdgeInsets.only(
            top: 50,
            left: 20,
            right: 20,
          ), // Padding para o conteúdo do AppBar
          decoration: BoxDecoration(
            color: Color(0xFF1E88E5), // Cor de fundo do AppBar
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(
                20,
              ), // Arredondamento do canto inferior esquerdo
              bottomRight: Radius.circular(
                20,
              ), // Arredondamento do canto inferior direito
            ),
          ),
          // Conteúdo do AppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, Dr.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'Ricardo Silva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Ícone de notificação e avatar do usuário
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ), // Foto fictícia
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 2. CORPO DA PÁGINA
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próxima Aula',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 3. CARD DA PRÓXIMA AULA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: const Border(
                  left: BorderSide(
                    color: Colors.orange,
                    width: 8,
                  ), // Destaque lateral
                ),
              ),
              child: Row(
                children: [
                  const Column(
                    children: [
                      Text(
                        '08:00',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('-', style: TextStyle(color: Colors.grey)),
                      Text(
                        '10:00',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Engenharia de Software',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Modelagem de Sistemas\nSala 301, Bloco C',
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Minhas Escalas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 4. CALENDÁRIO HORIZONTAL (Mock)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  bool isToday =
                      index == 0; // Simula que o primeiro é o dia atual
                  return Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF1E5BB2) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: isToday
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'][index],
                          style: TextStyle(
                            color: isToday ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${25 + index}', // Simula os dias 25, 26, 27...
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
