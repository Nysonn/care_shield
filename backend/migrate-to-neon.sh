#!/bin/bash#!/bin/bash



echo "🚀 Starting Neon Database Migration"echo "🚀 Starting Neon Database Migration"

echo "===================================="echo "===================================="



# Colors for output# Step 1: Backup from Render (BEFORE switching .env)

GREEN='\033[0;32m'echo ""

BLUE='\033[0;34m'echo "📦 Step 1: Creating backup from Render..."

YELLOW='\033[1;33m'echo "Run this command manually with your Render credentials:"

RED='\033[0;31m'echo 'pg_dump "postgresql://care_sheild_db_user:jjaoAXJ6psEFOLZVhWR7iR5uTgUz9rQn@dpg-d3cr2eq4d50c73cq4g10-a.oregon-postgres.render.com/care_sheild_db?sslmode=require" > render-backup.sql'

NC='\033[0m' # No Colorecho ""

read -p "Press Enter after you've created the backup..."

# Step 1: Backup from Render

echo ""# Step 2: Run Prisma migrations on Neon

echo -e "${BLUE}📦 Step 1: Creating backup from Render...${NC}"echo ""

echo "Run this command to backup your Render database:"echo "🔧 Step 2: Setting up schema on Neon..."

echo ""npx prisma migrate deploy

echo -e "${YELLOW}pg_dump \"postgresql://care_sheild_db_user:jjaoAXJ6psEFOLZVhWR7iR5uTgUz9rQn@dpg-d3cr2eq4d50c73cq4g10-a.oregon-postgres.render.com/care_sheild_db?sslmode=require\" > render-backup.sql${NC}"

echo ""# Step 3: Restore data

read -p "Press Enter after you've created the backup file..."echo ""

echo "📥 Step 3: Restoring data to Neon..."

# Check if backup existsif [ -f "render-backup.sql" ]; then

if [ ! -f "render-backup.sql" ]; then  psql "postgresql://neondb_owner:npg_sJ5leG9XutnO@ep-square-glade-a4ba2w83.us-east-1.aws.neon.tech/neondb?sslmode=require" < render-backup.sql

  echo -e "${RED}❌ Error: render-backup.sql not found!${NC}"  echo "✅ Data restored successfully!"

  exit 1else

fi  echo "⚠️  render-backup.sql not found. Please create backup first."

  exit 1

echo -e "${GREEN}✅ Backup file found!${NC}"fi



# Step 2: Run Prisma migrations on Neon# Step 4: Generate Prisma client

echo ""echo ""

echo -e "${BLUE}🔧 Step 2: Setting up schema on Neon...${NC}"echo "🔄 Step 4: Generating Prisma client..."

npx prisma migrate deploynpx prisma generate



if [ $? -ne 0 ]; then# Step 5: Verify connection

  echo -e "${RED}❌ Migration failed! Check your connection.${NC}"echo ""

  exit 1echo "✅ Step 5: Verifying connection..."

finpx prisma db execute --stdin <<SQL

SELECT COUNT(*) as user_count FROM "User";

echo -e "${GREEN}✅ Schema deployed!${NC}"SELECT COUNT(*) as drug_count FROM "Drug";

SELECT COUNT(*) as pharmacy_count FROM "Pharmacy";

# Step 3: Restore dataSELECT COUNT(*) as order_count FROM "MedOrder";

echo ""SQL

echo -e "${BLUE}📥 Step 3: Restoring data to Neon...${NC}"

psql "postgresql://neondb_owner:npg_sJ5leG9XutnO@ep-square-glade-a4ba2w83.us-east-1.aws.neon.tech/neondb?sslmode=require" < render-backup.sqlecho ""

echo "🎉 Migration completed!"

if [ $? -ne 0 ]; thenecho "Please test your application thoroughly before deleting the Render database."

  echo -e "${YELLOW}⚠️  Warning: Some errors occurred during restore.${NC}"
  echo "This is often normal if the schema was already created by Prisma."
else
  echo -e "${GREEN}✅ Data restored successfully!${NC}"
fi

# Step 4: Generate Prisma client
echo ""
echo -e "${BLUE}🔄 Step 4: Generating Prisma client...${NC}"
npx prisma generate

echo -e "${GREEN}✅ Prisma client generated!${NC}"

# Step 5: Test connection
echo ""
echo -e "${BLUE}🔍 Step 5: Testing connection...${NC}"
echo "Run 'npm run start' to test your API"

echo ""
echo -e "${GREEN}🎉 Migration completed!${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Test your application locally"
echo "2. Update production environment variables"
echo "3. Deploy your application"
echo "4. Keep Render database for 1-2 weeks as backup"
echo "5. Delete Render database after confirming everything works"
