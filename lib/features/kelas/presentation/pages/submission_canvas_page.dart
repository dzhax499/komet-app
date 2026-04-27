import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blockly/flutter_blockly.dart' as blockly;
import 'package:webview_flutter/webview_flutter.dart';

// ─────────────────────────────────────────────────────────────
// Custom Block Definitions (JavaScript)
// ─────────────────────────────────────────────────────────────
const String _kCustomBlocksScript = r"""
<script>
// ═══════════════ EVENTS ═══════════════
Blockly.Blocks['story_when_start'] = {
  init: function() {
    this.appendDummyInput().appendField("⚡ When Start Preview");
    this.setNextStatement(true, null);
    this.setColour('#7B8B3A');
    this.setTooltip("Runs when you press Play");
  }
};
Blockly.Blocks['story_when_touch'] = {
  init: function() {
    this.appendDummyInput().appendField("👆 When Touched");
    this.setNextStatement(true, null);
    this.setColour('#7B8B3A');
  }
};

// ═══════════════ MOTION ═══════════════
Blockly.Blocks['story_move'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("➡ Move")
        .appendField(new Blockly.FieldDropdown([["Right","R"],["Left","L"],["Up","U"],["Down","D"]]), "DIR")
        .appendField(new Blockly.FieldNumber(30, 1, 500), "STEPS")
        .appendField("px");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4C97AF');
  }
};
Blockly.Blocks['story_glide'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("✈ Glide to x:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "X")
        .appendField("y:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "Y")
        .appendField("in")
        .appendField(new Blockly.FieldNumber(1, 0.1, 10), "SEC")
        .appendField("s");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4C97AF');
  }
};
Blockly.Blocks['story_go_to'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("📍 Go to x:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "X")
        .appendField("y:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "Y");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4C97AF');
  }
};
Blockly.Blocks['story_rotate'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🔄 Rotate")
        .appendField(new Blockly.FieldNumber(90, -360, 360), "DEG")
        .appendField("degrees");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4C97AF');
  }
};
Blockly.Blocks['story_bounce'] = {
  init: function() {
    this.appendDummyInput().appendField("🏀 Bounce");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4C97AF');
  }
};

// ═══════════════ LOOKS ═══════════════
Blockly.Blocks['story_say'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("💬 Say")
        .appendField(new Blockly.FieldTextInput("Hello!"), "TEXT");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_think'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("💭 Think")
        .appendField(new Blockly.FieldTextInput("Hmm..."), "TEXT");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_show'] = {
  init: function() {
    this.appendDummyInput().appendField("👁 Show");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_hide'] = {
  init: function() {
    this.appendDummyInput().appendField("🙈 Hide");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_resize'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("📐 Set size to")
        .appendField(new Blockly.FieldNumber(100, 10, 500), "SIZE")
        .appendField("%");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_set_color'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🎨 Set color")
        .appendField(new Blockly.FieldDropdown([["Red","red"],["Blue","blue"],["Green","green"],["Yellow","yellow"],["Purple","purple"],["Orange","orange"],["White","white"]]), "COLOR");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};
Blockly.Blocks['story_set_opacity'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🌫 Set opacity")
        .appendField(new Blockly.FieldNumber(100, 0, 100), "OPACITY")
        .appendField("%");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#9966CC');
  }
};

// ═══════════════ SOUND ═══════════════
Blockly.Blocks['story_play_sound'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🔊 Play sound")
        .appendField(new Blockly.FieldDropdown([["Pop","pop"],["Whoosh","whoosh"],["Ding","ding"],["Boom","boom"],["Magic","magic"]]), "SOUND");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#CF8B17');
  }
};

// ═══════════════ CONTROL ═══════════════
Blockly.Blocks['story_wait'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("⏳ Wait")
        .appendField(new Blockly.FieldNumber(1, 0.1, 30), "SECONDS")
        .appendField("seconds");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#E8A317');
  }
};
Blockly.Blocks['story_repeat'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🔁 Repeat")
        .appendField(new Blockly.FieldNumber(3, 1, 50), "TIMES")
        .appendField("times");
    this.appendStatementInput("DO");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#E8A317');
  }
};
Blockly.Blocks['story_forever'] = {
  init: function() {
    this.appendDummyInput().appendField("♾ Forever");
    this.appendStatementInput("DO");
    this.setPreviousStatement(true, null);
    this.setColour('#E8A317');
  }
};
Blockly.Blocks['story_if'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("❓ If")
        .appendField(new Blockly.FieldDropdown([["touched","touched"],["visible","visible"],["at edge","at_edge"]]), "COND");
    this.appendStatementInput("THEN").appendField("then");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#E8A317');
  }
};
</script>
""";

class SubmissionCanvasPage extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;
  final String deadline;

  const SubmissionCanvasPage({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.deadline,
  });

  @override
  State<SubmissionCanvasPage> createState() => _SubmissionCanvasPageState();
}

// ── Data Models ──
class SceneObject {
  String name;
  IconData icon;
  Color baseColor;
  double spawnX, spawnY;
  double x, y;
  String speech;
  bool visible;
  double scale, rotation, opacity;
  Color color;
  String workspaceXml; // Stores Blockly XML state per object

  SceneObject({
    required this.name,
    required this.icon,
    required this.baseColor,
    this.spawnX = 0, this.spawnY = 0,
    this.workspaceXml = '<xml xmlns="https://developers.google.com/blockly/xml"><block type="story_when_start" x="50" y="50"></block></xml>',
  })  : x = spawnX, y = spawnY, speech = '',
        visible = true, scale = 1.0, rotation = 0.0,
        opacity = 1.0, color = baseColor;

  void resetToSpawn() {
    x = spawnX; y = spawnY; speech = '';
    visible = true; scale = 1.0; rotation = 0.0;
    opacity = 1.0; color = baseColor;
  }
}

class _SceneBg {
  final String name;
  final Color color;
  final IconData icon;
  const _SceneBg(this.name, this.color, this.icon);
}
class _SubmissionCanvasPageState extends State<SubmissionCanvasPage> {
  late final blockly.BlocklyOptions workspaceConfiguration;
  late final blockly.BlocklyEditor _editor;
  int _blockCount = 0;
  
  // Multi-object scene system
  List<SceneObject> _objects = [];
  int _selectedObjectIndex = 0;
  bool _isPlaying = false;
  
  // Scene camera
  double _sceneOffsetX = 0;
  double _sceneOffsetY = 0;
  
  // Scene background
  int _bgIndex = 0;
  static const List<_SceneBg> _backgrounds = [
    _SceneBg('Gelap', Color(0xFF1A1A2E), Icons.dark_mode),
    _SceneBg('Langit', Color(0xFF87CEEB), Icons.wb_sunny),
    _SceneBg('Hutan', Color(0xFF2D5A27), Icons.park),
    _SceneBg('Malam', Color(0xFF0D1B2A), Icons.nightlight),
    _SceneBg('Pantai', Color(0xFF4DB8D1), Icons.beach_access),
  ];

  SceneObject get _sel => _objects[_selectedObjectIndex];

  @override
  void initState() {
    super.initState();
    // 1. Kunci orientasi ke landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 2. Layar penuh (immersive)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Default object
    _objects = [
      SceneObject(name: 'Karakter 1', icon: Icons.person, baseColor: const Color(0xFF86AAC3)),
    ];

    // Konfigurasi Blockly DENGAN TOOLBOX untuk mendukung Drag & Drop Native
    workspaceConfiguration = blockly.BlocklyOptions(
      grid: blockly.GridOptions(
        spacing: 30,
        length: 3,
        colour: '#80FFFFFF', // Titik putih semi transparan seperti di desain
        snap: true,
      ),
      trashcan: true,
      theme: blockly.Theme(
        name: 'komet_theme',
        componentStyles: blockly.BlocklyComponentStyle(
          workspaceBackgroundColour: '#363636', // Warna gelap canvas di tengah
          toolboxBackgroundColour: '#4B797A', // Warna teal sidebar kiri UI Anda
          toolboxForegroundColour: '#FFFFFF', // Teks kategori putih
          flyoutBackgroundColour: '#4B797A', // Warna background saat blok ditarik
          flyoutForegroundColour: '#FFFFFF',
        ),
      ),
      // TOOLBOX Kategori Blok
      toolbox: blockly.ToolboxInfo(
        kind: 'categoryToolbox',
        contents: [
          {
            'kind': 'category',
            'name': '⚡ Events',
            'colour': '#7B8B3A',
            'contents': [
              {'kind': 'block', 'type': 'story_when_start'},
              {'kind': 'block', 'type': 'story_when_touch'},
            ],
          },
          {
            'kind': 'category',
            'name': '➡ Motion',
            'colour': '#4C97AF',
            'contents': [
              {'kind': 'block', 'type': 'story_move'},
              {'kind': 'block', 'type': 'story_glide'},
              {'kind': 'block', 'type': 'story_go_to'},
              {'kind': 'block', 'type': 'story_rotate'},
              {'kind': 'block', 'type': 'story_bounce'},
            ],
          },
          {
            'kind': 'category',
            'name': '💬 Looks',
            'colour': '#9966CC',
            'contents': [
              {'kind': 'block', 'type': 'story_say'},
              {'kind': 'block', 'type': 'story_think'},
              {'kind': 'block', 'type': 'story_show'},
              {'kind': 'block', 'type': 'story_hide'},
              {'kind': 'block', 'type': 'story_resize'},
              {'kind': 'block', 'type': 'story_set_color'},
              {'kind': 'block', 'type': 'story_set_opacity'},
            ],
          },
          {
            'kind': 'category',
            'name': '🔊 Sound',
            'colour': '#CF8B17',
            'contents': [
              {'kind': 'block', 'type': 'story_play_sound'},
            ],
          },
          {
            'kind': 'category',
            'name': '🔁 Control',
            'colour': '#E8A317',
            'contents': [
              {'kind': 'block', 'type': 'story_wait'},
              {'kind': 'block', 'type': 'story_repeat'},
              {'kind': 'block', 'type': 'story_forever'},
              {'kind': 'block', 'type': 'story_if'},
            ],
          },
        ],
      ),
    );

    _editor = blockly.BlocklyEditor(
      workspaceConfiguration: workspaceConfiguration,
      onInject: (data) => debugPrint("Blockly injected"),
      onChange: (data) {
        // Kita tidak lagi mengandalkan data.xml dari callback ini karena sering kosong.
        // Kita akan menarik XML secara on-demand saat tombol Play ditekan.
      },
    );

    // Konfigurasi WebView secara manual
    _editor.blocklyController
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _editor.init();
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: _editor.onMessage,
      );

    _editor
        .htmlRender(
      script: _kCustomBlocksScript,
    )
        .then((htmlString) {
      _editor.blocklyController.loadHtmlString(htmlString);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363636),
      body: Column(
        children: [
          _buildTopHeader(),
          Expanded(
            child: Row(
              children: [
                // Menggunakan WebViewWidget secara manual
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(
                        controller: _editor.blocklyController,
                      ),
                      // Indikator jumlah blok overlay di kiri bawah
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isPlaying ? const Color(0xFF4CAF50) : const Color(0xFF7EA7C8),
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
                          ),
                          child: Text(
                            _isPlaying ? "▶ Playing..." : "Ready | $_blockCount Blok",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                _buildRightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FUNGSI TOMBOL ─────────────────────────────────────────────
  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onStop() {
    setState(() {
      _isPlaying = false;
      for (var obj in _objects) {
        obj.resetToSpawn();
      }
    });
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cerita berhasil disimpan! ✅"),
        backgroundColor: Color(0xFF284C18),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPlay() async {
    if (_isPlaying) return;

    // Save current XML to current object before playing
    final saveJs = '''
      (function() {
        var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace());
        return Blockly.Xml.domToText(xml);
      })();
    ''';
    try {
      final result = await _editor.blocklyController.runJavaScriptReturningResult(saveJs);
      String xmlStr = result.toString();
      if (xmlStr.startsWith('"') && xmlStr.endsWith('"')) {
        xmlStr = jsonDecode(xmlStr) as String;
      }
      _sel.workspaceXml = xmlStr.replaceAll('\\"', '"').replaceAll('\\n', '');
    } catch (e) {
      debugPrint("Save XML error: $e");
    }

    setState(() {
      _isPlaying = true;
      for (var obj in _objects) {
        obj.resetToSpawn();
      }
    });

    // Create JS payload with all XMLs
    final allXmls = _objects.map((o) => o.workspaceXml.replaceAll("'", "\\'")).toList();
    
    // JS that parses each XML in a headless workspace and extracts actions
    final String extractorJS = '''
      (function() {
        function extract(block) {
          var list = [];
          while (block) {
            var t = block.type;
            var o = { type: t };
            if (t === 'story_say') o.text = block.getFieldValue('TEXT');
            else if (t === 'story_think') o.text = block.getFieldValue('TEXT');
            else if (t === 'story_move') { o.dir = block.getFieldValue('DIR'); o.steps = block.getFieldValue('STEPS'); }
            else if (t === 'story_glide') { o.x = block.getFieldValue('X'); o.y = block.getFieldValue('Y'); o.sec = block.getFieldValue('SEC'); }
            else if (t === 'story_go_to') { o.x = block.getFieldValue('X'); o.y = block.getFieldValue('Y'); }
            else if (t === 'story_rotate') o.deg = block.getFieldValue('DEG');
            else if (t === 'story_wait') o.sec = block.getFieldValue('SECONDS');
            else if (t === 'story_repeat') { o.times = block.getFieldValue('TIMES'); o.body = extract(block.getInputTargetBlock('DO')); }
            else if (t === 'story_forever') { o.body = extract(block.getInputTargetBlock('DO')); }
            else if (t === 'story_if') { o.cond = block.getFieldValue('COND'); o.body = extract(block.getInputTargetBlock('THEN')); }
            else if (t === 'story_resize') o.size = block.getFieldValue('SIZE');
            else if (t === 'story_set_color') o.color = block.getFieldValue('COLOR');
            else if (t === 'story_set_opacity') o.opacity = block.getFieldValue('OPACITY');
            else if (t === 'story_play_sound') o.sound = block.getFieldValue('SOUND');
            list.push(o);
            block = block.getNextBlock();
          }
          return list;
        }

        var xmls = ${jsonEncode(allXmls)};
        var allActions = [];
        var headless = new Blockly.Workspace();

        for (var i = 0; i < xmls.length; i++) {
          headless.clear();
          try {
            var dom = Blockly.Xml.textToDom(xmls[i]);
            Blockly.Xml.domToWorkspace(dom, headless);
            var tops = headless.getTopBlocks(true);
            var script = [];
            for (var j = 0; j < tops.length; j++) {
              if (tops[j].type === 'story_when_start') {
                script = extract(tops[j].getNextBlock());
                break;
              }
            }
            allActions.push(script);
          } catch(e) {
            allActions.push([]);
          }
        }
        headless.dispose();
        return JSON.stringify(allActions);
      })();
    ''';

    List<List<dynamic>> allActions = [];
    try {
      final Object result = await _editor.blocklyController.runJavaScriptReturningResult(extractorJS);
      String rawJson = result.toString();
      if (rawJson.startsWith('"') && rawJson.endsWith('"')) {
        rawJson = jsonDecode(rawJson) as String;
      }
      final parsed = jsonDecode(rawJson) as List<dynamic>;
      allActions = parsed.map((e) => e as List<dynamic>).toList();
    } catch (e) {
      debugPrint("Extract error: $e");
      allActions = List.generate(_objects.length, (_) => []);
    }

    bool hasAnyActions = allActions.any((list) => list.isNotEmpty);

    if (!hasAnyActions) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Tidak ada blok aksi yang tersambung ke '⚡ When Start Preview'."),
          backgroundColor: Colors.orange,
        ));
      }
      setState(() { _isPlaying = false; });
      return;
    }

    // Eksekusi semua objek secara paralel
    List<Future<void>> executions = [];
    for (int i = 0; i < _objects.length; i++) {
      if (allActions[i].isNotEmpty) {
        executions.add(_executeActions(_objects[i], allActions[i]));
      }
    }

    await Future.wait(executions);

    // Preview tetap hidup sampai user tekan Stop
    if (mounted && _isPlaying) {
      for (var obj in _objects) { obj.speech = ""; }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Preview selesai. Tekan ■ Stop untuk mereset."),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _executeActions(SceneObject obj, List<dynamic> actions) async {
    for (var a in actions) {
      if (!_isPlaying || !mounted) return;
      final type = a['type'];

      if (type == 'story_say') {
        setState(() => obj.speech = a['text'] ?? "...");
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => obj.speech = "");
      }
      else if (type == 'story_think') {
        setState(() => obj.speech = "💭 ${a['text'] ?? '...'}");
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => obj.speech = "");
      }
      else if (type == 'story_move') {
        String dir = a['dir'] ?? "R";
        double px = double.tryParse(a['steps']?.toString() ?? "30") ?? 30;
        setState(() {
          if (dir == "R") obj.x += px;
          if (dir == "L") obj.x -= px;
          if (dir == "U") obj.y -= px;
          if (dir == "D") obj.y += px;
        });
        await Future.delayed(const Duration(milliseconds: 500));
      }
      else if (type == 'story_glide') {
        double tx = double.tryParse(a['x']?.toString() ?? "0") ?? 0;
        double ty = double.tryParse(a['y']?.toString() ?? "0") ?? 0;
        double sec = double.tryParse(a['sec']?.toString() ?? "1") ?? 1;
        setState(() { obj.x = tx; obj.y = ty; });
        await Future.delayed(Duration(milliseconds: (sec * 1000).toInt()));
      }
      else if (type == 'story_go_to') {
        double tx = double.tryParse(a['x']?.toString() ?? "0") ?? 0;
        double ty = double.tryParse(a['y']?.toString() ?? "0") ?? 0;
        setState(() { obj.x = tx; obj.y = ty; });
        await Future.delayed(const Duration(milliseconds: 100));
      }
      else if (type == 'story_rotate') {
        double deg = double.tryParse(a['deg']?.toString() ?? "90") ?? 90;
        setState(() => obj.rotation += deg);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      else if (type == 'story_bounce') {
        double origY = obj.y;
        setState(() => obj.y -= 40);
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) setState(() => obj.y = origY);
        await Future.delayed(const Duration(milliseconds: 250));
      }
      else if (type == 'story_show') {
        setState(() => obj.visible = true);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      else if (type == 'story_hide') {
        setState(() => obj.visible = false);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      else if (type == 'story_resize') {
        double s = double.tryParse(a['size']?.toString() ?? "100") ?? 100;
        setState(() => obj.scale = s / 100.0);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      else if (type == 'story_set_color') {
        final colors = {'red': Colors.red, 'blue': Colors.blue, 'green': Colors.green, 'yellow': Colors.yellow, 'purple': Colors.purple, 'orange': Colors.orange, 'white': Colors.white};
        setState(() => obj.color = colors[a['color']] ?? obj.baseColor);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      else if (type == 'story_set_opacity') {
        double o = double.tryParse(a['opacity']?.toString() ?? "100") ?? 100;
        setState(() => obj.opacity = (o / 100.0).clamp(0.0, 1.0));
        await Future.delayed(const Duration(milliseconds: 200));
      }
      else if (type == 'story_play_sound') {
        setState(() => obj.speech = "🔊 ${a['sound'] ?? 'sound'}!");
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) setState(() => obj.speech = "");
      }
      else if (type == 'story_wait') {
        double sec = double.tryParse(a['sec']?.toString() ?? "1") ?? 1;
        await Future.delayed(Duration(milliseconds: (sec * 1000).toInt()));
      }
      else if (type == 'story_repeat') {
        int times = int.tryParse(a['times']?.toString() ?? "3") ?? 3;
        List<dynamic> body = a['body'] ?? [];
        for (int i = 0; i < times && _isPlaying; i++) {
          await _executeActions(obj, body);
        }
      }
      else if (type == 'story_forever') {
        List<dynamic> body = a['body'] ?? [];
        for (int i = 0; i < 5 && _isPlaying; i++) {
          await _executeActions(obj, body);
        }
      }
      else if (type == 'story_if') {
        List<dynamic> body = a['body'] ?? [];
        if (body.isNotEmpty) await _executeActions(obj, body);
      }
    }
  }

  Future<void> _switchObject(int newIndex) async {
    if (_selectedObjectIndex == newIndex || _isPlaying) return;
    
    // Save current XML
    final saveJs = '''
      (function() {
        var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace());
        return Blockly.Xml.domToText(xml);
      })();
    ''';
    try {
      final result = await _editor.blocklyController.runJavaScriptReturningResult(saveJs);
      String xmlStr = result.toString();
      if (xmlStr.startsWith('"') && xmlStr.endsWith('"')) {
        xmlStr = jsonDecode(xmlStr) as String;
      }
      // Bersihkan string dari escape backslash JSON jika ada
      xmlStr = xmlStr.replaceAll('\\"', '"').replaceAll('\\n', '');
      _sel.workspaceXml = xmlStr;
    } catch (e) {
      debugPrint("Save XML error: $e");
    }

    // Ubah selection
    setState(() => _selectedObjectIndex = newIndex);

    // Load new XML
    final newXml = _sel.workspaceXml.replaceAll("'", "\\'");
    final loadJs = '''
      (function() {
        var ws = Blockly.getMainWorkspace();
        ws.clear();
        var dom = Blockly.Xml.textToDom('$newXml');
        Blockly.Xml.domToWorkspace(dom, ws);
        return "ok";
      })();
    ''';
    try {
      await _editor.blocklyController.runJavaScriptReturningResult(loadJs);
    } catch (e) {
      debugPrint("Load XML error: $e");
    }
  }

  void _onAddObject() {
    final chars = [
      {'name': 'Anak', 'icon': Icons.person, 'color': 0xFF86AAC3},
      {'name': 'Guru', 'icon': Icons.school, 'color': 0xFFE8A317},
      {'name': 'Hewan', 'icon': Icons.pets, 'color': 0xFF8BC34A},
      {'name': 'Robot', 'icon': Icons.smart_toy, 'color': 0xFF9E9E9E},
      {'name': 'Bintang', 'icon': Icons.star, 'color': 0xFFFFD700},
      {'name': 'Bola', 'icon': Icons.sports_soccer, 'color': 0xFFFF5722},
      {'name': 'Bunga', 'icon': Icons.local_florist, 'color': 0xFFE91E63},
      {'name': 'Mobil', 'icon': Icons.directions_car, 'color': 0xFF2196F3},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Objek Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: chars.length,
            itemBuilder: (_, i) {
              final c = chars[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _objects.add(SceneObject(
                      name: '${c['name']} ${_objects.length + 1}',
                      icon: c['icon'] as IconData,
                      baseColor: Color(c['color'] as int),
                      spawnX: 20.0 * _objects.length,
                      spawnY: 20.0 * _objects.length,
                    ));
                    _selectedObjectIndex = _objects.length - 1;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("${c['name']} ditambahkan ke Scene!"),
                    backgroundColor: const Color(0xFF4CAF50),
                  ));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(c['color'] as int),
                      child: Icon(c['icon'] as IconData, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(c['name'] as String, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── HEADER ATAS ───────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF284C18), Color(0xFF557C26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBack,
            child: const Icon(Icons.reply, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              widget.assignmentTitle.isNotEmpty ? widget.assignmentTitle : "Create Story",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _onSave,
            child: const Icon(Icons.save, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          // Play / Stop toggle
          if (!_isPlaying)
            GestureDetector(
              onTap: _onPlay,
              child: const Icon(Icons.play_arrow, color: Color(0xFF67B5C8), size: 36),
            )
          else
            GestureDetector(
              onTap: _onStop,
              child: const Icon(Icons.stop, color: Color(0xFFE85454), size: 36),
            ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: Colors.white54),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _onBack,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward,
                  color: Color(0xFF284C18), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── PANEL KANAN (Scene) ───────────────────────────────────────
  Widget _buildRightPanel() {
    return Container(
      width: 260,
      color: Colors.black, // Latar Scene
      child: Column(
        children: [
          // Header Scene
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.vertical_split, color: Color(0xFF4B797A)),
                const SizedBox(width: 8),
                const Text(
                  "Scene",
                  style: TextStyle(
                    color: Color(0xFF4B797A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _onAddObject,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3C17),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "+ Object",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Canvas Scene
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _sceneOffsetX += details.delta.dx;
                  _sceneOffsetY += details.delta.dy;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _backgrounds[_bgIndex].color,
                  border: _isPlaying
                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                    : null,
                ),
                child: Stack(
                  children: [
                    // Grid
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: CustomPaint(
                          painter: GridPainter(offsetX: _sceneOffsetX, offsetY: _sceneOffsetY),
                        ),
                      ),
                    ),
                    // All objects
                    for (int i = 0; i < _objects.length; i++)
                      _buildSceneObject(i),
                  ],
                ),
              ),
            ),
          ),
          // Footer - Object Selector + Background Picker
          Container(
            height: 52,
            decoration: const BoxDecoration(color: Color(0xFF2D2D44)),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Object chips
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _objects.length,
                    itemBuilder: (_, i) {
                      final obj = _objects[i];
                      final selected = i == _selectedObjectIndex;
                      return GestureDetector(
                        onTap: () => _switchObject(i),
                        onLongPress: () async {
                          if (_objects.length > 1) {
                            // If deleting current, don't save its XML, just delete and switch
                            if (i == _selectedObjectIndex) {
                              setState(() {
                                _objects.removeAt(i);
                                if (_selectedObjectIndex >= _objects.length) {
                                  _selectedObjectIndex = _objects.length - 1;
                                }
                              });
                              // Load XML for new selection without saving
                              final newXml = _sel.workspaceXml.replaceAll("'", "\\'");
                              final loadJs = '''
                                (function() {
                                  var ws = Blockly.getMainWorkspace();
                                  ws.clear();
                                  var dom = Blockly.Xml.textToDom('$newXml');
                                  Blockly.Xml.domToWorkspace(dom, ws);
                                })();
                              ''';
                              await _editor.blocklyController.runJavaScript(loadJs);
                            } else {
                              setState(() {
                                _objects.removeAt(i);
                                if (_selectedObjectIndex > i) {
                                  _selectedObjectIndex--; // adjust index if deleted object was before current
                                }
                              });
                            }
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: selected ? obj.baseColor.withOpacity(0.3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? obj.baseColor : Colors.white24,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(obj.icon, color: obj.baseColor, size: 16),
                              const SizedBox(width: 4),
                              Text(obj.name, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Divider
                Container(width: 1, height: 30, color: Colors.white24),
                const SizedBox(width: 4),
                // Background picker
                GestureDetector(
                  onTap: () => setState(() => _bgIndex = (_bgIndex + 1) % _backgrounds.length),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: _backgrounds[_bgIndex].color.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_backgrounds[_bgIndex].icon, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(_backgrounds[_bgIndex].name, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneObject(int index) {
    final obj = _objects[index];
    final selected = index == _selectedObjectIndex;
    return AnimatedPositioned(
      duration: _isPlaying ? const Duration(milliseconds: 500) : Duration.zero,
      curve: Curves.easeInOut,
      left: 80 + obj.x + _sceneOffsetX,
      top: 60 + obj.y + _sceneOffsetY,
      child: GestureDetector(
        onTap: () {
          if (!_isPlaying) setState(() => _selectedObjectIndex = index);
        },
        onPanUpdate: (details) {
          if (_isPlaying) return;
          setState(() {
            _selectedObjectIndex = index;
            obj.spawnX += details.delta.dx;
            obj.spawnY += details.delta.dy;
            obj.x = obj.spawnX;
            obj.y = obj.spawnY;
          });
        },
        child: Opacity(
          opacity: obj.opacity,
          child: Visibility(
            visible: obj.visible,
            child: Transform.rotate(
              angle: obj.rotation * 3.14159 / 180,
              child: Transform.scale(
                scale: obj.scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (obj.speech.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: obj.speech.startsWith('💭') ? const Color(0xFFE8E8E8) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Text(obj.speech, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: obj.color,
                        border: Border.all(
                          color: selected ? Colors.yellow : Colors.white38,
                          width: selected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: selected ? 10 : 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Center(child: Icon(obj.icon, size: 30, color: Colors.white)),
                    ),
                    if (selected && !_isPlaying)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "x:${obj.x.toStringAsFixed(0)} y:${obj.y.toStringAsFixed(0)}",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Tambahan opsional: Painter untuk membuat titik-titik grid agar user tahu scene sedang digeser
class GridPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;

  GridPainter({required this.offsetX, required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    double spacing = 40.0;
    
    double startX = offsetX % spacing;
    double startY = offsetY % spacing;

    for (double x = startX; x < size.width; x += spacing) {
      for (double y = startY; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.offsetX != offsetX || oldDelegate.offsetY != offsetY;
  }
}
