# Supabase Backend

LandyMaker uses Supabase as its primary backend and infrastructure layer.

## 📂 Structure

- `migrations/`: Versioned SQL files defining the tables, views, and RLS (Row Level Security) policies.
- `functions/`: Serverless Deno Edge Functions for sensitive operations:
  - `lead-submit`: Routes form data, verifies Cloudflare Turnstile, and enforces rate limits.
  - `verify-turnstile`: Validates Captcha tokens.
  - `lead-notify`: (Future) Push/Email notifications for new leads.

## 🛡️ Row Level Security (RLS)

All tables are protected by strict RLS policies:
- `landing_pages`: Only owners can insert/update. Public can select if `is_published` is true.
- `leads`: Restricted access via Edge Functions for security.
- `analytics`: Insert allowed anonymously via `increment_page_view` RPC only.

## ⚙️ How to Deploy

Use the Supabase CLI:
```bash
supabase functions deploy <function-name>
supabase db push
```
