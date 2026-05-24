// lib/presentation/screens/script_editor/script_editor_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class ScriptEditorScreen extends StatefulWidget {
  final String? scriptId;
  const ScriptEditorScreen({super.key, this.scriptId});

  @override
  State<ScriptEditorScreen> createState() => _ScriptEditorScreenState();
}

class _ScriptEditorScreenState extends State<ScriptEditorScreen>
    with TickerProviderStateMixin {
  final _titleCtrl   = TextEditingController(text: 'My Executive Speech');
  final _rawCtrl     = TextEditingController();
  final _apexCtrl    = TextEditingController();
  late TabController _tabCtrl;

  bool _isApexifying = false;
  bool _isApexified  = false;
  bool _isGeneratingQA = false;
  String _selectedAudience = 'Executives';

  final _audiences = ['Executives', 'Investors', 'Students', 'General', 'Media', 'Clients'];
  final _qaList = <_QAItem>[];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    if (widget.scriptId != null) {
      _rawCtrl.text = '''Good afternoon everyone.

Today I want to talk about, um, the future of our company and basically where we're heading in the next few years.

So like, we have a really good product and I think, you know, our team is really working hard to make it better.

The thing is, we kind of have this opportunity and I feel like we should, you know, take advantage of it.

Thank you.''';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rawCtrl.dispose();
    _apexCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _apexify() async {
    if (_rawCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write your speech first!',
            style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppColors.amberWarning,
        ),
      );
      return;
    }
    setState(() => _isApexifying = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isApexifying = false;
      _isApexified = true;
      _apexCtrl.text = '''Ladies and gentlemen, visionary leaders of tomorrow —

The future doesn't wait. It rewards those bold enough to seize it.

Our company stands at the apex of a transformational moment. The product we've built doesn't just solve a problem — it redefines the standard of excellence in our industry. Our team isn't just working hard — they're architecting the future.

And the opportunity before us? It isn't just good timing. It's generational.

The question isn't whether we act. The question is: how brilliantly will we execute?

I invite you to join us in building something extraordinary.

The future belongs to the prepared.''';
      _tabCtrl.animateTo(1);
    });
  }

  Future<void> _generateQA() async {
    setState(() => _isGeneratingQA = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGeneratingQA = false;
      _qaList.addAll([
        _QAItem(
          q: 'What specific metrics support your claim that this is a generational opportunity?',
          a: 'Cite market size data, growth trajectory, and timing relative to competitor landscape.',
        ),
        _QAItem(
          q: 'How does your team\'s expertise differentiate you from existing solutions?',
          a: 'Highlight key team credentials, unique IP, and past track record of execution.',
        ),
        _QAItem(
          q: 'What is your 12-month execution roadmap and key milestones?',
          a: 'Provide 3–4 concrete milestones with dates, metrics, and resource requirements.',
        ),
        _QAItem(
          q: 'How do you plan to scale while maintaining product quality?',
          a: 'Discuss systems, processes, hiring plan, and quality checkpoints built into your roadmap.',
        ),
        _QAItem(
          q: 'What happens if market conditions change before you reach your targets?',
          a: 'Address contingency planning, adaptability of the model, and pivot readiness.',
        ),
      ]);
      _tabCtrl.animateTo(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.goldRoyal, size: 18),
          onPressed: () => context.go(AppRouter.dashboard),
        ),
        title: const Text('SCRIPT EDITOR'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('SAVE',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.goldRoyal, letterSpacing: 1)),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.goldRoyal,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
          labelColor: AppColors.goldRoyal,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'RAW DRAFT'),
            Tab(text: '⚡ APEXIFIED'),
            Tab(text: 'Q&A PREP'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleCtrl,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 16,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Script title...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
                // Audience selector
                GestureDetector(
                  onTap: _showAudiencePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(_selectedAudience,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderDark, height: 1),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _RawDraftTab(
                  controller: _rawCtrl,
                  isApexifying: _isApexifying,
                  onApexify: _apexify,
                ),
                _ApexifiedTab(
                  controller: _apexCtrl,
                  isApexified: _isApexified,
                  isApexifying: _isApexifying,
                  onApexify: _apexify,
                  isGeneratingQA: _isGeneratingQA,
                  onGenerateQA: _generateQA,
                  onPractice: () => context.push(AppRouter.livePractice,
                      extra: <String, dynamic>{'scriptId': 'mock'}),
                ),
                _QATab(
                  qaList: _qaList,
                  isGenerating: _isGeneratingQA,
                  onGenerate: _generateQA,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAudiencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Audience',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 16,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _audiences.map((a) =>
                ApexChip(
                  label: a,
                  isSelected: _selectedAudience == a,
                  onTap: () {
                    setState(() => _selectedAudience = a);
                    Navigator.pop(context);
                  },
                ),
              ).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _RawDraftTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isApexifying;
  final VoidCallback onApexify;

  const _RawDraftTab({
    required this.controller,
    required this.isApexifying,
    required this.onApexify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'Outfit', fontSize: 15,
                color: AppColors.textPrimary, height: 1.7,
              ),
              decoration: const InputDecoration(
                hintText: 'Type your raw speech ideas here...\n\nDon\'t worry about perfection — just get your thoughts down. The AI will refine everything.',
                hintStyle: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textMuted, height: 1.7),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        // Bottom action bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(top: BorderSide(color: AppColors.borderDark)),
          ),
          child: GoldButton(
            label: isApexifying ? 'Apexifying...' : '⚡ Apexify with GPT-4o',
            isLoading: isApexifying,
            onTap: onApexify,
          ),
        ),
      ],
    );
  }
}

class _ApexifiedTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isApexified, isApexifying, isGeneratingQA;
  final VoidCallback onApexify, onGenerateQA, onPractice;

  const _ApexifiedTab({
    required this.controller, required this.isApexified,
    required this.isApexifying, required this.isGeneratingQA,
    required this.onApexify, required this.onGenerateQA, required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    if (isApexifying) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldDim,
                border: Border.all(color: AppColors.goldRoyal, width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 30)],
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.goldBright, size: 36),
            ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: AppColors.goldGlowBright),
            const SizedBox(height: 20),
            const Text('GPT-4o is refining your speech...',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Removing jargon · Adding hooks · Maximizing impact',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    if (!isApexified) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Not Apexified Yet',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Write your raw speech in the Draft tab, then tap Apexify to transform it with executive-level precision.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted, height: 1.6)),
              const SizedBox(height: 24),
              GoldButton(label: '⚡ Apexify Now', onTap: onApexify),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Apex badge
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1E00), Color(0xFF1A1200)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldDim, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.goldBright, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('GPT-4o refinement complete. Jargon removed, impact maximized.',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textSecondary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('⚡ APEX',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 10,
                      fontWeight: FontWeight.w700, color: AppColors.goldBright)),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        // Apexified text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'Outfit', fontSize: 15,
                color: AppColors.textPrimary, height: 1.8,
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

        // Action bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(top: BorderSide(color: AppColors.borderDark)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GoldOutlinedButton(
                  label: 'Gen Q&A',
                  prefixIcon: Icons.quiz_outlined,
                  onTap: isGeneratingQA ? null : onGenerateQA,
                  height: 46,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GoldButton(
                  label: 'Practice',
                  prefixIcon: Icons.play_arrow_rounded,
                  onTap: onPractice,
                  height: 46,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QATab extends StatelessWidget {
  final List<_QAItem> qaList;
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _QATab({
    required this.qaList,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.goldRoyal),
            const SizedBox(height: 16),
            const Text('Generating tough questions...',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (qaList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined, size: 52, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('No Q&A Generated',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('The AI will generate the 5 most likely difficult questions your audience will ask — with suggested answers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted, height: 1.6)),
              const SizedBox(height: 24),
              GoldButton(label: '🎯 Generate Q&A', onTap: onGenerate),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: qaList.length,
      itemBuilder: (ctx, i) {
        final item = qaList[i];
        return _QACard(number: i + 1, item: item)
          .animate().fadeIn(delay: Duration(milliseconds: i * 100))
          .slideY(begin: 0.05, end: 0, delay: Duration(milliseconds: i * 100));
      },
    );
  }
}

class _QACard extends StatefulWidget {
  final int number;
  final _QAItem item;
  const _QACard({required this.number, required this.item});

  @override
  State<_QACard> createState() => _QACardState();
}

class _QACardState extends State<_QACard> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          GestureDetector(
            onTap: () => setState(() => _showAnswer = !_showAnswer),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldDim,
                      border: Border.all(color: AppColors.goldMuted, width: 1),
                    ),
                    child: Center(
                      child: Text('${widget.number}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 11,
                            fontWeight: FontWeight.w700, color: AppColors.goldBright)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.item.q,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13,
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showAnswer ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted, size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Answer (expandable)
          if (_showAnswer)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentBlueBright.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentBlueBright.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.accentBlueBright),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.item.a,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 12,
                          color: AppColors.textSecondary, height: 1.6)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
        ],
      ),
    );
  }
}

class _QAItem {
  final String q, a;
  const _QAItem({required this.q, required this.a});
}
