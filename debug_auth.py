#!/usr/bin/env python3
"""
Debug script to test Supabase authentication endpoints
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMDM1MTIsImV4cCI6MjA3Nzg3OTUxMn0.l6GFoJOHDn0IaGRQdqbPNAXwkaH74LkGLXoYeIX0dqk"

def test_signin():
    """Test sign in endpoint"""
    url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    body = {
        "email": "test@example.com",
        "password": "testpassword123",
        "gotrue_meta_security": {}
    }
    
    print("Testing Sign In...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_signup():
    """Test sign up endpoint"""
    url = f"{SUPABASE_URL}/auth/v1/signup"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    body = {
        "email": "test@example.com",
        "password": "testpassword123",
        "data": {"full_name": "Test User"}
    }
    
    print("Testing Sign Up...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

def test_rest_endpoint():
    """Test REST endpoint to check if tables exist"""
    url = f"{SUPABASE_URL}/rest/v1/leads?select=*&limit=1"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    print("Testing REST Endpoint (leads table)...")
    print(f"URL: {url}")
    
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print()

if __name__ == "__main__":
    print("=== Supabase Auth Debug ===")
    test_signup()
    test_signin()
    test_rest_endpoint()
