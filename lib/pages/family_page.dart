import 'package:flutter/material.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';
import 'famille_membre_form_page.dart';

/// Liste des membres de famille, chargée depuis l'API (/famille-membres).
class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<FamilleMembre> membres = [];
  bool chargement = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    chargerMembres();
  }

  Future<void> chargerMembres() async {
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final liste = await ApiService.getMembres();
      if (!mounted) return;
      setState(() => membres = liste);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => erreur = e.details);
    } finally {
      if (mounted) setState(() => chargement = false);
    }
  }

  /// Ouvre le formulaire (ajout si [membre] est null, sinon modification).
  Future<void> ouvrirFormulaire([FamilleMembre? membre]) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FamilleMembreFormPage(membre: membre),
      ),
    );
    if (modifie == true) chargerMembres();
  }

  Future<void> supprimer(FamilleMembre membre) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          '${membre.nomComplet} et sa photo seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.deleteMembre(membre.id!);
      messenger.showSnackBar(
        const SnackBar(content: Text('Membre supprimé')),
      );
      chargerMembres();
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.details), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ouvrirFormulaire(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: RefreshIndicator(
        onRefresh: chargerMembres,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
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
            ..._contenu(),
          ],
        ),
      ),
    );
  }

  List<Widget> _contenu() {
    if (chargement && membres.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (erreur != null) {
      return [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              Text(erreur!, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: chargerMembres,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ];
    }

    if (membres.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              'Aucun membre pour le moment.\nAppuyez sur « Ajouter ».',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return membres.map(_carte).toList();
  }

  Widget _carte(FamilleMembre membre) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ouvrirFormulaire(membre),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.blue.shade100,
                child: ClipOval(
                  child: membre.imageUrl == null
                      ? const Icon(Icons.person, size: 45, color: Colors.blue)
                      : Image.network(
                          membre.imageUrl!,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  size: 45, color: Colors.blue),
                        ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membre.nomComplet,
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
                      'Né(e) à ${membre.lieuNaissance}, le ${_formatDate(membre.dateNaissance)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) => action == 'modifier'
                    ? ouvrirFormulaire(membre)
                    : supprimer(membre),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'modifier',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Modifier'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Supprimer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AAAA-MM-JJ -> JJ/MM/AAAA
  static String _formatDate(String date) {
    final p = date.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : date;
  }
}
