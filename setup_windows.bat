@echo off
REM ─────────────────────────────────────────────────────────────
REM  EventFi — Full Project Structure Setup (Windows)
REM  Run from inside the eventfi\ root folder:
REM    setup_windows.bat
REM ─────────────────────────────────────────────────────────────

echo.
echo  Creating EventFi project structure...
echo.

REM ═══════════════════════════════════════════════════════════
REM  FLUTTER APP
REM ═══════════════════════════════════════════════════════════
cd eventfi_app

mkdir lib\core\constants
mkdir lib\core\theme
mkdir lib\core\routes
mkdir lib\core\network
mkdir lib\core\utils

mkdir lib\features\auth\screens
mkdir lib\features\auth\widgets
mkdir lib\features\auth\models
mkdir lib\features\auth\repository
mkdir lib\features\auth\providers

mkdir lib\features\home\screens
mkdir lib\features\home\widgets
mkdir lib\features\home\providers

mkdir lib\features\events\screens
mkdir lib\features\events\widgets
mkdir lib\features\events\models
mkdir lib\features\events\repository
mkdir lib\features\events\providers

mkdir lib\features\booking\screens
mkdir lib\features\booking\widgets
mkdir lib\features\booking\models
mkdir lib\features\booking\repository
mkdir lib\features\booking\providers

mkdir lib\features\points\screens
mkdir lib\features\points\widgets
mkdir lib\features\points\models
mkdir lib\features\points\repository
mkdir lib\features\points\providers

mkdir lib\features\wishlist\screens
mkdir lib\features\wishlist\repository
mkdir lib\features\wishlist\providers

mkdir lib\features\reviews\screens
mkdir lib\features\reviews\widgets
mkdir lib\features\reviews\models
mkdir lib\features\reviews\repository
mkdir lib\features\reviews\providers

mkdir lib\features\notifications\screens
mkdir lib\features\notifications\models
mkdir lib\features\notifications\repository
mkdir lib\features\notifications\providers

mkdir lib\features\profile\screens
mkdir lib\features\profile\providers

mkdir lib\features\admin\screens
mkdir lib\features\admin\providers

mkdir lib\shared\widgets
mkdir lib\shared\models
mkdir lib\services
mkdir assets\images
mkdir assets\fonts

REM Create empty Dart files
type nul > lib\core\utils\validators.dart
type nul > lib\core\utils\date_formatter.dart
type nul > lib\core\utils\helpers.dart

type nul > lib\features\auth\screens\onboarding_screen.dart
type nul > lib\features\auth\screens\login_screen.dart
type nul > lib\features\auth\screens\signup_screen.dart
type nul > lib\features\auth\screens\forgot_password_screen.dart
type nul > lib\features\auth\screens\otp_screen.dart
type nul > lib\features\auth\widgets\auth_text_field.dart
type nul > lib\features\auth\widgets\social_login_button.dart
type nul > lib\features\auth\models\user_model.dart
type nul > lib\features\auth\repository\auth_repository.dart
type nul > lib\features\auth\providers\auth_provider.dart

type nul > lib\features\home\screens\home_screen.dart
type nul > lib\features\home\widgets\category_tab.dart
type nul > lib\features\home\widgets\event_card.dart
type nul > lib\features\home\widgets\trending_section.dart
type nul > lib\features\home\widgets\search_bar_widget.dart
type nul > lib\features\home\providers\home_provider.dart

type nul > lib\features\events\screens\event_detail_screen.dart
type nul > lib\features\events\screens\event_list_screen.dart
type nul > lib\features\events\screens\event_search_screen.dart
type nul > lib\features\events\widgets\event_gallery.dart
type nul > lib\features\events\widgets\organizer_card.dart
type nul > lib\features\events\widgets\event_map_widget.dart
type nul > lib\features\events\widgets\event_filter_sheet.dart
type nul > lib\features\events\models\event_model.dart
type nul > lib\features\events\repository\event_repository.dart
type nul > lib\features\events\providers\event_provider.dart

type nul > lib\features\booking\screens\seat_selection_screen.dart
type nul > lib\features\booking\screens\checkout_screen.dart
type nul > lib\features\booking\screens\booking_confirmed_screen.dart
type nul > lib\features\booking\screens\booking_history_screen.dart
type nul > lib\features\booking\screens\ticket_screen.dart
type nul > lib\features\booking\widgets\seat_grid.dart
type nul > lib\features\booking\widgets\coupon_input.dart
type nul > lib\features\booking\widgets\price_breakdown.dart
type nul > lib\features\booking\widgets\qr_ticket_widget.dart
type nul > lib\features\booking\models\booking_model.dart
type nul > lib\features\booking\repository\booking_repository.dart
type nul > lib\features\booking\providers\booking_provider.dart

type nul > lib\features\points\screens\points_screen.dart
type nul > lib\features\points\screens\rewards_screen.dart
type nul > lib\features\points\widgets\points_balance_card.dart
type nul > lib\features\points\widgets\reward_tile.dart
type nul > lib\features\points\models\points_model.dart
type nul > lib\features\points\repository\points_repository.dart
type nul > lib\features\points\providers\points_provider.dart

type nul > lib\features\wishlist\screens\wishlist_screen.dart
type nul > lib\features\wishlist\repository\wishlist_repository.dart
type nul > lib\features\wishlist\providers\wishlist_provider.dart

type nul > lib\features\reviews\screens\reviews_screen.dart
type nul > lib\features\reviews\widgets\review_card.dart
type nul > lib\features\reviews\widgets\star_rating_widget.dart
type nul > lib\features\reviews\models\review_model.dart
type nul > lib\features\reviews\repository\review_repository.dart
type nul > lib\features\reviews\providers\review_provider.dart

type nul > lib\features\notifications\screens\notifications_screen.dart
type nul > lib\features\notifications\models\notification_model.dart
type nul > lib\features\notifications\repository\notification_repository.dart
type nul > lib\features\notifications\providers\notification_provider.dart

type nul > lib\features\profile\screens\profile_screen.dart
type nul > lib\features\profile\providers\profile_provider.dart

type nul > lib\features\admin\screens\admin_dashboard_screen.dart
type nul > lib\features\admin\screens\admin_events_screen.dart
type nul > lib\features\admin\screens\admin_bookings_screen.dart
type nul > lib\features\admin\screens\admin_coupons_screen.dart
type nul > lib\features\admin\screens\admin_rewards_screen.dart
type nul > lib\features\admin\screens\admin_qr_scanner_screen.dart
type nul > lib\features\admin\providers\admin_provider.dart

type nul > lib\shared\widgets\app_button.dart
type nul > lib\shared\widgets\app_text_field.dart
type nul > lib\shared\widgets\app_loader.dart
type nul > lib\shared\widgets\app_snackbar.dart
type nul > lib\shared\widgets\app_bottom_nav.dart
type nul > lib\shared\widgets\empty_state_widget.dart
type nul > lib\shared\widgets\error_widget.dart
type nul > lib\shared\models\api_response.dart

type nul > lib\services\firebase_service.dart
type nul > lib\services\storage_service.dart
type nul > lib\services\fcm_service.dart

echo  [OK] Flutter files created
cd ..

REM ═══════════════════════════════════════════════════════════
REM  NODE.JS BACKEND
REM ═══════════════════════════════════════════════════════════
cd eventfi_backend

mkdir src\config
mkdir src\models
mkdir src\routes
mkdir src\controllers
mkdir src\middleware
mkdir src\services
mkdir src\utils

type nul > src\models\User.js
type nul > src\models\Event.js
type nul > src\models\Booking.js
type nul > src\models\Coupon.js
type nul > src\models\Review.js
type nul > src\models\Notification.js
type nul > src\models\Points.js

type nul > src\routes\auth.routes.js
type nul > src\routes\event.routes.js
type nul > src\routes\booking.routes.js
type nul > src\routes\coupon.routes.js
type nul > src\routes\points.routes.js
type nul > src\routes\review.routes.js
type nul > src\routes\notification.routes.js
type nul > src\routes\admin.routes.js

type nul > src\controllers\auth.controller.js
type nul > src\controllers\event.controller.js
type nul > src\controllers\booking.controller.js
type nul > src\controllers\coupon.controller.js
type nul > src\controllers\points.controller.js
type nul > src\controllers\review.controller.js
type nul > src\controllers\notification.controller.js
type nul > src\controllers\admin.controller.js

type nul > src\middleware\auth.middleware.js
type nul > src\middleware\admin.middleware.js
type nul > src\middleware\validate.middleware.js
type nul > src\middleware\error.middleware.js

type nul > src\services\email.service.js
type nul > src\services\razorpay.service.js
type nul > src\services\qr.service.js
type nul > src\services\points.service.js
type nul > src\services\pdf.service.js

type nul > src\utils\response.js
type nul > src\utils\validators.js
type nul > src\utils\helpers.js
type nul > src\utils\seed.js

echo  [OK] Backend files created
cd ..

REM ═══════════════════════════════════════════════════════════
REM  PYTHON AI SERVICE
REM ═══════════════════════════════════════════════════════════
cd eventfi_ai

mkdir routes
mkdir models
mkdir utils
mkdir data

type nul > routes\__init__.py
type nul > routes\recommendation.py
type nul > routes\search.py
type nul > routes\chatbot.py
type nul > routes\demand.py
type nul > routes\sentiment.py
type nul > routes\fake_detector.py

type nul > models\__init__.py
type nul > models\recommender.py
type nul > models\demand_predictor.py
type nul > models\fake_booking_model.py

type nul > utils\__init__.py
type nul > utils\gemini_client.py
type nul > utils\data_processor.py
type nul > utils\model_trainer.py

type nul > data\sample_bookings.csv

echo  [OK] AI service files created
cd ..

echo.
echo  EventFi structure ready!
echo  Next steps:
echo    flutter pub get
echo    npm install  (in eventfi_backend)
echo    pip install -r requirements.txt  (in eventfi_ai)
echo.
pause
