import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blockly/flutter_blockly.dart' as blockly;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/submission_model.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// Custom Block Definitions (JavaScript)
// ─────────────────────────────────────────────────────────────
const String _kCustomBlocksScript = r"""
<script>
// ═══════════════ EVENTS ═══════════════
Blockly.Blocks['story_when_start'] = {
  init: function() {
    this.appendDummyInput().appendField("when ▶ start");
    this.setNextStatement(true, null);
    this.setColour('#5B8C3A');
    this.setTooltip("Runs when you press Play");
  }
};
Blockly.Blocks['story_when_touch'] = {
  init: function() {
    this.appendDummyInput().appendField("when tapped");
    this.setNextStatement(true, null);
    this.setColour('#5B8C3A');
  }
};

// ═══════════════ MOTION ═══════════════
Blockly.Blocks['story_move'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("move")
        .appendField(new Blockly.FieldDropdown([["right","R"],["left","L"],["up","U"],["down","D"]]), "DIR")
        .appendField(new Blockly.FieldNumber(30, 1, 500), "STEPS")
        .appendField("px");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4A90D9');
  }
};
Blockly.Blocks['story_glide'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("glide to x:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "X")
        .appendField("y:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "Y")
        .appendField("in")
        .appendField(new Blockly.FieldNumber(1, 0.1, 10), "SEC")
        .appendField("s");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4A90D9');
  }
};
Blockly.Blocks['story_go_to'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("go to x:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "X")
        .appendField("y:")
        .appendField(new Blockly.FieldNumber(0, -999, 999), "Y");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4A90D9');
  }
};
Blockly.Blocks['story_rotate'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("rotate")
        .appendField(new Blockly.FieldNumber(90, -360, 360), "DEG")
        .appendField("deg");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4A90D9');
  }
};
Blockly.Blocks['story_bounce'] = {
  init: function() {
    this.appendDummyInput().appendField("bounce");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#4A90D9');
  }
};

// ═══════════════ LOOKS ═══════════════
Blockly.Blocks['story_say'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("say")
        .appendField(new Blockly.FieldTextInput("Hello!"), "TEXT");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_think'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("think")
        .appendField(new Blockly.FieldTextInput("Hmm..."), "TEXT");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_show'] = {
  init: function() {
    this.appendDummyInput().appendField("show");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_hide'] = {
  init: function() {
    this.appendDummyInput().appendField("hide");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_resize'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("set size")
        .appendField(new Blockly.FieldNumber(100, 10, 500), "SIZE")
        .appendField("%");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_set_color'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("set color")
        .appendField(new Blockly.FieldDropdown([["Red","red"],["Blue","blue"],["Green","green"],["Yellow","yellow"],["Purple","purple"],["Orange","orange"],["White","white"]]), "COLOR");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};
Blockly.Blocks['story_set_opacity'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("set opacity")
        .appendField(new Blockly.FieldNumber(100, 0, 100), "OPACITY")
        .appendField("%");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#8855BB');
  }
};

// ═══════════════ SOUND ═══════════════
Blockly.Blocks['story_play_sound'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("play sound")
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
        .appendField("wait")
        .appendField(new Blockly.FieldNumber(1, 0.1, 30), "SECONDS")
        .appendField("sec");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#D4941A');
  }
};
Blockly.Blocks['story_repeat'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("repeat")
        .appendField(new Blockly.FieldNumber(3, 1, 50), "TIMES")
        .appendField("times");
    this.appendStatementInput("DO");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#D4941A');
  }
};
Blockly.Blocks['story_forever'] = {
  init: function() {
    this.appendDummyInput().appendField("forever");
    this.appendStatementInput("DO");
    this.setPreviousStatement(true, null);
    this.setColour('#D4941A');
  }
};
Blockly.Blocks['story_if'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("if")
        .appendField(new Blockly.FieldDropdown([["touched","touched"],["visible","visible"],["at edge","at_edge"]]), "COND");
    this.appendStatementInput("THEN").appendField("then");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#D4941A');
  }
};
</script>
""";

class SubmissionCanvasPage extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;
  final String deadline;
  final String studentId;
  final bool isReviewMode;
  final SubmissionModel? initialSubmission;

  const SubmissionCanvasPage({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.deadline,
    required this.studentId,
    this.isReviewMode = false,
    this.initialSubmission,
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
class _SubmissionCanvasPageState extends State<SubmissionCanvasPage> with TickerProviderStateMixin {
  late final blockly.BlocklyOptions workspaceConfiguration;
  late final blockly.BlocklyEditor _editor;
  late final AnimationController _bgController;
  int _blockCount = 0;
  
  // Multi-object scene system
  List<SceneObject> _objects = [];
  int _selectedObjectIndex = 0;
  bool _isPlaying = false;
  bool _isEditorReady = false;
  
  // Scene camera
  double _sceneOffsetX = 0;
  double _sceneOffsetY = 0;
  
  // Submission data
  SubmissionModel? _existingSubmission;

  // Scene background
  int _bgIndex = 0;
  static const List<_SceneBg> _backgrounds = [
    _SceneBg('Dark', Color(0xFF1A1A2E), Icons.dark_mode),
    _SceneBg('Sky', Color(0xFF87CEEB), Icons.wb_sunny),
    _SceneBg('Forest', Color(0xFF2D5A27), Icons.park),
    _SceneBg('Night', Color(0xFF0D1B2A), Icons.nightlight),
    _SceneBg('Beach', Color(0xFF4DB8D1), Icons.beach_access),
  ];

  SceneObject get _sel => _objects[_selectedObjectIndex];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    // 1. Kunci orientasi ke landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Load existing submission if any
    if (widget.initialSubmission != null) {
      _existingSubmission = widget.initialSubmission;
      if (_existingSubmission!.storyDataJson.isNotEmpty) {
        _deserializeCanvasState(_existingSubmission!.storyDataJson);
      }
    } else if (widget.studentId.isNotEmpty) {
      context.read<SubmissionBloc>().add(
        LoadExistingSubmissionEvent(
          assignmentId: widget.assignmentId,
          studentId: widget.studentId,
        ),
      );
    }
    // 2. Layar penuh (immersive)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Default object
    _objects = [
      SceneObject(name: 'Character 1', icon: Icons.person, baseColor: const Color(0xFF86AAC3)),
    ];

    // Konfigurasi Blockly DENGAN TOOLBOX untuk mendukung Drag & Drop Native
    workspaceConfiguration = blockly.BlocklyOptions(
      grid: blockly.GridOptions(
        spacing: 30,
        length: 3,
        colour: '#40FFFFFF', // Visible dotted texture
        snap: true,
      ),
      trashcan: true,
      theme: blockly.Theme(
        name: 'komet_theme',
        componentStyles: blockly.BlocklyComponentStyle(
          workspaceBackgroundColour: '#162822', // Premium Komet Dark Canvas
          toolboxBackgroundColour: '#1A3C0A', // AppColors.kometDarkGreen
          toolboxForegroundColour: '#FFFFFF', // Teks kategori putih
          flyoutBackgroundColour: '#4A7473', // AppColors.kometTeal
          flyoutForegroundColour: '#FFFFFF',
        ),
      ),
      // TOOLBOX Kategori Blok
      toolbox: blockly.ToolboxInfo(
        kind: 'categoryToolbox',
        contents: [
          {
            'kind': 'category',
            'name': 'Events',
            'colour': '#5B8C3A',
            'contents': [
              {'kind': 'block', 'type': 'story_when_start'},
              {'kind': 'block', 'type': 'story_when_touch'},
            ],
          },
          {
            'kind': 'category',
            'name': 'Motion',
            'colour': '#4A90D9',
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
            'name': 'Looks',
            'colour': '#8855BB',
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
            'name': 'Sound',
            'colour': '#CF8B17',
            'contents': [
              {'kind': 'block', 'type': 'story_play_sound'},
            ],
          },
          {
            'kind': 'category',
            'name': 'Control',
            'colour': '#D4941A',
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
      onInject: (data) {
        debugPrint("Blockly injected");
        _isEditorReady = true;
        if (_objects.isNotEmpty) {
          _injectWorkspaceXml(_objects[_selectedObjectIndex].workspaceXml);
        }
      },
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
    _bgController.dispose();
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
    return BlocListener<SubmissionBloc, SubmissionState>(
      listener: (context, state) {
        if (state is ExistingSubmissionLoaded) {
          _existingSubmission = state.submission;
          if (state.submission.storyDataJson.isNotEmpty) {
            _deserializeCanvasState(state.submission.storyDataJson);
          }
        } else if (state is SubmissionSaved) {
          _existingSubmission = state.submission;
          _showToast(
            state.submission.status == SubmissionStatus.submitted
                ? "Submission sent to teacher!"
                : "Draft saved successfully",
            Icons.check_circle_rounded,
            const Color(0xFF2D6A1E),
          );
        } else if (state is SubmissionFailure) {
          _showToast("Error: ${state.message}", Icons.error_outline_rounded, const Color(0xFFCC5555));
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBack();
        },
        child: Scaffold(
          backgroundColor: AppColors.kometDarkGreen,
          body: Stack(
            children: [
              AnimatedGlowingBackground(animation: _bgController),
              SafeArea(
                child: Column(
                  children: [
          _buildTopBar(),
          Expanded(
            child: Row(
              children: [
                if (!widget.isReviewMode)
                  Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _editor.blocklyController),
                      if (!_isPlaying)
                        Positioned(
                          bottom: 10, left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF272738),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF3A3A4E)),
                            ),
                            child: Text("$_blockCount blocks", style: const TextStyle(color: Color(0xFF8888AA), fontSize: 11, fontWeight: FontWeight.w500)),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildScenePanel(),
              ],
            ),
          ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
  // ── FUNGSI TOMBOL ─────────────────────────────────────────────
  void _onBack() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  // ── JSON State Serialization ────────────────────────────────────────────────
  String _serializeCanvasState() {
    final Map<String, dynamic> state = {
      'bgIndex': _bgIndex,
      'objects': _objects.map((o) => {
        'name': o.name,
        'icon': o.icon.codePoint, // save codepoint
        'baseColor': o.baseColor.value,
        'spawnX': o.spawnX,
        'spawnY': o.spawnY,
        'workspaceXml': o.workspaceXml,
      }).toList(),
    };
    return jsonEncode(state);
  }

  void _deserializeCanvasState(String jsonString) {
    try {
      final Map<String, dynamic> state = jsonDecode(jsonString);
      setState(() {
        _bgIndex = state['bgIndex'] ?? 0;
        final objs = state['objects'] as List<dynamic>?;
        if (objs != null && objs.isNotEmpty) {
          _objects = objs.map((o) => SceneObject(
            name: o['name'],
            icon: _getIconFromCodePoint(o['icon']),
            baseColor: Color(o['baseColor']),
            spawnX: (o['spawnX'] as num).toDouble(),
            spawnY: (o['spawnY'] as num).toDouble(),
            workspaceXml: o['workspaceXml'],
          )).toList();
          _selectedObjectIndex = 0;
        }
      });
      // Load first object into editor if ready
      if (_isEditorReady && _objects.isNotEmpty && !widget.isReviewMode) {
        _injectWorkspaceXml(_objects[_selectedObjectIndex].workspaceXml);
      }
    } catch (e) {
      debugPrint("Gagal load state: $e");
    }
  }

  IconData _getIconFromCodePoint(int codePoint) {
    const icons = [
      Icons.person,
      Icons.school,
      Icons.pets,
      Icons.smart_toy,
      Icons.star,
      Icons.sports_soccer,
      Icons.local_florist,
      Icons.directions_car,
    ];
    for (final icon in icons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.person;
  }

  void _injectWorkspaceXml(String xml) {
    if (xml.isEmpty) return;
    final nx = xml.replaceAll("'", "\\'");
    _editor.blocklyController.runJavaScriptReturningResult(
      '(function(){var w=Blockly.getMainWorkspace();if(!w)return"err";w.clear();Blockly.Xml.domToWorkspace(Blockly.utils.xml.textToDom(\'$nx\'),w);return"ok";})();'
    );
  }

  Future<void> _triggerSaveWorkspace() async {
    // Save current workspace to object before serializing
    try {
      final r = await _editor.blocklyController.runJavaScriptReturningResult(
          '(function(){return Blockly.Xml.domToText(Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()));})();');
      String x = r.toString();
      if (x.startsWith('"') && x.endsWith('"')) x = jsonDecode(x) as String;
      _sel.workspaceXml = x.replaceAll('\\"', '"').replaceAll('\\n', '');
    } catch (_) {}
  }

  Future<void> _performSave(SubmissionStatus status) async {
    if (widget.studentId.isEmpty) return; // Cannot save without student ID
    
    await _triggerSaveWorkspace();
    
    final stateJson = _serializeCanvasState();
    final submission = _existingSubmission?.copyWith(
      storyDataJson: stateJson,
      status: status,
      submittedAt: status == SubmissionStatus.submitted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    ) ?? SubmissionModel(
      id: const Uuid().v4(),
      assignmentId: widget.assignmentId,
      siswaId: widget.studentId,
      storyDataJson: stateJson,
      status: status,
      sudahSync: false,
      submittedAt: status == SubmissionStatus.submitted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
      komentarHalaman: [],
    );

    context.read<SubmissionBloc>().add(SubmitTaskEvent(submission));
  }

  void _onSave() {
    _performSave(_existingSubmission?.status == SubmissionStatus.submitted 
        ? SubmissionStatus.submitted 
        : SubmissionStatus.draft);
  }

  void _onSubmit() {
    _showSubmitConfirmation();
  }

  void _onUnsubmit() async {
    await _performSave(SubmissionStatus.draft);
    if (mounted) Navigator.of(context).pop();
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _performSave(SubmissionStatus.submitted);
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Send To Teacher",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A1E), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color(0xFF1E3A1E), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showToast(String message, IconData icon, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(message: message, icon: icon, color: color, onDismiss: () => entry.remove()),
    );
    overlay.insert(entry);
  }

  void _onPlay() async {
    if (_isPlaying) return;

    if (!widget.isReviewMode) {
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
            var dom = Blockly.utils.xml.textToDom(xmls[i]);
            Blockly.Xml.domToWorkspace(dom, headless);
            var tops = headless.getTopBlocks(true);
            var script = [];
            for (var j = 0; j < tops.length; j++) {
              if (tops[j].type === 'story_when_start') {
                script = script.concat(extract(tops[j].getNextBlock()));
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
        _showToast("Connect action blocks to ⚡ When Start", Icons.warning_amber_rounded, const Color(0xFFE8A317));
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
      _showToast("Preview finished — press Stop to reset", Icons.check_circle_outline_rounded, const Color(0xFF4A8C3F));
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
    if (!widget.isReviewMode) {
      final newXml = _sel.workspaceXml.replaceAll("'", "\\'");
      final loadJs = '''
        (function() {
          var ws = Blockly.getMainWorkspace();
          ws.clear();
          var dom = Blockly.utils.xml.textToDom('$newXml');
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
  }

  void _onAddObject() {
    final chars = [
      {'name': 'Kid', 'icon': Icons.person, 'color': 0xFF86AAC3},
      {'name': 'Teacher', 'icon': Icons.school, 'color': 0xFFE8A317},
      {'name': 'Animal', 'icon': Icons.pets, 'color': 0xFF8BC34A},
      {'name': 'Robot', 'icon': Icons.smart_toy, 'color': 0xFF9E9E9E},
      {'name': 'Star', 'icon': Icons.star, 'color': 0xFFFFD700},
      {'name': 'Ball', 'icon': Icons.sports_soccer, 'color': 0xFFFF5722},
      {'name': 'Flower', 'icon': Icons.local_florist, 'color': 0xFFE91E63},
      {'name': 'Car', 'icon': Icons.directions_car, 'color': 0xFF2196F3},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.kometDarkGreen.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 20),
                  Row(children: [
                    Text("Choose Character", style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const Spacer(),
                    Text("${_objects.length} active", style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                        itemCount: chars.length,
                        itemBuilder: (_, i) {
                          final c = chars[i];
                          final clr = Color(c['color'] as int);
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                Navigator.pop(ctx);
                                // Save current workspace
                                try {
                                  final r = await _editor.blocklyController.runJavaScriptReturningResult('(function(){return Blockly.Xml.domToText(Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()));})();');
                                  String x = r.toString(); if (x.startsWith('"')&&x.endsWith('"')) x = jsonDecode(x) as String;
                                  _sel.workspaceXml = x.replaceAll('\\"','"').replaceAll('\\n','');
                                } catch (_) {}
                                // Add new object
                                final newObj = SceneObject(name: '${c['name']} ${_objects.length+1}', icon: c['icon'] as IconData, baseColor: clr, spawnX: 20.0*_objects.length, spawnY: 20.0*_objects.length);
                                setState(() { _objects.add(newObj); _selectedObjectIndex = _objects.length - 1; });
                                // Load empty workspace
                                final nx = newObj.workspaceXml.replaceAll("'", "\\'");
                                try { await _editor.blocklyController.runJavaScriptReturningResult('(function(){var w=Blockly.getMainWorkspace();w.clear();Blockly.Xml.domToWorkspace(Blockly.utils.xml.textToDom(\'$nx\'),w);return"ok";})();'); } catch (_) {}
                                if (mounted) _showToast("${c['name']} added", Icons.person_add_alt_1_rounded, clr);
                              },
                              child: Container(
                                decoration: BoxDecoration(color: clr.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: clr.withValues(alpha: 0.3))),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, color: clr, boxShadow: [BoxShadow(color: clr.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(c['icon'] as IconData, color: Colors.white, size: 24)),
                                  const SizedBox(height: 10),
                                  Text(c['name'] as String, style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTopBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.kometDarkGreen.withValues(alpha: 0.6),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(onPressed: _onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24), splashRadius: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.assignmentTitle.isNotEmpty ? widget.assignmentTitle : "Canvas Workspace", style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_sel.icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(_sel.name, style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 16),
              if (!widget.isReviewMode) ...[
                _barBtn("Save", Icons.save_outlined, AppColors.kometTeal, onTap: _onSave),
                const SizedBox(width: 10),
              ],
              _isPlaying ? _barBtn("Stop", Icons.stop_rounded, const Color(0xFFCC5555), onTap: _onStop) : _barBtn("Play", Icons.play_arrow_rounded, AppColors.kometOlive, onTap: _onPlay),
              if (!widget.isReviewMode) ...[
                const SizedBox(width: 10),
                if (_existingSubmission?.status == SubmissionStatus.submitted)
                  _barBtn("Unsubmit", Icons.cancel_outlined, const Color(0xFFCC5555), onTap: _onUnsubmit)
                else
                  _barBtn("Submit", Icons.send_rounded, AppColors.kometBlue, onTap: _onSubmit),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _barBtn(String label, IconData icon, Color c, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: c.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.withValues(alpha: 0.8), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(label, style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenePanel() {
    Widget panel = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: widget.isReviewMode ? null : 270,
          decoration: BoxDecoration(
            color: AppColors.kometDarkGreen.withValues(alpha: 0.5),
            border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Text("Scene", style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const Spacer(),
                if (!widget.isReviewMode)
                  Material(color: AppColors.kometOlive.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16),
                    child: InkWell(onTap: _onAddObject, borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.kometOlive.withValues(alpha: 0.8)),
                        ),
                        child: Text("+ Object", style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ))),
              ]),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(8),
                child: ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onPanUpdate: (d) => setState(() { _sceneOffsetX += d.delta.dx; _sceneOffsetY += d.delta.dy; }),
                    child: Container(
                      decoration: BoxDecoration(color: _backgrounds[_bgIndex].color, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isPlaying ? AppColors.kometOlive : Colors.white.withValues(alpha: 0.2), width: _isPlaying ? 2 : 1)),
                      child: Stack(children: [
                        Positioned.fill(child: Opacity(opacity: 0.05, child: CustomPaint(painter: GridPainter(offsetX: _sceneOffsetX, offsetY: _sceneOffsetY)))),
                        for (int i = 0; i < _objects.length; i++) _buildObj(i),
                        if (_isPlaying) Positioned(top: 8, right: 8, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.kometOlive, borderRadius: BorderRadius.circular(6)),
                          child: Text("LIVE", style: GoogleFonts.nunito(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0)))),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            SizedBox(height: 44, child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), itemCount: _objects.length,
              itemBuilder: (_, i) {
                final o = _objects[i]; final s = i == _selectedObjectIndex;
                return GestureDetector(
                  onTap: () => _switchObject(i),
                  onLongPress: widget.isReviewMode ? null : () => _onDeleteObject(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: s ? o.baseColor.withValues(alpha: 0.25) : Colors.transparent, borderRadius: BorderRadius.circular(20),
                      border: s ? Border.all(color: o.baseColor.withValues(alpha: 0.6)) : Border.all(color: Colors.transparent)),
                    child: Row(children: [
                      Icon(o.icon, size: 14, color: s ? Colors.white : Colors.white60),
                      const SizedBox(width: 6),
                      Text(o.name, style: GoogleFonts.nunito(color: s ? Colors.white : Colors.white60, fontSize: 11, fontWeight: s ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                  ),
                );
              },
            )),
            Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 10), child: SizedBox(height: 28, child: ListView.builder(
              scrollDirection: Axis.horizontal, itemCount: _backgrounds.length,
              itemBuilder: (_, i) {
                final bg = _backgrounds[i]; final a = i == _bgIndex;
                return GestureDetector(
                  onTap: () => setState(() => _bgIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: a ? bg.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14),
                      border: a ? Border.all(color: bg.color.withValues(alpha: 0.8)) : Border.all(color: Colors.transparent)),
                    child: Row(children: [
                      Icon(bg.icon, size: 12, color: a ? Colors.white : Colors.white54),
                      const SizedBox(width: 4),
                      Text(bg.name, style: GoogleFonts.nunito(color: a ? Colors.white : Colors.white54, fontSize: 10, fontWeight: a ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                  ),
                );
              },
            ))),
          ]),
        ),
      ),
    );

    if (widget.isReviewMode) {
      return Expanded(child: panel);
    }
    return panel;
  }

  void _onDeleteObject(int i) async {
    if (_objects.length <= 1) return;
    if (i == _selectedObjectIndex) {
      setState(() { _objects.removeAt(i); if (_selectedObjectIndex >= _objects.length) _selectedObjectIndex = _objects.length - 1; });
      final nx = _sel.workspaceXml.replaceAll("'", "\\'");
      try { await _editor.blocklyController.runJavaScriptReturningResult('(function(){var w=Blockly.getMainWorkspace();w.clear();Blockly.Xml.domToWorkspace(Blockly.utils.xml.textToDom(\'$nx\'),w);return"ok";})();'); } catch (_) {}
    } else {
      setState(() { _objects.removeAt(i); if (_selectedObjectIndex > i) _selectedObjectIndex--; });
    }
  }

  Widget _buildObj(int index) {
    final obj = _objects[index]; final sel = index == _selectedObjectIndex;
    return AnimatedPositioned(
      duration: _isPlaying ? const Duration(milliseconds: 500) : Duration.zero, curve: Curves.easeInOut,
      left: 80 + obj.x + _sceneOffsetX, top: 60 + obj.y + _sceneOffsetY,
      child: GestureDetector(
        onTap: () { if (!_isPlaying && !widget.isReviewMode) _switchObject(index); },
        onPanStart: (_) { if (!_isPlaying && !widget.isReviewMode && _selectedObjectIndex != index) _switchObject(index); },
        onPanUpdate: (d) { if (_isPlaying || widget.isReviewMode) return; setState(() { obj.spawnX += d.delta.dx; obj.spawnY += d.delta.dy; obj.x = obj.spawnX; obj.y = obj.spawnY; }); },
        child: Opacity(opacity: obj.opacity, child: Visibility(visible: obj.visible,
          child: Transform.rotate(angle: obj.rotation * 3.14159 / 180,
            child: Transform.scale(scale: obj.scale, child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (obj.speech.isNotEmpty) Container(
                margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Text(obj.speech, style: GoogleFonts.nunito(color: AppColors.kometDarkGreen, fontSize: 12, fontWeight: FontWeight.w700))),
              Container(width: 56, height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: obj.color,
                  boxShadow: sel ? [BoxShadow(color: obj.color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)] : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                  border: Border.all(color: sel ? Colors.white : Colors.white.withValues(alpha: 0.5), width: sel ? 3.0 : 1.5)),
                child: Icon(obj.icon, size: 28, color: Colors.white)),
              if (sel && !_isPlaying) Padding(padding: const EdgeInsets.only(top: 6),
                child: Text(obj.name, style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, shadows: [const Shadow(color: Colors.black54, blurRadius: 2)]))),
            ]))))),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double offsetX, offsetY;
  GridPainter({required this.offsetX, required this.offsetY});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    const sp = 30.0;
    for (double x = offsetX % sp; x < size.width; x += sp) {
      for (double y = offsetY % sp; y < size.height; y += sp) { canvas.drawCircle(Offset(x, y), 0.8, p); }
    }
  }
  @override
  bool shouldRepaint(covariant GridPainter old) => old.offsetX != offsetX || old.offsetY != offsetY;
}

class _ToastWidget extends StatefulWidget {
  final String message; final IconData icon; final Color color; final VoidCallback onDismiss;
  const _ToastWidget({required this.message, required this.icon, required this.color, required this.onDismiss});
  @override State<_ToastWidget> createState() => _ToastWidgetState();
}
class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  @override void initState() { super.initState(); _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    Future.delayed(const Duration(seconds: 3), () { if (mounted) _ac.reverse().then((_) { if (mounted) widget.onDismiss(); }); }); }
  @override void dispose() { _ac.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Positioned(top: 24, left: 0, right: 0,
      child: AnimatedBuilder(animation: _ac, builder: (_, __) => Opacity(opacity: _ac.value,
        child: Transform.translate(offset: Offset(0, -20 * (1 - _ac.value)),
          child: Center(child: Material(color: Colors.transparent, child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(widget.icon, color: Colors.white, size: 18), const SizedBox(width: 10),
                  Text(widget.message, style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
                ]),
              ),
            ),
          )))))));
  }
}

class AnimatedGlowingBackground extends StatelessWidget {
  final Animation<double> animation;
  const AnimatedGlowingBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: AppColors.kometDarkGreen),
            // Orb 1: Teal
            Positioned(
              top: -150 + (animation.value * 100),
              left: -100 - (animation.value * 50),
              child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.kometTeal.withValues(alpha: 0.4), blurRadius: 200, spreadRadius: 50)
                  ]
                ),
              ),
            ),
            // Orb 2: Olive
            Positioned(
              bottom: -200 - (animation.value * 80),
              right: -50 + (animation.value * 60),
              child: Container(
                width: 600, height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.kometOlive.withValues(alpha: 0.35), blurRadius: 200, spreadRadius: 80)
                  ]
                ),
              ),
            ),
            // Orb 3: Blue
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3 + (animation.value * 60),
              left: MediaQuery.of(context).size.width * 0.4 - (animation.value * 70),
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.kometBlue.withValues(alpha: 0.25), blurRadius: 250, spreadRadius: 60)
                  ]
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
