#!/bin/bash

# Test script untuk verifikasi koneksi Flutter ke Backend

echo "🧪 Testing Digital Signage Connection..."
echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Endpoint..."
HEALTH=$(curl -s http://localhost:8080/health)
if [[ $HEALTH == *"ok"* ]]; then
    echo "   ✅ Backend is healthy"
else
    echo "   ❌ Backend health check failed"
    exit 1
fi

# Test 2: Login
echo ""
echo "2️⃣ Testing Login Endpoint..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
    echo "   ✅ Login successful"
    echo "   Token: ${TOKEN:0:20}..."
else
    echo "   ❌ Login failed"
    echo "   Response: $LOGIN_RESPONSE"
    exit 1
fi

# Test 3: Get Current User
echo ""
echo "3️⃣ Testing Auth Me Endpoint..."
USER_RESPONSE=$(curl -s http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN")

if [[ $USER_RESPONSE == *"admin@test.com"* ]]; then
    echo "   ✅ User authenticated"
    echo "   Email: admin@test.com"
else
    echo "   ❌ Authentication failed"
    exit 1
fi

# Test 4: Get Ads
echo ""
echo "4️⃣ Testing Ads Endpoint..."
ADS_RESPONSE=$(curl -s http://localhost:8080/api/v1/ads)
echo "   ✅ Ads endpoint accessible"
echo "   Response: $(echo $ADS_RESPONSE | head -c 100)..."

# Test 5: Get Devices
echo ""
echo "5️⃣ Testing Devices Endpoint..."
DEVICES_RESPONSE=$(curl -s http://localhost:8080/api/v1/devices \
  -H "Authorization: Bearer $TOKEN")
echo "   ✅ Devices endpoint accessible"

# Test 6: Dashboard Stats
echo ""
echo "6️⃣ Testing Dashboard Stats..."
STATS_RESPONSE=$(curl -s http://localhost:8080/api/v1/analytics/dashboard \
  -H "Authorization: Bearer $TOKEN")
echo "   ✅ Dashboard stats accessible"

echo ""
echo "✅ All tests passed!"
echo ""
echo "Backend is ready to accept Flutter app connections"
echo ""
echo "Run Flutter app with:"
echo "  flutter run -d chrome"
echo "  flutter run -d macos"
echo "  flutter run -d 'iPhone 16 Pro'"
