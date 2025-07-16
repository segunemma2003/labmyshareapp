import 'package:nylo_framework/nylo_framework.dart';

class AuthProvider implements NyProvider {

  @override
  boot(Nylo nylo) async {
   
     // boot your provider
     // ...
   
     return nylo;
  }
  
  @override
  afterBoot(Nylo nylo) async {
   
     // Called after Nylo has finished booting
     // ...
  }
}
