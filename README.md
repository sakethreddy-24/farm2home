# Farm2Home

Farm2Home connects farmers directly with consumers. Farmers list products; consumers browse, add to cart and place orders.

**Stack:** Flutter (Android) → REST API (Node.js + Express) → MySQL

## Project structure
```
farm2home/
├── backend/     # Express API (auth, products, orders)
├── frontend/    # Flutter mobile app
├── database.sql # Schema + sample data
└── PROJECT_GUIDE.md
```

## Run locally

### 1. Database
```bash
mysql -u root -p < database.sql
```

### 2. Backend
```bash
cd backend
cp .env.example .env     # then edit .env with your MySQL password and a JWT secret
npm install
npm start                # http://localhost:5000
```

### 3. Frontend
```bash
cd frontend
flutter pub get
flutter run
```
Android emulator reaches the backend at `http://10.0.2.2:5000` (set in `frontend/lib/utils/constants.dart`). On a physical phone, use your PC's LAN IP instead.

### Sample logins
Password `password123`: `farmer@farm2home.com`, `consumer@farm2home.com`

## API
| Route | Description |
|---|---|
| `POST /api/auth/register`, `POST /api/auth/login` | Register / login (JWT) |
| `GET/POST/DELETE /api/products` | Browse, add, delete products (farmer role for write) |
| `GET/POST /api/orders` | Place and view orders |

See `PROJECT_GUIDE.md` for a file-by-file walkthrough.
