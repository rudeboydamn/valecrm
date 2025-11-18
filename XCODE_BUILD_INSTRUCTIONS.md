# Xcode Build Instructions for ValeCRM

## Prerequisites
- **Xcode 15.0+** (Download from Mac App Store if needed)
- **macOS 13.0+**
- **iOS 16.0+ SDK**

## Step-by-Step Build Process

### 1. Open the Project
```bash
cd /Users/dammyhenry/CascadeProjects/windsurf-project/ValeCRM
open ValeCRM.xcodeproj
```

Or double-click `ValeCRM.xcodeproj` in Finder.

### 2. Select Target Device
In Xcode toolbar:
- Click on the device/simulator selector (next to the Run button)
- Choose:
  - **iOS Simulator**: iPhone 15 Pro (or any iPhone model)
  - **Physical Device**: Your connected iPhone/iPad

### 3. Configure Signing (If Using Physical Device)
1. Select `ValeCRM` project in the navigator
2. Select `ValeCRM` target
3. Go to **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Select your **Team** from dropdown
6. Xcode will automatically configure provisioning

### 4. Build the Project
**Option A: Using Keyboard**
- Press `⌘ + B` to build
- Press `⌘ + R` to build and run

**Option B: Using UI**
- Click the ▶️ (Play) button in the toolbar
- Or: Menu bar → Product → Run

### 5. Wait for Build to Complete
The build process will:
1. Compile all Swift files
2. Process resources (images, assets)
3. Link frameworks
4. Install on simulator/device

**Build time**: 30-60 seconds (first build may take longer)

### 6. App Launch
Once built successfully:
- App will automatically launch on the selected simulator/device
- You'll see the login screen

## Login Credentials

Use these credentials to test the app:
- **User ID**: `dammy`
- **Password**: `valley`

## Troubleshooting

### Build Error: "Failed to prepare device for development"
**Solution**: 
- Restart Xcode
- Clean build folder: `⌘ + Shift + K`
- Try again

### Build Error: "No signing certificate found"
**Solution**:
1. Go to Signing & Capabilities
2. Ensure "Automatically manage signing" is checked
3. Log into your Apple ID in Xcode (Preferences → Accounts)
4. Select your team

### Build Error: "Module not found"
**Solution**:
- Clean build folder: `⌘ + Shift + K`
- Clean derived data: Xcode → Preferences → Locations → Derived Data → Delete
- Rebuild: `⌘ + B`

### Simulator Not Showing
**Solution**:
- Xcode → Preferences → Components
- Download desired iOS simulator
- Restart Xcode

### App Crashes on Launch
**Solution**:
1. Check Console for error messages (⌘ + Shift + Y)
2. Ensure backend is accessible: https://keystonevale.org
3. Check network connectivity

## Quick Test Checklist

After successful build and launch:

1. **Login Screen**
   - [ ] Login screen displays correctly
   - [ ] Enter User ID: `dammy`
   - [ ] Enter Password: `valley`
   - [ ] Tap "Sign In"

2. **Dashboard Tab**
   - [ ] Dashboard loads with welcome message
   - [ ] Stats cards display (may show 0 if backend has no data)
   - [ ] No crashes or errors

3. **Leads Tab**
   - [ ] Leads list displays
   - [ ] Can tap "+" to add new lead
   - [ ] Search bar works

4. **Clients Tab**
   - [ ] Clients list displays (may be empty)
   - [ ] Can navigate and add client

5. **Tasks Tab**
   - [ ] Tasks list displays
   - [ ] Segmented control works (All, Today, Overdue, Completed)
   - [ ] Can add new task

6. **Projects Tab**
   - [ ] Projects list displays
   - [ ] Project cards show correctly

7. **Portfolio Tab**
   - [ ] Portfolio overview displays
   - [ ] Properties list accessible

8. **More Tab**
   - [ ] More menu displays
   - [ ] Can navigate to Communications
   - [ ] Can navigate to Documents
   - [ ] Can navigate to Reports
   - [ ] Can view Profile
   - [ ] Can access Settings
   - [ ] Sign Out button works

## Performance Optimization

For best performance during testing:

1. **Use iOS Simulator**
   - Faster than physical device for testing
   - Easier debugging
   - Recommended: iPhone 15 Pro simulator

2. **Debug Build Configuration**
   - Already set by default
   - Includes debug symbols
   - Allows breakpoints

3. **Release Build** (For App Store)
   - Change scheme to "Release"
   - Product → Scheme → Edit Scheme
   - Run → Build Configuration → Release
   - Optimized performance

## Xcode Shortcuts

**Building:**
- `⌘ + B` - Build
- `⌘ + R` - Run
- `⌘ + .` - Stop
- `⌘ + Shift + K` - Clean build folder

**Navigation:**
- `⌘ + 1-9` - Switch navigator panels
- `⌘ + Shift + Y` - Show/hide console
- `⌘ + Shift + O` - Open quickly (search files)

**Debugging:**
- `⌘ + \` - Add/remove breakpoint
- `F6` - Step over
- `F7` - Step into
- `F8` - Continue

## Backend Connection

The app connects to:
- **API Base URL**: `https://keystonevale.org`
- **Database**: PostgreSQL (vale_db)
- **Authentication**: JWT-based

All API endpoints are configured in:
- `ValeCRM/Config.swift` - Configuration
- `ValeCRM/Services/NetworkService.swift` - API calls
- `ValeCRM/Services/AuthManager.swift` - Authentication

## File Structure

```
ValeCRM/
├── ValeCRM.xcodeproj          # Xcode project file (open this)
├── ValeCRM/
│   ├── CRMApp.swift           # App entry point
│   ├── Config.swift           # Configuration
│   ├── Models/                # Data models
│   │   ├── Lead.swift
│   │   ├── Client.swift
│   │   ├── Task.swift
│   │   ├── Communication.swift
│   │   ├── Document.swift
│   │   ├── Report.swift
│   │   ├── Property.swift
│   │   └── RehabProject.swift
│   ├── Services/              # Backend services
│   │   ├── NetworkService.swift
│   │   ├── AuthManager.swift
│   │   ├── HubSpotService.swift
│   │   └── KeychainHelper.swift
│   ├── ViewModels/            # Business logic
│   │   ├── DashboardViewModel.swift
│   │   ├── LeadViewModel.swift
│   │   ├── ClientViewModel.swift
│   │   ├── TaskViewModel.swift
│   │   ├── CommunicationViewModel.swift
│   │   ├── PortfolioViewModel.swift
│   │   ├── PropertyViewModel.swift
│   │   └── RehabProjectViewModel.swift
│   └── Views/                 # UI components
│       ├── ContentView.swift
│       ├── LoginView.swift
│       ├── LeadsListView.swift
│       ├── Dashboard/
│       │   └── EnhancedDashboardView.swift
│       ├── Clients/
│       │   └── ClientsListView.swift
│       ├── Tasks/
│       │   └── TasksListView.swift
│       ├── Projects/
│       │   └── ProjectsListView.swift
│       └── Portfolio/
│           ├── PortfolioView.swift
│           └── EnhancedPortfolioView.swift
└── Documentation/
    ├── COMPREHENSIVE_CRM_UPDATE.md
    └── XCODE_BUILD_INSTRUCTIONS.md (this file)
```

## Next Steps After Successful Build

1. **Test Authentication**
   - Login with admin credentials
   - Verify JWT token storage

2. **Test Data Operations**
   - Create a new lead
   - Create a new client
   - Create a new task
   - Verify data saves to backend

3. **Cross-Platform Testing**
   - Make changes in mobile app
   - Verify changes appear on website (https://keystonevale.org/crm)
   - Make changes on website
   - Verify changes appear in mobile app (pull to refresh)

4. **Edge Case Testing**
   - Test with no internet connection
   - Test with invalid credentials
   - Test with empty data sets
   - Test form validation

## Support

For issues or questions:
- Check Console output in Xcode (⌘ + Shift + Y)
- Review error messages
- Verify backend connectivity
- Check API endpoint responses

## Success Criteria

✅ **Build succeeds without errors**
✅ **App launches on simulator/device**
✅ **Login works with admin credentials**
✅ **All 7 tabs are accessible**
✅ **Navigation works smoothly**
✅ **Data loads from backend**
✅ **CRUD operations work for leads, clients, tasks**
✅ **App doesn't crash during normal use**

---

**Ready to build!** Open ValeCRM.xcodeproj in Xcode and press ⌘ + R to run! 🚀
