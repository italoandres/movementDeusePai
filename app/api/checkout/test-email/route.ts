import { NextRequest, NextResponse } from 'next/server';
import { sendAccessEmail } from '@/lib/email/send-access-email';

/**
 * POST /api/checkout/test-email
 * 
 * TEST ENDPOINT — Sends the access email without requiring a real purchase.
 * Use this to verify Resend is configured correctly.
 * 
 * Body: { "email": "your-real-email@gmail.com" }
 * 
 * DELETE THIS ENDPOINT BEFORE GOING TO PRODUCTION or add auth protection.
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email } = body;

    if (!email || typeof email !== 'string') {
      return NextResponse.json(
        { error: 'Email é obrigatório. Envie: { "email": "seu@email.com" }' },
        { status: 400 }
      );
    }

    console.log('[Test Email] Sending test access email to:', email);

    const success = await sendAccessEmail(email);

    if (success) {
      return NextResponse.json({ 
        success: true, 
        message: `Email enviado para ${email}. Verifique sua caixa de entrada (e spam).` 
      });
    } else {
      return NextResponse.json({ 
        success: false, 
        message: 'Falha ao enviar. Verifique se RESEND_API_KEY está configurada na Vercel.' 
      }, { status: 500 });
    }
  } catch (error) {
    console.error('[Test Email] Error:', error);
    return NextResponse.json(
      { error: 'Erro interno', details: String(error) },
      { status: 500 }
    );
  }
}
