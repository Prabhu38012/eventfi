import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/event_model.dart';

class EventGallery extends StatefulWidget {
  final EventModel event;
  final double     height;

  const EventGallery({super.key, required this.event, this.height = 280});

  @override
  State<EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends State<EventGallery> {
  final _ctrl = PageController();
  int _current = 0;

  List<String?> get _images {
    final list = <String?>[];
    if (widget.event.posterUrl != null && widget.event.posterUrl!.isNotEmpty)
      list.add(widget.event.posterUrl);
    list.addAll(widget.event.images.where((i) => i.isNotEmpty));
    if (list.isEmpty) list.add(null);
    return list;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Page View ────────────────────────────
          PageView.builder(
            controller:    _ctrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount:     images.length,
            itemBuilder:   (_, i) => _buildImage(images[i]),
          ),

          // ─── Bottom gradient ──────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.dark.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // ─── Dot indicators ───────────────────────
          if (images.length > 1)
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width:  _current == i ? 22 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _current == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl:    url,
        fit:         BoxFit.cover,
        placeholder: (_, __) => _Placeholder(widget.event),
        errorWidget: (_, __, ___) => _Placeholder(widget.event),
      );
    }
    return _Placeholder(widget.event);
  }
}

class _Placeholder extends StatelessWidget {
  final EventModel event;
  const _Placeholder(this.event);

  @override
  Widget build(BuildContext context) => Container(
        color: event.categoryColor.withOpacity(0.12),
        child: Center(
          child: Icon(event.categoryIcon,
              size: 80, color: event.categoryColor.withOpacity(0.3)),
        ),
      );
}
