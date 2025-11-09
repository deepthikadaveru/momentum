import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MomentumApp());

/* =========================== THEME: CALM FOCUS =========================== */

class Palette {
  static const bg = Color(0xFFFAF8F6);        // soft creamy background
  static const card = Color(0xFFFFFFFF);      // white cards
  static const accent = Color.fromARGB(255, 42, 94, 0);    // eucalyptus green
  static const accent2 = Color(0xFFE8C7A0);   // warm sand beige
  static const text = Color(0xFF3B3A3A);      // charcoal text
  static const highlight = Color(0xFFA2D6B3); // light minty highlight
  static const divider = Color(0xFFEDE9E4);   // subtle divider
}


ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Palette.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 24, 151, 34),
      brightness: Brightness.light,
      surface: Palette.bg, // Changed 'background' to 'surface'
      primary: Palette.accent,
    ),
    cardColor: Palette.card,
    dividerColor: Palette.divider,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Palette.accent,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.accent,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Palette.card,
      selectedItemColor: Palette.accent,
      unselectedItemColor: Colors.black45,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black38),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Palette.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Palette.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Palette.accent, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  // System fonts only (DartPad): prefer a modern, real-app feel
  TextStyle baseText(double size, {FontWeight w = FontWeight.w500}) =>
      TextStyle(fontSize: size, fontWeight: w, color: Palette.text, height: 1.2);

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineSmall: baseText(26, w: FontWeight.w700),
      titleLarge: baseText(20, w: FontWeight.w700),
      titleMedium: baseText(16, w: FontWeight.w700),
      bodyLarge: baseText(16, w: FontWeight.w500),
      bodyMedium: baseText(14),
      bodySmall: baseText(12, w: FontWeight.w400),
      labelLarge: baseText(14, w: FontWeight.w700),
    ),
  );
}

/* =============================== APP STATE =============================== */

enum Priority { low, medium, high }
enum Category { work, study, personal }

class Task {
  String title;
  Priority priority;
  Category category;
  bool isDone;
  DateTime? due;
  Task(this.title,
      {this.priority = Priority.medium,
      this.category = Category.personal,
      this.isDone = false,
      this.due});
}

class NoteItem {
  String title;
  String content;
  DateTime createdAt;
  bool pinned;
  String? imageUrl; // URL-based for DartPad web
  NoteItem({
    required this.title,
    required this.content,
    this.pinned = false,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class DayPlan {
  String morning;
  String afternoon;
  String evening;
  String note;
  DayPlan({this.morning = '', this.afternoon = '', this.evening = '', this.note = ''});
}

class MomentumApp extends StatefulWidget {
  const MomentumApp({super.key});
  @override
  State<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends State<MomentumApp> {
  final List<Task> tasks = [];
  final Map<DateTime, DayPlan> plans = {};
  final List<NoteItem> notes = [];

  int totalFocusMinutes = 0;
  int pomodorosCompleted = 0;
  int journalStreak = 0;

  DayPlan dayPlan(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return plans.putIfAbsent(d, () => DayPlan());
  }

  void addTask(Task t) => setState(() => tasks.add(t));
  void removeTask(int i) => setState(() => tasks.removeAt(i));
  void bumpFocus(int minutes) => setState(() { totalFocusMinutes += minutes; pomodorosCompleted++; });
  void savePlan(DateTime date, DayPlan dp) {
    final d = DateTime(date.year, date.month, date.day);
    setState(() => plans[d] = dp);
  }
  void addNote(NoteItem n) => setState(() { notes.add(n); journalStreak++; });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOMENTUM',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: HomeShell(state: this),
    );
  }
}

/* =============================== SHELL + NAV ============================= */

class HomeShell extends StatefulWidget {
  final _MomentumAppState state;
  const HomeShell({super.key, required this.state});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(state: widget.state),
      TasksPage(state: widget.state),
      PlannerPage(state: widget.state),
      PomodoroPage(state: widget.state),
      NotesPage(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
        ],
      ),
    );
  }
}

/* ================================ DASHBOARD ============================== */

class DashboardPage extends StatelessWidget {
  final _MomentumAppState state;
  const DashboardPage({super.key, required this.state});

  static const heroImage =
  'https://i.ibb.co/0jM76ZKN/desk-setup.jpg'; // calm desk setup vibe

      //'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1600&auto=format&fit=crop'; // clean desk/work vibe

  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 21) return 'Good Evening';
    return 'Good Night';
  }

  static const quotes = [
    "Small steps build big momentum.",
    "Focus on the next right thing.",
    "Progress, not perfection.",
    "Consistency beats intensity.",
    "Win the day, gently."
  ];

  @override
  Widget build(BuildContext context) {
    final completed = state.tasks.where((t) => t.isDone).length;
    final total = state.tasks.isEmpty ? 1 : state.tasks.length;
    final ratio = completed / total;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroHeader(
          title: "${greeting()}, Deepthi",
          subtitle: quotes[DateTime.now().day % quotes.length],
          imageUrl: heroImage,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SummaryCard(
              title: 'Tasks Done',
              value: '$completed / ${state.tasks.length}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Palette.divider,
                  color: Palette.highlight,
                  minHeight: 10,
                ),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(
              title: 'Focus (mins)',
              value: '${state.totalFocusMinutes}',
              child: Text('Pomodoros: ${state.pomodorosCompleted}',
                  style: Theme.of(context).textTheme.bodySmall),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SummaryCard(
              title: 'Journal Streak',
              value: '${state.journalStreak} day(s)',
              child: const Text('Keep writing ✍️'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(
              title: 'Today',
              value: _today(),
              child: Text('Open Planner to schedule',
                  style: Theme.of(context).textTheme.bodySmall),
            )),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: const [
          _QuickAction(icon: Icons.add_task, label: 'Add Task (use Tasks tab)'),
          _QuickAction(icon: Icons.timer, label: 'Start Focus (Focus tab)'),
          _QuickAction(icon: Icons.calendar_month, label: 'Planner (Planner tab)'),
          _QuickAction(icon: Icons.note_add, label: 'New Note (Notes tab)'),
        ]),
      ],
    );
  }

  String _today() {
    final d = DateTime.now();
    return "${d.day}/${d.month}/${d.year}";
  }
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  const _HeroHeader({required this.title, required this.subtitle, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16/7,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Palette.accent2.withAlpha((255 * 0.2).round()), // Fix: Use withAlpha instead of withOpacity
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 48, color: Colors.black38),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withAlpha((255 * 0.45).round()), Colors.transparent], // Fix: Use withAlpha instead of withOpacity
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16, bottom: 14, right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? child;
  const _SummaryCard({required this.title, required this.value, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          if (child != null) ...[
            const SizedBox(height: 10),
            child!,
          ],
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.divider),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 5, offset: Offset(0,4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Palette.accent),
        const SizedBox(width: 8),
        Text(label),
      ]),
    );
  }
}

/* ================================= TASKS ================================= */

class TasksPage extends StatefulWidget {
  final _MomentumAppState state;
  const TasksPage({super.key, required this.state});
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final titleCtl = TextEditingController();
  Priority pri = Priority.medium;
  Category cat = Category.personal;
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final all = [...widget.state.tasks];
    // Apply filter
    if (filter == 'Open') {
      all.removeWhere((t) => t.isDone);
    } else if (filter == 'Done') {
      all.removeWhere((t) => !t.isDone);
    } else if (filter.startsWith('Pri:')) {
      final map = {'Pri: Low': Priority.low, 'Pri: Med': Priority.medium, 'Pri: High': Priority.high};
      all.removeWhere((t) => t.priority != map[filter]);
    } else if (filter.startsWith('Cat:')) {
      final map = {'Cat: Work': Category.work, 'Cat: Study': Category.study, 'Cat: Personal': Category.personal};
      all.removeWhere((t) => t.category != map[filter]);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: titleCtl,
                decoration: const InputDecoration(hintText: 'Add a task...'),
                onSubmitted: (_) => _addTask(),
              ),
            ),
            const SizedBox(width: 8),
            _chip(label: _priLabel(pri), icon: Icons.flag, color: _priColor(pri), onTap: _cyclePriority),
            const SizedBox(width: 8),
            _chip(label: _catLabel(cat), icon: Icons.local_offer, color: Palette.accent2, onTap: _cycleCategory),
            const SizedBox(width: 8),
            ElevatedButton.icon(onPressed: _addTask, icon: const Icon(Icons.add), label: const Text('Add')),
          ]),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filter('All'), _filter('Open'), _filter('Done'),
            _filter('Pri: Low'), _filter('Pri: Med'), _filter('Pri: High'),
            _filter('Cat: Work'), _filter('Cat: Study'), _filter('Cat: Personal'),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: all.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = widget.state.tasks.removeAt(oldIndex);
                widget.state.tasks.insert(newIndex, item);
              });
            },
            itemBuilder: (_, i) {
              final t = all[i];
              final realIndex = widget.state.tasks.indexOf(t);
              return Card(
                key: ValueKey(t),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(t.isDone ? Icons.check_circle : Icons.circle_outlined,
                        color: t.isDone ? Colors.green : Colors.black38),
                    onPressed: () {
                      setState(() => t.isDone = !t.isDone);
                      if (widget.state.tasks.isNotEmpty && widget.state.tasks.every((k) => k.isDone)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Everything done today — amazing! 🎉')),
                        );
                      }
                    },
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.isDone ? TextDecoration.lineThrough : null,
                      color: t.isDone ? Colors.black45 : Palette.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(children: [
                    _badge(_priLabel(t.priority), _priColor(t.priority)),
                    const SizedBox(width: 6),
                    _badge(_catLabel(t.category), Palette.accent2),
                    if (t.due != null) ...[
                      const SizedBox(width: 6),
                      _badge("${t.due!.day}/${t.due!.month}", Colors.blueGrey),
                    ]
                  ]),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTask(t)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => widget.state.removeTask(realIndex))),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addTask() {
    final title = titleCtl.text.trim();
    if (title.isEmpty) return;
    setState(() {
      widget.state.addTask(Task(title, priority: pri, category: cat));
      titleCtl.clear();
    });
  }

  Widget _filter(String label) {
    final active = filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => filter = label),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withAlpha((255 * 0.12).round()), borderRadius: BorderRadius.circular(20)), // Fix: Use withAlpha instead of withOpacity
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
  );

  Widget _chip({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Palette.divider),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label),
        ]),
      ),
    );
  }

  String _priLabel(Priority p) => p == Priority.low ? 'Low' : (p == Priority.medium ? 'Med' : 'High');
  Color _priColor(Priority p) => p == Priority.low ? Colors.grey : (p == Priority.medium ? Colors.orange : Colors.red);
  String _catLabel(Category c) => c == Category.work ? 'Work' : (c == Category.study ? 'Study' : 'Personal');

  void _cyclePriority() => setState(() => pri = Priority.values[(pri.index + 1) % Priority.values.length]);
  void _cycleCategory() => setState(() => cat = Category.values[(cat.index + 1) % Category.values.length]);

  void _editTask(Task t) {
    final ctl = TextEditingController(text: t.title);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Edit task'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctl),
        const SizedBox(height: 8),
        Row(children: [
          Text('Priority: '),
          const SizedBox(width: 8),
          DropdownButton<Priority>(
            value: t.priority,
            items: Priority.values.map((e) => DropdownMenuItem(value: e, child: Text(_priLabel(e)))).toList(),
            onChanged: (v) => setState(() => t.priority = v ?? t.priority),
          ),
          const SizedBox(width: 12),
          Text('Category: '),
          const SizedBox(width: 8),
          DropdownButton<Category>(
            value: t.category,
            items: Category.values.map((e) => DropdownMenuItem(value: e, child: Text(_catLabel(e)))).toList(),
            onChanged: (v) => setState(() => t.category = v ?? t.category),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text('Due: '),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: t.due ?? now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 2),
              );
              if (picked != null) setState(() => t.due = picked);
            },
            child: Text(t.due == null ? 'Pick' : "${t.due!.day}/${t.due!.month}/${t.due!.year}"),
          ),
          if (t.due != null)
            IconButton(onPressed: () => setState(() => t.due = null), icon: const Icon(Icons.clear)),
        ]),
      ]),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){
          setState(() { if (ctl.text.trim().isNotEmpty) t.title = ctl.text.trim(); });
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }
}

/* ================================= PLANNER =============================== */

class PlannerPage extends StatefulWidget {
  final _MomentumAppState state;
  const PlannerPage({super.key, required this.state});
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime focusDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        Container(
          color: Palette.card,
          child: const TabBar(
            indicatorColor: Palette.accent,
            labelColor: Palette.accent,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
            ],
          ),
        ),
        Expanded(child: TabBarView(children: [
          _dayView(),
          _weekView(),
          _monthView(),
        ])),
      ]),
    );
  }

  Widget _dayView() {
    final dp = widget.state.dayPlan(focusDate);
    final morningCtl = TextEditingController(text: dp.morning);
    final afternoonCtl = TextEditingController(text: dp.afternoon);
    final eveningCtl = TextEditingController(text: dp.evening);
    final noteCtl = TextEditingController(text: dp.note);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _dateHeader(row: true),
        const SizedBox(height: 12),
        _slotCard('Morning', morningCtl),
        _slotCard('Afternoon', afternoonCtl),
        _slotCard('Evening', eveningCtl),
        _noteCard(noteCtl),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.state.savePlan(focusDate, DayPlan(
                morning: morningCtl.text,
                afternoon: afternoonCtl.text,
                evening: eveningCtl.text,
                note: noteCtl.text,
              ));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Day plan saved ✅')));
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ),
      ],
    );
  }

  Widget _slotCard(String title, TextEditingController ctl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(maxLines: 2, controller: ctl, decoration: const InputDecoration(hintText: 'Plan tasks / notes...')),
        ]),
      ),
    );
  }

  Widget _noteCard(TextEditingController ctl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(maxLines: 4, controller: ctl, decoration: const InputDecoration(hintText: 'Any details, links, reminders...')),
        ]),
      ),
    );
  }

  Widget _weekView() {
    final startOfWeek = DateTime(focusDate.year, focusDate.month, focusDate.day)
        .subtract(Duration(days: (focusDate.weekday - 1) % 7));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _dateHeader(),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            final d = startOfWeek.add(Duration(days: i));
            final dp = widget.state.dayPlan(d);
            final summary = [
              if (dp.morning.trim().isNotEmpty) "M",
              if (dp.afternoon.trim().isNotEmpty) "A",
              if (dp.evening.trim().isNotEmpty) "E",
            ].join('·');
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => focusDate = d),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year
                        ? Palette.highlight.withAlpha((255 * 0.15).round()) // Fix: Use withAlpha instead of withOpacity
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.divider),
                  ),
                  child: Column(children: [
                    Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i],
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    CircleAvatar(radius: 15, backgroundColor: Palette.bg, child: Text('${d.day}')),
                    const SizedBox(height: 6),
                    Text(summary.isEmpty ? '-' : summary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Palette.accent, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text('Selected Day: ${focusDate.day}/${focusDate.month}/${focusDate.year}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        _dayMini(),
      ],
    );
  }

  Widget _dayMini() {
    final dp = widget.state.dayPlan(focusDate);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quick View', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text("Morning: ${dp.morning.isEmpty ? '-' : dp.morning}"),
          Text("Afternoon: ${dp.afternoon.isEmpty ? '-' : dp.afternoon}"),
          Text("Evening: ${dp.evening.isEmpty ? '-' : dp.evening}"),
        ]),
      ),
    );
  }

  Widget _monthView() {
    final firstDay = DateTime(focusDate.year, focusDate.month, 1);
    final firstWeekday = (firstDay.weekday % 7);
    final daysInMonth = DateTime(focusDate.year, focusDate.month + 1, 0).day;

    final cells = <DateTime?>[];
    for (int i = 0; i < (firstWeekday == 0 ? 6 : firstWeekday - 1); i++) { // Fix: Enclosed in a block
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) { // Fix: Enclosed in a block
      cells.add(DateTime(focusDate.year, focusDate.month, d));
    }

    final rows = <List<DateTime?>>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7 > cells.length ? cells.length : i + 7));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _dateHeader(),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: Center(child: Text('Mon'))),
            Expanded(child: Center(child: Text('Tue'))),
            Expanded(child: Center(child: Text('Wed'))),
            Expanded(child: Center(child: Text('Thu'))),
            Expanded(child: Center(child: Text('Fri'))),
            Expanded(child: Center(child: Text('Sat'))),
            Expanded(child: Center(child: Text('Sun'))),
          ],
        ),
        const SizedBox(height: 6),
        ...rows.map((row) => Row(
          children: row.map((d) {
            final isToday = d != null &&
                d.day == DateTime.now().day &&
                d.month == DateTime.now().month &&
                d.year == DateTime.now().year;
            final hasPlan = d != null && (() {
              final dp = widget.state.dayPlan(d);
              return (dp.morning + dp.afternoon + dp.evening).trim().isNotEmpty;
            })();

            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: InkWell(
                  onTap: d == null ? null : () => setState(() => focusDate = d),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: d == null ? Colors.transparent
                          : (isToday ? Palette.highlight.withAlpha((255 * 0.15).round()) : Colors.white), // Fix: Use withAlpha instead of withOpacity
                      borderRadius: BorderRadius.circular(10),
                      border: d == null ? null : Border.all(color: Palette.divider),
                    ),
                    child: d == null ? const SizedBox()
                    : Stack(children: [
                        Positioned(top: 6, left: 6,
                          child: Text('${d.day}', style: Theme.of(context).textTheme.bodySmall)),
                        if (hasPlan)
                          const Positioned(right: 6, bottom: 6,
                            child: Icon(Icons.circle, size: 8, color: Palette.accent)),
                      ]),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 10),
        Text('Selected: ${focusDate.day}/${focusDate.month}/${focusDate.year}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        _dayMini(),
      ],
    );
  }

  Widget _dateHeader({bool row = false}) {
    final d = focusDate;
    final label = "${d.day}/${d.month}/${d.year}";
    final nav = Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: ()=> setState(()=> focusDate = focusDate.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_left)),
      IconButton(onPressed: ()=> setState(()=> focusDate = DateTime.now()), icon: const Icon(Icons.today)),
      IconButton(onPressed: ()=> setState(()=> focusDate = focusDate.add(const Duration(days: 1))), icon: const Icon(Icons.chevron_right)),
    ]);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Palette.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: Palette.divider)),
      child: Text(label),
    );
    return row
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [chip, nav])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [chip, nav]);
  }
}

/* ================================ POMODORO =============================== */

class PomodoroPage extends StatefulWidget {
  final _MomentumAppState state;
  const PomodoroPage({super.key, required this.state});
  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  int focusMinutes = 25;
  int breakMinutes = 5;
  int cycles = 1;

  Timer? timer;
  bool running = false;
  bool onBreak = false;
  int remainingSeconds = 25 * 60;
  int totalSeconds = 25 * 60;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (running) return;
    setState(() {
      running = true;
      onBreak = false;
      remainingSeconds = focusMinutes * 60;
      totalSeconds = remainingSeconds;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        if (!onBreak) {
          widget.state.bumpFocus(focusMinutes);
          if (cycles > 1) {
            setState(() {
              onBreak = true;
              remainingSeconds = breakMinutes * 60;
              totalSeconds = remainingSeconds;
              cycles--;
            });
          } else {
            _finishAll();
          }
        } else {
          setState(() {
            onBreak = false;
            remainingSeconds = focusMinutes * 60;
            totalSeconds = remainingSeconds;
          });
        }
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void _pause() {
    timer?.cancel();
    setState(() => running = false);
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      running = false;
      onBreak = false;
      remainingSeconds = focusMinutes * 60;
      totalSeconds = remainingSeconds;
    });
  }

  void _finishAll() {
    timer?.cancel();
    setState(() { running = false; onBreak = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nice work — session complete! ✅')));
  }

  String _fmt(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : (1 - (remainingSeconds / totalSeconds));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroHeader(
          title: onBreak ? 'Break Time ☕' : 'Focus Time ⏳',
          subtitle: onBreak ? 'Breathe, stretch, sip water.' : 'Deep work on one task.',
          imageUrl: onBreak
              ? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1600&auto=format&fit=crop' // tea/cup vibe
              : 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?q=80&w=1600&auto=format&fit=crop', // coding desk
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 220, width: 220,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: 200, width: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Palette.divider,
                  color: onBreak ? Palette.accent2 : Palette.highlight,
                ),
              ),
              Text(_fmt(remainingSeconds),
                  style: Theme.of(context).textTheme.headlineSmall),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            onPressed: running ? _pause : _start,
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
            label: Text(running ? 'Pause' : 'Start'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Session Settings', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _numPicker('Focus (min)', focusMinutes, (v){ setState(() {
                focusMinutes = v.clamp(1, 180);
                if (!running) { remainingSeconds = focusMinutes * 60; totalSeconds = remainingSeconds; }
              }); }),
              _numPicker('Break (min)', breakMinutes, (v)=> setState(()=> breakMinutes = v.clamp(1, 60))),
              _numPicker('Cycles', cycles, (v)=> setState(()=> cycles = v.clamp(1, 12))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _numPicker(String label, int value, void Function(int) onChanged) {
    return Row(children: [
      Expanded(child: Text(label)),
      IconButton(onPressed: value>1?()=>onChanged(value-1):null, icon: const Icon(Icons.remove_circle_outline)),
      Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(onPressed: ()=>onChanged(value+1), icon: const Icon(Icons.add_circle_outline)),
    ]);
  }
}

/* ================================= NOTES ================================= */

class NotesPage extends StatefulWidget {
  final _MomentumAppState state;
  const NotesPage({super.key, required this.state});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String query = '';
  bool onlyToday = false;

  @override
  Widget build(BuildContext context) {
    final list = [...widget.state.notes]..sort((a,b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    final filtered = list.where((n){
      if (onlyToday) {
        final now = DateTime.now();
        final sameDay = n.createdAt.year == now.year && n.createdAt.month == now.month && n.createdAt.day == now.day;
        if (!sameDay) return false;
      }
      final q = query.toLowerCase();
      return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroHeader(
          title: 'Notes & Journal',
          subtitle: 'Capture thoughts. Add images. Pin favorites.',
          imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=1600&auto=format&fit=crop', // notebook/pen
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            decoration: const InputDecoration(hintText: 'Search notes...'),
            onChanged: (v)=> setState(()=> query = v),
          )),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Today'), selected: onlyToday, onSelected: (v)=> setState(()=> onlyToday = v)),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: ()=> _newNoteDialog(context),
            icon: const Icon(Icons.note_add), label: const Text('New'),
          )
        ]),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Palette.divider),
            ),
            child: const Center(child: Text('No notes yet — create your first thought!')),
          ),
        ...filtered.map((n) => _noteCard(n)),
      ],
    );
  }

  Widget _noteCard(NoteItem n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(n.title.isEmpty ? '(Untitled)' : n.title,
                style: Theme.of(context).textTheme.titleMedium)),
            IconButton(
              icon: Icon(n.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: n.pinned ? Palette.accent : null),
              onPressed: () => setState(() { n.pinned = !n.pinned; }),
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _editNoteDialog(context, n)),
          ]),
          const SizedBox(height: 6),
          if (n.imageUrl != null && n.imageUrl!.trim().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                n.imageUrl!,
                height: 140, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140, color: Palette.bg,
                  alignment: Alignment.center,
                  child: const Text('Image failed to load'),
                ),
              ),
            )
          else
            Container(
              height: 44, alignment: Alignment.centerLeft,
              child: Text('🖼️ Add an image (URL) via Edit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            ),
          const SizedBox(height: 8),
          Text(n.content.isEmpty ? '—' : n.content),
          const SizedBox(height: 8),
          Text("Created ${n.createdAt.day}/${n.createdAt.month}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
        ]),
      ),
    );
  }

  void _newNoteDialog(BuildContext context) {
    final t = TextEditingController();
    final c = TextEditingController();
    final img = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New note / journal'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _toolbarHint(context),
          const SizedBox(height: 8),
          TextField(controller: t, decoration: const InputDecoration(hintText: 'Title')),
          const SizedBox(height: 8),
          TextField(controller: c, minLines: 4, maxLines: 8, decoration: const InputDecoration(hintText: 'Write here...  *bold*  _italic_  - bullet')),
          const SizedBox(height: 8),
          TextField(controller: img, decoration: const InputDecoration(hintText: 'Image URL (optional)')),
        ]),
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){
          widget.state.addNote(NoteItem(
            title: t.text.trim(),
            content: _formatRichText(c.text),
            imageUrl: img.text.trim().isEmpty ? null : img.text.trim(),
          ));
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _editNoteDialog(BuildContext context, NoteItem n) {
    final t = TextEditingController(text: n.title);
    final c = TextEditingController(text: n.content);
    final img = TextEditingController(text: n.imageUrl ?? '');
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Edit note'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [ // Fixed from MainAxisSize.nin to MainAxisSize.min
          _toolbarHint(context),
          const SizedBox(height: 8),
          TextField(controller: t),
          const SizedBox(height: 8),
          TextField(controller: c, minLines: 4, maxLines: 8),
          const SizedBox(height: 8),
          TextField(controller: img, decoration: const InputDecoration(hintText: 'Image URL')),
        ]),
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){
          setState(() {
            n.title = t.text.trim();
            n.content = _formatRichText(c.text);
            n.imageUrl = img.text.trim().isEmpty ? null : img.text.trim();
          });
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }

  Widget _toolbarHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Palette.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: Palette.divider)),
      child: Row(children: const [
        Icon(Icons.format_bold, size: 18), SizedBox(width: 4), Text('*bold*'),
        SizedBox(width: 12),
        Icon(Icons.format_italic, size: 18), SizedBox(width: 4), Text('_italic_'),
        SizedBox(width: 12),
        Icon(Icons.format_list_bulleted, size: 18), SizedBox(width: 4), Text('- bullet'),
      ]),
    );
  }

  String _formatRichText(String src) {
    var s = src;
    s = s.replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => '𝗕 ${m.group(1)} 𝗕');
    s = s.replaceAllMapped(RegExp(r'_(.*?)_'), (m) => '𝑰 ${m.group(1)} 𝑰');
    s = s.replaceAll(RegExp(r'^\-\s+', multiLine: true), '• ');
    return s;
  }
}