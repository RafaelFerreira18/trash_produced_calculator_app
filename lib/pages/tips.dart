import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({Key? key}) : super(key: key);

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    // Posts pré-definidos
    posts = [
      Post(
        title: 'Evite o Desperdício: Dicas Simples para Reduzir o Lixo Alimentar',
        description:
            'Aprenda estratégias para aproveitar ao máximo os alimentos e evitar desperdícios desnecessários na sua cozinha. Planejar refeições, armazenar alimentos corretamente e utilizar sobras para criar novos pratos são algumas das maneiras de reduzir o lixo alimentar. Além de economizar dinheiro, você contribui para a redução da emissão de gases de efeito estufa gerados pelo desperdício de alimentos.',
        imagePath: 'assets/tipsImages/desperdicio-de-alimentos.jpg',
      ),
      Post(
        title: 'Guia de Separação de Resíduos: Como Fazer a Reciclagem Corretamente',
        description:
            'Saiba como separar seu lixo de maneira eficiente para facilitar o processo de reciclagem e contribuir para o meio ambiente. É essencial separar plásticos, papéis, metais e vidros em recipientes distintos, removendo contaminantes como restos de alimentos. Conhecer as diretrizes locais de reciclagem ajuda a garantir que seus esforços tenham o máximo impacto positivo.',
        imagePath: 'assets/tipsImages/separacao-de-residuos.jpg',
      ),
      Post(
        title: 'Transforme seu Lixo em Recursos: Dicas de Reciclagem Criativa!',
        description:
            'Aprenda maneiras inovadoras de reciclar materiais comuns e dar uma segunda vida a itens que iriam para o lixo. Você pode transformar garrafas plásticas em vasos para plantas, potes de vidro em organizadores e até mesmo criar obras de arte a partir de materiais reciclados. Essa abordagem não só reduz o desperdício como também estimula a criatividade e promove um estilo de vida mais sustentável.',
        imagePath: 'assets/tipsImages/reciclagem-criativa.jpg',
      ),
      Post(
        title: 'Reduzir, Reutilizar, Reciclar: Como Cuidar Melhor do Nosso Lixo',
        description:
            'Descubra práticas simples para reduzir sua pegada de lixo e fazer escolhas mais sustentáveis no dia a dia. A chave para reduzir o lixo está em optar por produtos com menos embalagens, preferir itens duráveis e reutilizáveis, e reciclar corretamente tudo o que puder. Ao praticar o "reduzir, reutilizar, reciclar", você contribui significativamente para a preservação do meio ambiente.',
        imagePath: 'assets/tipsImages/reduzir-reutilizar-reciclar.jpg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posts[index].title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        posts[index].description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  posts[index].imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Post {
  String title;
  String description;
  String imagePath;

  Post({required this.title, required this.description, required this.imagePath});
}
