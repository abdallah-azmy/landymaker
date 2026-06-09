# Guest AI Generation Flow Guide

## Overview
To maximize user acquisition, LandyMaker now supports a **Guest AI Flow**. Users can generate a complete landing page without creating an account first.

## Technical Implementation

### 1. Edge Function Level (`ai-page-generate`)
- The function no longer requires a valid Bearer token for every request.
- If no token is provided, it falls back to **IP-based Rate Limiting**.
- Guests are limited to **2 generations per hour** to prevent API abuse.

### 2. Frontend Level (`AiMagicFormModal`)
- The modal can be triggered from anywhere in the app (Landing Page, Dashboard Login).
- If the user is a guest, the generated page is applied to a "Temporary Builder State".
- The user is prompted to "Save to Account" only after they see the value of the AI-generated result.

### 3. Data Persistence
- Guest generations are logged in `ai_usage_log` with a `null` `user_id` but a valid `ip_address`.
- This ensures accurate quota enforcement without requiring PII.

---
**Commercial Strategy**: "Value-First" conversion. Let the AI show the results, then ask for the email.
