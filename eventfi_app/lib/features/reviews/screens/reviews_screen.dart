import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/star_rating_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_loader.dart';

class ReviewsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  const ReviewsScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.eventId);
    });
  }

  void _showWriteReview() {
    showModalBottomSheet(
      context:          context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _WriteReviewSheet(
        eventId:    widget.eventId,
        provider:   context.read<ReviewProvider>(),
        onSuccess:  () {
          Navigator.pop(context);
          AppSnackbar.success(context, 'Review submitted! Thank you 🙏');
        },
        onError: (msg) => AppSnackbar.error(context, msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReviewProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Reviews', style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: rp.loading
          ? const AppLoader()
          : CustomScrollView(
              slivers: [
                // ── Summary ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    child: Column(children: [
                      Text(widget.eventTitle,
                          style: AppFonts.headlineSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2, overflow: TextOverflow.ellipsis),

                      const SizedBox(height: AppSizes.xl),

                      // Large rating display
                      Text(rp.avgRating.toStringAsFixed(1),
                          style: AppFonts.tanker(
                              fontSize: 56, color: AppColors.gold)),
                      const SizedBox(height: 6),
                      StarRatingDisplay(
                        rating:     rp.avgRating,
                        count:      rp.totalReviews,
                        size:       22,
                      ),

                      const SizedBox(height: AppSizes.xl),

                      AppButton(
                        text:      '✏️  Write a Review',
                        onTap:     _showWriteReview,
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: Divider(color: AppColors.divider)),

                // ── Reviews list ───────────────────────────
                rp.reviews.isEmpty
                    ? SliverFillRemaining(child: _EmptyReviews())
                    : SliverPadding(
                        padding: const EdgeInsets.all(AppSizes.pagePadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ReviewCard(review: rp.reviews[i]),
                            childCount: rp.reviews.length,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}

// ── Write Review Sheet ────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  final String         eventId;
  final ReviewProvider provider;
  final VoidCallback   onSuccess;
  final Function(String) onError;
  const _WriteReviewSheet({
    required this.eventId, required this.provider,
    required this.onSuccess, required this.onError,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int    _rating  = 0;
  final  _ctrl    = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) {
      widget.onError('Please select a star rating');
      return;
    }
    final ok = await widget.provider.submitReview(
      eventId: widget.eventId,
      rating:  _rating,
      comment: _ctrl.text.trim(),
    );
    if (ok) widget.onSuccess();
    else    widget.onError(widget.provider.error ?? 'Failed to submit');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 20),

          Text('Write a Review', style: AppFonts.headlineMedium),
          const SizedBox(height: AppSizes.xl),

          // Stars
          Center(
            child: StarRatingInput(
              rating:    _rating,
              size:      44,
              onChanged: (r) => setState(() => _rating = r),
            ),
          ),
          Center(
            child: Text(
              _rating == 0 ? 'Tap to rate'
              : _rating == 1 ? '😞 Poor'
              : _rating == 2 ? '😐 Fair'
              : _rating == 3 ? '🙂 Good'
              : _rating == 4 ? '😊 Great'
              : '🤩 Excellent',
              style: AppFonts.labelMedium.copyWith(color: AppColors.gold),
            ),
          ),

          const SizedBox(height: AppSizes.xl),

          // Comment
          TextField(
            controller:  _ctrl,
            maxLines:    4,
            maxLength:   500,
            style:       AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:  'Share your experience (optional)...',
              filled:    true,
              fillColor: AppColors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide:   BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          ListenableBuilder(
            listenable: widget.provider,
            builder:    (_, __) => AppButton(
              text:      'Submit Review',
              isLoading: widget.provider.submitting,
              onTap:     _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('⭐', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 16),
      Text('No reviews yet', style: AppFonts.headlineSmall),
      const SizedBox(height: 8),
      Text('Be the first to review this event',
          style: AppFonts.bodySmall, textAlign: TextAlign.center),
    ]),
  );
}
