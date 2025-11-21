import 'package:flutter/material.dart';
import 'add_appointment_page.dart';
import 'services/appointment_service.dart';

class Appointment {
  String id;
  String title;
  String doctor;

  String? description;
  String? location;

  DateTime appointmentAt;

  Appointment({
    required this.id,
    required this.title,
    required this.doctor,
    required this.appointmentAt,
    this.description,
    this.location,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      title: json['title'],
      doctor: json['doctor'],
      description: json['description'],
      location: json['location'],
      appointmentAt: DateTime.parse(json['appointment_at']),
    );
  }
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppointmentService.testConnection();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final list = await AppointmentService.fetchAppointments();
      setState(() {
        _appointments = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _openAddEdit([Appointment? existing]) async {
    final result = await Navigator.push<Appointment?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAppointmentPage(appointment: existing),
      ),
    );

    if (result == null) return;

    setState(() {
      if (existing != null) {
        final index = _appointments.indexWhere((a) => a.id == existing.id);
        if (index != -1) _appointments[index] = result;
      } else {
        _appointments.insert(0, result);
      }
    });
  }

  void _confirmDelete(Appointment appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?'),
        content: Text(
            'Voulez-vous vraiment annuler "${appt.title}" le ${_formatDate(appt.appointmentAt)} à ${_formatTime(appt.appointmentAt)} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Non')),
          TextButton(
            onPressed: () async {
              try {
                await AppointmentService.deleteAppointment(appt.id);

                setState(() => _appointments.removeWhere((a) => a.id == appt.id));
                Navigator.of(ctx).pop();
              } catch (e) {
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Erreur : $e')));
                }
              }
            },
            child: const Text('Oui, annuler',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} / ${dt.month.toString().padLeft(2, '0')} / ${dt.year}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes rendez-vous"),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(null),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun rendez-vous',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (ctx, i) {
                    final a = _appointments[i];
                    final isFuture = a.appointmentAt.isAfter(DateTime.now());
                    
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isFuture ? 3 : 1,
                      child: ListTile(
                        leading: Icon(
                          isFuture ? Icons.calendar_today : Icons.history,
                          color: isFuture ? Colors.blueAccent : Colors.grey,
                          size: 28,
                        ),
                        title: Text(
                          a.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${_formatDate(a.appointmentAt)} • ${_formatTime(a.appointmentAt)}\nAvec : ${a.doctor}',
                          style: TextStyle(
                            color: isFuture ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        isThreeLine: true,
                        onTap: () => _openAddEdit(a),
                        onLongPress: () => _confirmDelete(a),
                      ),
                    );
                  },
                ),
    );
  }
}
