import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/notification_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final String baseUrl = 'http://127.0.0.1:8081/api/rendezvous';
  int? _userId;
  String? _token;
  List<dynamic> _rendezvousList = [];
  Map<DateTime, List<dynamic>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await NotificationService.init();
    await _loadUserIdAndFetchRendezVous();
  }

  Future<void> _loadUserIdAndFetchRendezVous() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null && _token!.isNotEmpty) {
      final payload = JwtDecoder.decode(_token!);
      setState(() {
        _userId = int.tryParse(payload['id'].toString());
      });
      await _fetchRendezVous();
    }
  }

  Future<void> _fetchRendezVous() async {
    if (_userId == null) return;
    final response = await http.get(Uri.parse('$baseUrl/$_userId'));

    if (response.statusCode == 200) {
      setState(() {
        _rendezvousList = json.decode(response.body);
      });
      _buildEventsMap();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des rendez-vous')),
      );
    }
  }

  void _buildEventsMap() {
    _events.clear();
    for (var rdv in _rendezvousList) {
      if (rdv['dateHeure'] == null) continue;
      DateTime date = DateTime.parse(rdv['dateHeure']);
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      if (_events[dateOnly] == null) {
        _events[dateOnly] = [rdv];
      } else {
        _events[dateOnly]!.add(rdv);
      }
    }
    setState(() {});
  }

  Color _getColorForEvent(Map event) {
    final titre = event['titre']?.toString().toLowerCase() ?? '';
    if (titre.contains('cours')) return const Color.fromARGB(255, 237, 169, 237);
    if (titre.contains('séance')) return const Color.fromARGB(255, 35, 88, 121);
    return Colors.blueGrey.shade400;
  }

  Future<void> _addRendezVous() async {
    if (_titleController.text.isEmpty) return;

    final newRDV = {
      'titre': _titleController.text,
      'dateHeure': _selectedDate.toIso8601String(),
      'user': {'id': _userId}
    };

    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newRDV),
    );

    if (response.statusCode == 200) {
      await NotificationService.showNotification(
        'Rendez-vous ajouté',
        _titleController.text,
        _selectedDate,
      );
      _titleController.clear();
      await _fetchRendezVous();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout')),
      );
    }
  }

  Future<void> _deleteRendezVous(dynamic id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rendez-vous supprimé')),
      );
      await _fetchRendezVous();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  void _confirmDelete(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRendezVous(id);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    DateTime tempSelectedDate = _selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Ajouter un rendez-vous'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(DateFormat('yyyy-MM-dd – kk:mm').format(tempSelectedDate)),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempSelectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(tempSelectedDate),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            tempSelectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _selectedDate = tempSelectedDate;
                _addRendezVous();
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getEventsForSelectedDay() {
    final dateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return _events[dateOnly] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDay = _getEventsForSelectedDay();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendrier'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final dateOnly = DateTime(day.year, day.month, day.day);
              return _events[dateOnly] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return SizedBox();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map((event) {
                    Color color = _getColorForEvent(event as Map);
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: eventsForSelectedDay.isEmpty
                  ? Center(child: Text('Aucun rendez-vous pour ce jour.'))
                  : ListView.builder(
                      itemCount: eventsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final rdv = eventsForSelectedDay[index];
                        final date = DateTime.parse(rdv['dateHeure']);
                        final color = _getColorForEvent(rdv as Map);
                        return Card(
                          color: color,
                          child: ListTile(
                            title: Text(
                              rdv['titre'] ?? 'Sans titre',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy – HH:mm').format(date),
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _confirmDelete(rdv['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
