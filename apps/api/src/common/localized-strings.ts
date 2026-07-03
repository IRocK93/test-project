/**
 * Production-grade localized strings for backend services.
 *
 * This module provides locale-aware strings for emails, push notifications,
 * stage content fallbacks, and reflection prompts. It mirrors the frontend
 * ARB system: each locale has a map of key → translated string.
 *
 * All keys default to English when a locale is not found.
 */

export type SupportedLocale = 'en' | 'ar' | 'de' | 'es' | 'fr' | 'he' | 'it' | 'pt' | 'zh';

/** Resolve locale from an arbitrary string, falling back to 'en'. */
export function resolveLocale(input?: string | null): SupportedLocale {
  if (!input) return 'en';
  const normalized = input.toLowerCase().slice(0, 2);
  const valid = new Set<string>(['en', 'ar', 'de', 'es', 'fr', 'he', 'it', 'pt', 'zh']);
  return valid.has(normalized) ? (normalized as SupportedLocale) : 'en';
}

// ─── Email Templates ────────────────────────────────────────────────

interface EmailTemplate {
  subject: string | ((params: Record<string, string>) => string);
  html: (params: Record<string, string>) => string;
  text: (params: Record<string, string>) => string;
}

const emailTemplates: Record<SupportedLocale, Record<string, EmailTemplate>> = {
  en: {
    verification: {
      subject: 'Verify your BabyMon account',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Welcome to BabyMon!</h1>
          <p>Please verify your email address by clicking the button below:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Verify Email</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>This link expires in 24 hours.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">If you didn't create this account, please ignore this email.</p>
        </div>`,
      text: (p) => `Welcome to BabyMon! Please verify your email: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'Reset your BabyMon password',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Reset Your Password</h1>
          <p>You requested to reset your password. Click the button below:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Reset Password</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${p.resetUrl}</p>
          <p>This link expires in 1 hour.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">If you didn't request this, please ignore this email and your password will remain unchanged.</p>
        </div>`,
      text: (p) => `Reset your password: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} wants to share their BabyMon with you`,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Co-Parenting Invitation</h1>
          <p><strong>${p.inviterName}</strong> has invited you to share their BabyMon journey.</p>
          <p>Click below to accept:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Accept Invitation</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${p.acceptUrl}</p>
          <p>This invitation expires in 7 days.</p>
        </div>`,
      text: (p) => `${p.inviterName} invited you to share their BabyMon: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `New ${p.proposalType} proposal for ${p.babyMonName}`,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>New Proposal</h1>
          <p>A new <strong>${p.proposalType}</strong> proposal has been submitted for <strong>${p.babyMonName}</strong>.</p>
          <p>Please review and respond in the BabyMon app.</p>
        </div>`,
      text: (p) => `New ${p.proposalType} proposal for ${p.babyMonName}`,
    },
  },

  ar: {
    verification: {
      subject: 'تحقق من حساب BabyMon الخاص بك',
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>مرحباً بك في BabyMon!</h1>
          <p>يرجى التحقق من بريدك الإلكتروني بالضغط على الزر أدناه:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">تحقق من البريد الإلكتروني</a>
          <p>أو انسخ والصق هذا الرابط في متصفحك:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>ينتهي هذا الرابط خلال 24 ساعة.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">إذا لم تقم بإنشاء هذا الحساب، يرجى تجاهل هذا البريد الإلكتروني.</p>
        </div>`,
      text: (p) => `مرحباً بك في BabyMon! يرجى التحقق من بريدك الإلكتروني: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'إعادة تعيين كلمة مرور BabyMon',
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>إعادة تعيين كلمة المرور</h1>
          <p>لقد طلبت إعادة تعيين كلمة المرور. اضغط على الزر أدناه:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">إعادة تعيين كلمة المرور</a>
          <p>أو انسخ والصق هذا الرابط في متصفحك:</p>
          <p style="word-break: break-all;">${p.resetUrl}</p>
          <p>ينتهي هذا الرابط خلال ساعة واحدة.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">إذا لم تطلب هذا، يرجى تجاهل هذا البريد الإلكتروني وستبقى كلمة المرور دون تغيير.</p>
        </div>`,
      text: (p) => `إعادة تعيين كلمة المرور: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} يريد مشاركة BabyMon معك` as any,
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>دعوة للمشاركة</h1>
          <p>يدعوك <strong>${p.inviterName}</strong> لمشاركة رحلة BabyMon الخاصة بهم.</p>
          <p>اضغط أدناه للقبول:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">قبول الدعوة</a>
          <p>أو انسخ والصق هذا الرابط في متصفحك:</p>
          <p style="word-break: break-all;">${p.acceptUrl}</p>
          <p>تنتهي هذه الدعوة خلال 7 أيام.</p>
        </div>`,
      text: (p) => `${p.inviterName} يدعوك لمشاركة BabyMon: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `اقتراح ${p.proposalType} جديد لـ ${p.babyMonName}` as any,
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>اقتراح جديد</h1>
          <p>تم تقديم اقتراح <strong>${p.proposalType}</strong> جديد لـ <strong>${p.babyMonName}</strong>.</p>
          <p>يرجى المراجعة والرد في تطبيق BabyMon.</p>
        </div>`,
      text: (p) => `اقتراح ${p.proposalType} جديد لـ ${p.babyMonName}`,
    },
  },

  de: {
    verification: {
      subject: 'Bestätigen Sie Ihr BabyMon-Konto',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Willkommen bei BabyMon!</h1>
          <p>Bitte bestätigen Sie Ihre E-Mail-Adresse:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">E-Mail bestätigen</a>
          <p>Oder kopieren Sie diesen Link in Ihren Browser:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>Dieser Link läuft in 24 Stunden ab.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Falls Sie dieses Konto nicht erstellt haben, ignorieren Sie bitte diese E-Mail.</p>
        </div>`,
      text: (p) => `Willkommen bei BabyMon! Bitte bestätigen Sie Ihre E-Mail: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'BabyMon-Passwort zurücksetzen',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Passwort zurücksetzen</h1>
          <p>Klicken Sie unten, um Ihr Passwort zurückzusetzen:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Passwort zurücksetzen</a>
          <p>Oder kopieren Sie diesen Link:</p>
          <p style="word-break: break-all;">${p.resetUrl}</p>
          <p>Dieser Link läuft in 1 Stunde ab.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Falls Sie dies nicht angefordert haben, ignorieren Sie diese E-Mail.</p>
        </div>`,
      text: (p) => `Passwort zurücksetzen: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} möchte seinen BabyMon mit Ihnen teilen` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Einladung zur gemeinsamen Betreuung</h1>
          <p><strong>${p.inviterName}</strong> hat Sie eingeladen, die BabyMon-Reise zu teilen.</p>
          <p>Klicken Sie unten, um anzunehmen:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Einladung annehmen</a>
          <p>Diese Einladung läuft in 7 Tagen ab.</p>
        </div>`,
      text: (p) => `${p.inviterName} hat Sie eingeladen: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `Neuer ${p.proposalType}-Vorschlag für ${p.babyMonName}` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Neuer Vorschlag</h1>
          <p>Ein neuer <strong>${p.proposalType}</strong>-Vorschlag wurde für <strong>${p.babyMonName}</strong> eingereicht.</p>
          <p>Bitte in der BabyMon-App prüfen.</p>
        </div>`,
      text: (p) => `Neuer ${p.proposalType}-Vorschlag für ${p.babyMonName}`,
    },
  },

  es: {
    verification: {
      subject: 'Verifica tu cuenta de BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>¡Bienvenido a BabyMon!</h1>
          <p>Verifica tu correo electrónico haciendo clic abajo:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Verificar Correo</a>
          <p>O copia y pega este enlace en tu navegador:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>Este enlace caduca en 24 horas.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Si no creaste esta cuenta, ignora este correo.</p>
        </div>`,
      text: (p) => `¡Bienvenido a BabyMon! Verifica tu correo: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'Restablece tu contraseña de BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Restablecer Contraseña</h1>
          <p>Haz clic abajo para restablecer tu contraseña:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Restablecer Contraseña</a>
          <p>Este enlace caduca en 1 hora.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Si no lo solicitaste, ignora este correo.</p>
        </div>`,
      text: (p) => `Restablece tu contraseña: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} quiere compartir su BabyMon contigo` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Invitación de Co-Crianza</h1>
          <p><strong>${p.inviterName}</strong> te ha invitado a compartir su BabyMon.</p>
          <p>Haz clic para aceptar:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Aceptar Invitación</a>
          <p>Esta invitación caduca en 7 días.</p>
        </div>`,
      text: (p) => `${p.inviterName} te invitó a compartir su BabyMon: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `Nueva propuesta de ${p.proposalType} para ${p.babyMonName}` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Nueva Propuesta</h1>
          <p>Se envió una propuesta de <strong>${p.proposalType}</strong> para <strong>${p.babyMonName}</strong>.</p>
          <p>Revísala en la app de BabyMon.</p>
        </div>`,
      text: (p) => `Nueva propuesta de ${p.proposalType} para ${p.babyMonName}`,
    },
  },

  fr: {
    verification: {
      subject: 'Vérifiez votre compte BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Bienvenue sur BabyMon !</h1>
          <p>Vérifiez votre adresse e-mail en cliquant ci-dessous :</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Vérifier l'e-mail</a>
          <p>Ou copiez ce lien dans votre navigateur :</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>Ce lien expire dans 24 heures.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Si vous n'avez pas créé ce compte, ignorez cet e-mail.</p>
        </div>`,
      text: (p) => `Bienvenue sur BabyMon ! Vérifiez votre e-mail : ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'Réinitialisez votre mot de passe BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Réinitialiser le mot de passe</h1>
          <p>Cliquez ci-dessous pour réinitialiser votre mot de passe :</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Réinitialiser</a>
          <p>Ce lien expire dans 1 heure.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Si vous n'avez pas demandé ceci, ignorez cet e-mail.</p>
        </div>`,
      text: (p) => `Réinitialisez votre mot de passe : ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} souhaite partager son BabyMon avec vous` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Invitation de co-parentalité</h1>
          <p><strong>${p.inviterName}</strong> vous invite à partager son BabyMon.</p>
          <p>Cliquez pour accepter :</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Accepter l'invitation</a>
          <p>Cette invitation expire dans 7 jours.</p>
        </div>`,
      text: (p) => `${p.inviterName} vous a invité : ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `Nouvelle proposition ${p.proposalType} pour ${p.babyMonName}` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Nouvelle proposition</h1>
          <p>Une proposition <strong>${p.proposalType}</strong> a été soumise pour <strong>${p.babyMonName}</strong>.</p>
          <p>Veuillez la consulter dans l'application BabyMon.</p>
        </div>`,
      text: (p) => `Nouvelle proposition ${p.proposalType} pour ${p.babyMonName}`,
    },
  },

  he: {
    verification: {
      subject: 'אמת את חשבון BabyMon שלך',
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>ברוך/ה הבא/ה ל-BabyMon!</h1>
          <p>אנא אמת/י את כתובת האימייל שלך בלחיצה על הכפתור:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">אמת אימייל</a>
          <p>או העתק/י את הקישור לדפדפן:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>קישור זה תקף ל-24 שעות.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">אם לא יצרת חשבון זה, אנא התעלם/י מאימייל זה.</p>
        </div>`,
      text: (p) => `ברוך/ה הבא/ה ל-BabyMon! אנא אמת/י את האימייל: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'אפס את סיסמת BabyMon שלך',
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>איפוס סיסמה</h1>
          <p>לחץ/י על הכפתור לאיפוס הסיסמה:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">אפס סיסמה</a>
          <p>קישור זה תקף לשעה אחת.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">אם לא ביקשת זאת, אנא התעלם/י והסיסמה לא תשתנה.</p>
        </div>`,
      text: (p) => `אפס סיסמה: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} רוצה לשתף איתך את BabyMon` as any,
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>הזמנה לשיתוף</h1>
          <p><strong>${p.inviterName}</strong> מזמין/ה אותך לשתף את מסע BabyMon.</p>
          <p>לחץ/י לקבלה:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">קבל/י הזמנה</a>
          <p>הזמנה זו תקפה ל-7 ימים.</p>
        </div>`,
      text: (p) => `${p.inviterName} הזמין/ה אותך לשתף BabyMon: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `הצעה חדשה מסוג ${p.proposalType} עבור ${p.babyMonName}` as any,
      html: (p) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>הצעה חדשה</h1>
          <p>הוגשה הצעה חדשה מסוג <strong>${p.proposalType}</strong> עבור <strong>${p.babyMonName}</strong>.</p>
          <p>אנא בדוק/י באפליקציית BabyMon.</p>
        </div>`,
      text: (p) => `הצעה חדשה מסוג ${p.proposalType} עבור ${p.babyMonName}`,
    },
  },

  it: {
    verification: {
      subject: 'Verifica il tuo account BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Benvenuto su BabyMon!</h1>
          <p>Verifica il tuo indirizzo email cliccando qui sotto:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Verifica Email</a>
          <p>Oppure copia questo link nel browser:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>Questo link scade tra 24 ore.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Se non hai creato questo account, ignora questa email.</p>
        </div>`,
      text: (p) => `Benvenuto su BabyMon! Verifica la tua email: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'Reimposta la password di BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Reimposta Password</h1>
          <p>Clicca qui sotto per reimpostare la password:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Reimposta Password</a>
          <p>Questo link scade tra 1 ora.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Se non hai richiesto questo, ignora questa email.</p>
        </div>`,
      text: (p) => `Reimposta password: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} vuole condividere BabyMon con te` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Invito alla Co-Genitorialità</h1>
          <p><strong>${p.inviterName}</strong> ti ha invitato a condividere BabyMon.</p>
          <p>Clicca per accettare:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Accetta Invito</a>
          <p>Questo invito scade tra 7 giorni.</p>
        </div>`,
      text: (p) => `${p.inviterName} ti ha invitato: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `Nuova proposta ${p.proposalType} per ${p.babyMonName}` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Nuova Proposta</h1>
          <p>È stata inviata una proposta <strong>${p.proposalType}</strong> per <strong>${p.babyMonName}</strong>.</p>
          <p>Controlla nell'app BabyMon.</p>
        </div>`,
      text: (p) => `Nuova proposta ${p.proposalType} per ${p.babyMonName}`,
    },
  },

  pt: {
    verification: {
      subject: 'Verifique sua conta BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Bem-vindo ao BabyMon!</h1>
          <p>Verifique seu e-mail clicando abaixo:</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Verificar E-mail</a>
          <p>Ou copie este link no seu navegador:</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>Este link expira em 24 horas.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Se você não criou esta conta, ignore este e-mail.</p>
        </div>`,
      text: (p) => `Bem-vindo ao BabyMon! Verifique seu e-mail: ${p.verificationUrl}`,
    },
    passwordReset: {
      subject: 'Redefina sua senha do BabyMon',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Redefinir Senha</h1>
          <p>Clique abaixo para redefinir sua senha:</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Redefinir Senha</a>
          <p>Este link expira em 1 hora.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">Se você não solicitou, ignore este e-mail.</p>
        </div>`,
      text: (p) => `Redefina sua senha: ${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} quer compartilhar o BabyMon com você` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Convite de Co-Parentalidade</h1>
          <p><strong>${p.inviterName}</strong> convidou você para compartilhar o BabyMon.</p>
          <p>Clique para aceitar:</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Aceitar Convite</a>
          <p>Este convite expira em 7 dias.</p>
        </div>`,
      text: (p) => `${p.inviterName} convidou você: ${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `Nova proposta de ${p.proposalType} para ${p.babyMonName}` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Nova Proposta</h1>
          <p>Uma proposta de <strong>${p.proposalType}</strong> foi enviada para <strong>${p.babyMonName}</strong>.</p>
          <p>Verifique no aplicativo BabyMon.</p>
        </div>`,
      text: (p) => `Nova proposta de ${p.proposalType} para ${p.babyMonName}`,
    },
  },

  zh: {
    verification: {
      subject: '验证您的 BabyMon 账户',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>欢迎来到 BabyMon！</h1>
          <p>请点击下方按钮验证您的电子邮件：</p>
          <a href="${p.verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">验证电子邮件</a>
          <p>或复制此链接到浏览器：</p>
          <p style="word-break: break-all;">${p.verificationUrl}</p>
          <p>此链接在 24 小时后过期。</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">如果您未创建此账户，请忽略此邮件。</p>
        </div>`,
      text: (p) => `欢迎来到 BabyMon！请验证您的电子邮件：${p.verificationUrl}`,
    },
    passwordReset: {
      subject: '重置您的 BabyMon 密码',
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>重置密码</h1>
          <p>点击下方重置密码：</p>
          <a href="${p.resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">重置密码</a>
          <p>此链接在 1 小时后过期。</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">如果您未请求此操作，请忽略此邮件。</p>
        </div>`,
      text: (p) => `重置密码：${p.resetUrl}`,
    },
    linkedAccountInvitation: {
      subject: (p) => `${p.inviterName} 想与您分享 BabyMon` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>共同育儿邀请</h1>
          <p><strong>${p.inviterName}</strong> 邀请您分享 BabyMon 旅程。</p>
          <p>点击接受：</p>
          <a href="${p.acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">接受邀请</a>
          <p>此邀请在 7 天后过期。</p>
        </div>`,
      text: (p) => `${p.inviterName} 邀请您分享 BabyMon：${p.acceptUrl}`,
    },
    proposalNotification: {
      subject: (p) => `${p.babyMonName} 的新${p.proposalType}提案` as any,
      html: (p) => `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>新提案</h1>
          <p>已为 <strong>${p.babyMonName}</strong> 提交了新的 <strong>${p.proposalType}</strong> 提案。</p>
          <p>请在 BabyMon 应用中查看。</p>
        </div>`,
      text: (p) => `${p.babyMonName} 的新${p.proposalType}提案`,
    },
  },
};

export function getEmailTemplate(locale: string, type: string): EmailTemplate {
  const loc = resolveLocale(locale);
  const templates = emailTemplates[loc] ?? emailTemplates['en'];
  return templates[type] ?? emailTemplates['en'][type];
}

// ─── Push Notification Strings ────────────────────────────────────

interface NotificationStrings {
  milestoneAdded: { title: string; body: (name: string, milestone: string) => string };
  badgeUnlocked: { title: string; body: (name: string, badge: string) => string };
  growthRecorded: { title: string; body: (name: string, type: string) => string };
  proposalReceived: { title: string; body: (proposalType: string) => string };
  paymentFailed: { title: string; bodySingle: string; bodyMultiple: string };
}

const notificationStrings: Record<SupportedLocale, NotificationStrings> = {
  en: {
    milestoneAdded: { title: 'New Milestone Added!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'Badge Unlocked!', body: (n, b) => `${n} earned: ${b}` },
    growthRecorded: { title: 'Growth Recorded', body: (n, t) => `${t} measurement added for ${n}` },
    proposalReceived: { title: 'New Proposal', body: (t) => `A new ${t} proposal needs your attention` },
    paymentFailed: {
      title: 'Payment Failed',
      bodySingle: 'There was an issue processing your subscription payment.',
      bodyMultiple: 'Your subscription payment has failed multiple times. Please update your payment method.',
    },
  },
  ar: {
    milestoneAdded: { title: 'تمت إضافة إنجاز جديد!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'تم فتح الشارة!', body: (n, b) => `حصل ${n} على: ${b}` },
    growthRecorded: { title: 'تم تسجيل النمو', body: (n, t) => `تمت إضافة قياس ${t} لـ ${n}` },
    proposalReceived: { title: 'اقتراح جديد', body: (t) => `اقتراح ${t} جديد يحتاج انتباهك` },
    paymentFailed: {
      title: 'فشل الدفع',
      bodySingle: 'حدثت مشكلة في معالجة دفعة الاشتراك.',
      bodyMultiple: 'فشلت دفعة الاشتراك عدة مرات. يرجى تحديث طريقة الدفع.',
    },
  },
  de: {
    milestoneAdded: { title: 'Neuer Meilenstein!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'Abzeichen freigeschaltet!', body: (n, b) => `${n} hat verdient: ${b}` },
    growthRecorded: { title: 'Wachstum aufgezeichnet', body: (n, t) => `${t}-Messung für ${n} hinzugefügt` },
    proposalReceived: { title: 'Neuer Vorschlag', body: (t) => `Ein neuer ${t}-Vorschlag benötigt Ihre Aufmerksamkeit` },
    paymentFailed: {
      title: 'Zahlung fehlgeschlagen',
      bodySingle: 'Bei der Verarbeitung Ihrer Abonnementzahlung ist ein Problem aufgetreten.',
      bodyMultiple: 'Ihre Abonnementzahlung ist mehrfach fehlgeschlagen. Bitte aktualisieren Sie Ihre Zahlungsmethode.',
    },
  },
  es: {
    milestoneAdded: { title: '¡Nuevo Hito Añadido!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: '¡Insignia Desbloqueada!', body: (n, b) => `${n} ganó: ${b}` },
    growthRecorded: { title: 'Crecimiento Registrado', body: (n, t) => `Medición de ${t} añadida para ${n}` },
    proposalReceived: { title: 'Nueva Propuesta', body: (t) => `Una nueva propuesta de ${t} necesita tu atención` },
    paymentFailed: {
      title: 'Pago Fallido',
      bodySingle: 'Hubo un problema al procesar el pago de tu suscripción.',
      bodyMultiple: 'El pago de tu suscripción ha fallado varias veces. Actualiza tu método de pago.',
    },
  },
  fr: {
    milestoneAdded: { title: 'Nouvelle Étape Ajoutée !', body: (n, m) => `${n} : ${m}` },
    badgeUnlocked: { title: 'Badge Débloqué !', body: (n, b) => `${n} a gagné : ${b}` },
    growthRecorded: { title: 'Croissance Enregistrée', body: (n, t) => `Mesure de ${t} ajoutée pour ${n}` },
    proposalReceived: { title: 'Nouvelle Proposition', body: (t) => `Une nouvelle proposition ${t} nécessite votre attention` },
    paymentFailed: {
      title: 'Paiement Échoué',
      bodySingle: 'Un problème est survenu lors du traitement de votre paiement.',
      bodyMultiple: 'Votre paiement a échoué plusieurs fois. Veuillez mettre à jour votre moyen de paiement.',
    },
  },
  he: {
    milestoneAdded: { title: 'אבן דרך חדשה נוספה!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'תג נפתח!', body: (n, b) => `${n} הרוויח/ה: ${b}` },
    growthRecorded: { title: 'צמיחה תועדה', body: (n, t) => `נמדד ${t} עבור ${n}` },
    proposalReceived: { title: 'הצעה חדשה', body: (t) => `הצעה חדשה מסוג ${t} דורשת את תשומת לבך` },
    paymentFailed: {
      title: 'תשלום נכשל',
      bodySingle: 'אירעה בעיה בעיבוד תשלום המנוי.',
      bodyMultiple: 'תשלום המנוי נכשל מספר פעמים. אנא עדכן/י את אמצעי התשלום.',
    },
  },
  it: {
    milestoneAdded: { title: 'Nuovo Traguardo!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'Badge Sbloccato!', body: (n, b) => `${n} ha guadagnato: ${b}` },
    growthRecorded: { title: 'Crescita Registrata', body: (n, t) => `Misurazione ${t} aggiunta per ${n}` },
    proposalReceived: { title: 'Nuova Proposta', body: (t) => `Una nuova proposta ${t} richiede la tua attenzione` },
    paymentFailed: {
      title: 'Pagamento Fallito',
      bodySingle: 'Si è verificato un problema con il pagamento dell\'abbonamento.',
      bodyMultiple: 'Il pagamento è fallito più volte. Aggiorna il metodo di pagamento.',
    },
  },
  pt: {
    milestoneAdded: { title: 'Novo Marco Adicionado!', body: (n, m) => `${n}: ${m}` },
    badgeUnlocked: { title: 'Distintivo Desbloqueado!', body: (n, b) => `${n} ganhou: ${b}` },
    growthRecorded: { title: 'Crescimento Registrado', body: (n, t) => `Medição de ${t} adicionada para ${n}` },
    proposalReceived: { title: 'Nova Proposta', body: (t) => `Uma nova proposta de ${t} precisa da sua atenção` },
    paymentFailed: {
      title: 'Pagamento Falhou',
      bodySingle: 'Houve um problema ao processar seu pagamento.',
      bodyMultiple: 'Seu pagamento falhou várias vezes. Atualize seu método de pagamento.',
    },
  },
  zh: {
    milestoneAdded: { title: '新里程碑已添加！', body: (n, m) => `${n}：${m}` },
    badgeUnlocked: { title: '徽章已解锁！', body: (n, b) => `${n} 获得了：${b}` },
    growthRecorded: { title: '成长记录', body: (n, t) => `已为 ${n} 添加${t}测量` },
    proposalReceived: { title: '新提案', body: (t) => `新的${t}提案需要您的关注` },
    paymentFailed: {
      title: '付款失败',
      bodySingle: '处理您的订阅付款时出现问题。',
      bodyMultiple: '您的订阅付款多次失败。请更新您的付款方式。',
    },
  },
};

export function getNotificationStrings(locale: string): NotificationStrings {
  const loc = resolveLocale(locale);
  return notificationStrings[loc] ?? notificationStrings['en'];
}

// ─── Stage Content Defaults ───────────────────────────────────────

interface StageContentDefaults {
  summaryText: string;
  nurturingText: string;
  encouragementText: string;
  stageTitle: (stageKey: string) => string;
}

const stageDefaults: Record<SupportedLocale, StageContentDefaults> = {
  en: {
    summaryText: 'Your BabyMon is growing! Track feedings, sleep, and milestones for personalized stage content.',
    nurturingText: 'Keep tracking feedings, sleep, and milestones.',
    encouragementText: "You're doing great!",
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} Month${parseInt(m[1]) > 1 ? 's' : ''} Insights`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Week ${w[1]} Insights`;
      return key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    },
  },
  ar: {
    summaryText: 'طفلك BabyMon ينمو! تابع الوجبات والنوم والإنجازات للحصول على محتوى مخصص.',
    nurturingText: 'استمر في متابعة الوجبات والنوم والإنجازات.',
    encouragementText: 'أنت تقوم بعمل رائع!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `رؤى الشهر ${m[1]}`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `رؤى الأسبوع ${w[1]}`;
      return key;
    },
  },
  de: {
    summaryText: 'Dein BabyMon wächst! Verfolge Fütterungen, Schlaf und Meilensteine für personalisierte Inhalte.',
    nurturingText: 'Verfolge weiterhin Fütterungen, Schlaf und Meilensteine.',
    encouragementText: 'Du machst das großartig!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]}. Monat — Einblicke`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Woche ${w[1]} — Einblicke`;
      return key;
    },
  },
  es: {
    summaryText: '¡Tu BabyMon está creciendo! Registra alimentación, sueño e hitos para contenido personalizado.',
    nurturingText: 'Sigue registrando alimentación, sueño e hitos.',
    encouragementText: '¡Lo estás haciendo genial!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} ${parseInt(m[1]) > 1 ? 'Meses' : 'Mes'} — Perspectivas`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Semana ${w[1]} — Perspectivas`;
      return key;
    },
  },
  fr: {
    summaryText: 'Votre BabyMon grandit ! Suivez les repas, le sommeil et les étapes pour du contenu personnalisé.',
    nurturingText: 'Continuez à suivre les repas, le sommeil et les étapes.',
    encouragementText: 'Vous faites un excellent travail !',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} Mois — Aperçus`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Semaine ${w[1]} — Aperçus`;
      return key;
    },
  },
  he: {
    summaryText: 'התינוק שלך BabyMon גדל! עקוב/י אחר האכלות, שינה ואבני דרך לתוכן מותאם.',
    nurturingText: 'המשך/י לעקוב אחר האכלות, שינה ואבני דרך.',
    encouragementText: 'את/ה עושה עבודה נהדרת!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `חודש ${m[1]} — תובנות`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `שבוע ${w[1]} — תובנות`;
      return key;
    },
  },
  it: {
    summaryText: 'Il tuo BabyMon sta crescendo! Tieni traccia di poppate, sonno e traguardi per contenuti personalizzati.',
    nurturingText: 'Continua a tracciare poppate, sonno e traguardi.',
    encouragementText: 'Stai facendo un ottimo lavoro!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} Mesi — Approfondimenti`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Settimana ${w[1]} — Approfondimenti`;
      return key;
    },
  },
  pt: {
    summaryText: 'Seu BabyMon está crescendo! Acompanhe alimentação, sono e marcos para conteúdo personalizado.',
    nurturingText: 'Continue acompanhando alimentação, sono e marcos.',
    encouragementText: 'Você está indo muito bem!',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} ${parseInt(m[1]) > 1 ? 'Meses' : 'Mês'} — Insights`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `Semana ${w[1]} — Insights`;
      return key;
    },
  },
  zh: {
    summaryText: '您的 BabyMon 正在成长！跟踪喂养、睡眠和里程碑以获取个性化内容。',
    nurturingText: '继续跟踪喂养、睡眠和里程碑。',
    encouragementText: '您做得很好！',
    stageTitle: (key: string) => {
      const m = key.match(/born_month_(\d+)/);
      if (m) return `${m[1]} 个月 — 洞察`;
      const w = key.match(/(?:born_week|preg_week)_(\d+)/);
      if (w) return `第 ${w[1]} 周 — 洞察`;
      return key;
    },
  },
};

export function getStageDefaults(locale: string): StageContentDefaults {
  const loc = resolveLocale(locale);
  return stageDefaults[loc] ?? stageDefaults['en'];
}

// ─── Reflection Prompts ───────────────────────────────────────────

const reflectionPrompts: Record<SupportedLocale, string[]> = {
  en: [
    'What small moment brought you joy today?',
    'What are you most proud of today?',
    'How did your baby make you smile today?',
    'What felt like a win today, no matter how small?',
    'What would you love to remember about this day?',
    'How are you feeling right now, truly?',
    'What made you grateful today?',
  ],
  ar: [
    'ما هي اللحظة الصغيرة التي جلبت لك الفرح اليوم؟',
    'ما الذي تفتخر به أكثر اليوم؟',
    'كيف جعلك طفلك تبتسم اليوم؟',
    'ما الذي شعرت أنه انتصار اليوم، مهما كان صغيراً؟',
    'ما الذي تود تذكره عن هذا اليوم؟',
    'كيف تشعر الآن، حقاً؟',
    'ما الذي جعلك ممتناً اليوم؟',
  ],
  de: [
    'Welcher kleine Moment hat dir heute Freude bereitet?',
    'Worauf bist du heute am meisten stolz?',
    'Wie hat dein Baby dich heute zum Lächeln gebracht?',
    'Was hat sich heute wie ein Erfolg angefühlt?',
    'Was möchtest du an diesem Tag in Erinnerung behalten?',
    'Wie fühlst du dich gerade wirklich?',
    'Wofür bist du heute dankbar?',
  ],
  es: [
    '¿Qué pequeño momento te trajo alegría hoy?',
    '¿De qué estás más orgulloso/a hoy?',
    '¿Cómo te hizo sonreír tu bebé hoy?',
    '¿Qué se sintió como un logro hoy?',
    '¿Qué te encantaría recordar de este día?',
    '¿Cómo te sientes ahora, de verdad?',
    '¿Qué te hizo sentir agradecido/a hoy?',
  ],
  fr: [
    'Quel petit moment vous a apporté de la joie aujourd\'hui ?',
    'De quoi êtes-vous le/la plus fier/fière aujourd\'hui ?',
    'Comment votre bébé vous a-t-il fait sourire aujourd\'hui ?',
    'Qu\'est-ce qui vous a semblé être une victoire aujourd\'hui ?',
    'Qu\'aimeriez-vous retenir de cette journée ?',
    'Comment vous sentez-vous vraiment en ce moment ?',
    'Qu\'est-ce qui vous a rendu reconnaissant(e) aujourd\'hui ?',
  ],
  he: [
    'איזה רגע קטן הביא לך שמחה היום?',
    'במה אתה/את הכי גאה היום?',
    'איך התינוק/ת גרם/ה לך לחייך היום?',
    'מה הרגיש כמו ניצחון היום, קטן ככל שיהיה?',
    'מה היית רוצה לזכור מהיום הזה?',
    'איך אתה/את מרגיש/ה עכשיו, באמת?',
    'על מה אתה/את מודה היום?',
  ],
  it: [
    'Quale piccolo momento ti ha portato gioia oggi?',
    'Di cosa sei più orgoglioso/a oggi?',
    'Come ti ha fatto sorridere il tuo bambino oggi?',
    'Cosa ti è sembrato un successo oggi?',
    'Cosa vorresti ricordare di questa giornata?',
    'Come ti senti davvero in questo momento?',
    'Cosa ti ha reso grato/a oggi?',
  ],
  pt: [
    'Que pequeno momento trouxe alegria hoje?',
    'Do que você mais se orgulha hoje?',
    'Como seu bebê fez você sorrir hoje?',
    'O que pareceu uma vitória hoje, por menor que seja?',
    'O que você gostaria de lembrar deste dia?',
    'Como você está se sentindo agora, de verdade?',
    'O que te deixou grato/a hoje?',
  ],
  zh: [
    '今天什么小时刻给您带来了快乐？',
    '今天您最自豪的是什么？',
    '您的宝宝今天如何让您微笑？',
    '今天什么感觉像是一个小小的胜利？',
    '您想记住今天的什么？',
    '您现在真正的感受是什么？',
    '今天什么让您心存感激？',
  ],
};

export function getReflectionPrompts(locale: string): string[] {
  const loc = resolveLocale(locale);
  return reflectionPrompts[loc] ?? reflectionPrompts['en'];
}

export function getReflectionPrompt(locale: string): string {
  const prompts = getReflectionPrompts(locale);
  return prompts[Math.floor(Date.now() / 86400000) % prompts.length];
}
