import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Счётчик нажатий',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  int _counter = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    setState(() {
      _isLoading = true;
      _loadError = false;
    });

    try {
      final counter = await _preferences.getInt('counter') ?? 0;
      if (!mounted) return;

      setState(() {
        _counter = counter;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _incrementCounter() async {
    if (_isLoading || _isSaving || _loadError) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final nextCounter = _counter + 1;
      await _preferences.setInt('counter', nextCounter);
      if (!mounted) return;

      setState(() {
        _counter = nextCounter;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить число')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const CircularProgressIndicator();
    } else if (_loadError) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Не удалось загрузить число'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadCounter,
            child: const Text('Повторить загрузку'),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Количество нажатий',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$_counter',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : _incrementCounter,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Увеличить'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Счётчик нажатий'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }
}
