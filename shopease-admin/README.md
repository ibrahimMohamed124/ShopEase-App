# ShopEase Command Center

Build a desktop-first admin dashboard for "ShopEase" — an existing Flutter e-commerce mobile app. This is an internal admin panel that will later be packaged inside Electron, so design it as a desktop web app (fixed sidebar layout, no mobile breakpoints needed, min-width ~1280px), NOT a responsive mobile-first app.

Tech stack

React + TypeScript + Vite

Tailwind CSS

React Router for navigation

A charting library (recharts) for the dashboard overview

Axios (or fetch) wrapped in a typed API client with JWT bearer auth

Design system (must match the mobile app exactly)

Colors (light theme only):

Background: #F8F9FE

Foreground/text: #1A1A2E

Card: #FFFFFF

Primary (accent, buttons, active states): #FF6B6B

Secondary: #6C63FF

Muted background: #F0F1F8

Muted foreground (secondary text): #9095A0

Border: #E8EAEF

Success: #22C55E

Destructive/error: #EF4444

Star/rating: #FFB800

Style rules:

Cards: white background, no shadow/elevation, border-radius: 16px, thin 1px border in #E8EAEF where needed instead of shadows

Inputs: filled style, border-radius: 14px, border #E8EAEF, focus border becomes primary #FF6B6B (1.5px)

Buttons: border-radius: 14px, primary buttons solid #FF6B6B with white text, font-weight 600, generous padding (18px horizontal / 14px vertical)

Outlined/secondary buttons: white bg, border #E8EAEF, text #1A1A2E

Chips/badges (order status, stock status, etc.): rounded-full (border-radius: 24px), background #F0F1F8

Overall feel: soft, rounded, flat, generous whitespace, modern e-commerce SaaS look — not dense/corporate. Think Material 3 but flattened (no shadows, no gradients).

Use a clean sans-serif (Inter or similar).

Layout

Fixed left sidebar (~240px) with logo/app name "ShopEase Admin" at top, nav items with icons, active item highlighted with a light #FF6B6B-tinted background and primary-colored text/icon.

Top bar: page title on the left, admin profile avatar + name on the right, maybe a search bar.

Main content area: #F8F9FE background, content in white rounded cards.

Sidebar navigation / pages to build

Dashboard (overview)

KPI cards: total revenue, total orders, total products, total users, pending returns

Revenue chart (line/area, last 30 days), orders by status (pie/donut: processing, shipped, delivered, cancelled)

Recent orders table (last 10)

Low-stock products widget

Products

Table: image thumbnail, name, category, price, original price (if discounted), rating, stock status (in stock / out of stock), badge (e.g. "New", "Sale")

Search + filter by category/stock status

Create/Edit product form (modal or side panel): name, description, price, original price, category, subcategory, image upload, badge, in-stock toggle

Delete with confirmation

Categories & Subcategories

Categories list: icon, name, color swatch (colorHex), product count, image

Nested/expandable subcategories per category

Create/edit/delete for both categories and subcategories

Orders

Table: order ID, date, customer, items count, total, status badge (processing=muted, shipped=secondary purple, delivered=success green, cancelled=destructive red), payment method

Order detail view: full item list (product image, name, price, qty, subtotal), shipping address, payment method, estimated delivery / delivered date, status history/timeline

Action: update order status (processing → shipped → delivered, or cancel)

Returns

Table: return ID, related order ID, product name, requested date, refund amount, status (in review / refunded / rejected), reason

Approve (mark refunded) / reject actions

Reviews

Table: product, reviewer name, rating (stars, use #FFB800), date, review text, verified purchase badge, helpful count

Ability to delete/moderate a review

Users

Table: name, email, phone, address, avatar

View user detail: profile info + their orders history

Payment methods overview (read-only reference screen)

List of payment method types in use across orders: Visa, Mastercard, Amex, PayPal, Cash on Delivery — just as a simple reference/filter, not full CRUD.

Data models (TypeScript interfaces to generate)

interface Product {
  id: string;
  name: string;
  price: number;
  originalPrice?: number;
  description: string;
  category: string; // category id
  rating: number;
  reviewCount: number;
  imageUrl: string;
  badge?: string;
  inStock: boolean;
}

interface Category {
  id: string;
  name: string;
  icon: string;
  colorHex: string;
  productCount: number;
  imageUrl: string;
  subcategories: string[];
}

interface Subcategory {
  id: string;
  name: string;
  categoryId: string;
  imageUrl: string;
}

type OrderStatus = 'processing' | 'shipped' | 'delivered' | 'cancelled';

interface OrderItem {
  productId: string;
  name: string;
  imageUrl: string;
  price: number;
  quantity: number;
}

interface Order {
  id: string;
  date: string;
  total: number;
  status: OrderStatus;
  items: OrderItem[];
  estimatedDelivery?: string;
  deliveredDate?: string;
  paymentMethod?: PaymentMethod;
}

type PaymentMethodType = 'visa' | 'mastercard' | 'amex' | 'paypal' | 'cashOnDelivery';

interface PaymentMethod {
  id: string;
  type: PaymentMethodType;
  lastFour?: string;
  expiry?: string;
  holderName?: string;
  isDefault: boolean;
}

type ReturnStatus = 'inReview' | 'refunded' | 'rejected';

interface ReturnRequest {
  id: string;
  orderId: string;
  productName: string;
  requestedDate: string;
  refundAmount: number;
  status: ReturnStatus;
  reason?: string;
}

interface ProductReview {
  id: string;
  productId: string;
  userId: string;
  name: string;
  rating: number;
  date: string;
  text: string;
  verified: boolean;
  helpfulCount: number;
}

interface AppUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  avatarUrl?: string;
}


API integration

The mobile app talks to a REST backend at apiBaseUrl (currently http://192.168.8.106:3000, make this configurable via an env var / settings screen since it'll change per environment). Auth is JWT Bearer token, sent as Authorization: Bearer <token> header, with automatic refresh-on-401 handled once in the API client.

Known existing endpoints from the mobile app (reuse the same base paths, extend with admin equivalents where needed — assume standard REST conventions: GET/POST/PUT/DELETE on the same base paths, plus an /admin prefix or query params for admin-only operations if the backend needs one):

POST /auth/login

POST /auth/register

POST /auth/forgot-password

GET /products, GET /products/featured

GET /categories

GET /orders

GET /cart

GET /wishlist

GET /users/me, PUT /users/me/avatar, PUT /users/me/shipping-address

Build the admin dashboard's API layer assuming it will call these same base resources with admin-level CRUD (POST/PUT/PATCH/DELETE on /products, /products/:id, /categories, /categories/:id, /orders/:id/status, /reviews/:id, /returns/:id/status, /users, /users/:id) — structure the API client so endpoint paths are easy to adjust later since the real backend contract may differ slightly.

Include a login screen for the admin (email + password) styled with the same design system, storing the JWT and redirecting to the dashboard.

Notes

Use mock/sample data for initial UI development so the dashboard renders fully without a live backend, then wire up the API client behind a simple service layer that's easy to swap.

Keep the whole app in a single consistent visual language — same card style, same spacing scale, same status-badge colors — across every page.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/831814df-31dc-4891-b060-26d74fc4390f).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
