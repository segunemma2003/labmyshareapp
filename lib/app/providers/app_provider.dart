import 'package:flutter_app/app/networking/services_api_service.dart';

import '/config/keys.dart';
import '/app/forms/style/form_style.dart';
import '/config/form_casts.dart';
import '/config/decoders.dart';
import '/config/design.dart';
import '/config/theme.dart';
import '/config/validation_rules.dart';
import '/config/localization.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/welcome_screen_page.dart';
import '/resources/pages/sign_in_page.dart';
import '/resources/pages/base_navigation_hub.dart';
import '/app/networking/auth_api_service.dart';

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
    // Initial route is now set only in the router
  }

  // Example token validation (replace with your own logic/API call)
  /// Validate token by making a GET request. If 401, token is invalid.
  Future<bool> _validateToken(String token) async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Token $token';
      final response = await dio.get('https://backend.beautyspabyshea.co.uk/api/v1/services');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
