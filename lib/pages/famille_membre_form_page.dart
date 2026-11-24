import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';

/// Formulaire d'ajout (membre == null) ou de modification d'un membre.
/// Renvoie true à la page précédente si une modification a été enregistrée.
class FamilleMembreFormPage extends StatefulWidget {
  final FamilleMembre? membre;

  const FamilleMembreFormPage({super.key, this.membre});

  @override
  State<FamilleMembreFormPage> createState() => _FamilleMembreFormPageState();
}

class _FamilleMembreFormPageState extends State<FamilleMembreFormPage> {
  static const _maxImageOctets = 2 * 1024 * 1024; // 2 Mo (limite de l'API)

  final _formKey = GlobalKey<FormState>();
  late final nomController = TextEditingController(text: widget.membre?.nom);
  late final postnomController =
      TextEditingController(text: widget.membre?.postnom);
  late final prenomController =
      TextEditingController(text: widget.membre?.prenom);
  late final lieuController =
      TextEditingController(text: widget.membre?.lieuNaissance);
  late final dateController =
      TextEditingController(text: widget.membre?.dateNaissance);
  late final parenteController =
      TextEditingController(text: widget.membre?.parente);

  XFile? nouvelleImage;
  Uint8List? apercuImage;
  bool chargement = false;
  Map<String, String> erreursServeur = {};

  bool get estModification => widget.membre != null;

  @override
  void dispose() {
    for (final c in [
      nomController,
      postnomController,
      prenomController,
      lieuController,
      dateController,
      parenteController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> choisirImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image == null) return;
    final octets = await image.readAsBytes();
    if (!mounted) return;
    if (octets.length > _maxImageOctets) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'image ne doit pas dépasser 2 Mo"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      nouvelleImage = image;
      apercuImage = octets;
      erreursServeur.remove('image');
    });
  }

  Future<void> choisirDate() async {
    final initiale = DateTime.tryParse(dateController.text) ?? DateTime(1990);
    final date = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );
    if (date != null) {
      dateController.text = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> enregistrer() async {
    setState(() => erreursServeur = {});
    if (!_formKey.currentState!.validate()) return;

    final membre = FamilleMembre(
      nom: nomController.text.trim(),
      postnom: postnomController.text.trim(),
      prenom: prenomController.text.trim(),
      lieuNaissance: lieuController.text.trim(),
      dateNaissance: dateController.text.trim(),
      parente: parenteController.text.trim(),
    );

    setState(() => chargement = true);
    try {
      if (estModification) {
        await ApiService.updateMembre(widget.membre!.id!, membre,
            image: nouvelleImage);
      } else {
        await ApiService.createMembre(membre, image: nouvelleImage);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estModification ? 'Membre modifié' : 'Membre ajouté'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => erreursServeur = e.errors);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.details), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(estModification ? 'Modifier le membre' : 'Nouveau membre'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _photo(),
            const SizedBox(height: 25),
            _champ(nomController, 'Nom', 'nom', 50, Icons.badge),
            _champ(postnomController, 'Postnom', 'postnom', 50, Icons.badge),
            _champ(prenomController, 'Prénom', 'prenom', 50, Icons.person),
            _champ(parenteController, 'Lien de parenté (ex. Père, Mère)',
                'parente', 50, Icons.family_restroom),
            _champ(lieuController, 'Lieu de naissance', 'lieu_naissance', 100,
                Icons.place),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: choisirDate,
                decoration: _decoration(
                    'Date de naissance', 'date_naissance', Icons.cake),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Le champ date de naissance est obligatoire'
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: chargement ? null : enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: chargement
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text(
                  'ENREGISTRER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo() {
    final imageUrl = widget.membre?.imageUrl;
    Widget contenu;
    if (apercuImage != null) {
      contenu = Image.memory(apercuImage!,
          width: 120, height: 120, fit: BoxFit.cover);
    } else if (imageUrl != null) {
      contenu = Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, size: 70, color: Colors.blue),
      );
    } else {
      contenu = const Icon(Icons.person, size: 70, color: Colors.blue);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue.shade100,
          child: ClipOval(child: contenu),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => choisirImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
            ),
            OutlinedButton.icon(
              onPressed: () => choisirImage(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Appareil photo'),
            ),
          ],
        ),
        if (erreursServeur['image'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              erreursServeur['image']!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const Text(
          'Photo facultative : jpg, png, gif ou webp, 2 Mo max',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label, String champ, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      errorText: erreursServeur[champ],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _champ(
    TextEditingController controller,
    String label,
    String champ,
    int max,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLength: max,
        decoration: _decoration(label, champ, icon).copyWith(counterText: ''),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Le champ ${label.split(' (').first.toLowerCase()} est obligatoire';
          }
          return null;
        },
      ),
    );
  }
}
