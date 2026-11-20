import 'package:flutter/material.dart';

import 'package:cv_flutter_constantin/pages/login_page.dart';
import 'package:cv_flutter_constantin/pages/cv_page.dart';
import 'package:cv_flutter_constantin/pages/family_page.dart';
import 'package:cv_flutter_constantin/pages/contact_page.dart';
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {

  int pageActuelle = 0;

  late final List<Widget> pages = [
    CvPage(),
    FamilyPage(),
    ContactPage(),
  ];

  final List<String> titres = [
    'Mon CV',
    'Ma famille',
    'Mes contacts',
  ];

  void changerPage(int index) {
    setState(() {
      pageActuelle = index;
    });
  }

  void seDeconnecter() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titres[pageActuelle]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: seDeconnecter,
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),

      body: IndexedStack(
        index: pageActuelle,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageActuelle,
        onTap: changerPage,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mon CV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Famille',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}
