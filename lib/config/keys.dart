import 'package:nylo_framework/nylo_framework.dart';

/* Keys
|--------------------------------------------------------------------------
| Storage keys are used to read and write to local storage.
| E.g. static StorageKey coins = "SK_COINS";
| String coins = await Keys.coins.read();
|
| Learn more: https://nylo.dev/docs/6.x/storage#storage-keys
|-------------------------------------------------------------------------- */

class Keys {
  // Define the keys you want to be synced on boot
  static syncedOnBoot() => () async {
        return [
          auth,
          bearerToken,
          currentRegion,
          userProfile,
          // coins.defaultValue(10), // give the user 10 coins by default
        ];
      };

  static StorageKey auth = getEnv('SK_USER', defaultValue: 'SK_USER');
  static StorageKey bearerToken = 'SK_BEARER_TOKEN';
  static StorageKey currentRegion = 'SK_CURRENT_REGION';
  static StorageKey userProfile = 'SK_USER_PROFILE';
  static StorageKey selectedServices = 'SK_SELECTED_SERVICES';
  static StorageKey selectedProfessional = 'SK_SELECTED_PROFESSIONAL';
  static StorageKey bookingDraft = 'SK_BOOKING_DRAFT';
  static StorageKey paymentMethods = 'SK_PAYMENT_METHODS';
  static StorageKey notificationPreferences = 'SK_NOTIFICATION_PREFERENCES';
  // static StorageKey coins = 'SK_COINS';

  /// Add your storage keys here...
}
