class Secrets {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aqeubrtkodjavzukuoba.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_fiAYzv69-e8UplmSQnxV8Q_vxBbC-2W',
  );
}
