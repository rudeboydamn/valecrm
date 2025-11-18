# ValeCRM iOS App - Testing Instructions

## 🎯 Current Status

The iOS app has been successfully aligned with the website backend and includes **temporary mock authentication** for testing while the website authentication endpoints are being deployed.

## ✅ What's Ready to Test

### 1. Build & Run in Xcode
```bash
# Open the project
open ValeCRM.xcodeproj

# Build (Cmd+B)
# Run on device/simulator (Cmd+R)
```

### 2. Login Functionality
- **User ID:** `dammy`
- **Password:** `valley`
- Expected: Successful login with mock authentication
- Shows loading spinner for 1 second (simulated network delay)
- Logs in as "Admin User" with admin role

### 3. Leads Display
- After login, app should show 2 mock leads:
  1. **John Doe** - 123 Main St, Harrisburg, PA (New/High Priority)
  2. **Jane Smith** - 456 Oak Ave, Mechanicsburg, PA (Contacted/Medium Priority)

### 4. UI Navigation
- Test all tabs: Dashboard, Leads, Properties, Projects, Settings
- Properties and Projects show "API not yet implemented" messages (expected)
- Settings should show user info and logout option

## 🧪 Testing Steps

### Step 1: Basic Login Test
1. Launch app
2. Verify pre-filled credentials: `dammy` / `valley`
3. Tap "Sign In"
4. Verify loading spinner appears
5. Verify successful login and navigation to main app

### Step 2: Leads Functionality Test
1. Navigate to Leads tab
2. Verify 2 mock leads are displayed
3. Tap on a lead to view details
4. Test search and filter functionality
5. Test adding new lead (will show mock success)

### Step 3: User Interface Test
1. Test all navigation tabs
2. Verify user profile shows correct admin info
3. Test logout functionality
4. Verify app returns to login screen

### Step 4: Data Persistence Test
1. Login successfully
2. Force close the app
3. Reopen app
4. Verify user stays logged in (JWT stored in Keychain)

## 🚨 Known Limitations (Temporary)

### Mock Authentication
- Only works with `dammy` / `valley` credentials
- Other credentials will attempt real API (which may fail)
- Remove mock code when website is deployed

### Mock Leads Data
- Shows 2 sample leads only
- Create/update/delete operations simulate success
- Real data sync when website API is deployed

### Properties & Projects
- Show "API not yet implemented" messages
- Will work when website adds these endpoints

## 🔄 Switching to Real API

When the website authentication is deployed, remove these sections:

### In AuthManager.swift
```swift
// Remove this entire block:
if userId == "dammy" && password == "valley" {
    // ... mock authentication code
    return
}
```

### In NetworkService.swift
```swift
// Replace fetchLeads() with:
func fetchLeads() -> AnyPublisher<[Lead], APIError> {
    return request(from: "/api/leads", method: "GET")
}
```

## 📱 Expected Behavior

### With Mock (Current)
- ✅ Login works instantly with dammy/valley
- ✅ Shows 2 sample leads
- ✅ UI fully functional
- ❌ No real data synchronization

### With Real API (After website deployment)
- ✅ Login works with real website authentication
- ✅ Shows real leads from database
- ✅ Data syncs between app and website
- ✅ Any user created on website works in app

## 🔍 Debug Information

### Console Logs
Look for these messages in Xcode console:
- "Mock authentication triggered" (for testing)
- "JWT token stored successfully"
- "Leads fetched successfully"

### Keychain Storage
Check that JWT token is stored:
- Key: `com.keystonevale.valeCRM.jwtToken`
- Value: `mock-jwt-token-for-testing` (temporary)

## 📞 Next Steps

1. **Test the app** with current mock implementation
2. **Deploy website** authentication from `compyle/user-auth-signup` branch
3. **Remove mock code** and test real API integration
4. **Verify cross-platform** authentication works

The app is now ready for testing and will work seamlessly with the website once the authentication endpoints are deployed!
