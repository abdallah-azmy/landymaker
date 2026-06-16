# Implementation Plan: Dynamic Template Management via Super Admin Dashboard

This document details the architectural plan to migrate templates from static code registers to a dynamic Supabase database schema, allowing Super Admins to create, edit, draft, publish, and toggle homepage visibility of templates.

---

## 1. Database Schema (`templates` Table)

Create a new PostgreSQL table in Supabase to house template configurations.

```sql
CREATE TABLE templates (
    id TEXT PRIMARY KEY,                       -- e.g. 'saas_startup', 'fashion_store', or UUID
    name TEXT NOT NULL,                        -- Template name (localized translation key or raw text)
    description TEXT,                          -- Brief template summary
    image_url TEXT NOT NULL,                   -- Cover/Preview image URL
    category TEXT DEFAULT 'general',           -- Category (e.g. 'ecommerce', 'tech')
    recommended_sections TEXT[] DEFAULT '{}',  -- List of block types (e.g., {'hero', 'features'})
    ai_prompt_hint TEXT DEFAULT '',            -- Guideline hint for LLM generation
    design_json JSONB DEFAULT '{"blocks": []}',-- The canvas starting JSON structure
    is_active BOOLEAN DEFAULT TRUE,            -- Soft delete / active state
    is_draft BOOLEAN DEFAULT FALSE,            -- Draft mode (invisible to normal users)
    is_featured BOOLEAN DEFAULT FALSE,         -- Homepage visibility flag
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active, published templates
CREATE POLICY "Allow public read access to active templates"
ON templates FOR SELECT
USING (is_active = TRUE AND is_draft = FALSE);

-- Allow Super Admins full read/write access
CREATE POLICY "Allow super admins full access"
ON templates FOR ALL
USING (
    auth.uid() IN (
        SELECT id FROM profiles WHERE role = 'super_admin'
    )
);
```

---

## 2. Dynamic Migration Utility

To ensure backward compatibility and prevent cold-start empty states, write a one-time migration utility or seed script that reads `TemplateRegistry.availableTemplates` and writes them into Supabase `templates` table.

---

## 3. Backend & Cubit Integration

### 3.1 Database Service Updates (`lib/services/database_service.dart`)
- **`fetchTemplates()`**: Returns a `Future<List<Map<String, dynamic>>>` fetching templates from Supabase.
- **`createTemplate(Map<String, dynamic>)`**: Admin-only write.
- **`updateTemplate(String id, Map<String, dynamic>)`**: Admin-only update.
- **`deleteTemplate(String id)`**: Admin-only soft-delete (`is_active = false`).

### 3.2 Super Admin Cubit Updates (`lib/features/super_admin/controllers/`)
Add events/methods to fetch all templates (including drafts and inactive templates) and perform CRUD operations:
- `fetchAdminTemplates()`
- `saveTemplate(Map<String, dynamic>)`
- `toggleTemplateStatus(String id, {bool? isDraft, bool? isFeatured, bool? isActive})`

---

## 4. UI Refactoring

### 4.1 Home Screen Template Slider (`lib/features/home/widgets/home_luxurious_template_slider.dart`)
- Replace the static read of `TemplateRegistry.availableTemplates` with a dynamic Bloc fetch of templates marked `is_featured = true` and `is_draft = false`.
- **Fallback**: If the network fetch fails, fallback to `TemplateRegistry.availableTemplates`.

### 4.2 Template Picker Screen (`lib/features/home/screens/template_picker_screen.dart`)
- Fetch templates dynamically from the database (`is_active = true` and `is_draft = false`).
- Group by `category`.
- **Fallback**: Load static templates as local assets on failure.

### 4.3 Super Admin Panel (`lib/features/super_admin/screens/super_admin_panel_screen.dart`)
- Add an 8th tab labeled **Templates** (`Tab(text: "Templates", icon: Icon(Icons.dashboard_customize_rounded))`).
- Render a list of templates using `ResponsiveDataTable` displaying columns: Name, Category, Status (Live / Draft), Homepage (Featured / Standard), Actions.
- Provide a modal/dialog form (`_showTemplateEditorDialog`) to add or edit templates:
  - **Inputs**: Text fields for `id`, `name`, `description`, `image_url`, `category`, `ai_prompt_hint`.
  - **JSON editor**: Text field with JSON formatting validation to edit `design_json` directly.
  - **Switches**: Toggle `is_draft` and `is_featured`.
- Action buttons: Add Template, Edit, Delete, Toggle Draft.

---

## 5. Verification & Safety Guards

- Validate image URLs before saving to prevent broken asset links.
- Parse `design_json` using a `jsonDecode` check before updates to prevent malformed canvas definitions from breaking client routers.
