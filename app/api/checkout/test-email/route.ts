import { NextRequest, NextResponse } from 'next/server';

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

    // Direct Resend call with detailed error reporting
    const { Resend } = await import('resend');
    const resendKey = process.env.RESEND_API_KEY;
    
    if (!resendKey) {
      return NextResponse.json({ 
        success: false, 
        message: 'RESEND_API_KEY não está configurada. Valor: undefined',
        envCheck: {
          hasKey: !!process.env.RESEND_API_KEY,
          keyPrefix: process.env.RESEND_API_KEY?.substring(0, 5) || 'N/A',
        }
      }, { status: 500 });
    }

    const resend = new Resend(resendKey);
    const APP_URL = process.env.NEXT_PUBLIC_APP_URL || 'https://movementdeusepai.vercel.app';
    const accessLink = `${APP_URL}/app/#/obrigado?external_reference=${encodeURIComponent(email)}`;

    const { data, error } = await resend.emails.send({
      from: process.env.RESEND_FROM_EMAIL || 'Jornada Deus é Pai <onboarding@resend.dev>',
      to: email,
      subject: 'Seu acesso está pronto — Jornada Deus é Pai',
      html: `<div style="background:#0D0D0D;padding:40px;text-align:center;font-family:sans-serif;">
        <h1 style="color:#F5F1E8;font-weight:300;">Seu acesso já está pronto.</h1>
        <p style="color:rgba(245,241,232,0.7);">Agora só falta criar sua senha para entrar no seu espaço diante do Pai.</p>
        <a href="${accessLink}" style="display:inline-block;margin-top:24px;padding:16px 36px;color:#C6A15B;text-decoration:none;border:1px solid rgba(198,161,91,0.35);border-radius:30px;">criar meu acesso</a>
      </div>`,
    });

    if (error) {
      return NextResponse.json({ 
        success: false, 
        error: error,
        message: `Resend retornou erro: ${JSON.stringify(error)}` 
      }, { status: 500 });
    }

    return NextResponse.json({ 
      success: true, 
      data,
      message: `Email enviado para ${email}! Verifique sua caixa de entrada.` 
    });
  } catch (error) {
    console.error('[Test Email] Error:', error);
    return NextResponse.json(
      { error: 'Erro interno', details: String(error) },
      { status: 500 }
    );
  }
}
