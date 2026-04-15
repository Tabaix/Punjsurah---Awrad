// lib/screens/tasbeeh_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _counter = 0;
  int _target = 33;
  final List<int> _targets = [33, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('tasbeeh_count') ?? 0;
      _target = prefs.getInt('tasbeeh_target') ?? 33;
    });
  }

  Future<void> _incrementCounter() async {
    HapticFeedback.lightImpact();
    setState(() {
      _counter++;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_count', _counter);
    
    if (_counter == _target) {
      HapticFeedback.vibrate();
      _showTargetReached();
    }
  }

  Future<void> _resetCounter() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ری سیٹ کریں؟', textDirection: TextDirection.rtl),
        content: const Text('کیا آپ تسبیح کو شروع سے شروع کرنا چاہتے ہیں؟', textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('نہیں')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ہاں')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _counter = 0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbeeh_count', 0);
    }
  }

  void _showTargetReached() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('هدف ($_target) مکمل ہو گیا!', textDirection: TextDirection.rtl),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text('ڈیجیٹل تسبیح', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Target selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _targets.map((t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('$t'),
                  selected: _target == t,
                  onSelected: (selected) async {
                    if (selected) {
                      setState(() => _target = t);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('tasbeeh_target', t);
                    }
                  },
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Counter Display
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                ],
                border: Border.all(color: const Color(0xFF1B5E20), width: 8),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_counter',
                      style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    Text(
                      'کل تعداد',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Main Tap Button
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B5E20),
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Icon(Icons.touch_app, color: Colors.white, size: 50),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Reset button
            IconButton(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh, color: Colors.red, size: 30),
              tooltip: 'ری سیٹ',
            ),
          ],
        ),
      ),
    );
  }
}
