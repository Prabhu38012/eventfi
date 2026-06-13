#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  EventFi — Full Project Structure Setup Script (Mac / Linux)
#  Run from inside the eventfi/ root folder:
#    chmod +x setup_mac.sh
#    ./setup_mac.sh
# ─────────────────────────────────────────────────────────────

ROOT="$(pwd)"
echo ""
echo "🔥 Creating EventFi project structure..."
echo "   Root: $ROOT"
echo ""

# ═══════════════════════════════════════════════════════════════
#  FLUTTER APP
# ═══════════════════════════════════════════════════════════════
cd "$ROOT/eventfi_app"

# Core folders
mkdir -p lib/core/constants
mkdir -p lib/core/theme
mkdir -p lib/core/routes
mkdir -p lib/core/network
mkdir -p lib/core/utils

# Features
mkdir -p lib/features/auth/{screens,widgets,models,repository,providers}
mkdir -p lib/features/home/{screens,widgets,providers}
mkdir -p lib/features/events/{screens,widgets,models,repository,providers}
mkdir -p lib/features/booking/{screens,widgets,models,repository,providers}
mkdir -p lib/features/points/{screens,widgets,models,repository,providers}
mkdir -p lib/features/wishlist/{screens,repository,providers}
mkdir -p lib/features/reviews/{screens,widgets,models,repository,providers}
mkdir -p lib/features/notifications/{screens,models,repository,providers}
mkdir -p lib/features/profile/{screens,providers}
mkdir -p lib/features/admin/{screens,providers}

# Shared + Services
mkdir -p lib/shared/{widgets,models}
mkdir -p lib/services

# Assets
mkdir -p assets/images
mkdir -p assets/fonts

# ── Core Utils ─────────────────────────────────────────────
touch lib/core/utils/validators.dart
touch lib/core/utils/date_formatter.dart
touch lib/core/utils/helpers.dart

# ── Auth Feature ───────────────────────────────────────────
touch lib/features/auth/screens/onboarding_screen.dart
touch lib/features/auth/screens/login_screen.dart
touch lib/features/auth/screens/signup_screen.dart
touch lib/features/auth/screens/forgot_password_screen.dart
touch lib/features/auth/screens/otp_screen.dart
touch lib/features/auth/widgets/auth_text_field.dart
touch lib/features/auth/widgets/social_login_button.dart
touch lib/features/auth/models/user_model.dart
touch lib/features/auth/repository/auth_repository.dart
touch lib/features/auth/providers/auth_provider.dart

# ── Home Feature ───────────────────────────────────────────
touch lib/features/home/screens/home_screen.dart
touch lib/features/home/widgets/category_tab.dart
touch lib/features/home/widgets/event_card.dart
touch lib/features/home/widgets/trending_section.dart
touch lib/features/home/widgets/search_bar_widget.dart
touch lib/features/home/providers/home_provider.dart

# ── Events Feature ─────────────────────────────────────────
touch lib/features/events/screens/event_detail_screen.dart
touch lib/features/events/screens/event_list_screen.dart
touch lib/features/events/screens/event_search_screen.dart
touch lib/features/events/widgets/event_gallery.dart
touch lib/features/events/widgets/organizer_card.dart
touch lib/features/events/widgets/event_map_widget.dart
touch lib/features/events/widgets/event_filter_sheet.dart
touch lib/features/events/models/event_model.dart
touch lib/features/events/repository/event_repository.dart
touch lib/features/events/providers/event_provider.dart

# ── Booking Feature ────────────────────────────────────────
touch lib/features/booking/screens/seat_selection_screen.dart
touch lib/features/booking/screens/checkout_screen.dart
touch lib/features/booking/screens/booking_confirmed_screen.dart
touch lib/features/booking/screens/booking_history_screen.dart
touch lib/features/booking/screens/ticket_screen.dart
touch lib/features/booking/widgets/seat_grid.dart
touch lib/features/booking/widgets/coupon_input.dart
touch lib/features/booking/widgets/price_breakdown.dart
touch lib/features/booking/widgets/qr_ticket_widget.dart
touch lib/features/booking/models/booking_model.dart
touch lib/features/booking/repository/booking_repository.dart
touch lib/features/booking/providers/booking_provider.dart

# ── Points Feature ─────────────────────────────────────────
touch lib/features/points/screens/points_screen.dart
touch lib/features/points/screens/rewards_screen.dart
touch lib/features/points/widgets/points_balance_card.dart
touch lib/features/points/widgets/reward_tile.dart
touch lib/features/points/models/points_model.dart
touch lib/features/points/repository/points_repository.dart
touch lib/features/points/providers/points_provider.dart

# ── Wishlist Feature ───────────────────────────────────────
touch lib/features/wishlist/screens/wishlist_screen.dart
touch lib/features/wishlist/repository/wishlist_repository.dart
touch lib/features/wishlist/providers/wishlist_provider.dart

# ── Reviews Feature ────────────────────────────────────────
touch lib/features/reviews/screens/reviews_screen.dart
touch lib/features/reviews/widgets/review_card.dart
touch lib/features/reviews/widgets/star_rating_widget.dart
touch lib/features/reviews/models/review_model.dart
touch lib/features/reviews/repository/review_repository.dart
touch lib/features/reviews/providers/review_provider.dart

# ── Notifications Feature ──────────────────────────────────
touch lib/features/notifications/screens/notifications_screen.dart
touch lib/features/notifications/models/notification_model.dart
touch lib/features/notifications/repository/notification_repository.dart
touch lib/features/notifications/providers/notification_provider.dart

# ── Profile Feature ────────────────────────────────────────
touch lib/features/profile/screens/profile_screen.dart
touch lib/features/profile/providers/profile_provider.dart

# ── Admin Feature ──────────────────────────────────────────
touch lib/features/admin/screens/admin_dashboard_screen.dart
touch lib/features/admin/screens/admin_events_screen.dart
touch lib/features/admin/screens/admin_bookings_screen.dart
touch lib/features/admin/screens/admin_coupons_screen.dart
touch lib/features/admin/screens/admin_rewards_screen.dart
touch lib/features/admin/screens/admin_qr_scanner_screen.dart
touch lib/features/admin/providers/admin_provider.dart

# ── Shared Widgets ─────────────────────────────────────────
touch lib/shared/widgets/app_button.dart
touch lib/shared/widgets/app_text_field.dart
touch lib/shared/widgets/app_loader.dart
touch lib/shared/widgets/app_snackbar.dart
touch lib/shared/widgets/app_bottom_nav.dart
touch lib/shared/widgets/empty_state_widget.dart
touch lib/shared/widgets/error_widget.dart
touch lib/shared/models/api_response.dart

# ── Services ───────────────────────────────────────────────
touch lib/services/firebase_service.dart
touch lib/services/storage_service.dart
touch lib/services/fcm_service.dart

FLUTTER_FILES=$(find "$ROOT/eventfi_app/lib" -name "*.dart" | wc -l | tr -d ' ')
echo "✅ Flutter: $FLUTTER_FILES Dart files created"

# ═══════════════════════════════════════════════════════════════
#  NODE.JS BACKEND
# ═══════════════════════════════════════════════════════════════
cd "$ROOT/eventfi_backend"

mkdir -p src/{config,models,routes,controllers,middleware,services,utils}

# ── Models ─────────────────────────────────────────────────
touch src/models/User.js
touch src/models/Event.js
touch src/models/Booking.js
touch src/models/Coupon.js
touch src/models/Review.js
touch src/models/Notification.js
touch src/models/Points.js

# ── Routes ─────────────────────────────────────────────────
touch src/routes/auth.routes.js
touch src/routes/event.routes.js
touch src/routes/booking.routes.js
touch src/routes/coupon.routes.js
touch src/routes/points.routes.js
touch src/routes/review.routes.js
touch src/routes/notification.routes.js
touch src/routes/admin.routes.js

# ── Controllers ────────────────────────────────────────────
touch src/controllers/auth.controller.js
touch src/controllers/event.controller.js
touch src/controllers/booking.controller.js
touch src/controllers/coupon.controller.js
touch src/controllers/points.controller.js
touch src/controllers/review.controller.js
touch src/controllers/notification.controller.js
touch src/controllers/admin.controller.js

# ── Middleware ─────────────────────────────────────────────
touch src/middleware/auth.middleware.js
touch src/middleware/admin.middleware.js
touch src/middleware/validate.middleware.js
touch src/middleware/error.middleware.js

# ── Services ───────────────────────────────────────────────
touch src/services/email.service.js
touch src/services/razorpay.service.js
touch src/services/qr.service.js
touch src/services/points.service.js
touch src/services/pdf.service.js

# ── Utils ──────────────────────────────────────────────────
touch src/utils/response.js
touch src/utils/validators.js
touch src/utils/helpers.js
touch src/utils/seed.js

BACKEND_FILES=$(find "$ROOT/eventfi_backend/src" -name "*.js" | wc -l | tr -d ' ')
echo "✅ Backend: $BACKEND_FILES JS files created"

# ═══════════════════════════════════════════════════════════════
#  PYTHON AI SERVICE
# ═══════════════════════════════════════════════════════════════
cd "$ROOT/eventfi_ai"

mkdir -p routes models utils data

touch routes/__init__.py
touch routes/recommendation.py
touch routes/search.py
touch routes/chatbot.py
touch routes/demand.py
touch routes/sentiment.py
touch routes/fake_detector.py

touch models/__init__.py
touch models/recommender.py
touch models/demand_predictor.py
touch models/fake_booking_model.py

touch utils/__init__.py
touch utils/gemini_client.py
touch utils/data_processor.py
touch utils/model_trainer.py

touch data/sample_bookings.csv

AI_FILES=$(find "$ROOT/eventfi_ai" -name "*.py" | wc -l | tr -d ' ')
echo "✅ AI Service: $AI_FILES Python files created"

# ─── Done ──────────────────────────────────────────────────
echo ""
echo "🎉 EventFi project structure is ready!"
echo "   Next: copy your Phase 0 code files into place"
echo "   Then: flutter pub get  &&  npm install  &&  pip install -r requirements.txt"
echo ""
