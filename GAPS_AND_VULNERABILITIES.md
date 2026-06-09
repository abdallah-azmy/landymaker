# Gaps and Vulnerabilities Analysis (E-commerce & Platform)

This document tracks current limitations, potential security risks, and future improvements for the LandyMaker platform, specifically focusing on the E-commerce experience.

## 1. E-commerce Limitations

### Product Management
- [ ] **No Product Variants**: Current system only supports flat product entries. No support for size, color, or material options.
- [ ] **Static Inventory**: No real-time inventory tracking. A product can be "purchased" via WhatsApp even if out of stock (if the admin doesn't manually remove it).
- [ ] **Limited Categories**: No nested categories support. Only top-level category filtering is available.

### Checkout & Payments
- [ ] **WhatsApp-Only Checkout**: While great for local markets, it lacks professional automated payments (Stripe, Paymob, etc.).
- [ ] **No Order History for Users**: Public users cannot see their previous orders since there is no persistent "Customer Account" on the public viewer.
- [ ] **Price Currency Hardcoded**: Currency is mostly hardcoded as EGP in many templates and UI labels.

### User Experience
- [ ] **Search Complexity**: No global product search across sections if multiple product blocks are used.
- [ ] **Cart Persistence**: Cart is stored in memory/state. If the user refreshes the page, the cart is lost (unless LocalStorage is used, which needs verification).

## 2. Technical Gaps

### Scalability
- [ ] **Product Feed Generation**: The `generate-product-feed` edge function is basic. Scaling to thousands of products might require more optimized database queries and pagination.
- [ ] **Image Optimization**: If users upload high-res images for products without compression, it will slow down page loads.

### Security
- [ ] **Public API Endpoints**: Ensure that the product feed and public viewer endpoints are strictly read-only and protected against scraping if necessary.
- [ ] **Super Admin Security**: The hardcoded security limits in the UI are good, but database RLS (Row Level Security) must be the source of truth (currently mentioned as being done in DB, but needs constant audit).

## 3. Future Opportunities
- [ ] **Abandoned Cart Recovery**: Since we use WhatsApp, we can't easily track abandoned carts unless we capture the phone number earlier in the funnel.
- [ ] **Up-sell/Cross-sell**: No automated "You might also like" sections based on cart contents.
- [ ] **Multi-currency Support**: Automatic currency conversion based on user location.
