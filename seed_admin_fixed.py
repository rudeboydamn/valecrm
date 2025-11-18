#!/usr/bin/env python3
"""
Fixed admin user creation with proper UUID generation
"""
import requests
import json
import uuid

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjMwMzUxMiwiZXhwIjoyMDc3ODc5NTEyfQ.rnE6jYDwKuHqIOhtCLiMVbwM3YjXXPVoXUU83SJuNkE"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMDM1MTIsImV4cCI6MjA3Nzg3OTUxMn0.l6GFoJOHDn0IaGRQdqbPNAXwkaH74LkGLXoYeIX0dqk"

def create_admin_with_uuid():
    """Create admin user with explicit UUID"""
    user_id = str(uuid.uuid4())
    
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    body = {
        "id": user_id,
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
    
    print("Creating Admin User with UUID...")
    print(f"URL: {url}")
    print(f"User ID: {user_id}")
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

def check_existing_users():
    """Check existing users to see if admin already exists"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    print("Checking Existing Users...")
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        users = response.json()
        print(f"Found {len(users)} total users")
        
        admin_users = [u for u in users if 'admin' in u.get('email', '').lower()]
        if admin_users:
            print("Existing admin users:")
            for user in admin_users:
                print(f"  - {user.get('email')} (ID: {user.get('id')})")
                print(f"    Created: {user.get('created_at')}")
                print(f"    Email Confirmed: {user.get('email_confirmed_at') is not None}")
        else:
            print("No admin users found")
    else:
        print(f"Error checking users: {response.text}")
    print()

if __name__ == "__main__":
    print("=== Fixed Admin User Creation ===")
    check_existing_users()
    create_admin_with_uuid()
    test_admin_signin()
    
    print("\n=== Admin Credentials ===")
    print("Email: admin@valecrm.com")
    print("Password: valley")
    print("\nThese are now pre-filled in your iPhone app login form.")
