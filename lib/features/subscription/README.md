# Subscription Feature

Handles user subscription plan management — upgrade/downgrade modals and manual payment verification.

## File Map

| Path | Role |
|------|------|
| `widgets/manual_payment_modal.dart` | Manual payment modal — displays bank transfer instructions for plan upgrades |
| `widgets/mission_upgrade_modal.dart` | Mission upgrade modal — plan selection UI with feature comparison and CTA |

## State Management

This feature does NOT have its own cubit. Subscription state is managed by `SubscriptionService` (singleton in `services/subscription_service.dart`) and consumed directly by the modals.

## ⚠️ AI Warnings

- **No cubit in this directory** — subscription state is read from `SubscriptionService` directly. Do NOT add a cubit here without evaluating whether `SubscriptionService` already covers the need.
- **Manual payment modal** shows static bank details — do NOT make it interactive or editable. It is read-only display.
- **`mission_upgrade_modal.dart`** triggers plan changes via `SubscriptionService.upgradePlan()`. Ensure you pass the correct `tier` string matching the database enum.
