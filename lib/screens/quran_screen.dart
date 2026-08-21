// lib/screens/quran_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:audio_service/audio_service.dart';
import '../services/quran_download_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _loading = true;
  String _translationEdition = 'ur.jalandhry';
  final TextEditingController _searchController = TextEditingController();
  static const String _keyQuranCache = 'quran_list_cache';
  final Map<int, bool> _downloadStatus = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _translationEdition = prefs.getString('quran_translation') ?? 'ur.jalandhry';
    await _loadFromCache();
    await _fetchFromApi();
    _checkAllDownloads();
  }

  Future<void> _checkAllDownloads() async {
    for (var s in _allSurahs) {
      final num = s['number'] as int;
      final exists = await QuranDownloadService.isSurahDownloaded(num, _translationEdition);
      if (mounted) setState(() => _downloadStatus[num] = exists);
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_keyQuranCache);
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        setState(() {
          _allSurahs = data;
          _filteredSurahs = data;
          _loading = false;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchFromApi() async {
    try {
      final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyQuranCache, jsonEncode(data));

        if (mounted) {
          setState(() {
            _allSurahs = data;
            _filteredSurahs = _searchController.text.isEmpty 
                ? data 
                : data.where((s) => s['englishName'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) || 
                                   s['name'].toString().contains(_searchController.text)).toList();
            _loading = false;
          });
          _checkAllDownloads();
        }
      } else if (_allSurahs.isEmpty) {
        setState(() { _loading = false; });
      }
    } catch (e) {
      if (_allSurahs.isEmpty) {
        setState(() { _loading = false; });
      }
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      _filteredSurahs = _allSurahs.where((s) {
        final enName = s['englishName'].toString().toLowerCase();
        final arName = s['name'].toString();
        return enName.contains(query.toLowerCase()) || arName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1B5E20)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: const Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                          style: TextStyle(color: Colors.amber, fontSize: 14, fontFamily: 'JameelNooriNastaliq')),
                      ),
                      const SizedBox(height: 8),
                      const Text('قرآن کریم',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'JameelNooriNastaliq')),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'JameelNooriNastaliq'),
              tabs: const [
                Tab(text: 'سورت'),
                Tab(text: 'پارہ / جز'),
              ],
            ),
            title: const Text('قرآن کریم', style: TextStyle(fontFamily: 'JameelNooriNastaliq', fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_sharp, color: Colors.white),
                onPressed: () => showSearch(context: context, delegate: QuranSearchDelegate()),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSurahList(),
            _buildJuzList(),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildSurahList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'سورت تلاش کریں (Search Surah...)',
              hintStyle: const TextStyle(fontFamily: 'JameelNooriNastaliq', color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () { _searchController.clear(); _filterSurahs(''); }) 
                : null,
            ),
          ),
        ),
        Expanded(
          child: _loading && _allSurahs.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (ctx, i) {
                    final s = _filteredSurahs[i];
                    final number = s['number'];
                    final nameAr = s['name'];
                    final nameEn = s['englishName'];
                    final ayahs = s['numberOfAyahs'];
                    final isDownloaded = _downloadStatus[number] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.08)),
                      ),
                      child: ListTile(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SurahDetailScreen(surahNumber: number, surahName: nameAr, surahNameEn: nameEn))),
                        leading: Container(
                          width: 35, height: 35,
                          decoration: const BoxDecoration(color: Color(0xFFF5F0E8), shape: BoxShape.circle),
                          child: Center(child: Text('$number', style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 11))),
                        ),
                        title: Text(nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E))),
                        subtitle: Text('$ayahs آیات', style: const TextStyle(fontSize: 10, fontFamily: 'JameelNooriNastaliq')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nameAr, style: const TextStyle(fontSize: 16, color: Color(0xFF1A237E), fontFamily: 'JameelNooriNastaliq')),
                            const SizedBox(width: 8),
                            if (isDownloaded)
                              const Icon(Icons.offline_pin, color: Colors.green, size: 20)
                            else
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 30,
      itemBuilder: (ctx, i) {
        final juzNumber = i + 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.1)),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => JuzDetailScreen(juzNumber: juzNumber)));
            },
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              radius: 18,
              child: Text('$juzNumber', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            title: Text('پارہ $juzNumber', style: const TextStyle(fontFamily: 'JameelNooriNastaliq', fontSize: 18)),
            subtitle: Text('Juz $juzNumber', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class QuranSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'تلاش کریں (Search Verse...)';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null)
  );

  @override
  Widget buildResults(BuildContext context) => _performSearch();

  @override
  Widget buildSuggestions(BuildContext context) => Container(
    color: const Color(0xFFF5F0E8),
    child: const Center(
      child: Text('آیت یا لفظ تلاش کریں\n(Search any word or verse)', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontFamily: 'JameelNooriNastaliq', fontSize: 18, color: Colors.grey)),
    ),
  );

  Widget _performSearch() {
    if (query.trim().length < 3) {
      return const Center(child: Text('براہ کرم کم از کم 3 حروف لکھیں'));
    }

    return FutureBuilder(
      future: http.get(Uri.parse('https://api.alquran.cloud/v1/search/$query/all/ur.jalandhry')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('سرچ میں غلطی ہوئی'));
        }

        final res = jsonDecode(snapshot.data!.body);
        final results = res['data']['matches'] as List;

        if (results.isEmpty) {
          return const Center(child: Text('کوئی نتیجہ نہیں ملا'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) {
            final m = results[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(m['text'], textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 18)),
                subtitle: Text('سورت ${m['surah']['englishName']} | آیت ${m['numberInSurah']}', 
                  style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailScreen(
                    surahNumber: m['surah']['number'],
                    surahName: m['surah']['name'],
                    surahNameEn: m['surah']['englishName'],
                  )));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  List<dynamic> _arabic = [];
  List<dynamic> _urdu = [];
  List<dynamic> _wbw = [];
  bool _loading = true;
  bool _showUrdu = true;
  bool _showWbw = false;
  bool _isOffline = false;
  String _translationEdition = 'ur.jalandhry';
  String _reciterEdition = 'ar.alafasy';
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  bool _mushafMode = false;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadJuz();
    _listenToPlayback();
  }

  void _listenToPlayback() {
    audioHandler.playbackState.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
    audioHandler.mediaItem.listen((item) {
      if (item != null && item.album == 'Juz ${widget.juzNumber}') {
        final index = item.extras?['index'] as int?;
        if (mounted && index != null) {
          setState(() => _currentlyPlayingIndex = index);
          if (!_mushafMode) {
            _itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          }
        }
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reciterEdition = prefs.getString('quran_reciter') ?? 'ar.alafasy';
      _translationEdition = prefs.getString('quran_translation') ?? 'ur.jalandhry';
      _showWbw = prefs.getBool('quran_wbw') ?? false;
      _mushafMode = prefs.getBool('quran_mushaf_mode') ?? false;
    });
  }

  Future<void> _toggleMushafMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_mushafMode;
    await prefs.setBool('quran_mushaf_mode', newVal);
    setState(() => _mushafMode = newVal);
  }

  Future<void> _toggleWbw() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_showWbw;
    await prefs.setBool('quran_wbw', newVal);
    setState(() => _showWbw = newVal);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadJuz() async {
    try {
      final offlineData = await QuranDownloadService.getDownloadedJuz(widget.juzNumber, _translationEdition);
      if (offlineData != null) {
        setState(() {
          _arabic = offlineData['data'][0]['ayahs'];
          _urdu = offlineData['data'][1]['ayahs'];
          _wbw = offlineData['data'].length > 2 ? offlineData['data'][2]['ayahs'] : [];
          _loading = false;
          _isOffline = true;
        });
        return;
      }

      final url = 'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/editions/quran-uthmani,$_translationEdition,quran-wordbyword-2';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _arabic = data['data'][0]['ayahs'];
          _urdu = data['data'][1]['ayahs'];
          _wbw = data['data'].length > 2 ? data['data'][2]['ayahs'] : [];
          _loading = false;
          _isOffline = false;
        });
      } else {
        setState(() { _loading = false; });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _downloadEntireJuz() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پارہ ڈاؤن لوڈ ہو رہا ہے... (Downloading Juz Text)')));
    bool textSuccess = await QuranDownloadService.downloadJuzText(widget.juzNumber, _translationEdition);
    if (textSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آڈیو ڈاؤن لوڈ ہو رہی ہے... (Downloading Audio)')));
      int downloadedCount = 0;
      for (var ayah in _arabic) {
        bool audioSuccess = await QuranDownloadService.downloadAyahAudio(ayah['number'], _reciterEdition);
        if (audioSuccess) downloadedCount++;
      }
      if (mounted) setState(() => _isOffline = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ڈاؤن لوڈ مکمل! $downloadedCount آیات محفوظ کر لی گئیں')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڈاؤن لوڈ میں غلطی ہوئی')));
    }
  }

  Future<void> _playAyah(int index) async {
    try {
      final currentItem = audioHandler.mediaItem.value;
      final albumName = 'Juz ${widget.juzNumber}';
      final isSameJuz = currentItem?.album == albumName;
      final isSameAyah = currentItem?.extras?['index'] == index;

      if (isSameJuz && isSameAyah) {
        if (_isPlaying) {
          await audioHandler.pause();
        } else {
          await audioHandler.play();
        }
        return;
      }

      if (!isSameJuz) {
        await audioHandler.loadAyahs(_arabic, _reciterEdition, albumName);
      }
      
      await audioHandler.skipToQueueItem(index);
      await audioHandler.play();
    } catch (e) {
      debugPrint('Playback error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('پارہ ${widget.juzNumber} (Juz ${widget.juzNumber})', 
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontFamily: 'JameelNooriNastaliq')),
        actions: [
          if (!_isOffline)
            IconButton(icon: const Icon(Icons.download_for_offline, color: Colors.grey), onPressed: _downloadEntireJuz)
          else
            const Icon(Icons.offline_pin, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_mushafMode ? Icons.auto_stories : Icons.format_list_bulleted, color: _mushafMode ? const Color(0xFF1B5E20) : Colors.grey),
            onPressed: _toggleMushafMode,
            tooltip: 'Mushaf Mode',
          ),
          IconButton(icon: Icon(_showWbw ? Icons.grid_view : Icons.grid_off, color: _showWbw ? const Color(0xFF1B5E20) : Colors.grey), onPressed: _toggleWbw),
          IconButton(icon: Icon(_showUrdu ? Icons.subtitles : Icons.subtitles_off, color: Colors.grey), onPressed: () => setState(() => _showUrdu = !_showUrdu)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : _mushafMode ? _buildMushafView() : _buildAyahList(),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildAyahList() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _arabic.length,
      itemBuilder: (ctx, i) {
        final ayahAr = _arabic[i]['text'];
        final ayahUr = _showUrdu ? _urdu[i]['text'] : null;
        final List<dynamic> wbwWords = (_showWbw && _wbw.length > i) ? jsonDecode(_wbw[i]['text']) : [];
        final surahName = _arabic[i]['surah']['name'];
        final ayahNumInSurah = _arabic[i]['numberInSurah'];
        final isThisPlaying = _currentlyPlayingIndex == i && _isPlaying;
        final hasSajda = _arabic[i]['sajda'] != false;
        return Column(
          children: [
            if (ayahNumInSurah == 1) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(surahName, style: const TextStyle(fontSize: 24, fontFamily: 'JameelNooriNastaliq', color: Color(0xFF1B5E20))),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isThisPlaying ? const Color(0xFF1B5E20).withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isThisPlaying ? Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.3)) : null,
                boxShadow: isThisPlaying ? [
                  BoxShadow(color: const Color(0xFF1B5E20).withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
                ] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(4)),
                        child: Text('$ayahNumInSurah', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                      if (hasSajda) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                          child: const Text('سجدہ (Sajda)', style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold, fontFamily: 'JameelNooriNastaliq')),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: Icon(isThisPlaying ? Icons.pause : Icons.play_arrow, color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.grey, size: 20),
                        onPressed: () => _playAyah(i),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_showWbw && wbwWords.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.end,
                      runSpacing: 10,
                      spacing: 10,
                      textDirection: TextDirection.rtl,
                      children: wbwWords.map((w) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(w['word_arabic'] ?? '', style: const TextStyle(fontSize: 22, color: Colors.black87, fontFamily: '')),
                          Text(w['word_urdu'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontFamily: 'JameelNooriNastaliq')),
                        ],
                      )).toList(),
                    )
                  else
                    Text(ayahAr, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28, 
                        height: 2.2, 
                        color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.black87,
                        fontFamily: '',
                      )),
                  if (ayahUr != null) ...[
                    const SizedBox(height: 12),
                    Text(ayahUr, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16, fontFamily: 'JameelNooriNastaliq', color: Colors.black54, height: 1.8)),
                  ],
                  const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMushafView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectionArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 10,
          textDirection: TextDirection.rtl,
          children: List.generate(_arabic.length, (i) {
            final ayah = _arabic[i];
            final isThisPlaying = _currentlyPlayingIndex == i && _isPlaying;
            final ayahNumInSurah = ayah['numberInSurah'];
            
            return GestureDetector(
              onTap: () => _playAyah(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isThisPlaying ? const Color(0xFF1B5E20).withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${ayah['text']} ',
                        style: TextStyle(
                          fontSize: 26,
                          height: 2.2,
                          color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.black87,
                          fontFamily: '',
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Center(child: Text('$ayahNumInSurah', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahNameEn;

  const SurahDetailScreen({super.key, required this.surahNumber, required this.surahName, required this.surahNameEn});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<dynamic> _arabic = [];
  List<dynamic> _urdu = [];
  List<dynamic> _wbw = [];
  bool _loading = true;
  bool _showUrdu = true;
  bool _showWbw = false;
  bool _isOffline = false;
  String _translationEdition = 'ur.jalandhry';
  String _reciterEdition = 'ar.alafasy';
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  bool _mushafMode = false;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  final Map<String, String> _reciters = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.abdulsamad': 'Abdul Basit (Murattal)',
    'ar.sudais': 'Abdurrahman As-Sudais',
    'ar.minshawi': 'Minshawi (Murattal)',
    'ar.husary': 'Mahmoud Khalil Al-Husary',
  };

  final Map<String, String> _translations = {
    'ur.jalandhry': 'Urdu - Fateh Muhammad Jalandhry',
    'ur.kanzuliman': 'Urdu - Ahmed Raza Khan (Kanzul Iman)',
    'en.sahih': 'English - Sahih International',
    'en.pickthall': 'English - Marmaduke Pickthall',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSurah();
    _listenToPlayback();
  }

  void _listenToPlayback() {
    audioHandler.playbackState.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
    audioHandler.mediaItem.listen((item) {
      if (item != null && item.album == widget.surahNameEn) {
        final index = item.extras?['index'] as int?;
        if (mounted && index != null) {
          setState(() => _currentlyPlayingIndex = index);
          if (!_mushafMode) {
            _itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          }
        }
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reciterEdition = prefs.getString('quran_reciter') ?? 'ar.alafasy';
      _translationEdition = prefs.getString('quran_translation') ?? 'ur.jalandhry';
      _showWbw = prefs.getBool('quran_wbw') ?? false;
      _mushafMode = prefs.getBool('quran_mushaf_mode') ?? false;
    });
  }

  Future<void> _toggleMushafMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_mushafMode;
    await prefs.setBool('quran_mushaf_mode', newVal);
    setState(() => _mushafMode = newVal);
  }

  Future<void> _toggleWbw() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_showWbw;
    await prefs.setBool('quran_wbw', newVal);
    setState(() => _showWbw = newVal);
  }

  Future<void> _saveReciter(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_reciter', id);
    setState(() => _reciterEdition = id);
  }

  Future<void> _saveTranslation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_translation', id);
    setState(() {
      _translationEdition = id;
      _loading = true;
    });
    _loadSurah();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSurah() async {
    try {
      final offlineData = await QuranDownloadService.getDownloadedSurah(widget.surahNumber, _translationEdition);
      if (offlineData != null) {
        setState(() {
          _arabic = offlineData['data'][0]['ayahs'];
          _urdu = offlineData['data'][1]['ayahs'];
          _wbw = offlineData['data'].length > 2 ? offlineData['data'][2]['ayahs'] : [];
          _loading = false;
          _isOffline = true;
        });
        return;
      }
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,$_translationEdition,quran-wordbyword-2';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _arabic = data['data'][0]['ayahs'];
          _urdu = data['data'][1]['ayahs'];
          _wbw = data['data'].length > 2 ? data['data'][2]['ayahs'] : [];
          _loading = false;
          _isOffline = false;
        });
      } else {
        setState(() { _loading = false; });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _downloadEntireSurah() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڈاؤن لوڈ شروع ہو رہا ہے... (Downloading Text)')));
    bool textSuccess = await QuranDownloadService.downloadSurahText(widget.surahNumber, _translationEdition);
    if (textSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آڈیو ڈاؤن لوڈ ہو رہی ہے... (Downloading Audio)')));
      int downloadedCount = 0;
      for (var ayah in _arabic) {
        bool audioSuccess = await QuranDownloadService.downloadAyahAudio(ayah['number'], _reciterEdition);
        if (audioSuccess) downloadedCount++;
      }
      if (mounted) setState(() => _isOffline = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ڈاؤن لوڈ مکمل! $downloadedCount آیات محفوظ کر لی گئیں')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڈاؤن لوڈ میں غلطی ہوئی')));
    }
  }

  Future<void> _playAyah(int index) async {
    try {
      final currentItem = audioHandler.mediaItem.value;
      final isSameSurah = currentItem?.album == widget.surahNameEn;
      final isSameAyah = currentItem?.extras?['index'] == index;

      if (isSameSurah && isSameAyah) {
        if (_isPlaying) {
          await audioHandler.pause();
        } else {
          await audioHandler.play();
        }
        return;
      }

      if (!isSameSurah) {
        await audioHandler.loadAyahs(_arabic, _reciterEdition, widget.surahNameEn);
      }
      
      await audioHandler.skipToQueueItem(index);
      await audioHandler.play();
    } catch (e) {
      debugPrint('Playback error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surahNameEn, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.surahName, style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 12, fontFamily: 'JameelNooriNastaliq')),
          ],
        ),
        actions: [
          if (!_isOffline)
            IconButton(icon: const Icon(Icons.download_for_offline, color: Colors.grey), onPressed: _downloadEntireSurah)
          else
            const Icon(Icons.offline_pin, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_mushafMode ? Icons.auto_stories : Icons.format_list_bulleted, color: _mushafMode ? const Color(0xFF2CA4AB) : Colors.grey),
            onPressed: _toggleMushafMode,
            tooltip: 'Mushaf Mode',
          ),
          IconButton(icon: Icon(_showWbw ? Icons.grid_view : Icons.grid_off, color: _showWbw ? const Color(0xFF2CA4AB) : Colors.grey), onPressed: _toggleWbw),
          IconButton(icon: const Icon(Icons.translate, color: Colors.grey), onPressed: _showTranslationSelection),
          IconButton(icon: const Icon(Icons.record_voice_over, color: Colors.grey), onPressed: _showReciterSelection),
          IconButton(icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: const Color(0xFF2CA4AB), size: 30), onPressed: () => _playAyah(_currentlyPlayingIndex ?? 0)),
          IconButton(icon: Icon(_showUrdu ? Icons.subtitles : Icons.subtitles_off, color: Colors.grey), onPressed: () => setState(() => _showUrdu = !_showUrdu)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2CA4AB)))
          : _mushafMode ? _buildMushafView() : _buildAyahList(),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildAyahList() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _arabic.length,
      itemBuilder: (ctx, i) {
        final ayahAr = _arabic[i]['text'];
        final ayahUr = _showUrdu ? _urdu[i]['text'] : null;
        final List<dynamic> wbwWords = (_showWbw && _wbw.length > i) ? jsonDecode(_wbw[i]['text']) : [];
        final isThisPlaying = _currentlyPlayingIndex == i && _isPlaying;
        final hasSajda = _arabic[i]['sajda'] != false;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isThisPlaying ? const Color(0xFF2CA4AB).withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isThisPlaying ? Border.all(color: const Color(0xFF2CA4AB).withValues(alpha: 0.3)) : null,
            boxShadow: isThisPlaying ? [
              BoxShadow(color: const Color(0xFF2CA4AB).withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(4)),
                    child: Text('${widget.surahNumber}:${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                  if (hasSajda) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                      child: const Text('سجدہ (Sajda)', style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold, fontFamily: 'JameelNooriNastaliq')),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: Icon(isThisPlaying ? Icons.pause : Icons.play_arrow, color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.grey, size: 20),
                    onPressed: () => _playAyah(i),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_showWbw && wbwWords.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.end,
                  runSpacing: 10,
                  spacing: 10,
                  textDirection: TextDirection.rtl,
                  children: wbwWords.map((w) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(w['word_arabic'] ?? '', style: const TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w500, fontFamily: '')),
                      Text(w['word_urdu'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontFamily: 'JameelNooriNastaliq')),
                    ],
                  )).toList(),
                )
              else
                Text(ayahAr, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 28, 
                    height: 2.2, 
                    color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.black87, 
                    fontWeight: FontWeight.w500,
                    fontFamily: '',
                  )),
              if (ayahUr != null) ...[
                const SizedBox(height: 12),
                Text(ayahUr, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontFamily: 'JameelNooriNastaliq', color: Colors.black54, height: 1.8)),
              ],
              const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMushafView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectionArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 10,
          textDirection: TextDirection.rtl,
          children: List.generate(_arabic.length, (i) {
            final ayah = _arabic[i];
            final isThisPlaying = _currentlyPlayingIndex == i && _isPlaying;
            
            return GestureDetector(
              onTap: () => _playAyah(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isThisPlaying ? const Color(0xFF2CA4AB).withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${ayah['text']} ',
                        style: TextStyle(
                          fontSize: 26,
                          height: 2.2,
                          color: isThisPlaying ? const Color(0xFF2CA4AB) : Colors.black87,
                          fontFamily: '',
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showTranslationSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ترجمہ منتخب کریں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'JameelNooriNastaliq')),
              const Divider(),
              ..._translations.entries.map((e) => RadioListTile<String>(
                title: Text(e.value),
                value: e.key,
                groupValue: _translationEdition,
                onChanged: (val) { if (val != null) { _saveTranslation(val); Navigator.pop(context); } },
                activeColor: const Color(0xFF2CA4AB),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showReciterSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('قاری منتخب کریں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'JameelNooriNastaliq')),
              const Divider(),
              ..._reciters.entries.map((e) => RadioListTile<String>(
                title: Text(e.value),
                value: e.key,
                groupValue: _reciterEdition,
                onChanged: (val) { if (val != null) { _saveReciter(val); Navigator.pop(context); if (_isPlaying) _playAyah(_currentlyPlayingIndex ?? 0); } },
                activeColor: const Color(0xFF2CA4AB),
              )),
            ],
          ),
        );
      },
    );
  }
}
