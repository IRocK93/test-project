import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as sgMail from '@sendgrid/mail';
import { getEmailTemplate } from '../common/localized-strings';

function resolveSubject(
  subject: string | ((params: Record<string, string>) => string),
  params: Record<string, string>,
): string {
  return typeof subject === 'function' ? subject(params) : subject;
}

export interface EmailOptions {
  to: string;
  subject: string;
  text?: string;
  html?: string;
}

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private initialized = false;
  private readonly fromEmail: string;
  private readonly appUrl: string;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get('sendgrid.apiKey') as string | undefined;
    if (apiKey) {
      sgMail.setApiKey(apiKey);
      this.initialized = true;
      this.logger.log('SendGrid initialized');
    } else {
      this.logger.warn('SENDGRID_API_KEY not set - email sending disabled');
    }
    this.fromEmail = (this.configService.get('sendgrid.fromEmail') as string) || 'noreply@babymon.app';
    this.appUrl = this.configService.get<string>('appUrl') || 'http://localhost:3000';
  }

  async sendEmail(options: EmailOptions): Promise<boolean> {
    if (!this.initialized) {
      this.logger.warn(`Email not sent (disabled): ${options.subject} to ${options.to}`);
      return false;
    }

    try {
      const msg = {
        to: options.to,
        from: this.fromEmail,
        subject: options.subject,
        text: options.text,
        html: options.html,
      };

      await sgMail.send(msg);
      this.logger.log(`Email sent: ${options.subject} to ${options.to}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send email: ${error.message}`);
      return false;
    }
  }

  async sendVerificationEmail(email: string, token: string, locale?: string): Promise<boolean> {
    const verificationUrl = `${this.appUrl}/verify-email?token=${token}`;
    const tpl = getEmailTemplate(locale || 'en', 'verification');
    return this.sendEmail({
      to: email,
      subject: resolveSubject(tpl.subject, { verificationUrl }),
      html: tpl.html({ verificationUrl }),
      text: tpl.text({ verificationUrl }),
    });
  }

  async sendPasswordResetEmail(email: string, token: string, locale?: string): Promise<boolean> {
    const resetUrl = `${this.appUrl}/reset-password?token=${token}`;
    const tpl = getEmailTemplate(locale || 'en', 'passwordReset');
    return this.sendEmail({
      to: email,
      subject: resolveSubject(tpl.subject, { resetUrl }),
      html: tpl.html({ resetUrl }),
      text: tpl.text({ resetUrl }),
    });
  }

  async sendLinkedAccountInvitation(inviterName: string, email: string, token: string, locale?: string): Promise<boolean> {
    const acceptUrl = `${this.appUrl}/accept-invitation?token=${token}`;
    const tpl = getEmailTemplate(locale || 'en', 'linkedAccountInvitation');
    return this.sendEmail({
      to: email,
      subject: resolveSubject(tpl.subject, { inviterName, acceptUrl }),
      html: tpl.html({ inviterName, acceptUrl }),
      text: tpl.text({ inviterName, acceptUrl }),
    });
  }

  async sendProposalNotification(email: string, babyMonName: string, proposalType: string, locale?: string): Promise<boolean> {
    const tpl = getEmailTemplate(locale || 'en', 'proposalNotification');
    return this.sendEmail({
      to: email,
      subject: resolveSubject(tpl.subject, { babyMonName, proposalType }),
      html: tpl.html({ babyMonName, proposalType }),
      text: tpl.text({ babyMonName, proposalType }),
    });
  }
}
