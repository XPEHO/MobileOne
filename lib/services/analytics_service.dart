import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  Future<void> sendAnalyticsEvent(String name, String message) async {
    await _analytics.logEvent(
      name: name,
      parameters: {
        'message': message,
      },
    );
  }
}
