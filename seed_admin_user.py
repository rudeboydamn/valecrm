#!/usr/bin/env python3
"""
Seed admin user credentials: admin / valley
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjMwMzUxMiwiZXhwIjoyMDc3ODc5NTEyfQ.rnE6jYDwKuHqIOhtCLiMVbwM3YjXXPVoXUU83SJuNkE"

def create_admin_user():
    """Create admin user using admin API"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "admin@valecrm.com",
        "password": "valley",
        "email_confirm": True,
        "user_metadata": {
            "full_name": "Admin User",
            "role": "admin"
        },
        "app_metadata": {
            "role": "admin",
            "provider": "email"
        }
    }
    
    print("Creating Admin User...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_admin_signin():
    """Test sign in with admin credentials"""
    url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "email": "admin@valecrm.com",
        "password": "valley",
        "gotrue_meta_security": {}
    }
    
    print("Testing Admin Sign In...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def check_existing_admin():
    """Check if admin user already exists"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    print("Checking for Existing Admin Users...")
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        users = response.json()
        admin_users = [u for u in users if 'admin' in u.get('email', '').lower()]
        print(f"Found {len(admin_users)} admin users:")
        for user in admin_users:
            print(f"  - {user.get('email')} (ID: {user.get('id')})")
    else:
        print(f"Error: {response.text}")
    print()

# Add the anon key for testing
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMDM1MTIsImV4cCI6MjA3Nzg3OTUxMn0.l6GFoJOHDn0IaGRQdqbPNAXwkaH74LkGLXoYeIX0dqk"

if __name__ == "__main__":
    print("=== Seed Admin User (admin/valley) ===")
    check_existing_admin()
    create_admin_user()
    test_admin_signin()
    
    print("\n=== Admin Credentials ===")
    print("Email: admin@valecrm.com")
    print("Password: valley")
    print("\nUse these credentials in your iPhone app to test authentication.")
