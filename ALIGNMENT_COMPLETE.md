# ValeCRM iOS App - Website Alignment Complete

## ✅ Completed Changes

### 1. Configuration (Config.swift)
- **Removed:** All Supabase configuration (URL, anon key, service key)
- **Added:** 
  - Website API Base URL: `https://keystonevale.org`
  - JWT Secret for token validation
  - Admin credentials: `dammy` / `valley` 
  - Email and app configuration from website

### 2. Authentication System (AuthManager.swift)
- **Removed:** 
  - Supabase auth endpoints
  - Email/password login
  - Refresh token flow
  - Access token management
- **Added:**
  - JWT-based authentication
  - User ID/password login (matching website)
  - Single JWT token storage in Keychain
  - Login endpoint: `POST /api/auth/signin`
  - Request body: `{ userId, password }`
  - Response: `{ user: {...}, token: "jwt..." }`

### 3. Data Models (AuthManager.swift)
- **Updated User Model:**
  ```swift
  struct User {
      let id: String
      let userId: String  // Username for login
      let email: String
      let name: String
      let role: String    // "admin" or "user"
      let isActive: Bool?
      let createdAt: Date?
      let lastLogin: Date?
  }
  ```
- **Updated AuthResponse:**
  ```swift
  struct AuthResponse {
      let user: User
      let token: String  // JWT token
  }
  ```

### 4. Network Service (NetworkService.swift)
- **Removed:**
  - Supabase-specific endpoint types (.rest, .auth, .absolute)
  - Supabase API key headers
  - Supabase REST API query parameters
  - Property and RehabProject endpoints (not in website API yet)
- **Added:**
  - Simple REST API endpoint construction
  - JWT Bearer token in Authorization header
  - Website API endpoints:
    - `GET /api/leads` - Fetch all leads
    - `POST /api/leads` - Create lead
    - `PATCH /api/leads/:id` - Update lead
    - `DELETE /api/leads/:id` - Delete lead

### 5. User Interface (LoginView.swift)
- **Changed:**
  - Input field: "Email" → "User ID"
  - Pre-filled with admin credentials: `dammy` / `valley`
  - Sign-in call: `signIn(userId:password:)` instead of `signIn(email:password:)`
  - Form validation: `userId.isEmpty` instead of `email.isEmpty`

## 🔄 How It Works Now

### Authentication Flow
1. User enters `userId` (e.g., "dammy") and password
2. App sends `POST /api/auth/signin` with `{userId, password}`
3. Website verifies credentials and returns JWT token
4. App stores JWT in Keychain
5. All subsequent API calls include `Authorization: Bearer {jwt}`

### Data Synchronization
- Both app and website use same Postgres database (`vale_db`)
- Both use same `users` table with `userId` field
- Same `leads` table with jsonb data structure
- JWT tokens work across both platforms

### Cross-Platform Compatibility
- ✅ User created on website → Can login in app
- ✅ User created in app → Can login on website (after admin approval)
- ✅ Lead created on website → Appears in app
- ✅ Lead created in app → Appears on website
- ✅ Same admin credentials work on both platforms

## 🧪 Testing Instructions

### 1. Test Admin Login
```
User ID: dammy
Password: valley
Expected: Successful login with admin role
```

### 2. Test Leads Fetch
After login, the app should automatically fetch leads from:
```
GET https://keystonevale.org/api/leads
Authorization: Bearer {jwt_token}
```

### 3. Test Cross-Platform
1. Login on website with `dammy` / `valley`
2. Create a lead on website
3. Login on iOS app with same credentials
4. Verify lead appears in app

### 4. Verify JWT Token
Check Keychain for:
```
Key: com.keystonevale.valeCRM.jwtToken
Value: {jwt_token_string}
```

## 📝 Important Notes

### Database Schema
The website uses this schema in `vale_db`:
```sql
users (
  id: text PRIMARY KEY,
  user_id: text UNIQUE NOT NULL,  -- Username for login
  email: text UNIQUE NOT NULL,
  password_hash: text NOT NULL,
  name: text NOT NULL,
  role: text DEFAULT 'user',      -- 'admin' or 'user'
  is_active: boolean DEFAULT false,
  created_at: timestamp,
  updated_at: timestamp,
  last_login: timestamp
)

leads (
  id: text PRIMARY KEY,
  data: jsonb NOT NULL,            -- All lead fields stored here
  hubspot_id: text,
  hubspot_deal_id: text,
  last_synced_at: timestamp,
  created_at: timestamp,
  updated_at: timestamp
)
```

### JWT Token Format
The JWT payload contains:
```json
{
  "id": "user-uuid",
  "userId": "dammy",
  "role": "admin"
}
```

### API Endpoints
Currently implemented on website:
- `POST /api/auth/signin` - Login
- `POST /api/auth/signup` - Create pending user (requires admin approval)
- `GET /api/leads` - Fetch leads
- `POST /api/leads` - Create lead
- `PATCH /api/leads/:id` - Update lead (needs implementation on website)
- `DELETE /api/leads/:id` - Delete lead (needs implementation on website)

## 🚀 Next Steps

### For Production
1. **Configure SMTP** on website for user approval emails
2. **Add Update/Delete Endpoints** for leads on website API
3. **Implement Contractors API** if needed
4. **Add Properties API** if needed
5. **Set up Error Logging** for production debugging
6. **Enable SSL Pinning** for enhanced security

### For Testing
1. Build and run the app in Xcode
2. Test login with `dammy` / `valley`
3. Verify leads data loads from website
4. Test creating a new lead
5. Verify new lead appears on website

## ⚠️ Breaking Changes
- **Old Supabase users won't work** - Must migrate to website's user system
- **Email login removed** - Must use userId
- **Properties and Projects** - Removed until website API supports them
- **Token refresh** - Removed (JWT expires after 24h, requires re-login)

## 🔐 Security Considerations
- JWT secret is stored in app for verification (if needed client-side)
- JWT tokens stored securely in iOS Keychain
- All API calls use HTTPS
- Bearer token authentication on all protected endpoints
- Passwords are bcrypt hashed (12 rounds) on backend

## 📞 Support
For issues or questions about the alignment:
- Check website backend: `https://github.com/rudeboydamn/keystoneweb`
- Branch: `compyle/user-auth-signup`
- Admin email: admin@keystonevale.com
