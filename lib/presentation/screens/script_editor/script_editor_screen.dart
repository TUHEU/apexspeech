// lib/presentation/screens/script_editor/script_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/common/apex_widgets.dart';

class ScriptEditorScreen extends StatefulWidget {
  final int? scriptId;
  const ScriptEditorScreen({super.key, this.scriptId});
  @override
  State<ScriptEditorScreen> createState() => _ScriptEditorScreenState();
}

class _ScriptEditorScreenState extends State<ScriptEditorScreen>
    with TickerProviderStateMixin {
  final _repo = ScriptRepository();
  final _titleCtrl = TextEditingController();
  final _rawCtrl = TextEditingController();
  final _apexCtrl = TextEditingController();
  late TabController _tabs;

  ScriptEntity? _script;
  bool _saving = false,
      _apexifying = false,
      _generatingQA = false,
      _loading = false;
  String _audience = 'Executives';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    if (widget.scriptId != null) _loadScript(widget.scriptId!);
  }

  // ── Load existing script by id ─────────────────────────
  Future<void> _loadScript(int id) async {
    setState(() => _loading = true);
    final r = await _repo.getById(id);
    r.fold((_) {}, (s) {
      _script = s;
      _titleCtrl.text = s.title;
      _rawCtrl.text = s.rawText;
      _apexCtrl.text = s.apexifiedText ?? '';
      _audience = s.audienceType;
    });
    setState(() => _loading = false);
  }

  // ── Save (create or update) — returns true on success ──
  // popOnSuccess: false when called internally (before apexify/qa)
  Future<bool> _save({bool popOnSuccess = true}) async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a title first');
      return false;
    }
    setState(() => _saving = true);

    if (_script == null) {
      // Creating a new script — capture the returned entity
      final r = await _repo.create({
        'title': _titleCtrl.text.trim(),
        'raw_text': _rawCtrl.text.trim(),
        'audience_type': _audience,
        'estimated_duration': _rawCtrl.text.split(' ').length ~/ 2,
      });
      setState(() => _saving = false);
      return r.fold(
        (f) {
          _showSnack(f.message);
          return false;
        },
        (s) {
          _script = s; // ← store the created script
          if (popOnSuccess && mounted) context.pop();
          return true;
        },
      );
    } else {
      // Updating existing script
      final r = await _repo.update(_script!.id, {
        'title': _titleCtrl.text.trim(),
        'raw_text': _rawCtrl.text.trim(),
        'audience_type': _audience,
      });
      setState(() => _saving = false);
      return r.fold(
        (f) {
          _showSnack(f.message);
          return false;
        },
        (s) {
          _script = s;
          if (popOnSuccess && mounted) context.pop();
          return true;
        },
      );
    }
  }

  // ── Apexify ────────────────────────────────────────────
  Future<void> _apexify() async {
    // If no script saved yet, save first WITHOUT popping
    if (_script == null) {
      final saved = await _save(popOnSuccess: false);
      if (!saved) return; // save failed — stop
    }
    if (_script == null) return; // still null — stop

    setState(() => _apexifying = true);
    final r = await _repo.apexify(_script!.id);
    r.fold((f) => _showSnack(f.message), (s) {
      _script = s;
      _apexCtrl.text = s.apexifiedText ?? '';
      _tabs.animateTo(1);
    });
    setState(() => _apexifying = false);
  }

  // ── Generate Q&A ───────────────────────────────────────
  Future<void> _generateQA() async {
    if (_script == null) {
      final saved = await _save(popOnSuccess: false);
      if (!saved) return;
    }
    if (_script == null) return;

    setState(() => _generatingQA = true);
    final r = await _repo.generateQA(_script!.id);
    r.fold((f) => _showSnack(f.message), (list) {
      _script = ScriptEntity(
        id: _script!.id,
        title: _script!.title,
        rawText: _script!.rawText,
        apexifiedText: _script!.apexifiedText,
        audienceType: _script!.audienceType,
        estimatedDuration: _script!.estimatedDuration,
        isApexified: _script!.isApexified,
        createdAt: _script!.createdAt,
        qaList: list,
      );
      _tabs.animateTo(2);
    });
    setState(() => _generatingQA = false);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rawCtrl.dispose();
    _apexCtrl.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.goldRoyal,
          size: 18,
        ),
        onPressed: () => context.pop(),
      ),
      title: TextField(
        controller: _titleCtrl,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: 'Script title…',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => _save(),
          child: Text(
            _saving ? 'Saving…' : 'SAVE',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.goldRoyal,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabs,
        indicatorColor: AppColors.goldRoyal,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
        ),
        labelColor: AppColors.goldRoyal,
        unselectedLabelColor: AppColors.textMuted,
        tabs: const [
          Tab(text: 'RAW DRAFT'),
          Tab(text: '⚡ APEX'),
          Tab(text: 'Q&A PREP'),
        ],
      ),
    ),
    body: _loading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.goldRoyal),
          )
        : TabBarView(
            controller: _tabs,
            children: [
              // ── Tab 0: Raw Draft ─────────────────────────
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Audience:',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        DropdownButton<String>(
                          value: _audience,
                          isDense: true,
                          dropdownColor: AppColors.surfaceDark,
                          underline: const SizedBox(),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          items:
                              [
                                    'General',
                                    'Executives',
                                    'Investors',
                                    'Students',
                                    'Media',
                                    'Clients',
                                  ]
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _audience = v!),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _rawCtrl,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.75,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText:
                              'Type your raw speech ideas here…\n\nDon\'t worry about perfection — just get your thoughts down. GPT-4o will refine everything.',
                          hintStyle: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.75,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border(
                        top: BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                    child: GoldButton(
                      label: _apexifying
                          ? 'Apexifying…'
                          : '⚡ Apexify with GPT-4o',
                      isLoading: _apexifying,
                      onTap: _apexifying ? null : _apexify,
                    ),
                  ),
                ],
              ),

              // ── Tab 1: Apexified ─────────────────────────
              _apexifying
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.goldDim,
                                  border: Border.all(
                                    color: AppColors.goldRoyal,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldGlow,
                                      blurRadius: 28,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.goldBright,
                                  size: 32,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .shimmer(
                                duration: 1200.ms,
                                color: AppColors.goldGlow,
                              ),
                          const SizedBox(height: 16),
                          const Text(
                            'GPT-4o is refining your speech…',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _apexCtrl.text.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.goldGradient.createShader(b),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Not Apexified Yet',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Write your speech in the Draft tab first, then tap Apexify.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 22),
                            GoldButton(label: '⚡ Apexify Now', onTap: _apexify),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A1E00), Color(0xFF1A1200)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.goldDim),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.goldBright,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'GPT-4o refinement complete.',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.goldDim,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '⚡ APEX',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldBright,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _apexCtrl,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.8,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceDark,
                            border: Border(
                              top: BorderSide(color: AppColors.borderDark),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GoldOutlinedButton(
                                  label: 'Gen Q&A',
                                  icon: Icons.quiz_outlined,
                                  height: 46,
                                  onTap: _generatingQA ? null : _generateQA,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GoldButton(
                                  label: 'Practice',
                                  icon: Icons.play_arrow_rounded,
                                  height: 46,
                                  onTap: () => context.push(
                                    AppRouter.livePractice,
                                    extra: _script?.id,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

              // ── Tab 2: Q&A ───────────────────────────────
              _generatingQA
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldRoyal,
                      ),
                    )
                  : (_script?.qaList.isEmpty ?? true)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No Q&A Generated',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Generate 5 tough questions your audience might ask, with suggested answers.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 22),
                            GoldButton(
                              label: '🎯 Generate Q&A',
                              onTap: _generateQA,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _script!.qaList.length,
                      itemBuilder: (ctx, i) {
                        final qa = _script!.qaList[i];
                        return _QACard(number: i + 1, qa: qa).animate().fadeIn(
                          delay: Duration(milliseconds: i * 80),
                        );
                      },
                    ),
            ],
          ),
  );
}

// ── Q&A Card ──────────────────────────────────────────────
class _QACard extends StatefulWidget {
  final int number;
  final QAEntity qa;
  const _QACard({required this.number, required this.qa});
  @override
  State<_QACard> createState() => _QACardState();
}

class _QACardState extends State<_QACard> {
  bool _open = false;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.borderDark),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldDim,
                    border: Border.all(color: AppColors.goldMuted),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.number}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldBright,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.qa.question,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Container(
            margin: const EdgeInsets.fromLTRB(13, 0, 13, 13),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.accentBlue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 13,
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    widget.qa.suggestedAnswer,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 180.ms),
      ],
    ),
  );
}
