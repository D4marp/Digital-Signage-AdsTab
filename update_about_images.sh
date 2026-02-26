#!/bin/bash

# Get authentication token
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"admin123"}' | jq -r '.token')

echo "Token obtained: ${TOKEN:0:50}..."

# Array of ad IDs
declare -a ADS=(
  "2046399f-e0f0-495f-9fe0-d21447ca9277"
  "5cf593f4-ddce-4910-9400-904f1b39cd10"
  "b781a159-25c3-4c37-ab29-deb088636394"
)

# Sample about images for each ad
declare -a ABOUT_IMAGES=(
  '["https://images.unsplash.com/photo-1491609154219-feb3807852ee?w=800","https://images.unsplash.com/photo-1511649475669-e288648b2e94?w=800","https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=800"]'
  '["https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800","https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=800","https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800"]'
  '["https://images.unsplash.com/photo-1488190211105-8b0e65b5b4fa?w=800","https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800","https://images.unsplash.com/photo-1469022563214-aa56433b5777?w=800"]'
)

# Update each ad
for i in "${!ADS[@]}"; do
  AD_ID=${ADS[$i]}
  IMAGES=${ABOUT_IMAGES[$i]}
  
  echo "Updating ad $((i+1))/3: $AD_ID"
  
  RESPONSE=$(curl -s -X PUT "http://localhost:8080/api/v1/ads/$AD_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"about_images\":$IMAGES}")
  
  COUNT=$(echo "$RESPONSE" | jq '.about_images | length' 2>/dev/null)
  echo "  ✅ About images count: $COUNT"
done

echo "All ads updated!"
