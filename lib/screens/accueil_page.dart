import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond avec effet sombre
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fitness.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Alignement à droite
                children: [
                  // Bouton "Join Us" en haut à droite
                  Align(
                    alignment: Alignment.topRight,
                    child: _buildButton(
                      text: "Join Us",
                      onPressed: () {
                        Navigator.pushNamed(context, '/LoginPage');
                      },
                      color: Colors.white,
                      textColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 80),

                  // Titre et sous-titre
                  Text(
                    "Transformez votre corps,\nChangez votre vie.",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right, // Alignement du texte à droite
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Rejoignez notre communauté et atteignez vos objectifs fitness avec nos experts.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.right, // Alignement du texte à droite
                  ),
                  SizedBox(height: 40),

                  // Mots-clés inspirants alignés à droite
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildKeyword("🔥 Santé"),
                      _buildKeyword("🏆 Performance"),
                      _buildKeyword("💪 Motivation"),
                      _buildKeyword("🧘 Bien-être"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour afficher les mots-clés inspirants
  Widget _buildKeyword(String keyword) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        keyword,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Fonction pour construire un bouton
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: textColor),
      ),
    );
  }
}
