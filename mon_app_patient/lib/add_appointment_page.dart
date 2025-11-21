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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Entrez $label',
              prefixIcon: Icon(icon, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            validator: isRequired
                ? (v) => v == null || v.trim().isEmpty ? 'Ce champ est requis' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
            foregroundColor: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            side: BorderSide(
              color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modifier le rendez-vous' : 'Nouveau rendez-vous',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 40,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEdit ? 'Modifier le rendez-vous' : 'Planifier un nouveau rendez-vous',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Formulaire
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView(
                          children: [
                            _buildFormField(
                              controller: _titleCtrl,
                              label: 'Intitulé du rendez-vous',
                              icon: Icons.event_note,
                              isRequired: true,
                            ),
                            _buildFormField(
                              controller: _doctorCtrl,
                              label: 'Médecin / Spécialiste',
                              icon: Icons.medical_services,
                              isRequired: true,
                            ),
                            _buildFormField(
                              controller: _descriptionCtrl,
                              label: 'Description',
                              icon: Icons.description,
                              isRequired: false,
                              maxLines: 3,
                            ),
                            _buildFormField(
                              controller: _locationCtrl,
                              label: 'Lieu / Adresse',
                              icon: Icons.location_on,
                              isRequired: true,
                            ),

                            // Section Date et Heure
                            const SizedBox(height: 10),
                            Text(
                              'Date et heure',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildDateTimeButton(
                                  onPressed: _pickDate,
                                  text: _selectedDate == null
                                      ? 'Choisir date'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  icon: Icons.calendar_month,
                                  isSelected: _selectedDate != null,
                                ),
                                _buildDateTimeButton(
                                  onPressed: _pickTime,
                                  text: _selectedTime == null
                                      ? 'Choisir heure'
                                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                  icon: Icons.access_time,
                                  isSelected: _selectedTime != null,
                                ),
                              ],
                            ),

                            // Bouton de sauvegarde
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  shadowColor: Colors.blue.withOpacity(0.3),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isEdit ? Icons.save : Icons.add,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isEdit ? 'Enregistrer les modifications' : 'Ajouter le rendez-vous',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}