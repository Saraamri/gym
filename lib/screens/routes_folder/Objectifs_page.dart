import 'package:flutter/material.dart';

class ObjectifsPage extends StatefulWidget {
  @override
  _ObjectifsPageState createState() => _ObjectifsPageState();
}

class _ObjectifsPageState extends State<ObjectifsPage> {
  // Contrôleurs de texte
  TextEditingController _weightController = TextEditingController();
  TextEditingController _targetWeightController = TextEditingController();
  TextEditingController _caloriesController = TextEditingController();
  TextEditingController _workoutFrequencyController = TextEditingController();

  // Valeurs des objectifs
  double _currentWeight = 0.0;
  double _targetWeight = 0.0;
  double _calories = 0.0;
  String _workoutFrequency = '';

  // Form Key pour validation
  final _formKey = GlobalKey<FormState>();

  bool _isUpdating = false;  // Indicateur pour savoir si on est en mode de mise à jour

  // Fonction de validation des champs
  bool _validateInputs() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _saveGoals() {
    if (_validateInputs()) {
      setState(() {
        _currentWeight = double.tryParse(_weightController.text) ?? 0.0;
        _targetWeight = double.tryParse(_targetWeightController.text) ?? 0.0;
        _calories = double.tryParse(_caloriesController.text) ?? 0.0;
        _workoutFrequency = _workoutFrequencyController.text;
        _isUpdating = false; // Quitter le mode mise à jour après l'enregistrement
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Objectifs enregistrés")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Veuillez remplir correctement tous les champs")));
    }
  }

  void _startUpdate() {
    setState(() {
      _isUpdating = true;  // Passer en mode de mise à jour
      _weightController.text = _currentWeight.toString();
      _targetWeightController.text = _targetWeight.toString();
      _caloriesController.text = _calories.toString();
      _workoutFrequencyController.text = _workoutFrequency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Objectifs"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Utilisation du formulaire avec validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Poids actuel (kg)"),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(hintText: "Entrez votre poids actuel (kg)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre poids actuel';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide pour le poids';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Poids cible (kg)"),
              TextFormField(
                controller: _targetWeightController,
                decoration: InputDecoration(hintText: "Entrez votre objectif de poids (kg)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre poids cible';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide pour le poids cible';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Calories quotidiennes"),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(hintText: "Calories à consommer par jour"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de calories';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide pour les calories';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Fréquence des entraînements"),
              TextFormField(
                controller: _workoutFrequencyController,
                decoration: InputDecoration(hintText: "Exemple: 3 séances par semaine"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la fréquence des entraînements';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGoals,
                child: Text(_isUpdating ? "Mettre à jour mes objectifs" : "Enregistrer mes objectifs"),
              ),
              SizedBox(height: 30),
              _buildCurrentGoals(),
            ],
          ),
        ),
      ),
    );
  }

  // Affichage des objectifs enregistrés
  Widget _buildCurrentGoals() {
    if (_currentWeight == 0.0 || _targetWeight == 0.0 || _calories == 0.0 || _workoutFrequency.isEmpty) {
      return Container(); // Si aucun objectif n'est encore enregistré
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Objectifs enregistrés :",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Poids actuel : $_currentWeight kg"),
        Text("Poids cible : $_targetWeight kg"),
        Text("Calories quotidiennes : $_calories kcal"),
        Text("Fréquence des entraînements : $_workoutFrequency"),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startUpdate,
          child: Text("Mettre à jour mes objectifs"),
        ),
      ],
    );
  }
}
