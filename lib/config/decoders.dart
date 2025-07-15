import '/app/models/notification.dart';
import '/app/models/region.dart';
import '/app/models/booking.dart';
import '/app/networking/notification_api_service.dart';
import '/app/networking/paymments_api_service.dart';
import '/app/networking/bookings_api_service.dart';
import '/app/networking/professionals_api_service.dart';
import '/app/networking/services_api_service.dart';
import '/app/networking/region_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/app/models/professional.dart';
import '/app/models/add_on_service.dart';
import '/app/models/service_item.dart';
import '/app/controllers/home_controller.dart';
import '/app/models/user.dart';
import '/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/6.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  // User: (data) => User.fromJson(data),

  List<Service>: (data) =>
      List.from(data).map((json) => Service.fromJson(json)).toList(),

  Service: (data) => Service.fromJson(data),

  List<AddOn>: (data) =>
      List.from(data).map((json) => AddOn.fromJson(json)).toList(),

  AddOn: (data) => AddOn.fromJson(data),

  List<Professional>: (data) =>
      List.from(data).map((json) => Professional.fromJson(json)).toList(),

  Professional: (data) => Professional.fromJson(data),

  List<Booking>: (data) =>
      List.from(data).map((json) => Booking.fromJson(json)).toList(),

  Booking: (data) => Booking.fromJson(data),

  List<Region>: (data) =>
      List.from(data).map((json) => Region.fromJson(json)).toList(),

  Region: (data) => Region.fromJson(data),

  List<NotificationModel>: (data) =>
      List.from(data).map((json) => NotificationModel.fromJson(json)).toList(),

  NotificationModel: (data) => NotificationModel.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/6.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...

  AuthApiService: AuthApiService(),

  RegionApiService: RegionApiService(),

  ServicesApiService: ServicesApiService(),

  ProfessionalsApiService: ProfessionalsApiService(),

  BookingsApiService: BookingsApiService(),

  PaymmentsApiService: PaymmentsApiService(),

  NotificationApiService: NotificationApiService(),
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/6.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),

  // ...
};
