
import 'package:flutter/material.dart';

class FamilyMember {
  final String nom;
  final String parente;
  final String profession;
  final String photo;

  const FamilyMember({
    required this.nom,
    required this.parente,
    required this.profession,
    required this.photo,
  });
}

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  static const List<FamilyMember> membres = [
    FamilyMember(
      nom: 'Joseph Tengeneza',
      parente: 'Mon père',
      profession: 'Agent de l’État à l’INPP',
      photo: 'assets/images/pere.jpg',
    ),

    FamilyMember(
      nom: 'Denise Mugangu',
      parente: 'Ma mère',
      profession: 'Agent de l’État à la SONAS',
      photo: 'assets/images/mere.jpg',
    ),

    FamilyMember(
      nom: 'Ampire Tengeneza',
      parente: 'Mon grand frère',
      profession: 'Ingénieur agronome',
      photo: 'assets/images/grand_frere.jpg',
    ),

    FamilyMember(
      nom: 'Ansima Tengeneza',
      parente: 'Ma sœur',
      profession: 'Pharmacologue et couturière',
      photo: 'assets/images/soeur.jpg',
    ),

    FamilyMember(
      nom: 'Isaac Tengeneza',
      parente: 'Mon frère',
      profession: 'Étudiant en microfinance',
      photo: 'assets/images/frere.jpg',
    ),

    FamilyMember(
      nom: 'Constantin Aganze',
      parente: 'Moi-même',
      profession: 'Étudiant en réseaux et télécommunications',
      photo: 'assets/images/profil.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [

        const Text(
          'Ma famille',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Découvrez les personnes qui composent ma famille.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 15),

        ...membres.map((membre) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.blue.shade100,
                    child: ClipOval(
                      child: Image.asset(
                        membre.photo,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          membre.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          membre.parente,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          membre.profession,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}