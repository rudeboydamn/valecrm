#!/usr/bin/env python3
"""
Test sign in with existing user from the database
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMDM1MTIsImV4cCI6MjA3Nzg3OTUxMn0.l6GFoJOHDn0IaGRQdqbPNAXwkaH74LkGLXoYeIX0dqk"

def test_existing_user_signin():
    """Test sign in with the existing user from leads table"""
    url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    # Try with the email from the leads table
    body = {
        "email": "dammy@dammyhenry.com",
        "password": "testpassword123",  # You'll need to know the actual password
        "gotrue_meta_security": {}
    }
    
    print("Testing Sign In with Existing User...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_simple_signup():
    """Test a simple signup without email confirmation"""
    url = f"{SUPABASE_URL}/auth/v1/signup"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    # Use a different email to avoid conflicts
    body = {
        "email": "testuser123@example.com",
        "password": "testpassword123",
        "data": {"full_name": "Test User 123"}
    }
    
    print("Testing Simple Sign Up...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

if __name__ == "__main__":
    print("=== Test Existing User & Simple Signup ===")
    test_simple_signup()
    test_existing_user_signin()
