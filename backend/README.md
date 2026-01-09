# Digital Signage Backend

Backend API untuk aplikasi Digital Signage menggunakan Golang, Gin Framework, dan PostgreSQL.

## Prerequisites

- Go 1.21 atau lebih baru
- PostgreSQL 12 atau lebih baru
- Git

## Installation

1. Clone repository dan masuk ke folder backend:
```bash
cd backend
```

2. Install dependencies:
```bash
go mod download
```

3. Setup database PostgreSQL:
```bash
createdb digital_signage
```

4. Copy file environment dan sesuaikan:
```bash
cp .env.example .env
```

Edit `.env` dan sesuaikan dengan konfigurasi Anda:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=digital_signage

JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

PORT=8080
GIN_MODE=debug

UPLOAD_PATH=./uploads
MAX_UPLOAD_SIZE=100
```

## Running the Server

### Development mode:
```bash
go run main.go
```

### Build and run:
```bash
go build -o digital-signage-backend
./digital-signage-backend
```

Server akan berjalan di `http://localhost:8080`

## API Documentation

### Authentication

#### Register
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123",
  "display_name": "Admin User"
}
```

#### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "email": "admin@example.com",
    "display_name": "Admin User",
    "role": "admin"
  }
}
```

#### Get Current User
```
GET /api/v1/auth/me
Authorization: Bearer <token>
```

### Ads

#### Get All Ads
```
GET /api/v1/ads
Optional Query Params:
  - location: filter by location
  - active: true/false (filter active ads)
```

#### Get Ad by ID
```
GET /api/v1/ads/:id
```

#### Create Ad
```
POST /api/v1/ads
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Promo Spesial",
  "media_url": "/uploads/filename.jpg",
  "media_type": "image",
  "duration_seconds": 5,
  "target_locations": ["all"]
}
```

#### Update Ad
```
PUT /api/v1/ads/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "is_enabled": false
}
```

#### Delete Ad
```
DELETE /api/v1/ads/:id
Authorization: Bearer <token>
```

#### Upload Media
```
POST /api/v1/ads/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: <binary>
```

### Devices

#### Get All Devices
```
GET /api/v1/devices
Authorization: Bearer <token>
```

#### Register Device
```
POST /api/v1/devices/register
Content-Type: application/json

{
  "device_id": "unique-device-id",
  "location": "Lobby"
}
```

#### Update Device
```
PUT /api/v1/devices/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "location": "New Location",
  "is_online": true
}
```

#### Device Heartbeat
```
POST /api/v1/devices/:id/heartbeat
```

### Analytics

#### Create Impression
```
POST /api/v1/analytics/impressions
Content-Type: application/json

{
  "ad_id": "uuid",
  "device_id": "uuid"
}
```

#### Get Analytics
```
GET /api/v1/analytics
Authorization: Bearer <token>
Query Params:
  - start_date: YYYY-MM-DD
  - end_date: YYYY-MM-DD
  - ad_id: filter by ad
```

#### Get Dashboard Stats
```
GET /api/v1/analytics/dashboard
Authorization: Bearer <token>
```

#### Get Ad Performance
```
GET /api/v1/analytics/ads/:id/performance
Authorization: Bearer <token>
Query Params:
  - days: number of days (default: 30)
```

## Database Schema

### users
- id (UUID, PK)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- display_name (VARCHAR)
- role (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### ads
- id (UUID, PK)
- title (VARCHAR)
- media_url (TEXT)
- media_type (VARCHAR)
- duration_seconds (INT)
- order_index (INT)
- is_enabled (BOOLEAN)
- target_locations (TEXT[])
- created_by (UUID, FK -> users)
- is_deleted (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### devices
- id (UUID, PK)
- device_id (VARCHAR, UNIQUE)
- location (VARCHAR)
- is_online (BOOLEAN)
- last_active (TIMESTAMP)
- today_views (INT)
- settings (JSONB)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### impressions
- id (UUID, PK)
- ad_id (UUID, FK -> ads)
- device_id (UUID, FK -> devices)
- viewed_at (TIMESTAMP)

### ad_analytics
- id (UUID, PK)
- ad_id (UUID, FK -> ads)
- date (DATE)
- impressions (INT)
- unique_devices (INT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

## Project Structure

```
backend/
├── main.go                 # Entry point
├── config/
│   └── config.go          # Configuration management
├── database/
│   └── database.go        # Database connection & migrations
├── models/
│   ├── user.go
│   ├── ad.go
│   ├── device.go
│   └── analytics.go
├── handlers/
│   ├── auth.go
│   ├── ad.go
│   ├── device.go
│   └── analytics.go
├── middleware/
│   ├── auth.go
│   └── cors.go
├── routes/
│   └── routes.go
└── utils/
    ├── jwt.go
    └── password.go
```

## Security Notes

- JWT tokens expire after 7 days
- Passwords are hashed using bcrypt
- CORS is enabled for all origins (configure for production)
- File uploads are limited by MAX_UPLOAD_SIZE
- Authentication required for admin operations
- SQL injection protection through parameterized queries

## Production Deployment

1. Set `GIN_MODE=release` in `.env`
2. Use strong `JWT_SECRET`
3. Configure proper CORS origins in `middleware/cors.go`
4. Use HTTPS with reverse proxy (nginx/traefik)
5. Set up proper database backups
6. Configure file upload limits
7. Set up monitoring and logging

## License

MIT
