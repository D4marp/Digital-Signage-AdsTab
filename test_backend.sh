#!/bin/bash

 BASE_URL="http://saas.hcm-lab.id/api/v1"
# BASE_URL="http://localhost:8080/api/v1"
TOKEN=""


echo "🧪 DIGITAL SIGNAGE BACKEND TEST SUITE"
echo "======================================"
echo ""

# Helper function for colored output
success() {
    echo "✅ $1"
}

error() {
    echo "❌ $1"
}

info() {
    echo "ℹ️  $1"
}

# Test 1: Register new user
echo "1️⃣  TEST REGISTRATION"
echo "-------------------"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "admin123",
    "display_name": "Admin"
  }')

echo "Response: $REGISTER_RESPONSE"
TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ ! -z "$TOKEN" ]; then
  success "Registration successful, Token: ${TOKEN:0:20}..."
else
  error "Registration failed"
  echo "Full response: $REGISTER_RESPONSE"
fi
echo ""

# Test 2: Login
echo "2️⃣  TEST LOGIN"
echo "---------------"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testadmin@test.com",
    "password": "Test@123456"
  }')

echo "Response: $LOGIN_RESPONSE"
NEW_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ ! -z "$NEW_TOKEN" ]; then
  success "Login successful"
  TOKEN=$NEW_TOKEN
else
  error "Login failed"
fi
echo ""

# Test 3: Get Current User
echo "3️⃣  TEST GET CURRENT USER"
echo "-------------------------"
USER_RESPONSE=$(curl -s -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $USER_RESPONSE"
if echo "$USER_RESPONSE" | grep -q '"id"'; then
  success "Get current user successful"
else
  error "Get current user failed"
fi
echo ""

# Test 4: Get all ads (public)
echo "4️⃣  TEST GET ADS (PUBLIC)"
echo "-------------------------"
ADS_RESPONSE=$(curl -s -X GET "$BASE_URL/ads")

echo "Response: $ADS_RESPONSE"
if echo "$ADS_RESPONSE" | grep -q '\['; then
  success "Get ads successful"
else
  error "Get ads failed"
fi
echo ""

# Test 5: Get ad details to verify structure
echo "5️⃣  TEST GET AD DETAILS"
echo "------------------------"
echo "------------------------------"
CREATE_AD=$(curl -s -X POST "$BASE_URL/ads" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Ad with Gallery and About Images",
    "media_url": "https://example.com/main-image.jpg",
    "media_type": "image",
    "duration_seconds": 10,
    "target_locations": ["all"],
    "gallery_images": [
      "https://example.com/promo1.jpg",
      "https://example.com/promo2.jpg",
      "https://example.com/promo3.jpg"
    ],
    "about_images": [
      "https://example.com/about1.jpg",
      "https://example.com/about2.jpg"
    ]
  }')

echo "Response: $CREATE_AD"
AD_ID=$(echo "$CREATE_AD" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
if [ ! -z "$AD_ID" ]; then
  success "Create ad with gallery and about images successful, AD ID: $AD_ID"
else
  error "Create ad with gallery and about images failed"
  echo "Full response: $CREATE_AD"
fi
echo ""

# Test 7: Track Ad View
if [ ! -z "$AD_ID" ]; then
echo "7️⃣  TEST TRACK AD VIEW"
echo "---------------------"
VIEW_RESPONSE=$(curl -s -X POST "$BASE_URL/ads/$AD_ID/view" \
  -H "Content-Type: application/json" \
  -d '{}')

echo "Response: $VIEW_RESPONSE"
if echo "$VIEW_RESPONSE" | grep -q '"message"'; then
  success "Track ad view successful"
else
  error "Track ad view failed"
fi
echo ""
fi

# Test 8: Get Ad by ID (with gallery and total_views)
if [ ! -z "$AD_ID" ]; then
echo "8️⃣  TEST GET AD BY ID (WITH GALLERY AND ABOUT IMAGES)"
echo "---------------------------------------------------"
GET_AD=$(curl -s -X GET "$BASE_URL/ads/$AD_ID")

echo "Response: $GET_AD"
if echo "$GET_AD" | grep -q '"gallery_images"' && echo "$GET_AD" | grep -q '"about_images"' && echo "$GET_AD" | grep -q '"total_views"'; then
  success "Get ad with gallery and about images successful"
else
  error "Get ad with gallery and about images failed or missing fields"
fi
echo ""
fi

# Test 9: Update Ad Gallery and About Images
if [ ! -z "$AD_ID" ]; then
echo "9️⃣  TEST UPDATE AD GALLERY AND ABOUT IMAGES"
echo "-------------------------------------------"
UPDATE_AD=$(curl -s -X PUT "$BASE_URL/ads/$AD_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gallery_images": [
      "https://example.com/updated-promo1.jpg",
      "https://example.com/updated-promo2.jpg"
    ],
    "about_images": [
      "https://example.com/updated-about1.jpg",
      "https://example.com/updated-about2.jpg"
    ]
  }')

echo "Response: $UPDATE_AD"
if echo "$UPDATE_AD" | grep -q '"gallery_images"' && echo "$UPDATE_AD" | grep -q '"about_images"'; then
  success "Update ad gallery and about images successful"
else
  error "Update ad gallery and about images failed"
fi
echo ""
fi

# Test 10: Register Device
echo "🔟 TEST REGISTER DEVICE"
echo "---------------------"
DEVICE_RESPONSE=$(curl -s -X POST "$BASE_URL/devices/register" \
  -H "Content-Type: application/json" \
  -d '{
    "device_name": "Test Device",
    "device_type": "display",
    "location": "Main Store"
  }')

echo "Response: $DEVICE_RESPONSE"
DEVICE_ID=$(echo "$DEVICE_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
DEVICE_TOKEN=$(echo "$DEVICE_RESPONSE" | grep -o '"device_token":"[^"]*' | cut -d'"' -f4)
if [ ! -z "$DEVICE_ID" ]; then
  success "Register device successful, Device ID: $DEVICE_ID"
else
  error "Register device failed"
fi
echo ""

# Test 11: Get all devices (protected)
echo "1️⃣1️⃣  TEST GET DEVICES (PROTECTED)"
echo "--------------------------------"
GET_DEVICES=$(curl -s -X GET "$BASE_URL/devices" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $GET_DEVICES"
if echo "$GET_DEVICES" | grep -q '\['; then
  success "Get devices successful"
else
  error "Get devices failed"
fi
echo ""

# Test 12: Device heartbeat (public)
if [ ! -z "$DEVICE_ID" ]; then
echo "1️⃣2️⃣ TEST DEVICE HEARTBEAT"
echo "------------------------"
HEARTBEAT=$(curl -s -X POST "$BASE_URL/devices/$DEVICE_ID/heartbeat" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "online"
  }')

echo "Response: $HEARTBEAT"
if echo "$HEARTBEAT" | grep -q '"id"'; then
  success "Device heartbeat successful"
else
  error "Device heartbeat failed"
fi
echo ""
fi

# Test 13: Create impression (public)
if [ ! -z "$AD_ID" ] && [ ! -z "$DEVICE_ID" ]; then
echo "1️⃣3️⃣  TEST CREATE IMPRESSION"
echo "----------------------------"
IMPRESSION=$(curl -s -X POST "$BASE_URL/analytics/impressions" \
  -H "Content-Type: application/json" \
  -d "{
    \"ad_id\": \"$AD_ID\",
    \"device_id\": \"$DEVICE_ID\",
    \"impression_type\": \"view\"
  }")

echo "Response: $IMPRESSION"
if echo "$IMPRESSION" | grep -q '"id"'; then
  success "Create impression successful"
else
  error "Create impression failed"
fi
echo ""
fi

# Test 14: Get analytics (protected)
echo "1️⃣4️⃣  TEST GET ANALYTICS"
echo "------------------------"
ANALYTICS=$(curl -s -X GET "$BASE_URL/analytics" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $ANALYTICS"
if echo "$ANALYTICS" | grep -q '\['; then
  success "Get analytics successful"
else
  error "Get analytics failed"
fi
echo ""

# Test 15: Get dashboard stats (protected)
echo "1️⃣5️⃣  TEST DASHBOARD STATS"
echo "-------------------------"
DASHBOARD=$(curl -s -X GET "$BASE_URL/analytics/dashboard" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $DASHBOARD"
if echo "$DASHBOARD" | grep -q '"'; then
  success "Get dashboard stats successful"
else
  error "Get dashboard stats failed"
fi
echo ""

# Test 16: Delete Ad
if [ ! -z "$AD_ID" ]; then
echo "1️⃣6️⃣  TEST DELETE AD"
echo "-------------------"
DELETE_AD=$(curl -s -X DELETE "$BASE_URL/ads/$AD_ID" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $DELETE_AD"
if echo "$DELETE_AD" | grep -q '"message"' || echo "$DELETE_AD" | grep -q '"success"'; then
  success "Delete ad successful"
else
  error "Delete ad failed"
fi
echo ""
fi

echo "======================================"
echo "✨ TEST SUITE COMPLETE"
