import { Injectable, Logger } from '@nestjs/common';
import * as sgMail from '@sendgrid/mail';

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

  constructor() {
    const apiKey = process.env.SENDGRID_API_KEY;
    if (apiKey) {
      sgMail.setApiKey(apiKey);
      this.initialized = true;
      this.logger.log('SendGrid initialized');
    } else {
      this.logger.warn('SENDGRID_API_KEY not set - email sending disabled');
    }
  }

  async sendEmail(options: EmailOptions): Promise<boolean> {
    if (!this.initialized) {
      this.logger.warn(`Email not sent (disabled): ${options.subject} to ${options.to}`);
      return false;
    }

    try {
      const msg = {
        to: options.to,
        from: process.env.SENDGRID_FROM_EMAIL || 'noreply@babymon.app',
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

  async sendVerificationEmail(email: string, token: string): Promise<boolean> {
    const verificationUrl = `${process.env.APP_URL || 'http://localhost:3000'}/verify-email?token=${token}`;
    return this.sendEmail({
      to: email,
      subject: 'Verify your BabyMon account',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Welcome to BabyMon!</h1>
          <p>Please verify your email address by clicking the button below:</p>
          <a href="${verificationUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Verify Email</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${verificationUrl}</p>
          <p>This link expires in 24 hours.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">If you didn't create this account, please ignore this email.</p>
        </div>
      `,
      text: `Welcome to BabyMon! Please verify your email: ${verificationUrl}`,
    });
  }

  async sendPasswordResetEmail(email: string, token: string): Promise<boolean> {
    const resetUrl = `${process.env.APP_URL || 'http://localhost:3000'}/reset-password?token=${token}`;
    return this.sendEmail({
      to: email,
      subject: 'Reset your BabyMon password',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Reset Your Password</h1>
          <p>You requested to reset your password. Click the button below:</p>
          <a href="${resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #DC2626; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Reset Password</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${resetUrl}</p>
          <p>This link expires in 1 hour.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #666; font-size: 12px;">If you didn't request this, please ignore this email and your password will remain unchanged.</p>
        </div>
      `,
      text: `Reset your password: ${resetUrl}`,
    });
  }

  async sendLinkedAccountInvitation(inviterName: string, email: string, token: string): Promise<boolean> {
    const acceptUrl = `${process.env.APP_URL || 'http://localhost:3000'}/accept-invitation?token=${token}`;
    return this.sendEmail({
      to: email,
      subject: `${inviterName} wants to share their BabyMon with you`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>Co-Parenting Invitation</h1>
          <p><strong>${inviterName}</strong> has invited you to share their BabyMon journey.</p>
          <p>Click below to accept:</p>
          <a href="${acceptUrl}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">Accept Invitation</a>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all;">${acceptUrl}</p>
          <p>This invitation expires in 7 days.</p>
        </div>
      `,
      text: `${inviterName} invited you to share their BabyMon: ${acceptUrl}`,
    });
  }

  async sendProposalNotification(email: string, babyMonName: string, proposalType: string): Promise<boolean> {
    return this.sendEmail({
      to: email,
      subject: `New ${proposalType} proposal for ${babyMonName}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h1>New Proposal</h1>
          <p>A new <strong>${proposalType}</strong> proposal has been submitted for <strong>${babyMonName}</strong>.</p>
          <p>Please review and respond in the BabyMon app.</p>
        </div>
      `,
      text: `New ${proposalType} proposal for ${babyMonName}`,
    });
  }
}
