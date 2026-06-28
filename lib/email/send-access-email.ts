import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

const APP_URL = process.env.NEXT_PUBLIC_APP_URL || 'https://nosecreto.app';

/**
 * Sends the access creation email to the buyer after payment approval.
 * 
 * This email contains:
 * - A warm, contemplative message (consistent with the ecosystem tone)
 * - A direct link to create their access (with email pre-filled)
 * 
 * The link format is: /app/#/obrigado?external_reference=email
 * This ensures the buyer can create their account even if they:
 * - Closed the browser after payment
 * - Lost the redirect from Mercado Pago
 * - Were redirected incorrectly
 */
export async function sendAccessEmail(email: string): Promise<boolean> {
  if (!process.env.RESEND_API_KEY) {
    console.log('[Email] RESEND_API_KEY not configured, skipping email send');
    return false;
  }

  const accessLink = `${APP_URL}/app/#/obrigado?external_reference=${encodeURIComponent(email)}`;

  try {
    const { error } = await resend.emails.send({
      from: process.env.RESEND_FROM_EMAIL || 'Jornada Deus é Pai <onboarding@resend.dev>',
      to: email,
      subject: 'Seu acesso está pronto — Jornada Deus é Pai',
      html: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0; padding:0; background-color:#0D0D0D; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#0D0D0D; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;">
          
          <!-- Spacer -->
          <tr><td height="60"></td></tr>
          
          <!-- Headline -->
          <tr>
            <td align="center" style="color:#F5F1E8; font-size:24px; font-weight:300; letter-spacing:0.3px; line-height:1.7;">
              Seu acesso já está pronto.
            </td>
          </tr>
          
          <tr><td height="24"></td></tr>
          
          <!-- Divider -->
          <tr>
            <td align="center">
              <div style="width:30px; height:1px; background-color:rgba(198,161,91,0.2);"></div>
            </td>
          </tr>
          
          <tr><td height="24"></td></tr>
          
          <!-- Body text -->
          <tr>
            <td align="center" style="color:rgba(245,241,232,0.7); font-size:15px; font-weight:300; line-height:1.8;">
              Agora só falta criar sua senha<br>
              para entrar no seu espaço diante do Pai.
            </td>
          </tr>
          
          <tr><td height="40"></td></tr>
          
          <!-- CTA Button -->
          <tr>
            <td align="center">
              <a href="${accessLink}" 
                 style="display:inline-block; padding:16px 36px; color:#C6A15B; font-size:15px; font-weight:300; letter-spacing:0.5px; text-decoration:none; border:1px solid rgba(198,161,91,0.35); border-radius:30px; background-color:rgba(198,161,91,0.08);">
                criar meu acesso
              </a>
            </td>
          </tr>
          
          <tr><td height="40"></td></tr>
          
          <!-- Footer text -->
          <tr>
            <td align="center" style="color:rgba(245,241,232,0.3); font-size:12px; font-weight:300; line-height:1.6;">
              Este link é exclusivo para você.<br>
              Guarde-o com carinho — ele é a porta<br>
              para o seu espaço dentro do ecossistema Deus é Pai.
            </td>
          </tr>
          
          <tr><td height="60"></td></tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
      `,
    });

    if (error) {
      console.error('[Email] Error sending access email:', error);
      return false;
    }

    console.log('[Email] ✓ Access email sent to:', email);
    return true;
  } catch (e) {
    console.error('[Email] Unexpected error sending email:', e);
    return false;
  }
}
