
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> ouvrirLien(
    BuildContext context,
    Uri lien,
  ) async {
    final resultat = await launchUrl(
      lien,
      mode: LaunchMode.externalApplication,
    );

    if (!resultat && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir cette application.'),
        ),
      );
    }
  }

  Widget carteContact({
    required BuildContext context,
    required IconData icone,
    required String titre,
    required String valeur,
    required Uri lien,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 13),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icone, color: Colors.blue),
        ),
        title: Text(
          titre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(valeur),
        trailing: const Icon(
          Icons.open_in_new,
          color: Colors.blue,
        ),
        onTap: () => ouvrirLien(context, lien),
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

          const Center(
            child: Icon(
              Icons.contact_mail,
              size: 85,
              color: Colors.blue,
            ),
          ),

          const Center(
            child: Text(
              'Restons en contact',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              'Vous pouvez me contacter à travers '
              'les coordonnées suivantes.',
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 25),

          carteContact(
            context: context,
            icone: Icons.phone,
            titre: 'Téléphone principal',
            valeur: '+243 855 740 110',
            lien: Uri(
              scheme: 'tel',
              path: '+243855740110',
            ),
          ),

          carteContact(
            context: context,
            icone: Icons.phone_android,
            titre: 'Téléphone secondaire',
            valeur: '+243 993 248 552',
            lien: Uri(
              scheme: 'tel',
              path: '+243993248552',
            ),
          ),

          carteContact(
            context: context,
            icone: Icons.email,
            titre: 'Adresse e-mail',
            valeur: 'aganzeconstantin@gmail.com',
            lien: Uri(
              scheme: 'mailto',
              path: 'aganzeconstantin@gmail.com',
              queryParameters: {
                'subject': 'Prise de contact',
              },
            ),
          ),

          carteContact(
            context: context,
            icone: Icons.location_on,
            titre: 'Adresse physique',
            valeur: 'Goma, Avenue Baraka, Himbi 1, N°298',
            lien: Uri.https(
              'www.google.com',
              '/maps/search/',
              {
                'api': '1',
                'query': 'Avenue Baraka, Himbi 1, Goma',
              },
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 10),

          const Text(
            'Mes réseaux professionnels',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'LinkedIn et GitHub : les liens de mes profils '
            'seront ajoutés après leur confirmation.',
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'Merci de votre visite !',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
