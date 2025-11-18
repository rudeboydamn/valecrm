# Website Backend Analysis (keystonevale.org)

## Authentication System
- **Type**: Custom JWT-based authentication (NOT Supabase Auth)
- **Login**: userId + password (NOT email + password)
- **Token**: JWT with 24h expiry
- **Password Hashing**: bcrypt with 12 rounds
- **JWT Secret**: `1a29ee8e4eab8f54a03db5a029221e649987cef787f59cca1141569763bc51f6fd3b60c9296846623c6ce0e877b7674c3229a5251f0f161a1ce75f5c8e50b8a2`

## Admin Credentials
- **User ID**: dammy
- **Email**: dammy@keystonevale.org
- **Password**: valley
- **Role**: admin

## Database Schema (vale_db)

### users table
```sql
id: text (primary key)
user_id: text (unique, not null) -- This is the username
email: text (unique, not null)
password_hash: text (not null)
name: text (not null)
role: text (default 'user') -- 'admin' or 'user'
is_active: boolean (default false)
created_at: timestamp
updated_at: timestamp
last_login: timestamp
```

### leads table
```sql
id: text (primary key)
data: jsonb (not null) -- Contains all lead fields
hubspot_id: text
hubspot_deal_id: text
last_synced_at: timestamp
created_at: timestamp
updated_at: timestamp
```

### contractors table
```sql
id: text (primary key)
data: jsonb (not null)
hubspot_id: text
last_synced_at: timestamp
created_at: timestamp
updated_at: timestamp
```

### pending_users table (signup approval system)
```sql
id: text (primary key)
user_id: text (unique, not null)
email: text (unique, not null)
password_hash: text (not null)
name: text (not null)
approval_token: text (unique, not null)
created_at: timestamp
expires_at: timestamp (24h expiry)
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create pending user (requires admin approval)
  - Body: `{ userId, email, password, name }`
  - Response: `{ success, message }`
  
- `POST /api/auth/signin` - Login user
  - Body: `{ userId, password }`
  - Response: `{ user: { id, userId, email, name, role }, token }`

### Leads
- `GET /api/leads` - Fetch all leads
- `POST /api/leads` - Create new lead
- `PATCH /api/leads/:id` - Update lead

### Data Models

#### AuthResponse
```typescript
{
  user: {
    id: string;
    userId: string;  // username
    email: string;
    name: string;
    role: 'admin' | 'user';
  };
  token: string;  // JWT token
}
```

#### JWT Token Payload
```typescript
{
  id: string;
  userId: string;
  role: string;
}
```

#### Lead Data (stored in jsonb)
```typescript
{
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  propertyAddress: string;
  propertyCity: string;
  propertyState: string;
  propertyZip: string;
  propertyType: string;
  source: string;
  status: string;
  priority: string;
  timeline: string;
  motivation: string;
  notes: array;
  tasks: array;
  tags: array;
  communications: array;
  createdAt: string;
  updatedAt: string;
}
```

## Required iOS App Changes

### 1. Replace Supabase Auth with JWT Auth
- Remove all Supabase auth dependencies
- Implement custom JWT authentication
- Store JWT token in Keychain
- Add Authorization header to all API requests

### 2. Update Login Flow
- Change from email/password to userId/password
- Update LoginView to use userId field
- Match website's auth response structure

### 3. Update Network Service
- Replace Supabase endpoint construction
- Use website API endpoints: `/api/auth/*`, `/api/leads/*`
- Add JWT token to Authorization header
- Remove Supabase-specific headers (apikey)

### 4. Update Data Models
- User model: match website's user structure
- Lead model: match website's lead jsonb structure
- Remove Supabase-specific fields

### 5. Update Config
- Remove Supabase URL and keys
- Add website API base URL: `https://keystonevale.org`
- Add JWT secret for verification (if needed)

### 6. Database Connection
- Both must use same Postgres database (vale_db)
- Same connection string: `process.env.POSTGRES_URL`

## Implementation Priority
1. Update Config.swift with website API URL
2. Rewrite AuthManager for JWT authentication
3. Update User and AuthResponse models
4. Rewrite NetworkService for REST API
5. Update LeadViewModel for new API
6. Update LoginView for userId/password
7. Test cross-platform authentication
8. Verify data synchronization

## Testing Checklist
- [ ] Admin login works: dammy / valley
- [ ] JWT token is stored correctly
- [ ] JWT token is sent in Authorization header
- [ ] Leads fetch from same database
- [ ] User created on website can login in app
- [ ] User created in app can login on website (after approval)
- [ ] Data changes sync between platforms
