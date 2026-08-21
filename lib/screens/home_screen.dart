// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/chapters_data.dart';
import '../widgets/chapter_card.dart';
import '../widgets/app_drawer.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';
import 'tasbeeh_screen.dart';
import 'quran_screen.dart';
import '../utils/prefs_helper.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Chapter? _lastChapter;
  int _lastPage = 1;
  List<Map<String, dynamic>> _bookmarks = [];
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final chapterId = prefs.getString('last_chapter_id');
    final page = prefs.getInt('last_page') ?? 1;
    final marks = await PrefsHelper.getBookmarks();

    if (mounted) {
      setState(() {
        _bookmarks = marks;
        if (chapterId != null) {
          final all = [...panjsurahChapters, ...awradChapters];
          _lastChapter = all.firstWhere((c) => c.id == chapterId, orElse: () => all.first);
          _lastPage = page;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bring Full Book Mode to the absolute top of the screen!
    final allChapters = [
      awradChapters.first, // The full book mode
      ...panjsurahChapters,
      ...awradChapters.skip(1),
    ];
    final filteredAll = _filterList(allChapters);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        SystemNavigator.pop(); // Completely and instantly exit the app
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: const Color(0xFFF5F0E8),
        floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E20),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehScreen())),
        child: const Icon(Icons.fingerprint, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _lastChapter != null ? 220 : 160,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            title: _isSearching 
              ? TextField(controller: _searchController, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'تلاش کریں...', border: InputBorder.none), onChanged: (v) => setState(() => _searchQuery = v))
              : const Text('پنجسورہ و اوراد', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'JameelNooriNastaliq', fontSize: 24)),
            actions: [
              IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search), onPressed: () => setState(() { _isSearching = !_isSearching; _searchQuery = ""; })),
              IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A237E), Color(0xFF1B5E20)])),
                child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ', style: TextStyle(color: Colors.amber, fontSize: 16)),
                  if (_lastChapter != null && !_isSearching) ...[const SizedBox(height: 15), _buildContinueCard()],
                ])),
              ),
            ),
          ),

          // ── Bookmarks Section ──────────────────────────────────────────────
          if (_bookmarks.isNotEmpty && !_isSearching) ...[
            _buildSectionHeader('پسندیدہ صفحات', Colors.orange.shade800),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _bookmarks.length,
                  itemBuilder: (ctx, i) {
                    final item = _bookmarks[i];
                    final all = [...panjsurahChapters, ...awradChapters];
                    final chapter = all.firstWhere((c) => c.id == item['chapterId'], orElse: () => all.first);
                    return _buildBookmarkTile(chapter, item['page']);
                  },
                ),
              ),
            ),
          ],

          // ── Quran Banner ─────────────────────────────────────────────────────
          if (!_isSearching)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Center(child: Text('📖', style: TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('قرآن کریم', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'JameelNooriNastaliq')),
                            Text('مکمل قرآن کریم با اردو ترجمہ', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'JameelNooriNastaliq')),
                            SizedBox(height: 4),
                            Text('Full Quran — 114 Surahs with Urdu Translation', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ),

          if (filteredAll.isNotEmpty) ...[
            _buildSectionHeader('فہرست', const Color(0xFF1B5E20)),
            _buildGrid(filteredAll, const Color(0xFF1B5E20)),
          ],

          if (filteredAll.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('کوئی نتیجہ نہیں ملا'))),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    ));
  }

  Widget _buildBookmarkTile(Chapter chapter, int page) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(chapter: chapter, initialPage: page)));
        _loadData();
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(chapter.titleUrdu, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('صفحہ $page', style: TextStyle(fontSize: 10, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
          const Spacer(),
          Container(height: 1, color: color.withValues(alpha: 0.2), width: 100),
        ]),
      ),
    );
  }

  Widget _buildGrid(List<Chapter> chapters, Color color) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 8, 
          mainAxisSpacing: 8, 
          childAspectRatio: 0.85
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => ChapterCard(chapter: chapters[i], accentColor: color), 
          childCount: chapters.length
        ),
      ),
    );
  }

  List<Chapter> _filterList(List<Chapter> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((c) => c.titleUrdu.contains(_searchQuery) || c.titleEnglish.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Widget _buildContinueCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(chapter: _lastChapter!, initialPage: _lastPage)));
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        child: Row(children: [
          const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.play_arrow, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('مطالعہ جاری رکھیں', style: TextStyle(color: Colors.white70, fontSize: 11)),
            Text(_lastChapter!.titleUrdu, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ])),
          Text('صفحہ $_lastPage', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
