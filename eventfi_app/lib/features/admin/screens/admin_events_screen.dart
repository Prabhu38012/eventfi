import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_snackbar.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});
  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<AdminProvider>().loadEvents());
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> events) {
    if (_query.isEmpty) return events;
    return events.where((e) =>
      (e['title']    ?? '').toLowerCase().contains(_query) ||
      (e['city']     ?? '').toLowerCase().contains(_query) ||
      (e['category'] ?? '').toLowerCase().contains(_query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ap      = context.watch<AdminProvider>();
    final events  = _filtered(ap.events);

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Events', style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add_circle_outline_rounded, color: AppColors.accent, size: 26),
            tooltip:   'Add Event',
            onPressed: () => context.push('/admin/events/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: TextField(
              controller: _search,
              style:      AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
              onChanged:  (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText:  'Search events...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textHint),
                filled:    true,
                fillColor: AppColors.surface1,
                border:    OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:   BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Events list
          Expanded(
            child: ap.loading
                ? const AppLoader()
                : events.isEmpty
                    ? Center(child: Text('No events found', style: AppFonts.bodySmall))
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: ap.loadEvents,
                        child: ListView.builder(
                          padding:     const EdgeInsets.fromLTRB(
                              AppSizes.pagePadding, 0, AppSizes.pagePadding, 80),
                          itemCount:   events.length,
                          itemBuilder: (_, i) => _EventTile(
                            event:    events[i],
                            onEdit:   () => context.push('/admin/events/edit', extra: events[i]),
                            onDelete: () => _confirmDelete(context, ap, events[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AdminProvider ap, Map event) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title:   Text('Delete Event?', style: AppFonts.headlineMedium),
        content: Text('${event['title']} will be permanently deleted.',
            style: AppFonts.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ap.deleteEvent(event['_id']);
              if (ap.success != null && ctx.mounted) {
                AppSnackbar.success(ctx, ap.success!);
                ap.clearMessages();
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onEdit, onDelete;
  const _EventTile({required this.event, required this.onEdit, required this.onDelete});

  Color _catColor(String? cat) {
    switch (cat) {
      case 'concert':    return AppColors.concert;
      case 'theatre':    return AppColors.theatre;
      case 'standup':    return AppColors.standup;
      case 'dance':      return AppColors.dance;
      case 'theme_park': return AppColors.themePark;
      default:           return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat   = event['category'] as String?;
    final color = _catColor(cat);
    final seats = event['availableSeats'] ?? 0;
    final total = event['totalSeats']     ?? 0;

    return Container(
      margin:  const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Category dot
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Center(child: Text(cat?.substring(0, 2).toUpperCase() ?? 'EV',
              style: AppFonts.labelSmall.copyWith(color: color))),
        ),
        const SizedBox(width: 12),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event['title'] ?? 'Untitled', style: AppFonts.labelLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('${event['city']} · ₹${event['price']} · $seats/$total seats',
              style: AppFonts.caption),
          Text(event['date'] != null
              ? DateTime.tryParse(event['date'])?.toString().substring(0, 10) ?? ''
              : '', style: AppFonts.caption),
        ])),

        // Actions
        Column(children: [
          IconButton(
            icon:      const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
            onPressed: onEdit, padding: EdgeInsets.zero,
          ),
          IconButton(
            icon:      Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: onDelete, padding: EdgeInsets.zero,
          ),
        ]),
      ]),
    );
  }
}
