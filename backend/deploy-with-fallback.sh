#!/bin/bash
set -e

echo "🔍 Checking environment variables..."

# Ensure DATABASE_DIRECT_URL is set
if [ -z "$DATABASE_DIRECT_URL" ]; then
    echo "⚠️  DATABASE_DIRECT_URL not set, using DATABASE_URL"
    export DATABASE_DIRECT_URL="$DATABASE_URL"
fi

echo "✅ Environment variables configured"

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Try to deploy migrations, if it fails, use db push
echo "🚀 Attempting to run Prisma migrations..."
if npx prisma migrate deploy 2>/dev/null; then
    echo "✅ Migrations completed successfully!"
else
    echo "⚠️  Migration deploy failed, falling back to db push..."
    npx prisma db push --skip-generate
    echo "✅ Database schema synchronized!"
fi

# Start the application
echo "🎉 Starting application..."
exec npm start
