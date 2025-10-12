# Pharmacy System Implementation Plan

**Project:** CareShield - Pharmacy Integration for Mbarara District  
**Date:** October 12, 2025  
**Status:** Ready for Implementation  

---

## 📋 Executive Summary

This document outlines the complete implementation plan for transitioning from a product-centric system to a pharmacy-centric system where pharmacies in Mbarara District sell drugs and services.

### Key Requirements:
- ✅ Pharmacy listings with name and address
- ✅ Each pharmacy has its own drug inventory with custom pricing
- ✅ Services (HIV testing, counseling, etc.) offered by pharmacies
- ✅ One pharmacy per order
- ✅ Centralized delivery (CareShield manages)
- ✅ Archive existing orders (fresh start)
- ✅ Migrate existing ~20 drugs to all pharmacies
- ✅ No admin portal (admin out of scope)
- ✅ Search pharmacies and drugs
- ✅ English only, Mbarara City focus

---

## 🗄️ Phase 1: Database Schema Design & Migration

### Task 1.1: Design New Database Models
**Priority:** Critical  
**Dependencies:** None

#### New Models to Create:

**1. Pharmacy Model**
```prisma
model Pharmacy {
  id          String   @id @default(uuid())
  name        String
  address     String
  district    String   @default("Mbarara")
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // Relations
  pharmacyDrugs    PharmacyDrug[]
  pharmacyServices PharmacyService[]
  orders           MedOrder[]
}
```

**2. PharmacyDrug Model (Junction table for Pharmacy-Drug with custom pricing)**
```prisma
model PharmacyDrug {
  id          String   @id @default(uuid())
  pharmacyId  String
  drugId      String
  price       Float    // Pharmacy-specific price
  isAvailable Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  pharmacy    Pharmacy @relation(fields: [pharmacyId], references: [id], onDelete: Cascade)
  drug        Drug     @relation(fields: [drugId], references: [id], onDelete: Cascade)
  
  @@unique([pharmacyId, drugId])
  @@index([pharmacyId])
  @@index([drugId])
}
```

**3. Service Model**
```prisma
model Service {
  id          String   @id @default(uuid())
  name        String
  description String
  category    String   // e.g., "Testing", "Counseling", "Health Check"
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  pharmacyServices PharmacyService[]
  orderServices    OrderService[]
}
```

**4. PharmacyService Model (Junction table for Pharmacy-Service with pricing)**
```prisma
model PharmacyService {
  id          String   @id @default(uuid())
  pharmacyId  String
  serviceId   String
  price       Float
  isAvailable Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  pharmacy    Pharmacy @relation(fields: [pharmacyId], references: [id], onDelete: Cascade)
  service     Service  @relation(fields: [serviceId], references: [id], onDelete: Cascade)
  
  @@unique([pharmacyId, serviceId])
  @@index([pharmacyId])
  @@index([serviceId])
}
```

**5. OrderService Model (Junction table for orders with services)**
```prisma
model OrderService {
  id         String   @id @default(uuid())
  orderId    String
  serviceId  String
  quantity   Int      @default(1)
  price      Float
  createdAt  DateTime @default(now())
  
  order      MedOrder @relation(fields: [orderId], references: [id], onDelete: Cascade)
  service    Service  @relation(fields: [serviceId], references: [id])
  
  @@index([orderId])
  @@index([serviceId])
}
```

**6. ArchivedOrder Model (For existing orders)**
```prisma
model ArchivedOrder {
  id           String   @id @default(uuid())
  originalId   String   @unique
  stage        String
  location     String
  createdAt    DateTime
  archivedAt   DateTime @default(now())
  eta          String
  totalAmount  Float
  deliveryFee  Float
  userId       String
  orderData    Json     // Store full order snapshot
  
  @@index([userId])
}
```

#### Updates to Existing Models:

**Update Drug Model**
```prisma
model Drug {
  id                 String   @id @default(uuid())
  name               String
  description        String
  dosage             String
  price              Float    // Base/reference price (optional)
  currency           String   @default("UGX")
  category           String
  requiresPrescription Boolean  @default(false)
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt
  
  // Updated relations
  pharmacyDrugs      PharmacyDrug[]  // NEW
  orders             MedOrder[]      // Keep for backward compatibility
}
```

**Update MedOrder Model**
```prisma
model MedOrder {
  id           String   @id @default(uuid())
  stage        String
  location     String
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  eta          String
  totalAmount  Float
  deliveryFee  Float
  pharmacyId   String?  // NEW - Link to pharmacy
  
  user         User     @relation(fields: [userId], references: [id])
  userId       String
  pharmacy     Pharmacy? @relation(fields: [pharmacyId], references: [id])  // NEW
  drugs        Drug[]   // Keep existing relation
  services     OrderService[]  // NEW
  payment      Payment? @relation(fields: [paymentId], references: [id])
  paymentId    String?  @unique
  
  @@index([pharmacyId])
}
```

**Checklist:**
- [ ] Create updated `schema.prisma` with all models
- [ ] Add proper indexes for performance
- [ ] Add cascade delete rules
- [ ] Review foreign key constraints

---

### Task 1.2: Create Migration Scripts
**Priority:** Critical  
**Dependencies:** Task 1.1

**Steps:**
1. [ ] Generate Prisma migration: `npx prisma migrate dev --name add_pharmacy_system`
2. [ ] Create data migration script: `backend/prisma/migrations/data-migration.ts`
3. [ ] Create seed script for initial pharmacies: `backend/prisma/seed-pharmacies.ts`

**Migration Script Outline:**
```typescript
// data-migration.ts
async function migrateData() {
  // 1. Archive existing orders
  // 2. Create initial pharmacies (10 Mbarara pharmacies)
  // 3. Migrate existing drugs to PharmacyDrug for all pharmacies
  // 4. Create initial services catalog
  // 5. Link services to pharmacies with default pricing
}
```

**Checklist:**
- [ ] Write archive orders function
- [ ] Create 10 sample Mbarara pharmacies with realistic data
- [ ] Migrate ~20 existing drugs to all pharmacies
- [ ] Create 8 services (HIV testing, counseling, etc.)
- [ ] Test migration on development database
- [ ] Create rollback script (just in case)

---

## 🔧 Phase 2: Backend API Development

### Task 2.1: Create Pharmacy Services
**Priority:** Critical  
**Dependencies:** Task 1.2

**File:** `backend/src/services/pharmacy.service.ts`

**Functions to implement:**
- [ ] `getPharmacies(page, limit, searchQuery?)` - Get paginated pharmacy list
- [ ] `getPharmacyById(id)` - Get single pharmacy with details
- [ ] `getPharmacyDrugs(pharmacyId, page, limit)` - Get drugs for a pharmacy
- [ ] `getPharmacyServices(pharmacyId)` - Get services offered by pharmacy
- [ ] `searchPharmaciesByDrug(drugName)` - Find pharmacies that have a specific drug
- [ ] `searchDrugsAcrossPharmacies(drugName)` - Search drugs across all pharmacies

**Implementation Notes:**
- Include pagination for drug listings
- Filter by availability
- Include pharmacy info with each drug
- Optimize queries with proper joins

---

### Task 2.2: Create Service Management Services
**Priority:** High  
**Dependencies:** Task 1.2

**File:** `backend/src/services/service.service.ts`

**Functions to implement:**
- [ ] `getServices()` - Get all available services
- [ ] `getServiceById(id)` - Get service details
- [ ] `getServicesByCategory(category)` - Filter services by category

---

### Task 2.3: Update Med Order Service
**Priority:** Critical  
**Dependencies:** Task 2.1, Task 2.2

**File:** `backend/src/services/med-order.service.ts`

**Updates needed:**
- [ ] Modify `createMedOrder()` to accept pharmacyId
- [ ] Add validation: ensure drugs belong to selected pharmacy
- [ ] Add support for services in order creation
- [ ] Calculate totals: (drugs + services + delivery fee)
- [ ] Update `getMedOrders()` to include pharmacy and service details

**New function signature:**
```typescript
interface CreateOrderData {
  pharmacyId: string;
  stage: string;
  location: string;
  eta: string;
  deliveryFee: number;
  drugs: Array<{ drugId: string; pharmacyDrugId: string; quantity?: number }>;
  services: Array<{ serviceId: string; quantity?: number }>;
}

async function createMedOrder(userId: string, data: CreateOrderData)
```

---

### Task 2.4: Create Controllers
**Priority:** Critical  
**Dependencies:** Task 2.1, 2.2, 2.3

**Files to create:**

1. **`backend/src/controllers/pharmacy.controller.ts`**
   - [ ] `getPharmacies` - GET /api/pharmacies
   - [ ] `getPharmacyById` - GET /api/pharmacies/:id
   - [ ] `getPharmacyDrugs` - GET /api/pharmacies/:id/drugs
   - [ ] `getPharmacyServices` - GET /api/pharmacies/:id/services
   - [ ] `searchPharmacies` - GET /api/pharmacies/search?q=...

2. **`backend/src/controllers/service.controller.ts`**
   - [ ] `getServices` - GET /api/services
   - [ ] `getServiceById` - GET /api/services/:id

3. **Update `backend/src/controllers/med-order.controller.ts`**
   - [ ] Update `createMedOrder` validation schema
   - [ ] Update response to include pharmacy and service info

---

### Task 2.5: Create Routes
**Priority:** Critical  
**Dependencies:** Task 2.4

**Files to create:**

1. **`backend/src/routes/pharmacy.routes.ts`**
```typescript
router.get('/', getPharmacies);
router.get('/search', searchPharmacies);
router.get('/:id', getPharmacyById);
router.get('/:id/drugs', getPharmacyDrugs);
router.get('/:id/services', getPharmacyServices);
```

2. **`backend/src/routes/service.routes.ts`**
```typescript
router.get('/', getServices);
router.get('/:id', getServiceById);
```

3. **Update `backend/src/index.ts`**
   - [ ] Add pharmacy routes: `app.use('/api/pharmacies', pharmacyRoutes)`
   - [ ] Add service routes: `app.use('/api/services', serviceRoutes)`

**Checklist:**
- [ ] Create pharmacy routes
- [ ] Create service routes
- [ ] Add authentication middleware where needed
- [ ] Test all endpoints with Postman/Thunder Client
- [ ] Add proper error handling

---

## 📱 Phase 3: Flutter Frontend - Models

### Task 3.1: Create Pharmacy Models
**Priority:** Critical  
**Dependencies:** None

**File:** `lib/features/meds/models/pharmacy.dart`

```dart
class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String district;
  
  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    this.district = 'Mbarara',
  });
  
  factory Pharmacy.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}
```

**Checklist:**
- [ ] Create `Pharmacy` model
- [ ] Add `fromMap` factory constructor
- [ ] Add `toMap` method
- [ ] Add proper null safety

---

### Task 3.2: Create PharmacyDrug Model
**Priority:** Critical  
**Dependencies:** Task 3.1

**File:** `lib/features/meds/models/pharmacy_drug.dart`

```dart
class PharmacyDrug {
  final String id;
  final String pharmacyId;
  final Drug drug;
  final double price;
  final bool isAvailable;
  
  PharmacyDrug({
    required this.id,
    required this.pharmacyId,
    required this.drug,
    required this.price,
    required this.isAvailable,
  });
  
  factory PharmacyDrug.fromMap(Map<String, dynamic> map);
}
```

**Checklist:**
- [ ] Create `PharmacyDrug` model
- [ ] Include nested `Drug` object
- [ ] Add serialization methods

---

### Task 3.3: Create Service Models
**Priority:** High  
**Dependencies:** None

**File:** `lib/features/meds/models/service.dart`

```dart
class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
  
  factory Service.fromMap(Map<String, dynamic> map);
}

class PharmacyService {
  final String id;
  final String pharmacyId;
  final Service service;
  final double price;
  final bool isAvailable;
  
  PharmacyService({
    required this.id,
    required this.pharmacyId,
    required this.service,
    required this.price,
    required this.isAvailable,
  });
  
  factory PharmacyService.fromMap(Map<String, dynamic> map);
}
```

**Checklist:**
- [ ] Create `Service` model
- [ ] Create `PharmacyService` model
- [ ] Add serialization methods

---

### Task 3.4: Update MedOrder Model
**Priority:** Critical  
**Dependencies:** Task 3.1, 3.3

**File:** `lib/features/meds/providers/meds_provider.dart`

**Updates:**
```dart
class MedOrder {
  final String id;
  final String stage;
  final List<Drug> drugs;
  final List<OrderService> services;  // NEW
  final Pharmacy? pharmacy;           // NEW
  final String location;
  final DateTime createdAt;
  final String eta;
  final double totalAmount;
  final double deliveryFee;
  // ... rest of fields
}

class OrderService {
  final Service service;
  final int quantity;
  final double price;
  
  OrderService({
    required this.service,
    required this.quantity,
    required this.price,
  });
  
  factory OrderService.fromMap(Map<String, dynamic> map);
}
```

**Checklist:**
- [ ] Add `pharmacy` field to `MedOrder`
- [ ] Add `services` field to `MedOrder`
- [ ] Create `OrderService` class
- [ ] Update `fromMap` to handle new fields

---

## 📱 Phase 4: Flutter Frontend - State Management

### Task 4.1: Create PharmacyProvider
**Priority:** Critical  
**Dependencies:** Task 3.1, 3.2, 3.3

**File:** `lib/features/meds/providers/pharmacy_provider.dart`

```dart
class PharmacyProvider extends ChangeNotifier {
  final ApiClient apiClient;
  
  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> get pharmacies => List.unmodifiable(_pharmacies);
  
  Pharmacy? _selectedPharmacy;
  Pharmacy? get selectedPharmacy => _selectedPharmacy;
  
  List<PharmacyDrug> _pharmacyDrugs = [];
  List<PharmacyDrug> get pharmacyDrugs => List.unmodifiable(_pharmacyDrugs);
  
  List<PharmacyService> _pharmacyServices = [];
  List<PharmacyService> get pharmacyServices => List.unmodifiable(_pharmacyServices);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Methods to implement
  Future<void> fetchPharmacies({String? searchQuery, int page = 1});
  Future<void> fetchPharmacyDrugs(String pharmacyId);
  Future<void> fetchPharmacyServices(String pharmacyId);
  void selectPharmacy(Pharmacy pharmacy);
  Future<List<Pharmacy>> searchPharmaciesByDrug(String drugName);
}
```

**Checklist:**
- [ ] Create `PharmacyProvider` class
- [ ] Implement `fetchPharmacies()` with pagination
- [ ] Implement `fetchPharmacyDrugs()`
- [ ] Implement `fetchPharmacyServices()`
- [ ] Implement `selectPharmacy()`
- [ ] Implement search functionality
- [ ] Add error handling
- [ ] Add loading states
- [ ] Register provider in `main.dart`

---

### Task 4.2: Update MedsProvider
**Priority:** Critical  
**Dependencies:** Task 3.4, Task 4.1

**File:** `lib/features/meds/providers/meds_provider.dart`

**Updates needed:**
- [ ] Remove or deprecate `fetchDrugs()` (drugs now come from pharmacies)
- [ ] Update `placeOrder()` to require `pharmacyId`
- [ ] Add `selectedServices` list for cart
- [ ] Add methods to add/remove services from cart
- [ ] Update order calculation to include services
- [ ] Update `fetchOrders()` to handle new structure

**New/Updated methods:**
```dart
// Cart management for services
void addServiceToCart(PharmacyService service, int quantity);
void removeServiceFromCart(String serviceId);
List<OrderService> get cartServices;

// Updated order placement
Future<void> placeOrder({
  required String pharmacyId,
  required String stage,
  required List<PharmacyDrug> drugs,
  required List<OrderService> services,
  required String location,
  DeliveryOption? deliveryOption,
  PaymentMethod? paymentMethod,
});
```

**Checklist:**
- [ ] Update order creation logic
- [ ] Add service cart management
- [ ] Update total calculation
- [ ] Validate pharmacy-drug relationship
- [ ] Update error handling

---

## 📱 Phase 5: Flutter Frontend - UI Screens

### Task 5.1: Create Pharmacy Listing Screen
**Priority:** Critical  
**Dependencies:** Task 4.1

**File:** `lib/features/meds/screens/pharmacies_screen.dart`

**Features:**
- [ ] Display list of pharmacies with pagination
- [ ] Show pharmacy name and address
- [ ] Search bar for pharmacy name
- [ ] Tap to view pharmacy details
- [ ] Loading states and error handling
- [ ] Pull-to-refresh functionality
- [ ] Empty state when no pharmacies found

**UI Components:**
- [ ] Search bar at top
- [ ] Pharmacy card widget
- [ ] Pagination loader
- [ ] Empty state illustration

---

### Task 5.2: Create Pharmacy Details Screen
**Priority:** Critical  
**Dependencies:** Task 5.1

**File:** `lib/features/meds/screens/pharmacy_details_screen.dart`

**Features:**
- [ ] Display pharmacy name and address prominently
- [ ] Tabs or sections for "Drugs" and "Services"
- [ ] List of available drugs with prices
- [ ] List of available services with prices
- [ ] "Add to cart" functionality
- [ ] Search/filter drugs within pharmacy
- [ ] Show drug categories
- [ ] Navigate to checkout with selected pharmacy

**UI Components:**
- [ ] Pharmacy header card
- [ ] Tabbed interface (Drugs / Services)
- [ ] Drug product cards
- [ ] Service cards
- [ ] Add to cart buttons
- [ ] Floating action button for checkout

---

### Task 5.3: Update Meds Screen (Entry Point)
**Priority:** Critical  
**Dependencies:** Task 5.1

**File:** `lib/features/meds/screens/meds_screen.dart`

**Changes:**
- [ ] Remove direct drug listing
- [ ] Change "Browse Products" action to "Browse Pharmacies"
- [ ] Update navigation to go to PharmaciesScreen instead
- [ ] Update header text from "Products" to "Pharmacies & Products"
- [ ] Keep "Order Refill" but navigate to pharmacies first

**Checklist:**
- [ ] Update action cards
- [ ] Update navigation routes
- [ ] Update header text
- [ ] Remove drug listings
- [ ] Add pharmacy search option

---

### Task 5.4: Create/Update Checkout Screen
**Priority:** Critical  
**Dependencies:** Task 5.2

**File:** `lib/features/meds/screens/checkout_screen.dart`

**Updates needed:**
- [ ] Display selected pharmacy info at top
- [ ] Show list of selected drugs with individual prices
- [ ] Show list of selected services with individual prices
- [ ] Calculate subtotal for drugs
- [ ] Calculate subtotal for services
- [ ] Add delivery fee (CareShield standard)
- [ ] Show grand total
- [ ] Validate all items belong to selected pharmacy
- [ ] Payment and delivery options
- [ ] Confirm order button

**Order Summary Structure:**
```
┌─────────────────────────────────┐
│ Pharmacy: ABC Pharmacy          │
│ Address: 123 Mbarara St         │
├─────────────────────────────────┤
│ DRUGS                           │
│ - Drug A (50mg)     25,000 UGX  │
│ - Drug B (100mg)    35,000 UGX  │
│                                 │
│ SERVICES                        │
│ - HIV Testing       15,000 UGX  │
│ - Counseling        20,000 UGX  │
├─────────────────────────────────┤
│ Drugs Subtotal:     60,000 UGX  │
│ Services Subtotal:  35,000 UGX  │
│ Delivery Fee:        5,000 UGX  │
│ ─────────────────────────────── │
│ TOTAL:             100,000 UGX  │
└─────────────────────────────────┘
```

**Checklist:**
- [ ] Update layout to show pharmacy
- [ ] Add services section
- [ ] Update calculation logic
- [ ] Add validation
- [ ] Update order placement API call

---

### Task 5.5: Update Order Details/History Screen
**Priority:** Medium  
**Dependencies:** Task 5.4

**File:** `lib/features/meds/screens/orders_history_screen.dart`

**Updates:**
- [ ] Display pharmacy name in order card
- [ ] Show both drugs and services in order details
- [ ] Update order summary to match new structure
- [ ] Handle orders without pharmacy (archived orders)

**Note:** Since we're archiving old orders and starting fresh, this might show empty initially.

---

### Task 5.6: Create Reusable Widget Components
**Priority:** Medium  
**Dependencies:** Task 5.1, 5.2

**Files to create:**

1. **`lib/core/widgets/pharmacy_card.dart`**
   - [ ] Pharmacy name
   - [ ] Address
   - [ ] Tap to view details
   - [ ] Consistent styling

2. **`lib/core/widgets/service_card.dart`**
   - [ ] Service name and description
   - [ ] Price
   - [ ] Category badge
   - [ ] Add to cart button

3. **Update `lib/core/widgets/product_card.dart`**
   - [ ] Show "at [Pharmacy Name]" if needed
   - [ ] Update for PharmacyDrug model

**Checklist:**
- [ ] Create PharmacyCard widget
- [ ] Create ServiceCard widget
- [ ] Update ProductCard widget
- [ ] Ensure consistent theming

---

## 📱 Phase 6: Navigation & Integration

### Task 6.1: Update Navigation Routes
**Priority:** Critical  
**Dependencies:** Phase 5

**Updates needed:**
- [ ] Add route for PharmaciesScreen
- [ ] Add route for PharmacyDetailsScreen
- [ ] Update MedsScreen navigation
- [ ] Update bottom navigation if needed

**File:** `lib/features/navigation/bottom_nav.dart` or route definitions

---

### Task 6.2: Update Main.dart Provider Registration
**Priority:** Critical  
**Dependencies:** Task 4.1

**File:** `lib/main.dart`

**Changes:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ChangeNotifierProvider<MedsProvider>.value(value: medsProvider),
    ChangeNotifierProvider<PharmacyProvider>.value(value: pharmacyProvider), // NEW
    ChangeNotifierProvider<SurveyProvider>.value(value: surveyProvider),
  ],
  child: const MyApp(),
)
```

**Checklist:**
- [ ] Create PharmacyProvider instance
- [ ] Initialize PharmacyProvider in main
- [ ] Register in MultiProvider
- [ ] Test provider access in widgets

---

## 🧪 Phase 7: Testing & Quality Assurance

### Task 7.1: Backend Testing
**Priority:** High  
**Dependencies:** Phase 2

**API Endpoint Tests:**
- [ ] GET /api/pharmacies - List pharmacies with pagination
- [ ] GET /api/pharmacies/search?q=ABC - Search pharmacies
- [ ] GET /api/pharmacies/:id - Get pharmacy details
- [ ] GET /api/pharmacies/:id/drugs - Get pharmacy drugs
- [ ] GET /api/pharmacies/:id/services - Get pharmacy services
- [ ] GET /api/services - List all services
- [ ] POST /api/med-orders - Create order with pharmacy & services
- [ ] GET /api/med-orders - Get user orders with pharmacy data

**Test Cases:**
- [ ] Pagination works correctly
- [ ] Search returns accurate results
- [ ] Pharmacy drugs include correct pricing
- [ ] Services are properly linked
- [ ] Order creation validates pharmacy-drug relationship
- [ ] Order totals calculate correctly (drugs + services + delivery)
- [ ] Error handling for invalid pharmacyId
- [ ] Error handling for unavailable drugs/services

---

### Task 7.2: Database Testing
**Priority:** Critical  
**Dependencies:** Task 1.2

**Migration Tests:**
- [ ] Migration runs without errors
- [ ] 10 pharmacies created successfully
- [ ] All 20 drugs migrated to PharmacyDrug for each pharmacy
- [ ] 8 services created successfully
- [ ] Services linked to all pharmacies
- [ ] Existing orders archived properly
- [ ] Foreign key constraints work correctly
- [ ] Cascade deletes work as expected

**Data Integrity:**
- [ ] No orphaned records
- [ ] All relationships intact
- [ ] Prices are positive values
- [ ] UGX currency consistent

---

### Task 7.3: Frontend Testing
**Priority:** High  
**Dependencies:** Phase 5

**UI Tests:**
- [ ] Pharmacy list loads and displays correctly
- [ ] Search functionality works
- [ ] Pagination loads more pharmacies
- [ ] Pharmacy details screen shows drugs and services
- [ ] Can add drugs to cart
- [ ] Can add services to cart
- [ ] Checkout shows correct totals
- [ ] Order placement succeeds
- [ ] Order history displays correctly

**User Flow Tests:**
1. [ ] Browse pharmacies → Select pharmacy → View drugs → Add to cart → Checkout → Place order
2. [ ] Search pharmacy → View details → Add services → Checkout
3. [ ] Browse pharmacies → Search drug → Find pharmacy with drug → Order
4. [ ] View order history → See pharmacy and items

**Edge Cases:**
- [ ] Empty pharmacy list
- [ ] Pharmacy with no drugs
- [ ] Pharmacy with no services
- [ ] Network errors handled gracefully
- [ ] Loading states display correctly

---

### Task 7.4: Integration Testing
**Priority:** High  
**Dependencies:** Phase 6

**End-to-End Tests:**
- [ ] User login → Browse pharmacies → Place order → View confirmation
- [ ] Complete order flow with both drugs and services
- [ ] Multiple orders from different pharmacies
- [ ] Order history displays all details correctly

---

## 📚 Phase 8: Documentation & Cleanup

### Task 8.1: Update API Documentation
**Priority:** Medium  
**Dependencies:** Phase 2

**Create/Update:**
- [ ] API endpoint documentation
- [ ] Request/response examples
- [ ] Error codes and messages
- [ ] Authentication requirements

**File:** `backend/README.md` or `docs/API_DOCUMENTATION.md`

---

### Task 8.2: Update Project Documentation
**Priority:** Medium  
**Dependencies:** All phases

**Files to update:**

1. **`README.md`**
   - [ ] Update features section to mention pharmacies
   - [ ] Update screenshots section
   - [ ] Update technical stack if needed

2. **`CHANGELOG.md`**
   - [ ] Document all changes in new version
   - [ ] List breaking changes
   - [ ] List new features
   - [ ] List deprecated features

3. **`docs/PROJECT_DOCUMENTATION.md`**
   - [ ] Update architecture description
   - [ ] Document new models and relationships
   - [ ] Update feature descriptions

---

### Task 8.3: Code Cleanup
**Priority:** Medium  
**Dependencies:** All phases

**Backend:**
- [ ] Remove unused imports
- [ ] Add comments to complex logic
- [ ] Ensure consistent code formatting
- [ ] Run linter and fix issues

**Frontend:**
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Add comments to complex widgets
- [ ] Run `flutter analyze` and fix issues
- [ ] Format code with `dart format`

---

### Task 8.4: Database Cleanup
**Priority:** Low  
**Dependencies:** Task 1.2

**Optional cleanup:**
- [ ] Remove unused fields from old models (if any)
- [ ] Optimize indexes based on query patterns
- [ ] Review and update cascade rules if needed

---

## 🎯 Phase 9: Deployment Preparation

### Task 9.1: Environment Configuration
**Priority:** High  
**Dependencies:** All backend tasks

**Checklist:**
- [ ] Update `.env.example` with new variables
- [ ] Document environment setup
- [ ] Test with production-like data
- [ ] Verify database connection strings

---

### Task 9.2: Database Backup & Migration Strategy
**Priority:** Critical  
**Dependencies:** Task 1.2

**Production Deployment:**
- [ ] Backup production database (if exists)
- [ ] Test migration on staging database
- [ ] Plan rollback strategy
- [ ] Schedule maintenance window
- [ ] Run migration on production
- [ ] Verify data integrity
- [ ] Monitor for issues

---

### Task 9.3: Frontend Build & Deployment
**Priority:** High  
**Dependencies:** Phase 5, 6

**Checklist:**
- [ ] Update app version in `pubspec.yaml`
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test release build on physical device
- [ ] Build iOS release (if applicable)
- [ ] Test on iOS device (if applicable)

---

## 📊 Summary & Statistics

### Implementation Overview:

| Phase | Tasks | Priority | Estimated Time |
|-------|-------|----------|----------------|
| 1. Database | 2 | Critical | 4-6 hours |
| 2. Backend API | 5 | Critical | 8-10 hours |
| 3. Flutter Models | 4 | Critical | 3-4 hours |
| 4. State Management | 2 | Critical | 4-5 hours |
| 5. UI Screens | 6 | Critical | 12-15 hours |
| 6. Navigation | 2 | Critical | 2-3 hours |
| 7. Testing | 4 | High | 6-8 hours |
| 8. Documentation | 4 | Medium | 3-4 hours |
| 9. Deployment | 3 | High | 2-3 hours |
| **TOTAL** | **32** | - | **44-58 hours** |

### Key Deliverables:

✅ **Backend:**
- New Pharmacy, Service, PharmacyDrug, PharmacyService models
- Complete REST API for pharmacies and services
- Updated order system with pharmacy integration
- Data migration scripts

✅ **Frontend:**
- Pharmacy listing and details screens
- Service selection and ordering
- Updated checkout with pharmacy context
- Complete state management

✅ **Database:**
- Pharmacy-centric schema
- Archived old orders (fresh start)
- Migrated 20 drugs to all pharmacies
- Service catalog

### Breaking Changes:

⚠️ **Users:**
- Order history will be empty (fresh start)
- Must select pharmacy before ordering

⚠️ **API:**
- Order creation endpoint requires `pharmacyId`
- Drug listing moved to pharmacy context
- New endpoints for pharmacies and services

---

## ✅ Implementation Checklist

### Pre-Implementation:
- [x] Requirements gathered and documented
- [x] Implementation plan created
- [ ] Development environment ready
- [ ] Database backup taken (if applicable)

### Implementation Order:
1. [ ] **Phase 1:** Database schema and migration
2. [ ] **Phase 2:** Backend API development
3. [ ] **Phase 3:** Flutter models
4. [ ] **Phase 4:** State management
5. [ ] **Phase 5:** UI screens
6. [ ] **Phase 6:** Navigation integration
7. [ ] **Phase 7:** Testing
8. [ ] **Phase 8:** Documentation
9. [ ] **Phase 9:** Deployment

### Post-Implementation:
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Deployed to production
- [ ] Monitoring active
- [ ] User feedback collected

---

## 📝 Notes & Considerations

### Important Reminders:

1. **Data Preservation:** Existing orders are archived, not deleted. The `ArchivedOrder` table preserves all historical data.

2. **Pharmacy Data:** The initial 10 Mbarara pharmacies should have realistic names and addresses. Consider:
   - ABC Pharmacy, Mbarara
   - Health First Pharmacy, High Street
   - MedPlus Pharmacy, Katete
   - (etc.)

3. **Pricing:** Each pharmacy can set its own prices, so the same drug may cost differently at different pharmacies.

4. **Services:** Services include: HIV testing, Counseling, Blood pressure checks, Blood sugar testing, Vaccinations, Prescription consultation, Home delivery, 24/7 emergency service.

5. **CareShield Business Model:** Delivery fees are set by CareShield and are the primary revenue source.

6. **Single Pharmacy Orders:** Users can only order from one pharmacy at a time. If they want items from multiple pharmacies, they need multiple orders.

7. **No Admin Portal:** All pharmacy management is handled manually or via direct database access for this phase (school assignment scope).

8. **Mbarara Focus:** The system is optimized for Mbarara District only, with no multi-district features needed.

---

**Document Version:** 1.0  
**Status:** ✅ Ready for Implementation  
**Next Action:** Begin Phase 1 - Database Schema Design

