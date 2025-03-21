import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          // Utilisation de l'image en arrière-plan
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gym2.jpg'), // Image de fond
              fit: BoxFit.cover, // Remplir tout l'écran
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message de bienvenue
                Text(
                  'Rejoignez notre communauté et atteignez vos objectifs de santé et bien-être avec nous!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.6),
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Espace avant le bouton
                SizedBox(height: 40),

                // Bouton Join Us
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/LoginPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 195, 195, 242),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Join Us',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
