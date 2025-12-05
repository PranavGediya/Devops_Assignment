#!/bin/bash

set -e

echo "=========================================="
echo "Testing Deployed Application"
echo "=========================================="
echo ""

cd terraform

# Get ALB URL
ALB_URL=$(terraform output -raw alb_url 2>/dev/null)

if [ -z "$ALB_URL" ]; then
    echo "❌ Could not find ALB URL. Is the infrastructure deployed?"
    exit 1
fi

echo "🌐 Testing URL: $ALB_URL"
echo ""

# Test root endpoint
echo "📝 Testing / endpoint..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$ALB_URL/")
if [ "$RESPONSE" = "200" ]; then
    echo "✅ Root endpoint: PASS (HTTP $RESPONSE)"
    curl -s "$ALB_URL/"
    echo ""
else
    echo "❌ Root endpoint: FAIL (HTTP $RESPONSE)"
fi

echo ""

# Test health endpoint
echo "📝 Testing /health endpoint..."
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$ALB_URL/health")
HEALTH_BODY=$(curl -s "$ALB_URL/health")
if [ "$HEALTH_RESPONSE" = "200" ] && [ "$HEALTH_BODY" = "ok" ]; then
    echo "✅ Health endpoint: PASS (HTTP $HEALTH_RESPONSE, body: $HEALTH_BODY)"
else
    echo "❌ Health endpoint: FAIL (HTTP $HEALTH_RESPONSE, body: $HEALTH_BODY)"
fi

echo ""

# Test multiple times to verify load balancing
echo "📝 Testing load balancing (making 5 requests)..."
for i in {1..5}; do
    echo "Request $i:"
    curl -s "$ALB_URL/" | head -c 50
    echo "..."
    sleep 1
done

echo ""
echo ""
echo "=========================================="
echo "✅ Testing Complete!"
echo "=========================================="