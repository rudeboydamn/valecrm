# Fix Supabase Email Configuration

## The Problem
Your Supabase project is trying to send confirmation emails but the email service isn't configured, causing 500 errors during signup.

## Solution Options

### Option 1: Configure Custom SMTP (Recommended)
1. Go to Supabase Dashboard → Authentication → Email Settings
2. Enable "Custom SMTP"
3. Configure with any email provider:

#### SendGrid (Easiest)
```
SMTP Server: smtp.sendgrid.net
Port: 587
Username: apikey
Password: YOUR_SENDGRID_API_KEY
```

#### AWS SES
```
SMTP Server: email-smtp.us-east-1.amazonaws.com
Port: 587
Username: YOUR_SES_SMTP_USERNAME  
Password: YOUR_SES_SMTP_PASSWORD
```

#### Gmail (for testing)
```
SMTP Server: smtp.gmail.com
Port: 587
Username: your-email@gmail.com
Password: Your App Password (not regular password)
```

### Option 2: Disable Email Confirmation (Testing Only)
1. Go to Supabase Dashboard → Authentication → Providers
2. Scroll down to "Email" section
3. Uncheck "Enable email confirmations"
4. Save settings

### Option 3: Use Supabase Admin API (Advanced)
Create users directly without email confirmation:

```bash
curl -X POST 'https://wjdbivxcrloqyblmqqui.supabase.co/auth/v1/admin/users' \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123",
    "email_confirm": true,
    "user_metadata": {"full_name": "Test User"}
  }'
```

## Testing After Fix
Run the debug script again:
```bash
python3 debug_auth.py
```

Expected results:
- Sign up: 200 status with user session
- Sign in: 200 status with access token
- App should authenticate successfully

## For Production
Always configure custom SMTP for proper email delivery in production applications.
