import 'package:emtrack/bindings/app_binding.dart';
import 'package:emtrack/l10n/app_localizations.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(GlobalLogoutHandler(), permanent: true);
  runApp(YokohamaApp());
}

class YokohamaApp extends StatelessWidget {
  const YokohamaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "EMTrack Mobile",
      debugShowCheckedModeBanner: false,
      locale: Locale('en'),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppPages.SPLASH,
      initialBinding: AppBindings(),
      getPages: AppPages.pages,
    );
  }
}
