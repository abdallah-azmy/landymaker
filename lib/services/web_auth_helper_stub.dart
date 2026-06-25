import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> signInWithGoogleWeb({
  required SupabaseClient client,
  bool selectAccount = false,
}) async {
  // Return false on mobile/desktop platforms where standard signInWithOAuth is used.
  return false;
}
