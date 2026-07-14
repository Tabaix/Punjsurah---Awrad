import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/chapters_data.dart';
import '../screens/reader_screen.dart';
import '../screens/quran_screen.dart';

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
                  // Quran Link
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen()));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: Colors.amber, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('قرآن کریم', style: TextStyle(color: Colors.white, fontFamily: 'JameelNooriNastaliq', fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Text('114 سورتیں', style: TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'JameelNooriNastaliq')),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16, thickness: 1, color: Colors.black12),
                  _buildSectionTitle('پنجسورہ شریف'),
                  ...panjSurah.map((chapter) => _buildDrawerItem(context, chapter)),
                  const Divider(height: 24, thickness: 1, color: Colors.black12),
                  _buildSectionTitle('مجموعہ اوراد و وظائف'),
                  ...awrad.map((chapter) => _buildDrawerItem(context, chapter)),
                  
                  const Divider(height: 32, thickness: 1, color: Colors.black12),
                  _buildSectionTitle('رابطہ اور فیڈ بیک'),
                  _buildSupportItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'واٹس ایپ پر رابطہ کریں',
                    subtitle: 'WhatsApp: +966 5585 343269',
                    color: const Color(0xFF25D366),
                    onTap: () => _launchURL('https://wa.me/9665585343269'),
                  ),
                  _buildSupportItem(
                    icon: Icons.email_outlined,
                    title: 'ای میل کریں',
                    subtitle: 'tayyabraza786mughal@gmail.com',
                    color: const Color(0xFFD44638),
                    onTap: () => _launchURL('mailto:tayyabraza786mughal@gmail.com?subject=Panjsurah App Feedback'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Could show a snackbar here if it fails
    }
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontFamily: 'JameelNooriNastaliq', fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      onTap: onTap,
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
