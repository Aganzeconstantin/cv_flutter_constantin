
import 'package:flutter/material.dart';

class CvPage extends StatelessWidget {
  const CvPage({super.key});

  Widget titreSection(String titre, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icone, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget carteInformation(String titre, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // PHOTO ET IDENTITE
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.blue.shade100,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profil.jpg',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 85,
                          color: Colors.blue,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'AGANZE TENGENEZA CONSTANTIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Informaticien - Réseaux et Télécommunications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // PROFIL
          titreSection('Mon profil', Icons.person_outline),

          const Text(
            "Informaticien rigoureux et passionné, "
            "je suis discipliné, organisé et motivé. "
            "J'aime apprendre, développer des solutions "
            "informatiques et travailler en équipe. "
            "Mon objectif est de créer de la valeur "
            "grâce aux technologies.",
            style: TextStyle(fontSize: 14, height: 1.5),
          ),

          // FORMATION
          titreSection('Formation', Icons.school),

          carteInformation(
            'ISIG Goma',
            'Depuis novembre 2024\n'
            'Réseaux et Télécommunications\n'
            'Option : Systèmes informatiques',
          ),

          carteInformation(
            'Complexe scolaire Nuru d’Uvira',
            '2017 - 2023\n'
            'Diplôme d’État en Sciences (Biologie-Chimie)',
          ),

          // EXPERIENCES
          titreSection('Expériences professionnelles',
              Icons.work_outline),

          carteInformation(
            'LE BÂTISSEUR',
            'Logisticien\n'
            'Novembre 2025 - Aujourd’hui',
          ),

          carteInformation(
            'LE BÂTISSEUR',
            'Secrétaire de bureau\n'
            'Depuis juillet 2025',
          ),

          carteInformation(
            'DEVCREED ACADEMY',
            'Développeur Web et Mobile\n'
            'Depuis juillet 2025\n'
            'Projet : création du site web de l’Université '
            'Lumière de Goma.',
          ),

          carteInformation(
            'LE BÂTISSEUR',
            'Chargé de communication\n'
            'Septembre 2024 - Juillet 2025',
          ),

          // COMPETENCES
          titreSection('Compétences techniques',
              Icons.computer),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              'Programmation Web',
              'Développement Mobile',
              'Administration BD',
              'Intelligence Artificielle',
              'MS Word',
              'MS Excel',
              'PowerPoint',
              'Montage vidéo',
              'Recherche informatique',
            ].map((competence) {
              return Chip(
                label: Text(competence),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),

          // LANGUES
          titreSection('Langues', Icons.language),

          const Text(
            'Français • Anglais • Swahili • Lingala',
            style: TextStyle(fontSize: 15),
          ),

          // CENTRES D'INTERET
          titreSection('Centres d’intérêt', Icons.favorite_outline),

          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Dessin')),
              Chip(label: Text('Lecture')),
              Chip(label: Text('Basketball')),
              Chip(label: Text('Recherche')),
            ],
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              '© 2026 - Constantin Aganze',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
