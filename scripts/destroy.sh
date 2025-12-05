#!/bin/bash

set -e

echo "=========================================="
echo "DevOps Infrastructure Teardown"
echo "=========================================="
echo ""

cd terraform

echo "⚠️  WARNING: This will destroy all resources!"
echo ""
read -p "Are you sure you want to destroy all infrastructure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Teardown cancelled."
    exit 0
fi

echo ""
echo "🔥 Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "=========================================="
echo "✅ Infrastructure destroyed successfully!"
echo "=========================================="
echo ""
echo "💰 All AWS resources have been removed to avoid charges."
echo ""