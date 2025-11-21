import 'package:flutter/material.dart';

class VitalsPage extends StatelessWidget {
  const VitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signes vitaux"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVitalCard(
              "Tension artérielle",
              "120 / 80 mmHg",
              Icons.favorite),
          _buildVitalCard(
              "Fréquence cardiaque",
              "72 bpm",
              Icons.monitor_heart),
          _buildVitalCard(
              "Température",
              "36.8 °C",
              Icons.thermostat),
          _buildVitalCard(
              "Oxygénation (SpO₂)",
              "98%",
              Icons.bloodtype),
          _buildVitalCard(
              "Poids",
              "68 kg",
              Icons.monitor_weight),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 35, color: Colors.blueAccent),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
