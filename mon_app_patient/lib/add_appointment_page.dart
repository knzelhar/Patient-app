import 'package:flutter/material.dart';
import 'appointments_page.dart';
import 'services/appointment_service.dart';

class AddAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  const AddAppointmentPage({super.key, this.appointment});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _doctorCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _locationCtrl;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;
  late String _id; 

  @override
  void initState() {
    super.initState();

    final a = widget.appointment;

    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _doctorCtrl = TextEditingController(text: a?.doctor ?? '');
    _descriptionCtrl = TextEditingController(text: a?.description ?? '');
    _locationCtrl = TextEditingController(text: a?.location ?? '');

    _id = a?.id ?? ''; 

    if (a != null) {
      _selectedDate = a.appointmentAt;
      _selectedTime =
          TimeOfDay(hour: a.appointmentAt.hour, minute: a.appointmentAt.minute);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date et l\'heure')),
      );
      return;
    }

    final appointmentAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final appt = Appointment(
      id: _id, 
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      doctor: _doctorCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      appointmentAt: appointmentAt,
    );

    setState(() => _isSaving = true);

    try {
      Appointment result;
      if (widget.appointment == null) {
        
        result = await AppointmentService.createAppointment(appt);
      } else {
      
        result = await AppointmentService.updateAppointment(appt);
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier RDV' : 'Ajouter RDV'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Intitulé'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _doctorCtrl,
                    decoration: const InputDecoration(labelText: 'Médecin / soins'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(labelText: 'Lieu'),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDate,
                          child: Text(
                            _selectedDate == null
                                ? 'Choisir une date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickTime,
                          child: Text(
                            _selectedTime == null
                                ? 'Choisir une heure'
                                : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
                    ),
                  ),
                ],
              ),
            ),
            if (_isSaving)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
