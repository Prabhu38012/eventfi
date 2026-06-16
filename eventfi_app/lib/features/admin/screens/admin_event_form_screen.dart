import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';

class AdminEventFormScreen extends StatefulWidget {
  final Map<String, dynamic>? event; // null = create, non-null = edit
  const AdminEventFormScreen({super.key, this.event});

  @override
  State<AdminEventFormScreen> createState() => _AdminEventFormScreenState();
}

class _AdminEventFormScreenState extends State<AdminEventFormScreen> {
  final _form = GlobalKey<FormState>();

  // Controllers
  late final _title       = TextEditingController();
  late final _description = TextEditingController();
  late final _city        = TextEditingController();
  late final _venue       = TextEditingController();
  late final _price       = TextEditingController();
  late final _seats       = TextEditingController();
  late final _lat         = TextEditingController();
  late final _lng         = TextEditingController();
  late final _orgName     = TextEditingController();
  late final _orgPhone    = TextEditingController();
  late final _posterUrl   = TextEditingController();

  String   _category = 'concert';
  DateTime _date     = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time    = const TimeOfDay(hour: 18, minute: 0);

  bool get _isEdit => widget.event != null;

  final _categories = [
    {'value': 'concert',    'label': '🎵 Concert'},
    {'value': 'theatre',    'label': '🎭 Theatre'},
    {'value': 'standup',    'label': '🎤 Standup'},
    {'value': 'dance',      'label': '💃 Dance'},
    {'value': 'theme_park', 'label': '🎢 Theme Park'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) _prefill();
  }

  void _prefill() {
    final e = widget.event!;
    _title.text       = e['title']         ?? '';
    _description.text = e['description']   ?? '';
    _city.text        = e['city']          ?? '';
    _venue.text       = e['venue']         ?? '';
    _price.text       = e['price']?.toString() ?? '';
    _seats.text       = e['totalSeats']?.toString() ?? '';
    _lat.text         = e['latitude']?.toString()  ?? '';
    _lng.text         = e['longitude']?.toString() ?? '';
    _orgName.text     = e['organizerName'] ?? '';
    _orgPhone.text    = e['organizerPhone'] ?? '';
    _posterUrl.text   = e['posterUrl']     ?? '';
    _category         = e['category']      ?? 'concert';
    if (e['date']  != null) _date = DateTime.tryParse(e['date'])  ?? _date;
    if (e['time'] != null) {
      // Stored as 24-hour "HH:mm" — parse safely
      final raw   = (e['time'] as String).trim();
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 18;
        final m = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _time = TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_title,_description,_city,_venue,_price,_seats,
                     _lat,_lng,_orgName,_orgPhone,_posterUrl]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    final data = {
      'title':         _title.text.trim(),
      'description':   _description.text.trim(),
      'category':      _category,
      'city':          _city.text.trim(),
      'venue':         _venue.text.trim(),
      'date':          _date.toIso8601String(),
      // Save as 24-hour HH:mm so _prefill can parse it reliably
      'time':          '${_time.hour.toString().padLeft(2,'0')}:${_time.minute.toString().padLeft(2,'0')}', 
      'price':         double.tryParse(_price.text.trim()) ?? 0,
      'totalSeats':    int.tryParse(_seats.text.trim()) ?? 100,
      'availableSeats': int.tryParse(_seats.text.trim()) ?? 100,
      'latitude':      double.tryParse(_lat.text.trim()),
      'longitude':     double.tryParse(_lng.text.trim()),
      'organizerName':  _orgName.text.trim(),
      'organizerPhone': _orgPhone.text.trim(),
      'posterUrl':      _posterUrl.text.trim(),
      'isActive':       true,
    };

    final ap = context.read<AdminProvider>();
    bool ok;
    if (_isEdit) {
      ok = await ap.updateEvent(widget.event!['_id'], data);
    } else {
      ok = await ap.createEvent(data);
    }

    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, _isEdit ? 'Event updated!' : 'Event created!');
        ap.clearMessages();
        context.canPop() ? context.pop() : context.go('/admin/events');
      } else {
        AppSnackbar.error(context, ap.error ?? 'Failed');
        ap.clearMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text(_isEdit ? 'Edit Event' : 'New Event',
            style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/events'),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            _field('Title *', _title, required: true),
            _field('Description', _description, maxLines: 3),

            // Category
            const SizedBox(height: AppSizes.md),
            Text('Category *', style: AppFonts.labelSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value:     _category,
              style:     AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
              dropdownColor: AppColors.surface1,
              decoration: _inputDeco(''),
              items: _categories.map((c) => DropdownMenuItem(
                value: c['value']!,
                child: Text(c['label']!),
              )).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),

            Row(children: [
              Expanded(child: _field('City *',  _city,  required: true)),
              const SizedBox(width: AppSizes.md),
              Expanded(child: _field('Price ₹ *', _price, keyboard: TextInputType.number, required: true)),
            ]),
            _field('Venue', _venue),

            Row(children: [
              Expanded(child: _field('Total Seats *', _seats, keyboard: TextInputType.number, required: true)),
            ]),

            // Date & Time row
            const SizedBox(height: AppSizes.md),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Date *', style: AppFonts.labelSmall),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color:        AppColors.surface3,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(DateFormat('d MMM yyyy').format(_date), style: AppFonts.bodySmall),
                    ]),
                  ),
                ),
              ])),
              const SizedBox(width: AppSizes.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Time *', style: AppFonts.labelSmall),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color:        AppColors.surface3,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time_outlined, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text('${_time.hour.toString().padLeft(2,'0')}:${_time.minute.toString().padLeft(2,'0')}', style: AppFonts.bodySmall),
                    ]),
                  ),
                ),
              ])),
            ]),

            Row(children: [
              Expanded(child: _field('Latitude',  _lat,  keyboard: TextInputType.number)),
              const SizedBox(width: AppSizes.md),
              Expanded(child: _field('Longitude', _lng,  keyboard: TextInputType.number)),
            ]),

            _field('Organizer Name',  _orgName),
            _field('Organizer Phone', _orgPhone, keyboard: TextInputType.phone),
            _field('Poster URL',      _posterUrl, hint: 'https://...'),

            const SizedBox(height: AppSizes.xl),
            AppButton(
              text:      _isEdit ? 'Update Event' : 'Create Event',
              isLoading: ap.saving,
              onTap:     _submit,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    bool required = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppFonts.labelSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller:  ctrl,
          maxLines:    maxLines,
          keyboardType: keyboard,
          style:       AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
          decoration:  _inputDeco(hint ?? ''),
          validator:   required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
        ),
      ]),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText:  hint,
    filled:    true,
    fillColor: AppColors.surface3,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide:   BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
