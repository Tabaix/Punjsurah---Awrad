// lib/screens/settings_screen.dart
// App settings: reader brightness/font-scale, keep-screen-on, RTL toggle.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../utils/prefs_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _brightness   = 1.0;
  double _fontScale    = 1.0;
  bool   _keepScreenOn = true;
  bool   _rtlLayout    = true;
  bool   _horizontalNav = true;
  bool   _loading      = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final brightness   = await PrefsHelper.getBrightness();
    final fontScale    = await PrefsHelper.getFontScale();
    final keepScreenOn = await PrefsHelper.getKeepScreenOn();
    final rtl          = await PrefsHelper.getRtlLayout();
    final horizontal   = await PrefsHelper.getHorizontalNav();
    if (!mounted) return;
    setState(() {
      _brightness   = brightness;
      _fontScale    = fontScale;
      _keepScreenOn = keepScreenOn;
      _rtlLayout    = rtl;
      _horizontalNav = horizontal;
      _loading      = false;
    });
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get _fontScaleLabel {
    if (_fontScale <= 0.9) return 'چھوٹا';      // Small
    if (_fontScale <= 1.1) return 'درمیانہ';   // Medium
    if (_fontScale <= 1.3) return 'بڑا';        // Large
    return 'بہت بڑا';                           // Very Large
  }

  // ─── Widget ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text(
          'ترتیبات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                // ── Reader section ──────────────────────────────────────────
                _sectionHeader('ریڈر ترتیبات', Icons.menu_book),
                const SizedBox(height: 8),

                _card(children: [
                  // Brightness
                  _rowLabel(
                    icon: Icons.brightness_6,
                    label: 'روشنی',
                    trailing: Text(
                      '${(_brightness * 100).round()}%',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Slider(
                    value: _brightness,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (v) {
                      setState(() => _brightness = v);
                      PrefsHelper.setBrightness(v);
                    },
                  ),

                  const Divider(),

                  // Font scale
                  _rowLabel(
                    icon: Icons.text_fields,
                    label: 'فونٹ سائز',
                    trailing: Text(
                      _fontScaleLabel,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (v) {
                      setState(() => _fontScale = v);
                      PrefsHelper.setFontScale(v);
                    },
                  ),
                ]),

                const SizedBox(height: 16),

                // ── Display section ─────────────────────────────────────────
                _sectionHeader('ڈسپلے', Icons.phone_android),
                const SizedBox(height: 8),

                _card(children: [
                  SwitchListTile.adaptive(
                    value: _keepScreenOn,
                    activeTrackColor: const Color(0xFF2E7D32),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('اسکرین آن رکھیں'),
                    subtitle:
                        const Text('پڑھتے وقت اسکرین بند نہ ہو'),
                    secondary: const Icon(Icons.screen_lock_portrait,
                        color: Color(0xFF2E7D32)),
                    onChanged: (v) {
                      setState(() => _keepScreenOn = v);
                      PrefsHelper.setKeepScreenOn(v);
                    },
                  ),

                  const Divider(),

                  SwitchListTile.adaptive(
                    value: _rtlLayout,
                    activeTrackColor: const Color(0xFF2E7D32),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('دائیں سے بائیں (RTL)'),
                    subtitle: const Text('صفحات کی سمت'),
                    secondary: const Icon(Icons.format_textdirection_r_to_l,
                        color: Color(0xFF2E7D32)),
                    onChanged: (v) {
                      setState(() => _rtlLayout = v);
                      PrefsHelper.setRtlLayout(v);
                    },
                  ),

                  const Divider(),

                  SwitchListTile.adaptive(
                    value: _horizontalNav,
                    activeTrackColor: const Color(0xFF2E7D32),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('افقی نیویگیشن (Horizontal)'),
                    subtitle: const Text('صفحات کو بائیں/دائیں سوائپ کریں'),
                    secondary: const Icon(Icons.swap_horiz,
                        color: Color(0xFF2E7D32)),
                    onChanged: (v) {
                      setState(() => _horizontalNav = v);
                      PrefsHelper.setHorizontalNav(v);
                    },
                  ),
                ]),

                const SizedBox(height: 16),

                // ── About section ───────────────────────────────────────────
                _sectionHeader('ایپ کے بارے میں', Icons.info_outline),
                const SizedBox(height: 8),

                _card(children: [
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.verified_user, color: Color(0xFF1B5E20)),
                    title: Text('پنج سورہ اور مجموعہ وظائف'),
                    subtitle: Text('ورژن 1.0.0 (Global Edition)'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.favorite, color: Colors.red),
                    title: Text('Developed with ❤'),
                    subtitle: Text('Tayyab Ali (tabaix.com)'),
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () {
                      Share.share(
                        'ڈاؤن لوڈ کریں "پنج سورہ اور مجموعہ وظائف" ایپ:\nhttps://play.google.com/store/apps/details?id=com.panjsurah.awrad',
                        subject: 'مجموعہ وظائف ایپ',
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: const Icon(Icons.share, color: Color(0xFF1B5E20)),
                    title: const Text('دوستوں کے ساتھ شیئر کریں'),
                    subtitle: const Text('صدقہ جاریہ میں حصہ لیں'),
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () async {
                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: const Icon(Icons.star_rate, color: Colors.amber),
                    title: const Text('ایپ کی درجہ بندی کریں'),
                    subtitle: const Text('ہمیں پلے اسٹور پر اپنی رائے دیں'),
                  ),
                ]),

                const SizedBox(height: 32),

                // Reset button
                OutlinedButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.restore, color: Colors.red),
                  label: const Text(
                    'آخری مطالعہ صاف کریں',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  // ─── Helper builders ────────────────────────────────────────────────────────

  Widget _sectionHeader(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _rowLabel({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('آخری مطالعہ صاف کریں'),
        content: const Text(
            'کیا آپ واقعی آخری مطالعہ کا ریکارڈ حذف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('نہیں'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('ہاں'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await PrefsHelper.clearLastRead();
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('آخری مطالعہ صاف ہو گیا'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
