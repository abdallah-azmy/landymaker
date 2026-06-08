# Global Services

The `services` folder contains singleton classes that provide high-level abstractions for infrastructure and external integrations.

## 📡 Services Index

- **SupabaseService**: The primary bridge to the Supabase SDK. Handles Auth, Database queries, and Realtime listeners.
- **DatabaseService**: A high-level wrapper around `SupabaseService` focused on business-specific data operations (e.g., `saveLandingPage`).
- **AuthService**: Manages user authentication state and session persistence.
- **TenantRoutingService**: Crucial for resolving subdomains, custom domains, and path-based tenants at startup.
- **StorageService**: Handles binary file uploads (images) to Supabase Storage buckets.
- **ImageMediaService**: Integrates with external providers like Pixabay and handles ImgBB proxies.
- **SubscriptionService**: Enforces tier limits (max pages) and checks feature availability.

## ⚙️ Design Pattern

- All services are registered as singletons in `injection_container.dart`.
- They should not contain UI logic.
- They are injected into BLoC/Cubit controllers.
