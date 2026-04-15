import 'package:flutter/material.dart';
import '../data/chapters_data.dart';
import '../screens/reader_screen.dart';

class AppDrawer extends StatelessWidget {
  final bool isReplacement;

  const AppDrawer({super.key, this.isReplacement = false});

  @override
  Widget build(BuildContext context) {
    final panjSurah = panjsurahChapters;
    final awrad = awradChapters; // This includes "Full Book" at the top

    return Drawer(
      backgroundColor: const Color(0xFFF5F0E8),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.menu_book, color: Colors.amber, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'فہرست ابواب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JameelNooriNastaliq',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Panjsurah & Awrad',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionTitle('پنجسورہ شریف'),
                  ...panjSurah.map((chapter) => _buildDrawerItem(context, chapter)),
                  const Divider(height: 24, thickness: 1, color: Colors.black12),
                  _buildSectionTitle('مجموعہ اوراد و وظائف'),
                  ...awrad.map((chapter) => _buildDrawerItem(context, chapter)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'JameelNooriNastaliq',
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, Chapter chapter) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      visualDensity: VisualDensity.compact,
      trailing: const Icon(Icons.chevron_left, size: 20, color: Colors.black26),
      title: Text(
        chapter.titleUrdu,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'JameelNooriNastaliq',
        ),
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text(
        chapter.titleEnglish,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        textAlign: TextAlign.right,
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        
        if (isReplacement) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderScreen(chapter: chapter),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderScreen(chapter: chapter),
            ),
          );
        }
      },
    );
  }
}
