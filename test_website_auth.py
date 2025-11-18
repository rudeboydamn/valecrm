#!/usr/bin/env python3
"""
Test authentication against the website backend to verify it works
"""
import requests
import json

def test_website_auth():
    """Test the website authentication endpoint"""
    base_url = "https://keystonevale.org"
    
    print("=== Testing Website Authentication ===")
    
    # Test login with admin credentials
    login_url = f"{base_url}/api/auth/signin"
    login_data = {
        "userId": "dammy",
        "password": "valley"
    }
    
    try:
        print(f"POST {login_url}")
        print(f"Body: {json.dumps(login_data, indent=2)}")
        
        response = requests.post(
            login_url,
            json=login_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"Status: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            print("✅ Login successful!")
            response_data = response.json()
            print(f"Response: {json.dumps(response_data, indent=2)}")
            
            # Extract JWT token
            if 'token' in response_data:
                token = response_data['token']
                print(f"JWT Token: {token[:50]}...")
                
                # Test protected endpoint
                print("\n=== Testing Protected Endpoint ===")
                leads_url = f"{base_url}/api/leads"
                leads_response = requests.get(
                    leads_url,
                    headers={
                        "Authorization": f"Bearer {token}",
                        "Content-Type": "application/json"
                    },
                    timeout=10
                )
                
                print(f"GET {leads_url}")
                print(f"Status: {leads_response.status_code}")
                
                if leads_response.status_code == 200:
                    print("✅ Leads endpoint accessible!")
                    leads_data = leads_response.json()
                    print(f"Leads count: {len(leads_data) if isinstance(leads_data, list) else 'N/A'}")
                    if isinstance(leads_data, list) and len(leads_data) > 0:
                        print(f"Sample lead: {json.dumps(leads_data[0], indent=2)[:500]}...")
                else:
                    print(f"❌ Leads endpoint failed: {leads_response.text}")
            else:
                print("❌ No token in response")
        else:
            print(f"❌ Login failed: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")
    
    print("\n=== Testing Sign-up Endpoint ===")
    
    # Test sign-up endpoint
    signup_url = f"{base_url}/api/auth/signup"
    signup_data = {
        "userId": "testuser123",
        "email": "test@example.com", 
        "password": "testpass123",
        "name": "Test User"
    }
    
    try:
        print(f"POST {signup_url}")
        print(f"Body: {json.dumps(signup_data, indent=2)}")
        
        response = requests.post(
            signup_url,
            json=signup_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Sign-up endpoint accessible!")
        else:
            print(f"❌ Sign-up failed")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")

if __name__ == "__main__":
    test_website_auth()
