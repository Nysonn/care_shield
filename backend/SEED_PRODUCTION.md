# How to Seed Production Database

Since your Neon database is not accessible from your local machine, you have **two options** to seed your production database:

## Option 1: Use Render Shell (Recommended - Simplest)

1. Go to your Render Dashboard: https://dashboard.render.com
2. Click on your **backend service** (care-shield-backend or similar)
3. Click on the **"Shell"** tab in the left sidebar
4. Run these commands one by one:

```bash
# Seed drugs and health centers first
npm run seed

# Then seed pharmacies and their relationships
npm run seed:pharmacies
```

5. You should see success messages with counts of created records

---

## Option 2: Use Admin API Endpoints (Secure)

I've created two secure admin endpoints that you can call via Postman or curl to seed your database.

### Step 1: Set ADMIN_SECRET in Render

1. Go to your Render Dashboard
2. Click on your backend service
3. Go to **Environment** tab
4. Add a new environment variable:
   - **Key**: `ADMIN_SECRET`
   - **Value**: `your-super-secret-admin-key-change-this` (or use a strong random string)
5. Click **Save Changes** (this will redeploy your service)

### Step 2: Deploy the Updated Code

```bash
# Commit and push the changes
git add .
git commit -m "Add admin seed endpoints"
git push origin master
```

Wait for Render to deploy the updated code.

### Step 3: Call the Seed Endpoints

**Using Postman:**

1. **Seed Base Data (Drugs & Health Centers)**
   - Method: `POST`
   - URL: `https://care-shield.onrender.com/api/admin/seed-base`
   - Headers:
     - `Content-Type`: `application/json`
     - `x-admin-secret`: `your-super-secret-admin-key-change-this`
   - Click **Send**

2. **Seed Pharmacies & Relationships**
   - Method: `POST`
   - URL: `https://care-shield.onrender.com/api/admin/seed-pharmacies`
   - Headers:
     - `Content-Type`: `application/json`
     - `x-admin-secret`: `your-super-secret-admin-key-change-this`
   - Click **Send**

**Using curl:**

```bash
# Seed base data
curl -X POST https://care-shield.onrender.com/api/admin/seed-base \
  -H "Content-Type: application/json" \
  -H "x-admin-secret: your-super-secret-admin-key-change-this"

# Seed pharmacies
curl -X POST https://care-shield.onrender.com/api/admin/seed-pharmacies \
  -H "Content-Type: application/json" \
  -H "x-admin-secret: your-super-secret-admin-key-change-this"
```

### Expected Response

You should get a JSON response like:

```json
{
  "success": true,
  "message": "Pharmacy system seeded successfully",
  "data": {
    "pharmacies": 10,
    "services": 8,
    "drugs": 21,
    "pharmacyDrugLinks": 210,
    "pharmacyServiceLinks": 80
  }
}
```

---

## Verify the Data

After seeding, test with your existing endpoints:

```bash
# Get all pharmacies
curl https://care-shield.onrender.com/api/pharmacies

# Get all drugs
curl https://care-shield.onrender.com/api/drugs
```

---

## Security Note

⚠️ **IMPORTANT**: After seeding, you should either:
1. Remove the ADMIN_SECRET from environment variables (to disable the endpoints), OR
2. Keep it but NEVER share the secret key

The admin endpoints are protected and will only work with the correct `x-admin-secret` header.

---

## Troubleshooting

### "Can't reach database server"
- Your Neon database might be paused (free tier)
- Go to Neon dashboard and check if the database is active
- Try accessing it from Render Shell instead

### "Unauthorized" error
- Make sure you set the ADMIN_SECRET in Render environment variables
- Ensure the header value matches exactly (case-sensitive)

### Duplicate key errors
- The seed scripts use `skipDuplicates: true` and `createMany` for drugs/health centers
- For pharmacies, if you run it twice, you might get duplicate errors
- Check existing data first: `SELECT * FROM "Pharmacy";` in Render Shell

---

## What Gets Seeded

### Base Data (`/api/admin/seed-base`):
- ✅ 21 Drugs (HIV meds, contraceptives, health products, testing kits)
- ✅ 4 Health Centers in Mbarara

### Pharmacy System (`/api/admin/seed-pharmacies`):
- ✅ 10 Pharmacies in Mbarara
- ✅ 8 Services (HIV Testing, Counseling, Blood Pressure Check, etc.)
- ✅ 210 Pharmacy-Drug relationships (all drugs available at all pharmacies with varying prices)
- ✅ 80 Pharmacy-Service relationships (most services available at most pharmacies)
