import { NextRequest, NextResponse } from 'next/server';

/**
 * GET /api/checkout/redirect
 * 
 * Mercado Pago redirects here after payment with query params like:
 * ?collection_id=xxx&external_reference=email@test.com&payment_type=...
 * 
 * This route captures the external_reference (email) and redirects to
 * the Flutter Web app with the email as a query param AFTER the hash,
 * so GoRouter can access it:
 * /app/#/obrigado?external_reference=email@test.com
 */
export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const externalReference = url.searchParams.get('external_reference') || '';
  const collectionStatus = url.searchParams.get('collection_status') || '';
  
  const appUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
  
  // If payment was not approved, redirect to sales page
  if (collectionStatus === 'rejected' || collectionStatus === 'cancelled') {
    return NextResponse.redirect(`${appUrl}/app/#/journey/sales`);
  }
  
  // Redirect to Flutter app with email in the hash fragment query params
  // Flutter's GoRouter reads: state.uri.queryParameters['external_reference']
  const redirectUrl = `${appUrl}/app/#/obrigado?external_reference=${encodeURIComponent(externalReference)}`;
  
  return NextResponse.redirect(redirectUrl);
}
