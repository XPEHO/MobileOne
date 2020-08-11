import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  Future<void> sendAnalyticsEvent(String name) async {
    await _analytics.logEvent(
      name: name,
    );
  }

  Future<void> setCurrentPage(String screenName) async {
    await _analytics.setCurrentScreen(screenName: screenName);
  }

  Future<void> loging() async {
    await _analytics.logLogin();
  }
}
