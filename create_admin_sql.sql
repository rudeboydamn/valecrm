-- Create admin user with proper UUID
INSERT INTO auth.users (
  id,
  email, 
  encrypted_password, 
  email_confirmed_at,
  raw_user_meta_data,
  raw_app_meta_data,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'admin@valecrm.com',
  crypt('valley', gen_salt('bf')),
  NOW(),
  '{"full_name": "Admin User"}',
  '{"role": "admin", "provider": "email"}',
  NOW(),
  NOW()
);

-- Create identity record for the user
INSERT INTO auth.identities (
  id,
  user_id,
  provider,
  identity_data,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'admin@valecrm.com'),
  'email',
  '{"email": "admin@valecrm.com", "sub": "admin@valecrm.com"}',
  'admin@valecrm.com',
  NOW(),
  NOW(),
  NOW()
);

-- Verify the user was created
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at,
  raw_user_meta_data
FROM auth.users 
WHERE email = 'admin@valecrm.com';
