#!/usr/bin/env python3
"""
Create a test user using Supabase Admin API (bypasses email confirmation)
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjMwMzUxMiwiZXhwIjoyMDc3ODc5NTEyfQ.rnE6jYDwKuHqIOhtCLiMVbwM3YjXXPVoXUU83SJuNkE"

def create_test_user():
    """Create a test user using admin API"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "testuser@valecrm.com",
        "password": "testpassword123",
        "email_confirm": True,
        "user_metadata": {"full_name": "Test User"}
    }
    
    print("Creating Test User via Admin API...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_created_user_signin():
    """Test sign in with the created user"""
    url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "testuser@valecrm.com",
        "password": "testpassword123",
        "gotrue_meta_security": {}
    }
    
    print("Testing Sign In with Created User...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

if __name__ == "__main__":
    print("=== Create Test User & Test Sign In ===")
    create_test_user()
    test_created_user_signin()
    
    print("\n=== Instructions ===")
    print("1. If user creation was successful, use these credentials in the app:")
    print("   Email: testuser@valecrm.com")
    print("   Password: testpassword123")
    print("\n2. For production, configure SMTP in Supabase Dashboard:")
    print("   Authentication → Email Settings → Enable Custom SMTP")
