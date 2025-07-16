import '/resources/pages/booking_details_page.dart';
import '/resources/pages/select_time_page.dart';
import '/resources/pages/reset_password_o_t_p_page.dart';
import '/resources/pages/forgot_password_page.dart';
import '/resources/pages/welcome_screen_page.dart';
import '/resources/pages/legal_page.dart';
import '/resources/pages/faqs_page.dart';
import '/resources/pages/chat_page.dart';
import '/resources/pages/get_help_page.dart';
import '/resources/pages/payment_detail_page.dart';
import '/resources/pages/location_change_page.dart';
import '/resources/pages/profile_detail_page.dart';
import '/resources/pages/close_appointment_detail_page.dart';
import '/resources/pages/pending_appointment_detail_page.dart';
import '/resources/pages/open_appointment_detail_page.dart';
import '/resources/pages/review_page.dart';
import '/resources/pages/appointment_time_page.dart';
import '/resources/pages/select_professional_page.dart';
import '/resources/pages/select_services_page.dart';
import '/resources/pages/base_navigation_hub.dart';
import '/resources/pages/select_region_page.dart';
import '/resources/pages/confirm_selfie_page.dart';
import '/resources/pages/complete_profile_page.dart';
import '/resources/pages/new_password_page.dart';
import '/resources/pages/verify_email_page.dart';
import '/resources/pages/sign_in_page.dart';
import '/resources/pages/sign_up_page.dart';
import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Run the below in the terminal to create new a page.
| "dart run nylo_framework:main make:page profile_page"
|
| * [Tip] Add authentication 🔑
| Run the below in the terminal to add authentication to your project.
| "dart run scaffold_ui:main auth"
|
| * [Tip] Add In-app Purchases 💳
| Run the below in the terminal to add In-app Purchases to your project.
| "dart run scaffold_ui:main iap"
|
| Learn more https://nylo.dev/docs/6.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(HomePage.path);

      // Add your routes here ...
      // router.add(NewPage.path, transitionType: TransitionType.fade());

      // Example using grouped routes
      // router.group(() => {
      //   "route_guards": [AuthRouteGuard()],
      //   "prefix": "/dashboard"
      // }, (router) {
      //
      // });
      router.add(NotFoundPage.path).unknownRoute();
      router.add(SignUpPage.path);
      router.add(SignInPage.path).initialRoute();
      router.add(VerifyEmailPage.path);
      router.add(NewPasswordPage.path);
      router.add(CompleteProfilePage.path);
      router.add(ConfirmSelfiePage.path);
      router.add(SelectRegionPage.path);
      router.add(BaseNavigationHub.path);
      router.add(SelectServicesPage.path);
      router.add(SelectProfessionalPage.path);
      router.add(AppointmentTimePage.path);
      router.add(ReviewPage.path);
      router.add(OpenAppointmentDetailPage.path);
      router.add(PendingAppointmentDetailPage.path);
      router.add(CloseAppointmentDetailPage.path);
      router.add(ProfileDetailPage.path);
      router.add(LocationChangePage.path);
      router.add(PaymentDetailPage.path);
      router.add(GetHelpPage.path);
      router.add(ChatPage.path);

      router.add(FaqsPage.path);
      router.add(LegalPage.path);
      router.add(WelcomeScreenPage.path);
      router.add(ForgotPasswordPage.path);
      router.add(ResetPasswordOTPPage.path);
      router.add(SelectTimePage.path);
  router.add(BookingDetailsPage.path);
});
