// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:async';

/// Opens Razorpay checkout popup on web using checkout.js (loaded in index.html).
/// Returns payment IDs on success, null on cancel/timeout.
Future<Map<String, String>?> razorpayWebCheckout(
    String key, String orderId, int paise) async {

  // Clear any leftover state from a previous attempt
  js.context['_rzpResult'] = null;

  js.context.callMethod('eval', ['''
    (function() {
      window._rzpResult = null;
      var rzp = new Razorpay({
        key:         '$key',
        order_id:    '$orderId',
        amount:      $paise,
        currency:    'INR',
        name:        'EventFi',
        description: 'Event Ticket Booking',
        theme:       { color: '#FF6B35' },
        handler: function(response) {
          window._rzpResult = {
            ok: true,
            p:  response.razorpay_payment_id,
            o:  response.razorpay_order_id,
            s:  response.razorpay_signature
          };
        },
        modal: {
          ondismiss: function() {
            if (!window._rzpResult) {
              window._rzpResult = { ok: false };
            }
          }
        }
      });
      rzp.open();
    })();
  ''']);

  // Poll every 500ms — Razorpay calls the handler asynchronously
  for (int i = 0; i < 120; i++) {          // 60 second max timeout
    await Future.delayed(const Duration(milliseconds: 500));
    final result = js.context['_rzpResult'];
    if (result != null) {
      js.context['_rzpResult'] = null;      // clean up
      if (result['ok'] == true) {
        return {
          'paymentId': result['p']?.toString() ?? '',
          'orderId':   result['o']?.toString() ?? '',
          'signature': result['s']?.toString() ?? '',
        };
      }
      return null; // cancelled by user
    }
  }

  return null; // timeout
}
