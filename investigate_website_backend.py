#!/usr/bin/env python3
"""
Investigate keystonevale.org website backend structure
"""
import requests
import json

def investigate_api_endpoints():
    """Check for common API endpoints"""
    base_url = "https://keystonevale.org"
    
    endpoints = [
        "/api/auth/signin",
        "/api/auth/signup", 
        "/api/auth/user",
        "/api/leads",
        "/api/users",
        "/auth/signin",
        "/auth/signup",
        "/api/login",
        "/api/register"
    ]
    
    print("=== Investigating Website API Endpoints ===")
    
    for endpoint in endpoints:
        url = base_url + endpoint
        try:
            response = requests.options(url, timeout=5)
            print(f"OPTIONS {url}: {response.status_code}")
            if response.status_code != 404:
                print(f"  Headers: {dict(response.headers)}")
        except requests.exceptions.RequestException as e:
            print(f"OPTIONS {url}: Error - {e}")
    
    print()

def check_supabase_usage():
    """Check if website uses Supabase"""
    base_url = "https://keystonevale.org"
    
    supabase_indicators = [
        "/supabase",
        "/functions/v1",
        "/rest/v1", 
        "/auth/v1"
    ]
    
    print("=== Checking for Supabase Usage ===")
    
    for indicator in supabase_indicators:
        url = base_url + indicator
        try:
            response = requests.head(url, timeout=5)
            if response.status_code != 404:
                print(f"Found: {url} - {response.status_code}")
        except requests.exceptions.RequestException:
            pass
    
    print()

def test_website_auth():
    """Test website authentication with admin credentials"""
    base_url = "https://keystonevale.org"
    
    auth_attempts = [
        {
            "url": base_url + "/api/auth/signin",
            "body": {"email": "admin@keystonevale.org", "password": "vale"}
        },
        {
            "url": base_url + "/api/login", 
            "body": {"email": "admin", "password": "vale"}
        },
        {
            "url": base_url + "/auth/signin",
            "body": {"username": "admin", "password": "vale"}
        }
    ]
    
    print("=== Testing Website Authentication ===")
    
    for attempt in auth_attempts:
        try:
            response = requests.post(
                attempt["url"], 
                json=attempt["body"],
                headers={"Content-Type": "application/json"},
                timeout=5
            )
            print(f"POST {attempt['url']}: {response.status_code}")
            if response.text:
                print(f"  Response: {response.text[:200]}...")
        except requests.exceptions.RequestException as e:
            print(f"POST {attempt['url']}: Error - {e}")
    
    print()

if __name__ == "__main__":
    investigate_api_endpoints()
    check_supabase_usage()
    test_website_auth()
    
    print("=== Next Steps ===")
    print("1. Provide the GitHub repository URL for keystonevale.org")
    print("2. Share the authentication system details")
    print("3. List any existing users that should work in the app")
    print("4. Confirm if both platforms should use the same Supabase project")
