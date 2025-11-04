# CareShield Riders App - Complete Development Prompt

## 🎯 Project Overview

Create a Flutter mobile application for CareShield delivery riders that enables them to view, accept, and deliver medication orders. This app will work alongside the existing CareShield customer app but is completely independent, using the same backend API and PostgreSQL database.

---

## 📱 App Purpose & User Flow

**Target Users**: Delivery riders who transport medications from pharmacies to customers

**Core Functionality**:
1. Rider registration with vehicle details (Boda/My Car) and license number
2. View a pool of pending orders waiting to be accepted
3. Accept orders from the pool (first-come, first-served)
4. View customer contact information after accepting
5. Mark orders as delivered after completion
6. View delivery history and earnings overview

**Business Rules**:
- Once a rider accepts an order, it disappears from other riders' pending lists
- Riders can only see customer phone number AFTER accepting the order
- No payment processing in the app (handled externally)
- Riders choose their own orders; no automatic assignment

---

## 🎨 Design System (Match Existing CareShield Theme)

### Color Palette
```dart
// Use these exact colors from the CareShield design system
class AppColors {
  static const primaryBlue = Color(0xFF2563EB);     // Main brand color
  static const secondaryGreen = Color(0xFF10B981);  // Success, positive actions
  static const background = Color(0xFFF8FAFC);      // Screen backgrounds
  static const surface = Color(0xFFFFFFFF);         // Card backgrounds
  static const text = Color(0xFF1E293B);            // Primary text
  static const accent = Color(0xFFF59E0B);          // Warnings, highlights
}
```

### Typography
- **Font Family**: Inter (via Google Fonts) or System UI fallback
- **App Name**: "CareShield Riders" or "CareShield Delivery"
- **Font Weights**: 
  - Headlines: w700-w800 (Bold/ExtraBold)
  - Body: w400-w500 (Regular/Medium)
  - Labels: w600 (SemiBold)

### UI Design Principles
- Clean, medical-grade interface with rounded corners (12-24px border radius)
- Generous whitespace and padding (16-24px)
- Subtle shadows for depth (use `primaryBlue.withOpacity(0.1-0.3)`)
- Smooth animations (300-800ms duration)
- Haptic feedback on interactions
- Card-based layouts with elevation

### Key UI Patterns
- **Gradient Headers**: Use `LinearGradient` with `primaryBlue` variations
- **Status Badges**: Rounded pills with colored backgrounds and borders
- **Action Buttons**: Elevated buttons with shadows, 56px height for primary actions
- **Icon Containers**: Rounded squares (40-60px) with colored backgrounds at 10-20% opacity

---

## 🏗️ Technical Architecture

### Tech Stack
```yaml
dependencies:
  flutter_sdk: ">=3.8.0"
  dart: ">=3.0.0"
  
  # State Management
  provider: ^6.1.2
  
  # Network & API
  dio: ^5.4.3+1
  
  # Local Storage
  flutter_secure_storage: ^9.1.1
  shared_preferences: ^2.2.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.2  # For loading animations
  
  # Utilities
  intl: ^0.19.0  # Date formatting
  url_launcher: ^6.2.5  # For calling customer phone numbers
```

### Project Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants.dart          # AppColors and constants
│   ├── theme.dart              # Theme configuration
│   └── widgets/                # Shared widgets
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── custom_button.dart
├── services/
│   ├── api_client.dart         # Dio configuration
│   ├── local_storage_service.dart
│   └── phone_service.dart      # For making phone calls
├── models/
│   ├── rider.dart
│   ├── order.dart
│   ├── customer.dart
│   └── drug.dart
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       ├── welcome_screen.dart
│   │       ├── login_screen.dart
│   │       └── signup_screen.dart
│   ├── orders/
│   │   ├── models/
│   │   ├── providers/
│   │   │   └── orders_provider.dart
│   │   ├── widgets/
│   │   │   ├── order_card.dart
│   │   │   └── order_details_bottom_sheet.dart
│   │   └── screens/
│   │       ├── pending_orders_screen.dart
│   │       ├── active_orders_screen.dart
│   │       ├── order_details_screen.dart
│   │       └── history_screen.dart
│   ├── dashboard/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── stats_card.dart
│   │       └── quick_actions.dart
│   └── profile/
│       └── screens/
│           └── profile_screen.dart
```

---

## 🔌 Backend API Integration

### Base URL Configuration
```dart
// API Client Setup (services/api_client.dart)
class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    // Use environment variable or default
    const envBase = String.fromEnvironment('API_BASE_URL');
    final defaultBase = Platform.isAndroid
        ? 'https://care-shield.onrender.com/api'  // Production
        : 'http://192.168.70.23:3000/api';        // Local dev
    
    dio.options.baseUrl = envBase.isNotEmpty ? envBase : defaultBase;
    
    // Add auth token to all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'rider_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
```

### API Endpoints

#### Authentication Endpoints

**1. Rider Signup**
```
POST /api/auth/signup
Content-Type: application/json

Request Body:
{
  "fullName": "John Rider",
  "phone": "+256700987654",
  "email": "john.rider@example.com",
  "password": "password123",
  "role": "rider",                    // REQUIRED: Must be "rider"
  "vehicleType": "Boda",              // REQUIRED: "Boda" or "My Car"
  "licenseNumber": "UG12345ABC"       // REQUIRED
}

Response (201 Created):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "fullName": "John Rider",
    "phone": "+256700987654",
    "email": "john.rider@example.com",
    "role": "rider",
    "vehicleType": "Boda",
    "licenseNumber": "UG12345ABC",
    "createdAt": "2025-11-04T10:00:00Z",
    "updatedAt": "2025-11-04T10:00:00Z"
  }
}
```

**2. Rider Login**
```
POST /api/auth/login
Content-Type: application/json

Request Body:
{
  "phone": "+256700987654",
  "password": "password123"
}

Response (200 OK):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "fullName": "John Rider",
    "phone": "+256700987654",
    "email": "john.rider@example.com",
    "role": "rider",
    "vehicleType": "Boda",
    "licenseNumber": "UG12345ABC",
    "createdAt": "2025-11-04T10:00:00Z",
    "updatedAt": "2025-11-04T10:00:00Z"
  }
}
```

**3. Get Profile**
```
GET /api/auth/me
Authorization: Bearer {token}

Response (200 OK):
{
  "id": "uuid-here",
  "fullName": "John Rider",
  "phone": "+256700987654",
  "email": "john.rider@example.com",
  "role": "rider",
  "vehicleType": "Boda",
  "licenseNumber": "UG12345ABC",
  "createdAt": "2025-11-04T10:00:00Z",
  "updatedAt": "2025-11-04T10:00:00Z"
}
```

#### Rider Order Endpoints

**4. Get Pending Orders (Pool)**
```
GET /api/riders/pending-orders
Authorization: Bearer {token}

Response (200 OK):
[
  {
    "id": "order-uuid-1",
    "stage": "Ordered",
    "location": "Mbarara, Kakoba Division, Near Main Road",
    "status": "pending",
    "eta": "30-45 minutes",
    "totalAmount": 45000,
    "deliveryFee": 5000,
    "createdAt": "2025-11-04T09:30:00Z",
    "updatedAt": "2025-11-04T09:30:00Z",
    "user": {
      "id": "customer-uuid",
      "fullName": "Jane Doe",
      "phone": "+256700123456"
    },
    "pharmacy": {
      "id": "pharmacy-uuid",
      "name": "HealthPlus Pharmacy",
      "address": "Mbarara Town, High Street"
    },
    "drugs": [
      {
        "id": "drug-uuid-1",
        "name": "Paracetamol 500mg",
        "description": "Pain relief and fever reduction",
        "dosage": "1 tablet every 6 hours"
      },
      {
        "id": "drug-uuid-2",
        "name": "Amoxicillin 250mg",
        "description": "Antibiotic",
        "dosage": "1 capsule 3 times daily"
      }
    ],
    "services": []
  }
]
```

**5. Accept Order**
```
POST /api/riders/orders/{orderId}/accept
Authorization: Bearer {token}

Response (200 OK):
{
  "id": "order-uuid-1",
  "stage": "Ordered",
  "location": "Mbarara, Kakoba Division, Near Main Road",
  "status": "accepted",
  "eta": "30-45 minutes",
  "totalAmount": 45000,
  "deliveryFee": 5000,
  "riderId": "rider-uuid",
  "createdAt": "2025-11-04T09:30:00Z",
  "updatedAt": "2025-11-04T10:00:00Z",
  "user": {
    "id": "customer-uuid",
    "fullName": "Jane Doe",
    "phone": "+256700123456"  // NOW VISIBLE after acceptance
  },
  "pharmacy": {
    "id": "pharmacy-uuid",
    "name": "HealthPlus Pharmacy",
    "address": "Mbarara Town, High Street"
  },
  "drugs": [...],
  "services": []
}

Error (400 Bad Request):
{
  "message": "Order has already been accepted by another rider"
}
```

**6. Get My Accepted Orders**
```
GET /api/riders/accepted-orders
Authorization: Bearer {token}

Response (200 OK):
[
  {
    "id": "order-uuid-1",
    "stage": "Ordered",
    "location": "Mbarara, Kakoba Division, Near Main Road",
    "status": "accepted",
    "eta": "30-45 minutes",
    "totalAmount": 45000,
    "deliveryFee": 5000,
    "riderId": "rider-uuid",
    "createdAt": "2025-11-04T09:30:00Z",
    "updatedAt": "2025-11-04T10:00:00Z",
    "user": {
      "id": "customer-uuid",
      "fullName": "Jane Doe",
      "phone": "+256700123456"
    },
    "pharmacy": {
      "id": "pharmacy-uuid",
      "name": "HealthPlus Pharmacy",
      "address": "Mbarara Town, High Street"
    },
    "drugs": [...],
    "services": []
  }
]
```

**7. Mark Order as Delivered**
```
PATCH /api/riders/orders/{orderId}/deliver
Authorization: Bearer {token}

Response (200 OK):
{
  "id": "order-uuid-1",
  "stage": "Ordered",
  "location": "Mbarara, Kakoba Division, Near Main Road",
  "status": "delivered",
  "eta": "30-45 minutes",
  "totalAmount": 45000,
  "deliveryFee": 5000,
  "riderId": "rider-uuid",
  "createdAt": "2025-11-04T09:30:00Z",
  "updatedAt": "2025-11-04T10:30:00Z",
  "user": {
    "id": "customer-uuid",
    "fullName": "Jane Doe",
    "phone": "+256700123456"
  },
  "pharmacy": {...},
  "drugs": [...],
  "services": []
}

Error (400 Bad Request):
{
  "message": "You can only mark your own orders as delivered"
}
```

**8. Get Order History**
```
GET /api/riders/order-history
Authorization: Bearer {token}

Response (200 OK):
[
  {
    "id": "order-uuid-3",
    "stage": "Ordered",
    "location": "Mbarara, Ruharo",
    "status": "delivered",
    "totalAmount": 35000,
    "deliveryFee": 4000,
    "createdAt": "2025-11-03T14:00:00Z",
    "updatedAt": "2025-11-03T15:00:00Z",
    "user": {
      "id": "customer-uuid-2",
      "fullName": "David Smith",
      "phone": "+256700555666"
    },
    "pharmacy": {...},
    "drugs": [...],
    "services": []
  }
]
```

---

## 📋 Data Models

### Rider Model
```dart
class Rider {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role; // Always "rider"
  final String vehicleType; // "Boda" or "My Car"
  final String licenseNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rider({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.vehicleType,
    required this.licenseNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      vehicleType: json['vehicleType'],
      licenseNumber: json['licenseNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### Order Model
```dart
class Order {
  final String id;
  final String stage;
  final String location;
  final String status; // "pending", "accepted", "delivered"
  final String eta;
  final double totalAmount;
  final double deliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer user;
  final Pharmacy? pharmacy;
  final List<Drug> drugs;
  final String? riderId;

  Order({
    required this.id,
    required this.stage,
    required this.location,
    required this.status,
    required this.eta,
    required this.totalAmount,
    required this.deliveryFee,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.pharmacy,
    required this.drugs,
    this.riderId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      stage: json['stage'],
      location: json['location'],
      status: json['status'],
      eta: json['eta'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: Customer.fromJson(json['user']),
      pharmacy: json['pharmacy'] != null 
          ? Pharmacy.fromJson(json['pharmacy']) 
          : null,
      drugs: (json['drugs'] as List)
          .map((drug) => Drug.fromJson(drug))
          .toList(),
      riderId: json['riderId'],
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDelivered => status == 'delivered';
  
  String get formattedTotal => 'UGX ${totalAmount.toStringAsFixed(0)}';
  String get formattedDeliveryFee => 'UGX ${deliveryFee.toStringAsFixed(0)}';
}
```

### Customer Model
```dart
class Customer {
  final String id;
  final String fullName;
  final String phone;

  Customer({
    required this.id,
    required this.fullName,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
    );
  }
}
```

### Drug Model
```dart
class Drug {
  final String id;
  final String name;
  final String description;
  final String dosage;

  Drug({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dosage: json['dosage'],
    );
  }
}
```

### Pharmacy Model
```dart
class Pharmacy {
  final String id;
  final String name;
  final String address;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}
```

---

## 🖼️ Screen Specifications

### 1. Welcome Screen
**Purpose**: First screen when app launches (if not logged in)

**Layout**:
- App logo at top (60-80px)
- App name "CareShield Riders"
- Tagline: "Deliver health, earn with purpose"
- Illustration/Lottie animation showing delivery
- Two buttons:
  - "Get Started" (Primary button - navigates to signup)
  - "Sign In" (Outlined button - navigates to login)

**Design Notes**:
- Use gradient background (primaryBlue variations)
- Animate logo entrance with scale animation
- Fade in text and buttons with stagger

---

### 2. Signup Screen
**Purpose**: Rider registration

**Form Fields**:
1. Full Name (Text input)
2. Phone Number (Phone input with country code +256)
3. Email (Optional, email input)
4. Password (Password input, minimum 6 characters)
5. Confirm Password (Password input)
6. Vehicle Type (Dropdown: "Boda" or "My Car")
7. License Number (Text input)

**Validation**:
- All fields required except email
- Phone must be valid format
- Password must match confirm password
- Vehicle type must be selected
- License number required

**UI Elements**:
- Form in scrollable container
- Rounded input fields with icons
- "Create Account" button at bottom
- "Already have an account? Sign In" link
- Loading indicator during signup

**API Call**: `POST /api/auth/signup` with role="rider"

---

### 3. Login Screen
**Purpose**: Rider authentication

**Form Fields**:
1. Phone Number (Phone input)
2. Password (Password input)

**UI Elements**:
- Logo at top
- Form centered
- "Sign In" button
- "Don't have an account? Sign Up" link
- Forgot password link (optional for v1)

**API Call**: `POST /api/auth/login`

**Success Behavior**:
- Save token to secure storage
- Navigate to Home Screen
- Show success snackbar

---

### 4. Home Screen (Dashboard)
**Purpose**: Main landing screen after login, shows rider overview

**Sections**:

**Header**:
- Greeting: "Hi [Rider Name]"
- Vehicle type badge (Boda/My Car icon + text)
- Profile icon button (top right)

**Stats Cards** (3 cards in row or 2x2 grid):
1. **Pending Orders**
   - Icon: `Icons.pending_actions`
   - Number: Count of pending orders
   - Label: "Available Orders"
   - Color: accent
   
2. **Active Deliveries**
   - Icon: `Icons.local_shipping`
   - Number: Count of accepted orders
   - Label: "Active Deliveries"
   - Color: primaryBlue
   
3. **Completed Today**
   - Icon: `Icons.check_circle`
   - Number: Count of delivered today
   - Label: "Completed"
   - Color: secondaryGreen

**Quick Actions** (2 large buttons):
1. "View Pending Orders" → Navigate to Pending Orders Screen
   - Primary blue button
   - Icon: `Icons.list_alt`
   
2. "My Active Orders" → Navigate to Active Orders Screen
   - Green button
   - Icon: `Icons.delivery_dining`

**Recent Deliveries Section**:
- Title: "Recent Deliveries"
- List of last 3 delivered orders (compact cards)
- "View All History" button

**Design Notes**:
- Use gradient header similar to CareShield
- Cards with subtle shadows
- Pull-to-refresh functionality
- Auto-refresh every 30 seconds for pending count

---

### 5. Pending Orders Screen
**Purpose**: Show pool of available orders to accept

**Header**:
- Title: "Available Orders"
- Subtitle: "Tap to view details"
- Refresh button
- Filter button (optional: by location, amount)

**Order List**:
Each order card shows:
- **Top Row**: 
  - Order time (e.g., "2 mins ago")
  - Delivery fee badge (prominent, in accent color)
  
- **Middle Section**:
  - Customer name (e.g., "Jane D.") - partial for privacy
  - Location with icon
  - Pharmacy name with icon
  - Number of items (e.g., "3 medications")
  
- **Bottom Row**:
  - Total amount (large, bold)
  - "View Details" button (outlined)

**Empty State**:
- Icon: `Icons.inbox_outlined`
- Text: "No orders available right now"
- Subtext: "Check back soon for new deliveries"

**Interaction**:
- Tap card → Show Order Details Bottom Sheet
- Pull to refresh
- Auto-refresh every 15 seconds

**Design Notes**:
- Cards in ListView with spacing
- Shimmer loading effect while fetching
- Use accent color for delivery fee highlight
- Sort by creation time (newest first)

---

### 6. Order Details Bottom Sheet
**Purpose**: Show full order details before acceptance

**Content**:

**Header**:
- "Order Details"
- Close button

**Customer Info** (limited):
- Icon with "Customer"
- Partial name (e.g., "Jane D.")
- Note: "Phone number revealed after acceptance"

**Pickup Location**:
- Pharmacy name
- Pharmacy address
- Icon: `Icons.local_pharmacy`

**Delivery Location**:
- Full address from order.location
- Icon: `Icons.location_on`

**Order Items**:
- List of drugs with:
  - Drug name
  - Dosage
  - Description (if available)

**Payment Info**:
- Total Amount: UGX X
- Delivery Fee: UGX Y (highlighted in green)
- ETA: "30-45 minutes"

**Actions**:
- "Accept Order" button (large, primary blue)
  - Shows loading spinner when pressed
  - Calls `POST /api/riders/orders/{orderId}/accept`
  
**Success Behavior**:
- Close bottom sheet
- Show success message
- Navigate to Active Orders screen
- Show customer phone number

**Error Handling**:
- If order already accepted by another rider:
  - Show error snackbar
  - Close bottom sheet
  - Refresh pending list

---

### 7. Active Orders Screen
**Purpose**: Show orders accepted by this rider

**Header**:
- Title: "My Active Deliveries"
- Count badge

**Order Cards** (Expanded):
Each card shows:

**Status Badge**: "In Progress" (green)

**Customer Section**:
- Customer name
- **Phone number** with call button
  - Tap to call using `url_launcher`
  - Icon: `Icons.phone`

**Pickup Details**:
- Pharmacy name
- Pharmacy address
- "Pickup from here" label

**Delivery Details**:
- Delivery address
- Map icon (optional: integrate Google Maps)
- "Get Directions" button

**Order Items**:
- Expandable list of drugs
- Show count: "3 items" (collapsed)

**Amount**:
- Total: UGX X
- Delivery Fee: UGX Y

**Action Button**:
- "Mark as Delivered" (green button)
  - Confirmation dialog
  - Calls `PATCH /api/riders/orders/{orderId}/deliver`

**Empty State**:
- Icon: `Icons.delivery_dining`
- Text: "No active deliveries"
- "View Pending Orders" button

**Design Notes**:
- Phone button prominent (primary action)
- Use green secondaryGreen color for active status
- Swipe to call functionality
- Confirmation dialog before marking delivered

---

### 8. History Screen
**Purpose**: Show completed deliveries

**Header**:
- Title: "Delivery History"
- Date filter button (Today, This Week, This Month)

**Summary Card** (Top):
- Total Deliveries: Count
- Total Earned: Sum of delivery fees
- Average per delivery
- Icon: `Icons.trending_up`

**History List**:
Each completed order card:
- Date & time
- Customer name
- Delivery location (short)
- Delivery fee earned (highlighted)
- Status badge: "Completed" (green)
- Tap to expand for full details

**Filter Options**:
- Today
- Last 7 days
- Last 30 days
- Custom date range

**Empty State**:
- Icon: `Icons.history`
- Text: "No delivery history yet"
- "Start Earning" button → Go to Pending Orders

**Design Notes**:
- Group by date (Today, Yesterday, etc.)
- Show earnings prominently
- Use green for completed status

---

### 9. Profile Screen
**Purpose**: Rider account management

**Header**:
- Profile avatar (initials or placeholder)
- Rider name
- Vehicle type badge
- Rating/stats (optional for v1)

**Account Info Section**:
- Full Name (read-only)
- Phone Number (read-only)
- Email (read-only)
- Vehicle Type (editable in v2)
- License Number (read-only)
- Member since date

**Statistics Section**:
- Total Deliveries
- Total Earnings (sum of delivery fees)
- Average Rating (if implemented)
- Acceptance Rate

**Settings Section**:
- Notifications toggle
- Language (optional)
- App version
- Terms & Privacy links

**Danger Zone**:
- "Logout" button (outlined, red)
  - Confirmation dialog
  - Clear token
  - Navigate to Welcome screen

**Design Notes**:
- Use card-based layout
- Icons for each section
- Editable fields with edit icon (for v2)

---

## 🎭 User Interactions & Flows

### Flow 1: First Time User - Signup & First Order

```
1. Open App
   ↓
2. Welcome Screen
   ↓
3. Tap "Get Started"
   ↓
4. Signup Screen
   ↓
5. Fill form (name, phone, password, vehicle, license)
   ↓
6. Tap "Create Account"
   ↓
7. [API] POST /api/auth/signup
   ↓
8. Success → Save token → Navigate to Home
   ↓
9. Home Screen (shows 0 stats)
   ↓
10. Tap "View Pending Orders"
    ↓
11. Pending Orders Screen (list of orders)
    ↓
12. Tap an order card
    ↓
13. Order Details Bottom Sheet opens
    ↓
14. Review order details
    ↓
15. Tap "Accept Order"
    ↓
16. [API] POST /api/riders/orders/{id}/accept
    ↓
17. Success → Close sheet → Navigate to Active Orders
    ↓
18. Active Orders Screen shows accepted order
    ↓
19. Tap phone icon to call customer
    ↓
20. Make delivery
    ↓
21. Tap "Mark as Delivered"
    ↓
22. Confirmation dialog → Confirm
    ↓
23. [API] PATCH /api/riders/orders/{id}/deliver
    ↓
24. Success → Order moves to History
    ↓
25. Show success message with earnings
```

### Flow 2: Returning User - Quick Delivery

```
1. Open App
   ↓
2. [Auto] Check token → Login success
   ↓
3. Home Screen (shows current stats)
   ↓
4. See "3 Available Orders"
   ↓
5. Tap "View Pending Orders"
   ↓
6. Pending Orders Screen
   ↓
7. Tap first order (highest fee)
   ↓
8. Bottom sheet opens
   ↓
9. Quick review → Tap "Accept"
   ↓
10. Navigate to Active Orders
    ↓
11. Tap phone → Call customer
    ↓
12. Deliver → Tap "Mark Delivered"
    ↓
13. Confirm → Complete
```

### Flow 3: Order Already Accepted by Another Rider

```
1. Pending Orders Screen (shows Order A)
   ↓
2. Tap Order A
   ↓
3. Bottom sheet opens
   ↓
4. Tap "Accept Order"
   ↓
5. [API] POST /api/riders/orders/A/accept
   ↓
6. [API Response] 400 Bad Request
   {
     "message": "Order has already been accepted by another rider"
   }
   ↓
7. Show error snackbar with message
   ↓
8. Close bottom sheet
   ↓
9. Refresh pending orders list
   ↓
10. Order A no longer appears
```

---

## 🚀 Key Features Implementation

### Feature 1: Real-time Order Updates

**Requirement**: Auto-refresh pending orders so riders see latest availability

**Implementation**:
```dart
class OrdersProvider extends ChangeNotifier {
  Timer? _refreshTimer;
  
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: 15),
      (timer) => fetchPendingOrders(),
    );
  }
  
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
```

**Usage**:
- Start timer when Pending Orders screen is visible
- Stop when screen is disposed
- Manual refresh via pull-to-refresh

---

### Feature 2: Phone Call Integration

**Requirement**: Riders can call customers directly from the app

**Implementation**:
```dart
import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch phone call';
    }
  }
}
```

**UI**:
```dart
// In Active Order Card
IconButton(
  icon: Icon(Icons.phone, color: AppColors.primaryBlue),
  onPressed: () async {
    await PhoneService.makePhoneCall(order.user.phone);
  },
  tooltip: 'Call Customer',
)
```

---

### Feature 3: Order Acceptance with Race Condition Handling

**Challenge**: Two riders might try to accept the same order simultaneously

**Solution**:
```dart
Future<void> acceptOrder(String orderId) async {
  try {
    setLoading(true);
    
    final response = await _apiClient.dio.post(
      '/riders/orders/$orderId/accept',
    );
    
    // Success - order accepted
    final acceptedOrder = Order.fromJson(response.data);
    _acceptedOrders.add(acceptedOrder);
    
    // Remove from pending list
    _pendingOrders.removeWhere((o) => o.id == orderId);
    
    notifyListeners();
    
    // Show success feedback
    return Future.value();
    
  } on DioError catch (e) {
    if (e.response?.statusCode == 400) {
      // Order already accepted by another rider
      final message = e.response?.data['message'] ?? 
                     'This order is no longer available';
      
      // Remove from local list
      _pendingOrders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      
      // Throw error for UI to handle
      throw message;
    } else {
      throw 'Failed to accept order. Please try again.';
    }
  } finally {
    setLoading(false);
  }
}
```

**UI Handling**:
```dart
// In Order Details Bottom Sheet
ElevatedButton(
  onPressed: _isAccepting ? null : () async {
    setState(() => _isAccepting = true);
    
    try {
      await ordersProvider.acceptOrder(widget.order.id);
      
      // Success
      Navigator.pop(context); // Close bottom sheet
      Navigator.pushNamed(context, '/active-orders');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order accepted! Customer: ${order.user.phone}'),
          backgroundColor: AppColors.secondaryGreen,
        ),
      );
      
    } catch (e) {
      // Error (order taken by another rider)
      Navigator.pop(context); // Close bottom sheet
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  },
  child: _isAccepting
      ? CircularProgressIndicator(color: Colors.white)
      : Text('Accept Order'),
)
```

---

### Feature 4: Delivery Confirmation

**Requirement**: Confirm before marking order as delivered

**Implementation**:
```dart
Future<void> _confirmDelivery(BuildContext context, Order order) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Delivery'),
      content: Text(
        'Have you successfully delivered the order to ${order.user.fullName}?'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryGreen,
          ),
          child: Text('Confirm'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    try {
      await ordersProvider.markAsDelivered(order.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as delivered! +UGX ${order.deliveryFee}'),
          backgroundColor: AppColors.secondaryGreen,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

### Feature 5: Statistics & Earnings Tracking

**Requirement**: Show rider performance metrics

**Implementation**:
```dart
class RiderStats {
  final int totalDeliveries;
  final double totalEarnings;
  final int completedToday;
  final double averageDeliveryFee;
  
  RiderStats({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.completedToday,
    required this.averageDeliveryFee,
  });
  
  factory RiderStats.fromOrders(List<Order> deliveredOrders) {
    final today = DateTime.now();
    final todayOrders = deliveredOrders.where((o) {
      return o.updatedAt.year == today.year &&
             o.updatedAt.month == today.month &&
             o.updatedAt.day == today.day;
    }).length;
    
    final totalEarnings = deliveredOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );
    
    return RiderStats(
      totalDeliveries: deliveredOrders.length,
      totalEarnings: totalEarnings,
      completedToday: todayOrders,
      averageDeliveryFee: deliveredOrders.isEmpty 
          ? 0 
          : totalEarnings / deliveredOrders.length,
    );
  }
}
```

---

## 🎨 Sample UI Components

### Stat Card Widget
```dart
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Order Card Widget
```dart
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  
  const OrderCard({
    required this.order,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.text.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Time and delivery fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.formattedDeliveryFee,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Customer name
            Row(
              children: [
                Icon(Icons.person_outline, 
                     size: 16, 
                     color: AppColors.text.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  order.user.fullName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, 
                     size: 16, 
                     color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Pharmacy
            if (order.pharmacy != null)
              Row(
                children: [
                  Icon(Icons.local_pharmacy, 
                       size: 16, 
                       color: AppColors.secondaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    order.pharmacy!.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Bottom row: Total and button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      order.formattedTotal,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
```

---

## ✅ Testing Checklist

### Authentication Testing
- [ ] Rider can sign up with valid credentials
- [ ] Signup validates all required fields
- [ ] Vehicle type dropdown works correctly
- [ ] Login works with correct credentials
- [ ] Login fails with wrong credentials
- [ ] Token is saved and persisted
- [ ] Auto-login works on app restart
- [ ] Logout clears token and navigates to welcome

### Orders Testing
- [ ] Pending orders list loads correctly
- [ ] Empty state shows when no pending orders
- [ ] Refresh updates the list
- [ ] Auto-refresh works every 15 seconds
- [ ] Order details bottom sheet displays correctly
- [ ] Accept order succeeds and navigates properly
- [ ] Accept order shows error if already taken
- [ ] Accepted order shows customer phone number
- [ ] Phone call button launches phone dialer
- [ ] Mark as delivered shows confirmation dialog
- [ ] Mark as delivered succeeds
- [ ] Delivered orders appear in history
- [ ] Cannot mark other rider's orders as delivered

### UI/UX Testing
- [ ] All screens match design guidelines
- [ ] Colors match CareShield theme
- [ ] Fonts are consistent (Inter/Google Fonts)
- [ ] Loading states show properly
- [ ] Error messages are user-friendly
- [ ] Success feedback is clear
- [ ] Animations are smooth
- [ ] Haptic feedback works
- [ ] Pull-to-refresh works on all lists
- [ ] Back button navigation works correctly

### Edge Cases
- [ ] Handle network errors gracefully
- [ ] Show retry option on failed requests
- [ ] Handle expired token (redirect to login)
- [ ] Handle empty responses
- [ ] Handle malformed data
- [ ] Prevent double-submission of actions
- [ ] Handle background/foreground transitions
- [ ] Test with slow network
- [ ] Test with no network
- [ ] Test with multiple rapid taps

---

## 📦 Deliverables

1. **Complete Flutter Project**
   - All screens implemented
   - All features working
   - Clean code with comments
   - Proper error handling

2. **README.md**
   - Project setup instructions
   - How to run the app
   - API configuration
   - Environment variables
   - Build instructions

3. **Screenshots** (Optional but recommended)
   - Welcome screen
   - Login screen
   - Home dashboard
   - Pending orders list
   - Order details
   - Active order with phone
   - Delivery history

4. **APK** (Optional)
   - Signed release APK for testing
   - Installation instructions

---

## 🚀 Getting Started Steps

1. **Create Flutter Project**
   ```bash
   flutter create care_shield_riders
   cd care_shield_riders
   ```

2. **Add Dependencies**
   - Copy the dependencies from pubspec.yaml specification above
   - Run `flutter pub get`

3. **Setup Project Structure**
   - Create folder structure as specified
   - Create core files (constants.dart, theme.dart)

4. **Implement API Client**
   - Setup Dio
   - Add token interceptor
   - Configure base URL

5. **Create Data Models**
   - Implement all model classes
   - Add fromJson/toJson methods

6. **Build Authentication**
   - Create auth provider
   - Build welcome/login/signup screens
   - Implement token storage

7. **Build Orders Feature**
   - Create orders provider
   - Build pending orders screen
   - Implement order acceptance
   - Build active orders screen
   - Implement delivery marking

8. **Build Dashboard**
   - Create home screen
   - Calculate statistics
   - Add navigation

9. **Build Profile**
   - Create profile screen
   - Implement logout

10. **Polish & Test**
    - Add loading states
    - Handle errors
    - Test all flows
    - Fix UI issues

---

## 💡 Important Notes

1. **Security**:
   - Store auth token securely using `flutter_secure_storage`
   - Never log sensitive data (tokens, passwords)
   - Validate all user inputs

2. **Performance**:
   - Use `ListView.builder` for long lists
   - Implement pagination if needed
   - Cache data locally where appropriate
   - Optimize image loading

3. **UX**:
   - Show loading indicators for all async operations
   - Provide clear error messages
   - Use haptic feedback for important actions
   - Implement pull-to-refresh
   - Add empty states

4. **Code Quality**:
   - Follow Flutter best practices
   - Use const constructors where possible
   - Extract reusable widgets
   - Add comments for complex logic
   - Use meaningful variable names

5. **Testing**:
   - Test with real API endpoints
   - Test edge cases
   - Test on different screen sizes
   - Test network failure scenarios

---

## 📞 Support & Questions

If you encounter issues:
1. Check API endpoint URLs
2. Verify token is being sent
3. Check network logs in Dio
4. Verify model parsing
5. Check backend error responses

---

## 🎉 Success Criteria

The app is complete when:
- ✅ Rider can signup and login
- ✅ Rider can see pending orders
- ✅ Rider can accept orders
- ✅ Rider can call customers
- ✅ Rider can mark orders as delivered
- ✅ Rider can view delivery history
- ✅ All error cases are handled
- ✅ UI matches design guidelines
- ✅ App works smoothly without crashes

---

**Good luck building the CareShield Riders app! 🚀**


Note that the app being created is in the folder riders_careshield this is the riders app use the Care_sheild app as reference to create the full app. Note that include the app image a presentable app name, integrate the api and all that.
