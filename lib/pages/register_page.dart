import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Création d'un compte via POST /accounts/register.
/// Renvoie l'email du compte créé à la page précédente.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmationController = TextEditingController();

  bool masquerMotDePasse = true;
  bool chargement = false;
  Map<String, String> erreursServeur = {};

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  Future<void> creerCompte() async {
    setState(() => erreursServeur = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => chargement = true);
    try {
      final compte = await ApiService.register(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé, vous pouvez vous connecter'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, compte.email);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        setState(() => erreursServeur = {'email': e.message});
      } else if (e.errors.isNotEmpty) {
        setState(() => erreursServeur = e.errors);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.details), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => chargement = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, String champ,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      errorText: erreursServeur[champ],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 90, color: Colors.blue),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoration('Email', Icons.email, 'email'),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Veuillez saisir votre email';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                      return 'Adresse email invalide';
                    }
                    if (v.length > 100) return '100 caractères maximum';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: masquerMotDePasse,
                  decoration: _decoration(
                    'Mot de passe',
                    Icons.lock,
                    'password',
                    suffix: IconButton(
                      icon: Icon(masquerMotDePasse
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => masquerMotDePasse = !masquerMotDePasse),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un mot de passe';
                    }
                    if (value.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmationController,
                  obscureText: masquerMotDePasse,
                  decoration: _decoration(
                      'Confirmer le mot de passe', Icons.lock_outline, '_'),
                  validator: (value) => value != passwordController.text
                      ? 'Les mots de passe ne correspondent pas'
                      : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: chargement ? null : creerCompte,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: chargement
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'CRÉER LE COMPTE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
