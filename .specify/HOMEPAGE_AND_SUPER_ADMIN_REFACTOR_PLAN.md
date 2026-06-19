# Homepage & Super Admin Refactor Plan

> **Author:** AI Assistant  
> **Date:** 2026-06-19  
> **Status:** Proposed — Not started  

---

## 📖 Pre-Reading (Verified)

Before writing this plan, the following sources were read and cross-referenced:
- [x] `AI_CONTEXT.md` — Master context, architecture, protected systems
- [x] `docs/ai/AI_ONBOARDING.md` — Entry point, safety rules, navigation
- [x] `docs/ai/AI_DOCUMENTATION_RULES.md` — Strict execution rules (30+ rules)
- [x] `docs/ai/AI_NAVIGATION.md` — System locations
- [x] `docs/ai/PROJECT_STRUCTURE.md` — Folder hierarchy
- [x] `docs/ai/ROUTE_INDEX.md` — Routes, guards, safe back nav
- [x] `docs/ai/FEATURE_INDEX.md` — Feature-to-file mapping
- [x] `docs/ai/SCREEN_INDEX.md` — Screen-to-file mapping
- [x] `docs/ai/SERVICE_INDEX.md` — Service dependencies
- [x] `docs/ai/DEPENDENCY_MAPS.md` — System relationships
- [x] `docs/ai/BUILDER_ARCHITECTURE.md` — Builder data flow
- [x] `docs/ai/BLOCK_SCHEMA_REGISTRY.md` — JSON schema
- [x] `docs/ai/THEME_SYSTEM.md` — Dynamic M3 theme rules
- [x] `docs/ai/TASK_ROUTING_GUIDE.md` — Task workflow
- [x] `docs/ai/DEVOPS_AND_ASSETS.md` — DevOps/CI-CD
- [x] `docs/ai/API_LOGGING_GUIDE.md` — Logging patterns

---

## 🎯 Scope

7 objectives consolidated into **4 execution phases**:

| # | Objective | Priority |
|---|-----------|----------|
| 1 | **Homepage layout optimization** — Eliminate wasted whitespace on desktop, fully responsive on mobile | High |
| 2 | **Super Admin — User profile page** — Click user name → full profile (pages, subscription, stats, renew/upgrade/downgrade/block) | High |
| 3 | **Super Admin — Bulk actions** — Multi-select users, batch renew/upgrade/downgrade/block | Medium |
| 4 | **Super Admin — Sidebar redesign** — Direct links to users, plans, homepage editor, templates, broadcast | Medium |
| 5 | **Super Admin — Users table mobile redesign** — Card-based layout replacing cramped table | Medium |
| 6 | **Homepage content management screen** — Super admin controls ALL homepage content (sections on/off, text, layout, template visibility) | High |
| 7 | **Replace sub-hero sliders/carousels** — Remove `FeatureBento`, `TemplateSlider`, `DesktopPreviewCarousel` below hero. Replace with dynamic landing-page sections rendered via `SectionRenderer`, fully controlled by super admin | High |

---

## 🏗 Phase 1: Homepage Layout Optimization

### Problem
- `HomeHeroSection` uses `BoxConstraints(maxWidth: 1200)` with `padding: 24` — too narrow on desktop (≥1440px)
- Phone preview mockup has fixed pixel sizes (`mockupWidth: 320`, `mockupHeight: 580`) instead of proportional scaling
- Split layout flex ratio (6:5 text:preview) creates imbalance on ultra-wide screens
- Feature Bento & CTA sections also constrained to 1200px

### Solution

1. **Hero Split Layout** (`home_hero_section.dart`):
   - Relax `maxWidth` from `1200` to `1400` on desktop (≥1200px), keep `1200` on smaller screens
   - Change outer `padding` horizontal: `isMobile ? 24 : 48` (was `24` for both)
   - Change flex ratio from `6:5` to `7:5` (more weight to text)
   - Convert phone preview from fixed pixels to `Flex`-based proportional sizing:
     - Wrap `_PhonePreview` in `Expanded` with `flex: 5`
     - Inside `_PhonePreview`, derive mockup size from `constraints.maxWidth`:
       ```dart
       final mockupWidth = isMobile ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.45;
       ```
   - Enlarge typography on desktop: `fontSize: isMobile ? 32 : 58` (was 52)

2. **Feature Bento** (`home_feature_bento.dart`):
   - Change outer `maxWidth` from `1200` to `1400`
   - Increase horizontal padding: `isMobile ? 24 : 48`

3. **CTA Section** (`home_cta_section.dart`):
   - Same padding/maxWidth treatment

4. **Navbar** (`home_navbar.dart`):
   - Full-width with content constrained to `maxWidth: 1400` centered

5. **Standard padding rule applied consistently**:
   - Mobile: `EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: ...)`
   - Desktop: `EdgeInsetsDirectional.symmetric(horizontal: 48, vertical: ...)`

### Rules to respect
- **Rule #12**: Use `LayoutBuilder` + `constraints.maxWidth` for responsiveness (already done)
- **Rule #24**: Factory pattern (already in place)
- **Rule #30**: Dynamic theme colors (already using `Theme.of(context).colorScheme.*`)

### Files
| File | Change |
|------|--------|
| `lib/features/home/widgets/home_hero_section.dart` | Relax constraints, proportional mockup, enlarged text |
| `lib/features/home/widgets/home_feature_bento.dart` | Relax maxWidth |
| `lib/features/home/widgets/home_cta_section.dart` | Relax constraints |
| `lib/features/home/widgets/home_navbar.dart` | Full-width layout |

**Progress:** [ ] Not started

---

## 🏗 Phase 2: Dynamic Homepage Engine

### 2A — Database Schema

New table `homepage_sections`:
```sql
CREATE TABLE homepage_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_key TEXT NOT NULL UNIQUE,
  is_visible BOOLEAN DEFAULT TRUE,
  sort_order INT NOT NULL DEFAULT 0,
  display_name TEXT NOT NULL,
  config JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

Modify `profiles` table:
```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMPTZ;
```

New table `subscriptions`:
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  plan_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  start_date TIMESTAMPTZ DEFAULT now(),
  end_date TIMESTAMPTZ,
  auto_renew BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2B — Homepage Configuration Data Model

The `homepage_sections.config` JSONB stores section-specific settings:

**hero config:**
```json
{
  "title": "ابنِ صفحة هبوط احترافية متكاملة لخدماتك",
  "subtitle": "بدون الحاجة لخبرة برمجية...",
  "typewriter_texts": [
    "منيو مطعم إلكتروني تفاعلي",
    "معرض أعمال شخصي للمستقلين"
  ],
  "cta_text": "ابدأ الآن مجاناً",
  "layout": "split",
  "show_phone_preview": true,
  "show_ai_button": true,
  "badge_text": "أطلق موقعك في ٥ دقائق فقط 🚀"
}
```

**templates config:**
```json
{
  "visible": true,
  "selected_template_ids": ["saas_startup", "restaurant_pro"],
  "max_to_show": 6,
  "title": "ابدأ بقوالب احترافية"
}
```

**cta config:**
```json
{
  "visible": true,
  "title": "جاهز لبناء صفحتك؟",
  "subtitle": "اختر قالباً وانطلق في دقائق",
  "button_text": "ابدأ مجاناً"
}
```

**footer config:**
```json
{
  "visible": true,
  "copyright_text": "© 2026 LandyMaker. جميع الحقوق محفوظة.",
  "links": [
    {"title": "عن المنصة", "url": "/about"},
    {"title": "سياسة الخصوصية", "url": "/privacy-policy"}
  ]
}
```

### 2C — Service Layer

Add to `DatabaseService`:
```dart
Future<List<Map<String, dynamic>>> getHomepageSections();
Future<void> updateHomepageSection(String sectionKey, Map<String, dynamic> data);
Future<void> updateHomepageSectionsOrder(List<Map<String, dynamic>> sections);
```

Add RPC or direct table access via Supabase.

### 2D — Homepage Screen Rewrite (`landymaker_home_screen.dart`)

The current screen has hardcoded sections:
```dart
Column(
  children: [
    HomeHeroSection(...),
    HomeFeatureBento(...),
    HomeLuxuriousTemplateSlider(...),
    HomeDesktopPreviewCarousel(...),
    HomeCtaSection(...),
    HomeFooter(),
  ],
)
```

Rewrite to read from `homepage_sections` and render dynamically:
```dart
BlocBuilder<HomepageCubit, HomepageState>(
  builder: (context, state) {
    return Column(
      children: state.visibleSections.map((section) {
        switch (section.sectionKey) {
          case 'hero':
            return HomeHeroSection(config: section.config);
          case 'template_block':
            return _buildTemplateBlock(section.config);
          case 'cta':
            return HomeCtaSection(config: section.config);
          case 'footer':
            return HomeFooter(config: section.config);
          // Template/preview blocks rendered via SectionRenderer
          default:
            if (section.templateDesignJson != null) {
              return SectionRenderer(
                pageId: 'homepage',
                theme: section.theme ?? defaultTheme,
                blocks: section.templateDesignJson,
              );
            }
            return SizedBox.shrink();
        }
      }).toList(),
    );
  },
);
```

### 2E — Remove Old Sections

- `HomeFeatureBento` → removed (replaced by template blocks controlled by super admin)
- `HomeLuxuriousTemplateSlider` → removed (replaced)
- `HomeDesktopPreviewCarousel` → removed (replaced)
- `HomeTemplateStrip` → removed (was unused)
- `HomeTestimonialsSection` → removed (can be re-added via template block)

The hero stays but becomes configurable.

### 2F — Homepage Editor Screen (Super Admin)

New screen at `/dashboard/super-admin/homepage`:

```
┌─────────────────────────────────────┐
│  🏠 Homepage Content Manager       │
│  Last updated: 5 min ago           │
├─────────────────────────────────────┤
│  ── Sections ──                     │
│  [☰] [ON] Navbar              [⚙️] │
│  [☰] [ON] Hero Section        [⚙️] │
│  [☰] [ON] Template Block      [⚙️] │
│  [☰] [ON] CTA                 [⚙️] │
│  [☰] [ON] Footer              [⚙️] │
│  [ ⋮⋮  Reorder  ]                  │
│                                     │
│  ── Add Section ──                  │
│  [ Template ▼ ] [Add]               │
│                                     │
│  ⚙️ Hero Settings:                  │
│  ┌─────────────────────────────────┐│
│  │ Title: [____________________]   ││
│  │ Subtitle: [________________]    ││
│  │ Layout: [Split ▼]               ││
│  │ [✓] Show phone preview          ││
│  │ [✓] Show AI button              ││
│  └─────────────────────────────────┘│
│                                     │
│  [📱 Preview Homepage]              │
└─────────────────────────────────────┘
```

**Files:**
| File | Type |
|------|------|
| `lib/features/super_admin/screens/homepage_editor_screen.dart` | New |
| `lib/features/super_admin/controllers/homepage_editor_cubit.dart` | New |
| `lib/features/super_admin/controllers/homepage_editor_state.dart` | New |
| `lib/features/super_admin/widgets/homepage_section_card.dart` | New |
| `lib/features/super_admin/widgets/section_config_editor.dart` | New |
| `lib/features/home/screens/landymaker_home_screen.dart` | Modified |
| `lib/features/home/controllers/homepage_cubit.dart` | New |
| `lib/features/home/controllers/homepage_state.dart` | New |
| `lib/services/database_service.dart` | Modified |

**Progress:** [ ] Not started

---

## 🏗 Phase 3: Super Admin User Profile & Bulk Actions

### 3A — User Profile Screen

**Route:** `/dashboard/super-admin/users/:userId`  
**Guard:** `super_admin` role only

Layout (Factory pattern with `_DesktopProfile` / `_MobileProfile`):

```
┌─ Header ────────────────────────────┐
│  ← Users          User Profile      │
│  [Avatar]  User Name                 │
│  email@example.com  •  Member since  │
│  Tier: PRO  •  Role: user           │
│  [Edit] [Renew] [Block] [Delete]    │
├─ Stats Row ─────────────────────────┤
│  👁 Views: 1,234  📋 Leads: 56     │
│  📄 Pages: 5  🔄 Conv: 4.5%        │
├─ Landing Pages ─────────────────────┤
│  ┌─── page-name ───┐ ┌─── page-2 ─┐│
│  │ Published ✓      │ │ Draft 📝   ││
│  │ [Edit] [Delete]  │ │ [Edit]     ││
│  └─────────────────┘ └────────────┘│
├─ Subscription ──────────────────────┤
│  Plan: PRO (1,199 EGP/mo)           │
│  Status: 🟢 Active                  │
│  Ends: 2026-08-15                   │
│  [Renew] [Upgrade ▼] [Downgrade ▼] │
├─ Activity Log ──────────────────────┤
│  • 2026-06-18  Published new page   │
│  • 2026-06-17  Subscription renewed │
│  • 2026-06-15  Received 3 leads     │
│  [View all →]                       │
└─────────────────────────────────────┘
```

**Data sources:**
- User profile → `profiles` table
- Landing pages → `landing_pages` table (filtered by `user_id`)
- Subscription → `subscriptions` table
- Analytics → `analytics` table (aggregated per user)
- Activity → `audit_logs` table (filtered by `target_user_id`)

**Actions:**
| Action | Implementation |
|--------|----------------|
| Renew subscription | Extend `subscription_end_date` by selected period, log to audit |
| Upgrade plan | Change `tier` in profiles, update subscription record |
| Downgrade plan | Change `tier` in profiles, update subscription record |
| Block user | Set `is_blocked = true` in profiles, log to audit |
| Unblock user | Set `is_blocked = false` in profiles, log to audit |
| Send notification | Reuse existing `SupabaseService.sendTargetedNotification()` |

**Files:**
| File | Type |
|------|------|
| `lib/features/super_admin/screens/user_profile_screen.dart` | New |
| `lib/features/super_admin/controllers/user_profile_cubit.dart` | New |
| `lib/features/super_admin/controllers/user_profile_state.dart` | New |
| `lib/features/super_admin/widgets/profile_stats_row.dart` | New |
| `lib/features/super_admin/widgets/profile_pages_list.dart` | New |
| `lib/features/super_admin/widgets/profile_subscription_card.dart` | New |
| `lib/features/super_admin/widgets/profile_activity_log.dart` | New |
| `lib/features/dashboard/screens/dashboard_shell.dart` | Add route |

### 3B — Users Table Mobile Redesign

Current: `ResponsiveDataTable` with small cards.
New: dedicated mobile card widget in `_buildUsersTab`.

On mobile (< 600px):
```
┌──────────────────────────────┐
│  AH  Ahmed Hassan            │
│  ahmed@email.com             │
│  🟡 PRO  •  5 pages          │
│  [🔔] [✏️] [👤 Profile]      │
├──────────────────────────────┤
│  MS  Mona Samir              │
│  mona@email.com              │
│  ⚪ FREE  •  2 pages         │
│  [🔔] [✏️] [👤 Profile]      │
└──────────────────────────────┘
```

Each card: leading avatar (first letter), name + email, tier pill + page count, action row with clear buttons. Links to user profile on name tap.

### 3C — Bulk Actions

**Selection mode** toggle in the Users tab:
- "Select Multiple" button activates checkboxes per row
- "Select All" checkbox in header
- Bottom action bar appears when ≥1 user selected:

```
┌── Bulk Actions ─────────────────────┐
│  3 users selected                    │
│  [🔄 Renew] [⬆️ Upgrade] [⬇️ Downgrade]│
│  [🚫 Block] [🔓 Unblock] [✉️ Notify] │
└─────────────────────────────────────┘
```

**File structure:**
| File | Type |
|------|------|
| `lib/features/super_admin/widgets/bulk_action_bar.dart` | New |
| `lib/features/super_admin/widgets/user_selection_table.dart` | New (extends/modifies users tab) |

**Database service additions:**
```dart
Future<void> bulkUpdateUserProfiles(List<String> userIds, Map<String, dynamic> data);
Future<void> bulkRenewSubscriptions(List<String> userIds, Duration period);
Future<void> bulkBlockUsers(List<String> userIds);
Future<void> bulkUnblockUsers(List<String> userIds);
```

All bulk operations must go through Supabase Edge Function or use batched RPC to ensure atomicity and audit logging.

### 3D — Sidebar Redesign

Current super admin sidebar items:
```
إدارة المنصة
├── Super Admin (/dashboard/super-admin)
├── Platform SEO (/dashboard/platform-seo)
└── Blog Management (/dashboard/blog-admin)
```

New:
```
إدارة المنصة
├── 👥 المستخدمين (/dashboard/super-admin/users) ← direct to users tab
├── 💳 الخطط والاشتراكات (/dashboard/super-admin/plans)
├── 🏠 إدارة الصفحة الرئيسية (/dashboard/super-admin/homepage)
├── 📦 القوالب (/dashboard/super-admin/templates)
├── 📢 الإشعارات الجماعية (/dashboard/super-admin/broadcast)
├── 📊 إحصائيات المنصة (/dashboard/super-admin/stats)
│
├── ⚙️ Platform SEO (/dashboard/platform-seo)
└── 📝 Blog Management (/dashboard/blog-admin)
```

This requires splitting the current single `SuperAdminPanelScreen` (with 9 tabs) into dedicated routes/pages or keeping the tabs but adding direct navigation to specific tabs.

**Approach:** Keep the tabbed panel as the main route, but use URL hash or query params to deep-link into specific tabs. Alternatively, create separate `StatefulShellBranch` entries for each tab.

**Simpler approach:** Keep `SuperAdminPanelScreen` with tabs, but:
- Sidebar items navigate to `/dashboard/super-admin?tab=users`
- `SuperAdminPanelScreen` reads query param and auto-selects the tab
- The active tab is synced to URL state

**Files:**
| File | Change |
|------|--------|
| `lib/core/widgets/organisms/sidebar_navigation.dart` | Add new sidebar items for super admin |
| `lib/features/super_admin/screens/super_admin_panel_screen.dart` | Support `?tab=` query param for deep-linking |

**Progress:** [ ] Not started

---

## 🏗 Phase 4: Route Registration, Docs & Polish

### 4A — Route Registration

New routes to add to `lib/core/router/app_router.dart`:

```dart
// Inside StatefulShellRoute branches:
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/dashboard/super-admin/homepage',
      builder: (context, state) => const HomepageEditorScreen(),
      redirect: superAdminGuard,
    ),
  ],
),
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/dashboard/super-admin/users/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserProfileScreen(userId: userId);
      },
      redirect: superAdminGuard,
    ),
  ],
),
```

And add all new paths to `TenantRoutingService.reservedPaths`.

### 4B — Documentation Updates

After each phase, update:
- `docs/ai/FEATURE_INDEX.md` — Add new features
- `docs/ai/ROUTE_INDEX.md` — Add new routes
- `docs/ai/SCREEN_INDEX.md` — Add new screens
- `docs/ai/SERVICE_INDEX.md` — Add new service methods
- `AI_CONTEXT.md` — Add Phase changes

### 4C — Audit Logging

All super admin actions must log to `audit_logs`:
- User block/unblock
- Subscription changes (renew, upgrade, downgrade)
- Homepage section changes
- Bulk actions

Use the existing `DatabaseService` pattern:
```dart
await supabase.from('audit_logs').insert({
  'admin_id': adminUserId,
  'action': 'BLOCK_USER',
  'table_name': 'profiles',
  'record_id': targetUserId,
  'old_data': oldData,
  'new_data': newData,
});
```

### 4D — Security

- Every new route has a `superAdminGuard`:
  ```dart
  redirect: (context, state) {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated && authState.role == 'super_admin') {
      return null;
    }
    return '/dashboard';
  },
  ```
- RLS policies on new tables: only `super_admin` role can write
- Edge Function for bulk operations (avoid client-side batch flaws)
- Rate limit on bulk notification sends

**Progress:** [ ] Not started

---

## 📋 Execution Order (Recommended)

```
Phase 1 ─── Homepage layout optimization
  │
  ▼
Phase 2 ─── Dynamic homepage engine (DB + service + screen rewrite + editor)
  │
  ▼
Phase 3A ── User profile screen
  │
  ▼
Phase 3B ── Users table mobile redesign
  │
  ▼
Phase 3C ── Bulk actions
  │
  ▼
Phase 3D ── Sidebar redesign
  │
  ▼
Phase 4 ─── Routes, docs, audit, security
```

---

## ⚠️ Architecture Constraints (Must Follow)

| # | Rule | Source |
|---|------|--------|
| 1 | All new UI: `Theme.of(context).colorScheme.*` for colors. Never `AppColors.*` for surface/text/border | Theme Rule #30 |
| 2 | No `const` with `Theme.of(context)`; strip `const` from enclosing widgets | Theme Rule #30 |
| 3 | `EdgeInsetsDirectional` for all padding/margin (RTL support) | Rule #12 |
| 4 | `PositionedDirectional` for all `Stack` positioning | Rule #12 |
| 5 | `LayoutBuilder` for responsive breakpoints; never `MediaQuery.size` in section widgets | Rule #12 |
| 6 | Factory pattern: hoist state to parent `StatefulWidget`, pass via props to `_DesktopLayout`/`_MobileLayout` | Rule #24 |
| 7 | New routes added to `reservedPaths` in `TenantRoutingService` | Rule #29 |
| 8 | `AnimatedThemeToggle` in every new top-level AppBar | Rule #31 |
| 9 | Super admin role guard on all new `/dashboard/super-admin/*` routes | Existing pattern |
| 10 | Audit logging for all destructive/billing actions | Existing pattern |

---

## 📁 File Summary

### New Files (13)
| File | Phase |
|------|-------|
| `lib/features/home/controllers/homepage_cubit.dart` | 2 |
| `lib/features/home/controllers/homepage_state.dart` | 2 |
| `lib/features/super_admin/screens/homepage_editor_screen.dart` | 2 |
| `lib/features/super_admin/controllers/homepage_editor_cubit.dart` | 2 |
| `lib/features/super_admin/controllers/homepage_editor_state.dart` | 2 |
| `lib/features/super_admin/widgets/homepage_section_card.dart` | 2 |
| `lib/features/super_admin/widgets/section_config_editor.dart` | 2 |
| `lib/features/super_admin/screens/user_profile_screen.dart` | 3 |
| `lib/features/super_admin/controllers/user_profile_cubit.dart` | 3 |
| `lib/features/super_admin/controllers/user_profile_state.dart` | 3 |
| `lib/features/super_admin/widgets/profile_stats_row.dart` | 3 |
| `lib/features/super_admin/widgets/bulk_action_bar.dart` | 3 |
| `lib/features/super_admin/widgets/user_selection_table.dart` | 3 |

### Modified Files (12)
| File | Phase |
|------|-------|
| `lib/features/home/widgets/home_hero_section.dart` | 1 |
| `lib/features/home/widgets/home_feature_bento.dart` | 1 |
| `lib/features/home/widgets/home_cta_section.dart` | 1 |
| `lib/features/home/widgets/home_navbar.dart` | 1 |
| `lib/features/home/screens/landymaker_home_screen.dart` | 2 |
| `lib/features/super_admin/screens/super_admin_panel_screen.dart` | 3 |
| `lib/features/super_admin/controllers/super_admin_cubit.dart` | 3 |
| `lib/features/super_admin/controllers/super_admin_state.dart` | 3 |
| `lib/core/widgets/organisms/sidebar_navigation.dart` | 3 |
| `lib/core/router/app_router.dart` | 4 |
| `lib/services/database_service.dart` | 2+3 |
| `lib/services/tenant_routing_service.dart` | 4 |

### Removed Files (4)
| File | Reason |
|------|--------|
| `lib/features/home/widgets/home_luxurious_template_slider.dart` | Replaced by dynamic template blocks |
| `lib/features/home/widgets/home_desktop_preview_carousel.dart` | Replaced by dynamic template blocks |
| `lib/features/home/widgets/home_template_strip.dart` | Was unused |
| `lib/features/home/widgets/home_testimonials_section.dart` | Replaced by dynamic template blocks |

### Database Migrations (3)
| File | Description |
|------|-------------|
| `supabase/migrations/20260620000000_homepage_sections.sql` | New `homepage_sections` table |
| `supabase/migrations/20260620000001_profiles_extensions.sql` | Add `is_blocked`, `subscription_end_date` to profiles |
| `supabase/migrations/20260620000002_subscriptions_table.sql` | New `subscriptions` table |

---

## 📊 Progress Tracker

### Phase 1: Homepage Layout Optimization
- [ ] `lib/features/home/widgets/home_hero_section.dart` — Relax constraints, proportional mockup, larger text
- [ ] `lib/features/home/widgets/home_feature_bento.dart` — Relax maxWidth
- [ ] `lib/features/home/widgets/home_cta_section.dart` — Relax constraints
- [ ] `lib/features/home/widgets/home_navbar.dart` — Full-width layout

### Phase 2: Dynamic Homepage Engine
- [ ] `supabase/migrations/20260620000000_homepage_sections.sql` — Create table
- [ ] `lib/services/database_service.dart` — Add homepage section CRUD
- [ ] `lib/features/home/controllers/homepage_cubit.dart` + `homepage_state.dart`
- [ ] `lib/features/home/screens/landymaker_home_screen.dart` — Rewrite to dynamic sections
- [ ] Remove old section widgets (feature_bento, template_slider, desktop_preview_carousel, template_strip, testimonials)
- [ ] `lib/features/super_admin/controllers/homepage_editor_cubit.dart` + state
- [ ] `lib/features/super_admin/screens/homepage_editor_screen.dart`
- [ ] `lib/features/super_admin/widgets/homepage_section_card.dart`
- [ ] `lib/features/super_admin/widgets/section_config_editor.dart`

### Phase 3: Super Admin User Profile & Bulk Actions
- [ ] `supabase/migrations/20260620000001_profiles_extensions.sql`
- [ ] `supabase/migrations/20260620000002_subscriptions_table.sql`
- [ ] `lib/services/database_service.dart` — Add user profile + subscription methods
- [ ] `lib/features/super_admin/controllers/user_profile_cubit.dart` + state
- [ ] `lib/features/super_admin/screens/user_profile_screen.dart`
- [ ] `lib/features/super_admin/widgets/profile_stats_row.dart`
- [ ] `lib/features/super_admin/screens/super_admin_panel_screen.dart` — Users tab mobile redesign
- [ ] `lib/features/super_admin/widgets/bulk_action_bar.dart`
- [ ] `lib/features/super_admin/widgets/user_selection_table.dart`
- [ ] `lib/core/widgets/organisms/sidebar_navigation.dart` — Add new sidebar items
- [ ] `lib/features/super_admin/controllers/super_admin_cubit.dart` — Add bulk methods
- [ ] `lib/features/super_admin/controllers/super_admin_state.dart` — Extend state

### Phase 4: Routes, Docs & Polish
- [ ] `lib/core/router/app_router.dart` — Add new routes + guards
- [ ] `lib/services/tenant_routing_service.dart` — Add reserved paths
- [ ] Update `docs/ai/FEATURE_INDEX.md`
- [ ] Update `docs/ai/ROUTE_INDEX.md`
- [ ] Update `docs/ai/SCREEN_INDEX.md`
- [ ] Update `docs/ai/SERVICE_INDEX.md`
- [ ] Update `AI_CONTEXT.md`
- [ ] Verify no analyzer errors (`dart analyze`)
- [ ] Verify RTL rendering on all new screens
- [ ] Verify dark mode on all new screens
