import '/config/keys.dart';
import '/app/forms/style/form_style.dart';
import '/config/form_casts.dart';
import '/config/decoders.dart';
import '/config/design.dart';
import '/config/theme.dart';
import '/config/validation_rules.dart';
import '/config/localization.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/resources/pages/base_navigation_hub.dart';
import '/resources/pages/sign_in_page.dart';

class AppProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    await NyLocalization.instance.init(
      localeType: localeType,
      languageCode: languageCode,
      assetsDirectory: assetsDirectory,
    );

    FormStyle formStyle = FormStyle();

    nylo.addLoader(loader);
    nylo.addLogo(logo);
    nylo.addThemes(appThemes);
    nylo.addToastNotification(getToastNotificationWidget);
    nylo.addValidationRules(validationRules);
    nylo.addModelDecoders(modelDecoders);
    nylo.addControllers(controllers);
    nylo.addApiDecoders(apiDecoders);
    nylo.addFormCasts(formCasts);
    nylo.useErrorStack();
    nylo.addFormStyle(formStyle);
    nylo.addAuthKey(Keys.auth);
    await nylo.syncKeys(Keys.syncedOnBoot);

    // Initial route is now set only in the router

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {
    // Check if user is persistently logged in and set initial route accordingly
    try {
      final isPersistentlyLoggedIn = await AuthService.isPersistentlyLoggedIn();

      if (isPersistentlyLoggedIn) {
        // User is logged in, authenticate with Nylo and navigate to main app
        print('User is persistently logged in, authenticating with Nylo');

        // Get user data and authenticate with Nylo
        final userData = await AuthService.getCurrentUser();
        if (userData != null) {
          await Auth.authenticate(data: userData.toJson());
          // Navigate to main app using Nylo's routeTo
          routeTo(BaseNavigationHub.path);
        }
      } else {
        // User is not logged in, check if it's first time opening the app
        final hasOpenedApp = await Keys.hasOpenedApp.read();

        if (hasOpenedApp == true) {
          // Not first time, go directly to login page
          print('User has opened app before, navigating to login page');
          routeTo(SignInPage.path);
        } else {
          // First time opening the app, show welcome screen
          print('First time opening app, staying on welcome screen');
          // Mark that user has opened the app
          await Keys.hasOpenedApp.save(true);
        }
      }
    } catch (e) {
      print('Error checking persistent login in afterBoot: $e');
      // On error, default to welcome page
    }
  }
}
