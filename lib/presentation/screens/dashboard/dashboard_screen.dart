// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/common/apex_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final _profileRepo = ProfileRepository();
  final _scriptRepo  = ScriptRepository();
  final _sessionRepo = SessionRepository();
  int _tab = 0;
  UserEntity?          _user;
  List<ScriptEntity>   _scripts  = [];
  List<SessionEntity>  _sessions = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _profileRepo.getProfile(),
      _scriptRepo.getAll(),
      _sessionRepo.getAll(),
    ]);
    if (!mounted) return;
    results[0].fold((_){}, (u) => _user   = u as UserEntity);
    results[1].fold((_){}, (s) => _scripts  = s as List<ScriptEntity>);
    results[2].fold((_){}, (s) => _sessions = s as List<SessionEntity>);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: _loading
      ? const Center(child: CircularProgressIndicator(color: AppColors.goldRoyal))
      : IndexedStack(index: _tab, children: [
          _HomeTab(user:_user, scripts:_scripts, sessions:_sessions, onRefresh:_load),
          _ScriptsTab(scripts:_scripts, onRefresh:_load),
          _AnalyticsTab(sessions:_sessions),
          const _ProfileTab(),
        ]),
    bottomNavigationBar: _BottomNav(index:_tab, onTap:(i)=>setState(()=>_tab=i)),
  );
}

// ── Home Tab ──────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final UserEntity? user;
  final List<ScriptEntity> scripts;
  final List<SessionEntity> sessions;
  final VoidCallback onRefresh;
  const _HomeTab({required this.user, required this.scripts,
      required this.sessions, required this.onRefresh});

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers:[
    SliverAppBar(expandedHeight:180, pinned:true, backgroundColor:AppColors.obsidian,
      flexibleSpace: FlexibleSpaceBar(background: Stack(children:[
        Container(decoration:const BoxDecoration(gradient:AppColors.darkGradient)),
        Positioned(top:-30, right:-20, child:Container(width:160, height:160,
          decoration:BoxDecoration(shape:BoxShape.circle,
            border:Border.all(color:AppColors.goldDim)))),
        Positioned(bottom:14, left:20, right:20, child: Row(children:[
          Container(width:46, height:46,
            decoration: BoxDecoration(shape:BoxShape.circle,
              gradient:AppColors.goldGradient,
              boxShadow:[BoxShadow(color:AppColors.goldGlow, blurRadius:12)]),
            child: Center(child: Text(user?.fullName.substring(0,1) ?? 'A',
              style:const TextStyle(fontFamily:'Outfit', fontSize:20,
                  fontWeight:FontWeight.w800, color:AppColors.obsidian)))),
          const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            const Text('Good morning,', style:TextStyle(fontFamily:'Outfit',
                fontSize:11, color:AppColors.textMuted)),
            Text(user?.fullName ?? '…', style:const TextStyle(fontFamily:'Outfit',
                fontSize:15, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
          ])),
          Container(padding:const EdgeInsets.symmetric(horizontal:10, vertical:5),
            decoration: BoxDecoration(color:AppColors.goldDim,
              borderRadius:BorderRadius.circular(20),
              border:Border.all(color:AppColors.goldRoyal),
              boxShadow:[BoxShadow(color:AppColors.goldGlow, blurRadius:8)]),
            child:Text('⭐ LVL ${user?.apexLevel ?? 1} ${(user?.levelName ?? 'Novice').toUpperCase()}',
              style:const TextStyle(fontFamily:'Outfit', fontSize:10,
                  fontWeight:FontWeight.w700, color:AppColors.goldBright, letterSpacing:0.5))),
        ])),
      ])),
    ),
    SliverPadding(padding:const EdgeInsets.all(18), sliver: SliverList(
      delegate: SliverChildListDelegate([
        // Stats row
        Row(children:[
          _Stat('${user?.totalSessions??0}','Sessions',Icons.play_circle_outline,AppColors.accentBlue),
          const SizedBox(width:10),
          _Stat('${user?.avgConfidence.toInt()??0}%','Avg Score',Icons.trending_up,AppColors.matrixGreen),
          const SizedBox(width:10),
          _Stat('🔥 ${user?.streakDays??0}','Day Streak',Icons.local_fire_department,AppColors.amberWarning),
        ]).animate().fadeIn(delay:100.ms),
        const SizedBox(height:22),
        // Start CTA
        GestureDetector(onTap:()=>context.push(AppRouter.livePractice),
          child:Container(height:110,
            decoration:BoxDecoration(gradient:const LinearGradient(
              colors:[Color(0xFF2A1E00), Color(0xFF1A1200)]),
              borderRadius:BorderRadius.circular(18),
              border:Border.all(color:AppColors.goldDim, width:1.5),
              boxShadow:[BoxShadow(color:AppColors.goldGlow, blurRadius:20)]),
            child:Row(children:[
              const SizedBox(width:18),
              Container(width:54, height:54, decoration:BoxDecoration(
                shape:BoxShape.circle, color:AppColors.goldGlow,
                border:Border.all(color:AppColors.goldRoyal, width:1.5)),
                child:const Icon(Icons.play_arrow_rounded, color:AppColors.goldBright, size:28)),
              const SizedBox(width:16),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
                mainAxisAlignment:MainAxisAlignment.center, children:[
                  const Text('START PRACTICE', style:TextStyle(fontFamily:'Outfit',
                      fontSize:17, fontWeight:FontWeight.w800, color:AppColors.goldBright, letterSpacing:0.5)),
                  const SizedBox(height:3),
                  const Text('Live posture + vocal AI feedback', style:TextStyle(
                    fontFamily:'Outfit', fontSize:11, color:AppColors.textSecondary)),
                ])),
              const Icon(Icons.arrow_forward_ios, color:AppColors.goldRoyal, size:14),
              const SizedBox(width:18),
            ]),
          ),
        ).animate().fadeIn(delay:180.ms),
        const SizedBox(height:24),
        // Recent sessions
        SectionHeader(title:'Recent Sessions', sub:'${sessions.length} total',
          action:TextButton(onPressed:(){}, child:const Text('See All',
            style:TextStyle(fontFamily:'Outfit', fontSize:11, color:AppColors.goldRoyal)))),
        const SizedBox(height:10),
        if (sessions.isEmpty)
          _EmptyState('No sessions yet', 'Tap Start Practice to begin', Icons.mic_none),
        ...sessions.take(3).toList().asMap().entries.map((e) => Padding(
          padding:const EdgeInsets.only(bottom:10),
          child: _SessionCard(e.value, onTap:()=>context.push(AppRouter.postGame, extra:e.value.id))
            .animate().fadeIn(delay:Duration(milliseconds:300+e.key*70)).slideX(begin:0.04, end:0),
        )),
        const SizedBox(height:24),
        // Scripts preview
        SectionHeader(title:'My Scripts', sub:'${scripts.length} saved',
          action:IconButton(icon:const Icon(Icons.add, color:AppColors.goldRoyal, size:20),
            onPressed:()=>context.push(AppRouter.scriptEditor))),
        const SizedBox(height:10),
        if (scripts.isEmpty)
          _EmptyState('No scripts yet', 'Create your first speech script', Icons.description_outlined),
        if (scripts.isNotEmpty) SizedBox(height:130, child:ListView.separated(
          scrollDirection:Axis.horizontal, itemCount:scripts.length,
          separatorBuilder:(_,__)=>const SizedBox(width:12),
          itemBuilder:(ctx, i)=>_ScriptMiniCard(scripts[i],
            onTap:()=>context.push(AppRouter.scriptEditor, extra:scripts[i].id)),
        )),
        const SizedBox(height:90),
      ]),
    )),
  ]);
}

class _Stat extends StatelessWidget {
  final String v, l; final IconData icon; final Color c;
  const _Stat(this.v, this.l, this.icon, this.c);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(11), decoration: BoxDecoration(color:AppColors.cardDark,
      borderRadius:BorderRadius.circular(12), border:Border.all(color:AppColors.borderDark)),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Icon(icon, color:c, size:15), const SizedBox(height:5),
      Text(v, style:const TextStyle(fontFamily:'Outfit', fontSize:17,
          fontWeight:FontWeight.w800, color:AppColors.textPrimary)),
      Text(l, style:const TextStyle(fontFamily:'Outfit', fontSize:9, color:AppColors.textMuted)),
    ]),
  ));
}

class _SessionCard extends StatelessWidget {
  final SessionEntity s; final VoidCallback onTap;
  const _SessionCard(this.s, {required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap:onTap,
    child:Container(padding:const EdgeInsets.all(13),
      decoration:BoxDecoration(color:AppColors.cardDark, borderRadius:BorderRadius.circular(13),
        border:Border.all(color:AppColors.borderDark)),
      child:Row(children:[
        GradeBadge(grade:s.grade),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('Session ${s.id}', style:const TextStyle(fontFamily:'Outfit', fontSize:13,
              fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
          Text('${s.confidenceScore.toInt()}% confidence  ·  ${s.durationLabel}',
            style:const TextStyle(fontFamily:'Outfit', fontSize:11, color:AppColors.textMuted)),
        ])),
        Text(s.createdAt.substring(0,10), style:const TextStyle(
          fontFamily:'Outfit', fontSize:10, color:AppColors.textMuted)),
      ]),
    ));
}

class _ScriptMiniCard extends StatelessWidget {
  final ScriptEntity s; final VoidCallback onTap;
  const _ScriptMiniCard(this.s, {required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap:onTap,
    child:Container(width:160, padding:const EdgeInsets.all(13),
      decoration:BoxDecoration(gradient:AppColors.cardGradient, borderRadius:BorderRadius.circular(13),
        border:Border.all(color:AppColors.borderDark)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Expanded(child:Text(s.title, maxLines:2, style:const TextStyle(fontFamily:'Outfit',
            fontSize:13, fontWeight:FontWeight.w600, color:AppColors.textPrimary, height:1.3))),
        Text(s.audienceType, style:const TextStyle(fontFamily:'Outfit', fontSize:10, color:AppColors.textMuted)),
        const SizedBox(height:5),
        Row(children:[
          if (s.isApexified) Container(padding:const EdgeInsets.symmetric(horizontal:6, vertical:2),
            decoration:BoxDecoration(color:AppColors.goldDim, borderRadius:BorderRadius.circular(6)),
            child:const Text('⚡ APEX', style:TextStyle(fontFamily:'Outfit', fontSize:9,
                fontWeight:FontWeight.w700, color:AppColors.goldBright))),
          const Spacer(),
          Text(s.durationLabel, style:const TextStyle(fontFamily:'Outfit', fontSize:10, color:AppColors.textMuted)),
        ]),
      ]),
    ));
}

class _EmptyState extends StatelessWidget {
  final String title, sub; final IconData icon;
  const _EmptyState(this.title, this.sub, this.icon);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom:16), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color:AppColors.cardDark, borderRadius:BorderRadius.circular(12),
      border:Border.all(color:AppColors.borderDark)),
    child:Column(children:[
      Icon(icon, color:AppColors.textMuted, size:32),
      const SizedBox(height:8),
      Text(title, style:const TextStyle(fontFamily:'Outfit', fontSize:13,
          fontWeight:FontWeight.w600, color:AppColors.textSecondary)),
      Text(sub, style:const TextStyle(fontFamily:'Outfit', fontSize:11, color:AppColors.textMuted)),
    ]),
  );
}

// ── Scripts Tab ───────────────────────────────────────────
class _ScriptsTab extends StatelessWidget {
  final List<ScriptEntity> scripts; final VoidCallback onRefresh;
  const _ScriptsTab({required this.scripts, required this.onRefresh});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor:AppColors.obsidian,
    appBar:AppBar(title:const Text('MY SCRIPTS'),
      actions:[IconButton(icon:const Icon(Icons.add, color:AppColors.goldRoyal),
        onPressed:()=>context.push(AppRouter.scriptEditor).then((_)=>onRefresh()))]),
    body: scripts.isEmpty
      ? Center(child:Column(mainAxisSize:MainAxisSize.min, children:[
          const Icon(Icons.description_outlined, color:AppColors.textMuted, size:52),
          const SizedBox(height:12),
          const Text('No scripts yet', style:TextStyle(fontFamily:'Outfit', fontSize:16,
              fontWeight:FontWeight.w600, color:AppColors.textSecondary)),
          const SizedBox(height:20),
          GoldButton(label:'Create Script', icon:Icons.add,
            isFullWidth:false,
            onTap:()=>context.push(AppRouter.scriptEditor).then((_)=>onRefresh())),
        ]))
      : ListView.builder(padding:const EdgeInsets.all(18), itemCount:scripts.length,
          itemBuilder:(ctx, i) {
            final s = scripts[i];
            return Container(margin:const EdgeInsets.only(bottom:12), padding:const EdgeInsets.all(15),
              decoration:BoxDecoration(color:AppColors.cardDark, borderRadius:BorderRadius.circular(13),
                border:Border.all(color:AppColors.borderDark)),
              child:GestureDetector(onTap:()=>context.push(AppRouter.scriptEditor, extra:s.id)
                  .then((_)=>onRefresh()),
                child:Row(children:[
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                    Text(s.title, style:const TextStyle(fontFamily:'Outfit', fontSize:14,
                        fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
                    const SizedBox(height:3),
                    Text('${s.audienceType}  ·  ${s.durationLabel}', style:const TextStyle(
                      fontFamily:'Outfit', fontSize:11, color:AppColors.textMuted)),
                  ])),
                  if (s.isApexified) Container(padding:const EdgeInsets.symmetric(horizontal:7, vertical:3),
                    decoration:BoxDecoration(color:AppColors.goldDim, borderRadius:BorderRadius.circular(7)),
                    child:const Text('⚡ APEX', style:TextStyle(fontFamily:'Outfit', fontSize:10,
                        fontWeight:FontWeight.w700, color:AppColors.goldBright))),
                ]),
              ),
            ).animate().fadeIn(delay:Duration(milliseconds:i*60)).slideX(begin:0.04, end:0);
          }),
    floatingActionButton: FloatingActionButton.extended(
      onPressed:()=>context.push(AppRouter.scriptEditor).then((_)=>onRefresh()),
      backgroundColor:AppColors.goldRoyal, foregroundColor:AppColors.obsidian,
      icon:const Icon(Icons.add), label:const Text('NEW SCRIPT',
        style:TextStyle(fontFamily:'Outfit', fontWeight:FontWeight.w700, letterSpacing:1))),
  );
}

// ── Analytics Tab ─────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final List<SessionEntity> sessions;
  const _AnalyticsTab({required this.sessions});
  @override Widget build(BuildContext context) {
    final avgConf = sessions.isEmpty ? 0.0 : sessions.map((s)=>s.confidenceScore).reduce((a,b)=>a+b)/sessions.length;
    final avgEnth = sessions.isEmpty ? 0.0 : sessions.map((s)=>s.enthusiasmScore).reduce((a,b)=>a+b)/sessions.length;
    final avgAuth = sessions.isEmpty ? 0.0 : sessions.map((s)=>s.authorityScore).reduce((a,b)=>a+b)/sessions.length;
    return Scaffold(backgroundColor:AppColors.obsidian,
      appBar:AppBar(title:const Text('ANALYTICS')),
      body:SingleChildScrollView(padding:const EdgeInsets.all(18), child:Column(children:[
        const SectionHeader(title:'Average Performance'),
        const SizedBox(height:16),
        Row(mainAxisAlignment:MainAxisAlignment.spaceAround, children:[
          ScoreRing(score:avgConf, label:'CONFIDENCE', color:AppColors.matrixGreen, size:88),
          ScoreRing(score:avgEnth, label:'ENTHUSIASM', color:AppColors.goldRoyal, size:88),
          ScoreRing(score:avgAuth, label:'AUTHORITY', color:AppColors.accentBlue, size:88),
        ]).animate().fadeIn(delay:150.ms),
        const SizedBox(height:28),
        const SectionHeader(title:'All Sessions'),
        const SizedBox(height:12),
        if (sessions.isEmpty) const Center(child:Padding(padding:EdgeInsets.all(32),
          child:Text('Complete your first session to see analytics.',
            textAlign:TextAlign.center,
            style:TextStyle(fontFamily:'Outfit', color:AppColors.textMuted, fontSize:13)))),
        ...sessions.asMap().entries.map((e) => Padding(
          padding:const EdgeInsets.only(bottom:10),
          child: _SessionCard(e.value, onTap:()=>Navigator.of(context).push(MaterialPageRoute(
            builder:(_)=>Scaffold()))).animate().fadeIn(delay:Duration(milliseconds:e.key*60)),
        )),
      ])),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor:AppColors.obsidian,
    appBar:AppBar(title:const Text('PROFILE')),
    body:Center(child:Column(mainAxisSize:MainAxisSize.min, children:[
      const Text('Profile', style:TextStyle(color:AppColors.textMuted)),
      const SizedBox(height:20),
      GoldButton(label:'Sign Out', isFullWidth:false, icon:Icons.logout,
        onTap:() async {
          await AuthRepository().logout();
          if(context.mounted) context.go(AppRouter.login);
        }),
    ])),
  );
}

// ── Bottom Nav ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int index; final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});
  @override Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined,       Icons.home_rounded,       'Home'),
      (Icons.description_outlined,Icons.description_rounded,'Scripts'),
      (Icons.bar_chart_outlined,  Icons.bar_chart_rounded,  'Analytics'),
      (Icons.person_outline,      Icons.person_rounded,     'Profile'),
    ];
    return Container(decoration:const BoxDecoration(color:AppColors.surfaceDark,
        border:Border(top:BorderSide(color:AppColors.borderDark))),
      child:SafeArea(child:SizedBox(height:56, child:Row(
        children:items.asMap().entries.map((e){
          final sel = index==e.key;
          final (out, fill, label) = e.value;
          return Expanded(child:GestureDetector(
            onTap:()=>onTap(e.key), behavior:HitTestBehavior.opaque,
            child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[
              Icon(sel?fill:out, color:sel?AppColors.goldRoyal:AppColors.textMuted, size:21),
              const SizedBox(height:2),
              Text(label, style:TextStyle(fontFamily:'Outfit', fontSize:9,
                  fontWeight:sel?FontWeight.w600:FontWeight.w400,
                  color:sel?AppColors.goldRoyal:AppColors.textMuted)),
            ]),
          ));
        }).toList(),
      ))),
    );
  }
}
