// lib/screens/quran_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../services/quran_download_service.dart';
import '../widgets/banner_ad_widget.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  static const String _keyQuranCache = 'quran_list_cache';
  Map<int, bool> _downloadStatus = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadFromCache();
    await _fetchFromApi();
    _checkAllDownloads();
  }

  Future<void> _checkAllDownloads() async {
    for (var s in _allSurahs) {
      final num = s['number'] as int;
      final exists = await QuranDownloadService.isSurahDownloaded(num);
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
            _error = null;
          });
          _checkAllDownloads();
        }
      } else if (_allSurahs.isEmpty) {
        setState(() { _error = 'سرور سے جواب نہیں ملا'; _loading = false; });
      }
    } catch (e) {
      if (_allSurahs.isEmpty) {
        setState(() { _error = 'انٹرنیٹ کنکشن چیک کریں'; _loading = false; });
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
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
                      const Text('Holy Quran — 114 Surahs',
                        style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('قرآن کریم', style: TextStyle(fontFamily: 'JameelNooriNastaliq', fontSize: 20)),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          ),

          if (_loading && _allSurahs.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))))
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
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
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                                tooltip: 'ڈاؤن لوڈ ختم کریں (Delete)',
                                onPressed: () async {
                                  await QuranDownloadService.deleteSurah(number);
                                  setState(() => _downloadStatus[number] = false);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڈاؤن لوڈ ختم کر دیا گیا (Deleted)')));
                                },
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.download_for_offline_outlined, color: Colors.grey, size: 20),
                                tooltip: 'آف لائن کے لیے ڈاؤن لوڈ کریں',
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$nameEn ڈاؤن لوڈ ہو رہا ہے...')));
                                  final success = await QuranDownloadService.downloadSurah(number);
                                  if (success) {
                                    setState(() => _downloadStatus[number] = true);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$nameEn ڈاؤن لوڈ مکمل ہو گیا!')));
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _filteredSurahs.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
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
  bool _loading = true;
  String? _error;
  bool _showUrdu = true;
  bool _isOffline = false;
  String _translationEdition = 'ur.jalandhry'; // Default to Urdu
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSurah() async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,$_translationEdition';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _arabic = data['data'][0]['ayahs'];
          _urdu = data['data'][1]['ayahs'];
          _loading = false;
        });
      } else {
        setState(() { _error = 'سرور سے جواب نہیں ملا'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'انٹرنیٹ کنکشن چیک کریں'; _loading = false; });
    }
  }

  Future<void> _playAyah(int index) async {
    try {
      if (_currentlyPlayingIndex == index && _isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
        return;
      }

      final ayahNumber = _arabic[index]['number'];
      final audioUrl = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3';
      
      await _audioPlayer.setUrl(audioUrl);
      setState(() {
        _currentlyPlayingIndex = index;
        _isPlaying = true;
      });
      
      _audioPlayer.play();
      
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آڈیو لوڈ کرنے میں غلطی ہوئی')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Text(widget.surahName, style: const TextStyle(fontFamily: 'JameelNooriNastaliq')),
        actions: [
          if (_isOffline) const Icon(Icons.offline_pin, color: Colors.greenAccent, size: 18),
          IconButton(
            icon: Icon(_showUrdu ? Icons.translate : Icons.translate_outlined),
            onPressed: () => setState(() => _showUrdu = !_showUrdu),
            tooltip: 'ترجمہ دکھائیں/چھپائیں',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _arabic.length,
              itemBuilder: (ctx, i) {
                final ayahAr = _arabic[i]['text'];
                final ayahUr = _showUrdu ? _urdu[i]['text'] : null;
                final isThisPlaying = _currentlyPlayingIndex == i && _isPlaying;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(14),
                    border: isThisPlaying ? Border.all(color: Colors.amber, width: 2) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: const Color(0xFF1A237E)),
                            onPressed: () => _playAyah(i),
                          ),
                          Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                      Text(ayahAr, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, height: 2.0)),
                      if (ayahUr != null) ...[
                        const Divider(),
                        Text(ayahUr, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontFamily: 'JameelNooriNastaliq', color: Colors.black87)),
                      ],
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
