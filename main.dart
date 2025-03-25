import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatefulWidget {
  const CodeEditorApp({super.key});

  @override
  _CodeEditorAppState createState() => _CodeEditorAppState();
}

class _CodeEditorAppState extends State<CodeEditorApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          (prefs.getBool('isDark') ?? true) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hunter Code Editor',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      themeMode: _themeMode,
      home: CodeEditorScreen(onThemeToggle: _toggleTheme),
    );
  }
}

class CodeEditorScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const CodeEditorScreen({super.key, required this.onThemeToggle});

  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  late WebViewController _webViewController;
  bool _isWebViewReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _codeController.text = '''<!DOCTYPE html>
<html>
<head>
  <style>
    body { background-color: black; color: white; font-family: Arial; }
    h1 { color: cyan; font-size: 28px; text-align: center; }
  </style>
</head>
<body>
  <h1>Hello, Coder Are you ready to code html</h1>
</body>
</html>''';
    _initWebView();
  }

  Future<void> _initWebView() async {
    final WebViewController controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(_codeController.text);
    setState(() {
      _webViewController = controller;
      _isWebViewReady = true;
    });
  }

  void _runCode() {
    String code = _codeController.text.trim();
    String? validationResult = _validateHtml(code);

    if (validationResult != null) {
      setState(() => _errorMessage = validationResult);
      return;
    }
    if (!_isWebViewReady) return;
    _webViewController.loadHtmlString(code);
    setState(() => _errorMessage = null);
  }

  String? _validateHtml(String code) {
    if (!code.contains('<!DOCTYPE html>'))
      return "Missing <!DOCTYPE html> declaration.";
    if (!code.contains('<html>') || !code.contains('</html>'))
      return "Missing <html> or </html> tag.";
    if (!code.contains('<head>') || !code.contains('</head>'))
      return "Missing <head> or </head> tag.";
    if (!code.contains('<body>') || !code.contains('</body>'))
      return "Missing <body> or </body> tag.";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hunter Code Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _codeController,
                maxLines: 8,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Write your HTML code here...",
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _runCode,
              child: const Text(
                'Run Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      _errorMessage == null
                          ? WebViewWidget(controller: _webViewController)
                          : Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
