import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://npsryevgqghkbllyszet.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'fake_key';
}
