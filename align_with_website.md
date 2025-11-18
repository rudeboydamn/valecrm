# Aligning ValeCRM App with keystonevale.org Website

## Current Situation
- ValeCRM iOS app uses Supabase backend with project ID: `wjdbivxcrloqyblmqqui`
- Website keystonevale.org is a Next.js application 
- Both need to share the same authentication system and `vale_db` database
- Users created on website must work in app and vice versa

## Required Changes

### 1. Authentication Alignment
The website likely uses a different authentication approach than the current app. We need to:

#### A. Investigate Website Authentication
```bash
# Check if website uses Supabase auth
curl -s "https://keystonevale.org/api/auth/signin" -X OPTIONS

# Look for auth endpoints
curl -s "https://keystonevale.org/api/auth" -I
```

#### B. Match Authentication Models
Update iOS app auth models to match exactly what the website expects:
- Same user fields (id, email, name, role, etc.)
- Same session/token structure
- Same metadata format

### 2. Database Schema Alignment
Ensure both app and website use identical database tables:
- `auth.users` - user authentication
- `profiles` - user profiles/roles  
- `leads` - real estate leads
- `properties` - property listings
- `deals` - deal tracking
- `contractors` - contractor management

### 3. API Endpoint Consistency
Both should use the same REST API endpoints:
- `/api/auth/*` - authentication
- `/api/leads/*` - lead management
- `/api/properties/*` - property data
- `/api/deals/*` - deal tracking

### 4. User Seeding for Testing
Create admin user that works on both platforms:
- Email: admin@keystonevale.org (or admin@valecrm.com)
- Password: vale
- Role: admin
- Should authenticate on both website and app

## Implementation Steps

### Step 1: Investigate Website Backend
1. Find the website's GitHub repository
2. Examine authentication implementation
3. Document API endpoints and data models
4. Identify database schema

### Step 2: Update iOS App Configuration
1. Update Supabase config to match website
2. Modify auth models to match website structure
3. Update API calls to use website endpoints
4. Ensure same database references

### Step 3: Test Cross-Platform Authentication
1. Create user on website → login in app
2. Create user in app → login on website
3. Verify data syncs correctly
4. Test admin credentials on both

### Step 4: Align Data Models
Ensure identical data structures for:
- User profiles and roles
- Lead management
- Property data
- Deal tracking
- Contractor information

## Next Actions Needed
1. Locate the website's source code repository
2. Examine the authentication implementation
3. Document the exact API structure
4. Update iOS app to match website backend
5. Test seamless authentication between platforms

## Questions for You
1. What's the exact GitHub URL for the keystoneweb repository?
2. Does the website use Supabase as backend?
3. What authentication system does the website currently use?
4. Are there existing users in the system I should be aware of?
