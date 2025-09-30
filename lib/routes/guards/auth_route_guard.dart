import '/resources/pages/sign_in_page.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Auth Route Guard
|--------------------------------------------------------------------------
| Checks if the User is authenticated.
|
| * [Tip] Create new route guards using the CLI 🚀
| Run the below in the terminal to create a new route guard.
| "dart run nylo_framework:main make:route_guard check_subscription"
|
| Learn more https://nylo.dev/docs/6.x/router#route-guards
|-------------------------------------------------------------------------- */

class AuthRouteGuard extends NyRouteGuard {
  AuthRouteGuard();

  @override
  onRequest(PageRequest pageRequest) async {
    // Check if user is persistently logged in
    bool isPersistentlyLoggedIn = await AuthService.isPersistentlyLoggedIn();

    if (!isPersistentlyLoggedIn) {
      // Redirect to sign-in page if not authenticated
      return redirect(SignInPage.path);
    }

    return pageRequest;
  }
}
