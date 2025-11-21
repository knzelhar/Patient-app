import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  
  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final adresseController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dateController = TextEditingController(); 

  DateTime? selectedDate;

  //API CALL 
  Future<void> registerUser() async {
    final url = Uri.parse("http://10.0.2.2:3000/api/auth/register");

    final body = {
      "nom": nameController.text,
      "prenom": prenomController.text,
      "adresse": adresseController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
      "date_naissance": dateController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès ✔")),
        );

        
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e")),
      );
    }
  }

  
  void register() {
    if (_formKey.currentState!.validate()) {
      if (dateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner une date de naissance")),
        );
        return;
      }
      registerUser();
    }
  }

  
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      setState(() {
        selectedDate = picked;
        dateController.text = formatted; 
      });
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Créer un compte"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20),

              
              TextFormField(
                controller: nameController,
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                decoration: InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: prenomController,
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                decoration: InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: () => selectDate(context),
                validator: (v) =>
                    v!.isEmpty ? "Sélectionnez une date" : null,
                decoration: InputDecoration(
                  labelText: "Date de naissance",
                  hintText: "Sélectionner une date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: adresseController,
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                decoration: InputDecoration(
                  labelText: "Adresse",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: emailController,
                validator: (v) {
                  if (v!.isEmpty) return "Champ obligatoire";
                  if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(v)) {
                    return "Email invalide";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                validator: (v) {
                  if (v!.isEmpty) return "Champ obligatoire";
                  if (v != passwordController.text) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Confirmer le mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Créer le compte",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
