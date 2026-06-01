import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://npsryevgqghkbllyszet.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'fake_key'; // I don't know the exact key but I can find it in lib/core/constants/api_keys.dart or similar.
}
