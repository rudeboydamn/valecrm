#!/usr/bin/env python3
"""
Check existing users in auth system and try alternative signup
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjMwMzUxMiwiZXhwIjoyMDc3ODc5NTEyfQ.rnE6jYDwKuHqIOhtCLiMVbwM3YjXXPVoXUU83SJuNkE"

def list_auth_users():
    """List existing users in auth system"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    print("Listing Existing Auth Users...")
    print(f"URL: {url}")
    
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_magic_link_signup():
    """Try signup with magic link approach"""
    url = f"{SUPABASE_URL}/auth/v1/otp"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "testuser@valecrm.com",
        "create_user": True,
        "data": {"full_name": "Test User"}
    }
    
    print("Testing Magic Link Signup...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_simple_signup_no_confirm():
    """Try signup without any confirmation settings"""
    url = f"{SUPABASE_URL}/auth/v1/signup"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "testuser2@valecrm.com",
        "password": "testpassword123",
        "data": {"full_name": "Test User 2"}
    }
    
    print("Testing Simple Signup (No Confirm)...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

if __name__ == "__main__":
    print("=== Check Auth System & Alternative Signup ===")
    list_auth_users()
    test_simple_signup_no_confirm()
    test_magic_link_signup()
    
    print("\n=== Next Steps ===")
    print("1. If any of these work, use the successful credentials in the app")
    print("2. If all fail, you need to configure SMTP in Supabase Dashboard:")
    print("   Authentication → Email Settings → Enable Custom SMTP")
    print("3. Or disable email confirmations in Auth Providers settings")
