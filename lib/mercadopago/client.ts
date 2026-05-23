import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';

/**
 * Mercado Pago SDK Configuration
 * 
 * Uses the access token from environment variables.
 * In test mode, use your TEST access token.
 * In production, use your PRODUCTION access token.
 */
const client = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN!,
});

export const preferenceClient = new Preference(client);
export const paymentClient = new Payment(client);

export { client };
