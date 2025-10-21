#!/bin/bash
set -e

echo "🔍 Checking environment variables..."

# Ensure DATABASE_DIRECT_URL is set
if [ -z "$DATABASE_DIRECT_URL" ]; then
    echo "⚠️  DATABASE_DIRECT_URL not set, using DATABASE_URL"
    export DATABASE_DIRECT_URL="$DATABASE_URL"
fi

echo "✅ Environment variables configured"
echo "📊 Database URL: ${DATABASE_URL:0:30}..."
echo "📊 Direct URL: ${DATABASE_DIRECT_URL:0:30}..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Run migrations
echo "🚀 Running Prisma migrations..."
npx prisma migrate deploy

echo "✅ Migrations completed successfully!"

# Start the application
echo "🎉 Starting application..."
exec npm start
