# Farm2Home – Project Guide (for viva)

Farm2Home connects farmers with consumers. Farmers add products, and consumers browse, add to cart and order.

**Architecture:** `Flutter app  →  (HTTP + JSON)  →  Node/Express API  →  MySQL`

## How to run
1. Run `database.sql` in MySQL (creates the `farm2home` DB, tables and sample data).
2. Put your MySQL password in `backend/.env`.
3. `cd backend` → `npm install` → `npm start`  (runs on port 5000)
4. Start an Android emulator, then `cd frontend` → `flutter pub get` → `flutter run`

Sample logins (password `password123`): `farmer@farm2home.com`, `consumer@farm2home.com`.
Phone instead of emulator: change `baseUrl` in `lib/utils/constants.dart` to `http://<PC-IP>:5000`.

---

## Top level
| File | What / Why |
|---|---|
| `database.sql` | Creates the database, the 4 tables (with foreign keys) and sample users/products. One run sets up the whole DB. |
| `PROJECT_GUIDE.md` | This file. |

## backend/ (Node.js + Express)
| File | What / Why |
|---|---|
| `server.js` | Entry point. Creates the Express app, enables CORS and JSON parsing, mounts the 3 route groups, starts the server. |
| `package.json` | Lists dependencies (express, mysql2, cors, bcryptjs, jsonwebtoken, dotenv) and the `npm start` script. |
| `package-lock.json` | Auto-generated; locks exact versions. Don't edit. |
| `.env` | Secrets and settings: DB host/user/password/name, JWT secret, port. Kept out of the code. |
| `node_modules/` | Downloaded libraries (created by `npm install`). Can be deleted and recreated with `npm install`. |
| `config/db.js` | Creates one MySQL connection pool used by all controllers. |
| `middleware/auth.js` | `verifyToken` checks the JWT on each request and sets `req.user`. `requireRole('farmer')` blocks other roles. |
| `routes/auth.js` | Maps `POST /register` and `POST /login` to the controller. |
| `routes/products.js` | Maps the product URLs. Add/delete require the farmer role. |
| `routes/orders.js` | Maps order URLs. Placing an order requires the consumer role. |
| `controllers/authController.js` | Register (validates, hashes password with bcrypt, saves the user). Login (compares bcrypt hash, returns JWT + user info). |
| `controllers/productController.js` | List (with `?search=` and `?mine=true`), get one, add (farmer id comes from the token), delete (only your own). |
| `controllers/orderController.js` | Place order: reads prices from the DB, checks stock, saves order + items in one transaction, reduces stock. Get orders: consumer sees their own, farmer sees orders containing their products. |

**Why routes and controllers are separate:** routes decide *which URL*, controllers contain *what to do*.

## frontend/ (Flutter)
### Files you should know
| File | What / Why |
|---|---|
| `pubspec.yaml` | Flutter's package list. We added `http` (API calls) and `shared_preferences` (store login on the phone). |
| `android/app/src/main/AndroidManifest.xml` | Android settings. We added internet permission and allowed plain `http://` (needed for the local server). |

### Auto-generated (don't edit, don't explain)
| File | What |
|---|---|
| `pubspec.lock` | Locks exact package versions. |
| `analysis_options.yaml` | Code-style (lint) rules used by `flutter analyze`. |
| `.metadata`, `.gitignore`, `.dart_tool/`, `.flutter-plugins-dependencies`, `build/`, rest of `android/` | Created by Flutter/Gradle; needed to build the Android app. `build/` and `.dart_tool/` are recreated automatically. |

### lib/ – our code
| File | What / Why |
|---|---|
| `main.dart` | App start. Sets the green Material 3 theme and opens the Splash screen. |
| **utils/** | |
| `constants.dart` | Server URL, delivery fee, colours, category list, category→icon, date format. Central place for fixed values. |
| `session.dart` | Holds the logged-in user (token, name, role...) in memory and saves/loads/clears it using `shared_preferences`. This is how login is remembered and logout works. |
| `helpers.dart` | `showMessage` (snackbar) and `goToHome` (Consumer → consumer app, Farmer → farmer app). |
| **models/** | Plain Dart classes for data. |
| `product.dart` | A product, built from the server JSON. |
| `order.dart` | An order and its items, built from JSON. |
| `cart.dart` | Cart kept in memory (no DB table): add, remove, subtotal, total. |
| **services/** | |
| `api_service.dart` | The only file that talks to the backend: adds the JWT header, handles errors, auto-logout if the token is invalid. Every screen calls this. |
| **widgets/** | Reusable UI pieces. |
| `product_card.dart` | Product card on the home list. |
| `quantity_selector.dart` | The `[-] 1 [+]` control, used on details and cart. |
| **screens/** | One file per screen, grouped by who uses it: `auth/`, `consumer/`, `farmer/`, `shared/`. |
| `auth/splash_screen.dart` | Logo for 2 seconds; goes to home if already logged in, else Login. |
| `auth/login_screen.dart` / `auth/register_screen.dart` | Forms with validation; call the API. |
| `consumer/consumer_shell.dart` | Consumer bottom `NavigationBar`: Home, Cart, Orders, Profile. |
| `consumer/consumer_home_screen.dart` | Welcome text, search, product list, Add to Cart. |
| `consumer/product_details_screen.dart` | Full product info, quantity selector, Add to Cart. |
| `consumer/cart_screen.dart` | Cart items, +/-/remove, subtotal, delivery fee, total. |
| `consumer/checkout_screen.dart` | Name, phone, address, Place Order → API → clears cart. |
| `consumer/orders_screen.dart` | Consumer's orders with date, total, status. |
| `farmer/farmer_shell.dart` | Farmer bottom `NavigationBar`: Dashboard, Products, Orders, Profile. |
| `farmer/farmer_dashboard_screen.dart` | Welcome, product/order counts, shortcut buttons, Logout. |
| `farmer/add_product_screen.dart` | Form to add a product. |
| `farmer/my_products_screen.dart` | Farmer's own products with Delete. |
| `farmer/farmer_orders_screen.dart` | Orders containing the farmer's products, with customer name. |
| `shared/profile_screen.dart` | User info and Logout (shared by both roles). |

---

## Likely viva questions
- **How is the password stored?** Hashed with bcrypt; never saved as plain text.
- **What is JWT?** A signed token returned at login; Flutter sends it in the `Authorization: Bearer` header; the backend middleware verifies it.
- **How do you stop a consumer adding products?** `requireRole('farmer')` middleware returns 403.
- **Why `10.0.2.2`?** In the emulator `localhost` means the emulator itself; `10.0.2.2` is the host computer.
- **State management?** Only `setState()`. The cart is a static list in memory.
- **Why are prices read from DB when ordering?** So the app can't send fake prices.
- **Why a transaction in orders?** So the order, its items and the stock update all succeed or all fail together.
- **Where is login remembered?** `shared_preferences` (via `session.dart`).
