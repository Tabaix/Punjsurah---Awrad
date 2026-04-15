// lib/screens/reader_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../data/chapters_data.dart';
import '../utils/prefs_helper.dart';
import '../widgets/app_drawer.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final int initialPage;

  const ReaderScreen({
    super.key,
    required this.chapter,
    this.initialPage = 1,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _showControls = true;
  bool _isNightMode = false;
  double _readerBrightness = 1.0;
  bool _isCurrentPageBookmarked = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadReaderSettings();
    _checkBookmarkStatus();
  }

  Future<void> _loadReaderSettings() async {
    final brightness = await PrefsHelper.getBrightness();
    if (mounted) setState(() => _readerBrightness = brightness);
  }

  Future<void> _checkBookmarkStatus() async {
    final isFav = await PrefsHelper.isBookmarked(widget.chapter.id, _currentPage);
    if (mounted) setState(() => _isCurrentPageBookmarked = isFav);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _precachePages(int centerIndex) {
    final indices = [centerIndex, centerIndex + 1, centerIndex - 1];
    for (final i in indices) {
      if (centerIndex >= 0 && centerIndex < widget.chapter.pageCount) {
        precacheImage(AssetImage(widget.chapter.getPageAsset(i + 1)), context);
      }
    }
  }

  void _jumpToPage(int page) {
    if (page >= 1 && page <= widget.chapter.pageCount) {
      _pageController.jumpToPage(page - 1);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _toggleBookmark() async {
    await PrefsHelper.toggleBookmark(widget.chapter.id, _currentPage);
    HapticFeedback.mediumImpact();
    _checkBookmarkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(isReplacement: true),
      backgroundColor: Colors.black,
      body: Opacity(
        opacity: _readerBrightness.clamp(0.4, 1.0),
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/imgs/bg.png'), fit: BoxFit.cover),
                  color: Color(0xFF1B5E20), // Fallback
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20, left: 4, right: 4), // Reduced padding for less gap
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNightMode ? Colors.black : Colors.white,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 6), // Thick Golden outer border
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 4, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF1B5E20), width: 3), // Dark Green inner border
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: ColorFiltered(
                          colorFilter: _isNightMode 
                              ? const ColorFilter.matrix([-1,0,0,0,255, 0,-1,0,0,255, 0,0,-1,0,255, 0,0,0,1,0])
                              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                          child: PhotoViewGallery.builder(
                            scrollDirection: Axis.vertical,
                            pageController: _pageController,
                            itemCount: widget.chapter.pageCount,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index + 1);
                              _precachePages(index);
                              _checkBookmarkStatus();
                              PrefsHelper.saveLastRead(widget.chapter.id, _currentPage);
                            },
                            builder: (context, index) {
                              return PhotoViewGalleryPageOptions(
                                imageProvider: AssetImage(widget.chapter.getPageAsset(index + 1)),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 4.0,
                                initialScale: PhotoViewComputedScale.contained,
                              );
                            },
                            backgroundDecoration: BoxDecoration(color: _isNightMode ? Colors.black : Colors.white),
                            loadingBuilder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2)),
                          ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildTopBar(),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: AnimatedSlide(
        offset: _showControls ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.format_list_bulleted, color: Colors.amber),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              Expanded(child: Text(widget.chapter.titleUrdu, style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'JameelNooriNastaliq', fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              IconButton(
                icon: Icon(_isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.amber),
                onPressed: _toggleBookmark,
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
              IconButton(
                icon: Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.amber),
                onPressed: () => setState(() => _isNightMode = !_isNightMode),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String input = '';
                      return AlertDialog(
                        title: const Text('صفحہ نمبر درج کریں', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'JameelNooriNastaliq')),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          onChanged: (v) => input = v,
                          onSubmitted: (v) {
                            int? page = int.tryParse(v);
                            if (page != null && page >= 1 && page <= widget.chapter.pageCount) {
                              _jumpToPage(page);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('منسوخ', style: TextStyle(fontFamily: 'JameelNooriNastaliq', color: Colors.grey))),
                          TextButton(onPressed: () {
                            int? page = int.tryParse(input);
                            if (page != null && page >= 1 && page <= widget.chapter.pageCount) {
                              _jumpToPage(page);
                              Navigator.pop(context);
                            }
                          }, child: const Text('جائیں', style: TextStyle(fontFamily: 'JameelNooriNastaliq', color: Colors.green, fontWeight: FontWeight.bold))),
                        ],
                      );
                    }
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.shade800, borderRadius: BorderRadius.circular(12)),
                  child: Text('$_currentPage / ${widget.chapter.pageCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: AnimatedSlide(
        offset: _showControls ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.chapter.pageCount > 1)
                Slider(value: _currentPage.toDouble(), min: 1, max: widget.chapter.pageCount.toDouble(), divisions: widget.chapter.pageCount - 1, activeColor: Colors.amber, onChanged: (v) => _jumpToPage(v.round())),
            ],
          ),
        ),
      ),
    );
  }
}
