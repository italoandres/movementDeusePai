/**
 * Middleware Verification Script
 * 
 * Tests the authentication middleware by making requests to protected and public routes.
 * This script verifies that:
 * 1. Protected routes redirect unauthenticated users to /login
 * 2. Public routes are accessible without authentication
 * 3. Redirect parameter is properly set
 */

async function testMiddleware() {
  const baseUrl = 'http://localhost:3000';
  
  console.log('🧪 Testing Authentication Middleware\n');
  
  // Test 1: Protected route without authentication
  console.log('Test 1: Accessing /journey without authentication');
  try {
    const response = await fetch(`${baseUrl}/journey`, {
      redirect: 'manual' // Don't follow redirects automatically
    });
    
    if (response.status === 307 || response.status === 308) {
      const location = response.headers.get('location');
      console.log(`✅ Redirected to: ${location}`);
      
      if (location && location.includes('/login') && location.includes('redirect=/journey')) {
        console.log('✅ Redirect parameter correctly set\n');
      } else {
        console.log('❌ Redirect parameter missing or incorrect\n');
      }
    } else {
      console.log(`❌ Expected redirect, got status: ${response.status}\n`);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}\n`);
  }
  
  // Test 2: Public route (landing page)
  console.log('Test 2: Accessing / (landing page)');
  try {
    const response = await fetch(`${baseUrl}/`, {
      redirect: 'manual'
    });
    
    if (response.status === 200) {
      console.log('✅ Landing page accessible without authentication\n');
    } else if (response.status === 307 || response.status === 308) {
      console.log(`❌ Landing page should not redirect, got redirect to: ${response.headers.get('location')}\n`);
    } else {
      console.log(`❌ Unexpected status: ${response.status}\n`);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}\n`);
  }
  
  // Test 3: Public route (login page)
  console.log('Test 3: Accessing /login');
  try {
    const response = await fetch(`${baseUrl}/login`, {
      redirect: 'manual'
    });
    
    if (response.status === 200) {
      console.log('✅ Login page accessible without authentication\n');
    } else if (response.status === 307 || response.status === 308) {
      console.log(`❌ Login page should not redirect, got redirect to: ${response.headers.get('location')}\n`);
    } else {
      console.log(`❌ Unexpected status: ${response.status}\n`);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}\n`);
  }
  
  // Test 4: Public route (signup page)
  console.log('Test 4: Accessing /signup');
  try {
    const response = await fetch(`${baseUrl}/signup`, {
      redirect: 'manual'
    });
    
    if (response.status === 200) {
      console.log('✅ Signup page accessible without authentication\n');
    } else if (response.status === 307 || response.status === 308) {
      console.log(`❌ Signup page should not redirect, got redirect to: ${response.headers.get('location')}\n`);
    } else {
      console.log(`❌ Unexpected status: ${response.status}\n`);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}\n`);
  }
  
  console.log('✅ Middleware verification complete!');
}

// Run tests
testMiddleware().catch(console.error);
