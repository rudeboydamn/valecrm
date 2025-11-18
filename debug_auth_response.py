#!/usr/bin/env python3
"""
Debug the actual auth response format from Supabase
"""
import requests
import json

# Configuration from your app
SUPABASE_URL = "https://wjdbivxcrloqyblmqqui.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqZGJpdnhjcmxvcXlibG1xcXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMDM1MTIsImV4cCI6MjA3Nzg3OTUxMn0.l6GFoJOHDn0IaGRQdqbPNAXwkaH74LkGLXoYeIX0dqk"

def debug_signin_response():
    """Debug the actual response format from Supabase"""
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
    
    print("Debugging Auth Response Format...")
    print(f"URL: {url}")
    print(f"Body: {json.dumps(body, indent=2)}")
    
    response = requests.post(url, headers=headers, json=body)
    print(f"Status: {response.status_code}")
    print(f"Headers: {dict(response.headers)}")
    
    if response.status_code == 200:
        print(f"Raw Response: {response.text}")
        try:
            json_response = response.json()
            print(f"Parsed JSON: {json.dumps(json_response, indent=2)}")
            
            # Check what fields are actually present
            print("\n=== Response Fields Analysis ===")
            if isinstance(json_response, dict):
                for key in json_response.keys():
                    value = json_response[key]
                    print(f"{key}: {type(value).__name__} = {value}")
                    
                    if key == "user" and isinstance(value, dict):
                        print("  User fields:")
                        for user_key in value.keys():
                            print(f"    {user_key}: {type(value[user_key]).__name__} = {value[user_key]}")
        except json.JSONDecodeError as e:
            print(f"JSON Decode Error: {e}")
    else:
        print(f"Error Response: {response.text}")

if __name__ == "__main__":
    debug_signin_response()
