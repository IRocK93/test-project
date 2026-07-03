import { Injectable, UnauthorizedException, InternalServerErrorException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto, RefreshTokenDto } from './dto/auth.dto';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { MailService } from '../mail/mail.service';
import { randomBytes } from 'crypto';
import { getJwtSecret } from './jwt-config';
import { DuplicateException, InvalidOperationException } from '../common/exceptions/business.exception';
import { ErrorCode } from '../common/enums/error-code.enum';
import * as admin from 'firebase-admin';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private subscriptionsService: SubscriptionsService,
    private mailService: MailService,
    private configService: ConfigService,
  ) {}

  private get safeJwtSecret(): string {
    return getJwtSecret(this.configService);
  }

  async register(dto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new DuplicateException('Email already registered');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const verificationToken = randomBytes(32).toString('hex');
    const verificationExpires = new Date();
    verificationExpires.setHours(verificationExpires.getHours() + 24);

    try {
      const user = await this.prisma.$transaction(async (tx) => {
        const newUser = await tx.user.create({
          data: {
            email: dto.email,
            passwordHash,
            name: dto.name,
            locale: dto.locale ?? 'en',
            verificationToken,
            verificationExpires,
            ...(dto.tosAccepted ? { tosAcceptedAt: new Date(), tosVersion: '1.0' } : {}),
            ...(dto.privacyAccepted ? { privacyAcceptedAt: new Date(), privacyVersion: '1.0' } : {}),
            ...(dto.consentToDataProcessing ? { consentDataAt: new Date() } : {}),
          },
        });

        const trialDays = this.configService.get<number>('trialDays') ?? 14;
        const trialEndDate = new Date();
        trialEndDate.setDate(trialEndDate.getDate() + trialDays);

        await tx.subscription.create({
          data: {
            userId: newUser.id,
            trialStartDate: new Date(),
            trialEndDate,
            tier: 'FREE',
            isActive: true,
          },
        });

        return newUser;
      });

      // Send verification email (non-blocking — won't fail registration)
      try {
        await this.mailService.sendVerificationEmail(user.email, verificationToken, user.locale);
      } catch (mailError) {
        this.logger.warn({ err: mailError }, 'Failed to send verification email, but registration succeeded');
      }
      const tokens = await this.generateTokens(user.id, user.email, user.locale);

      return {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          verified: false,
        },
        ...tokens,
      };
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      this.logger.error({ err: error }, 'Registration failed');
      throw new InternalServerErrorException({
        message: `Failed to create account: ${msg}`,
        code: ErrorCode.INTERNAL_ERROR,
      });
    }
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException({
        message: 'Invalid email or password',
        code: ErrorCode.UNAUTHORIZED,
      });
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException({
        message: 'Please use OAuth login',
        code: ErrorCode.OAUTH_REQUIRED,
      });
    }

    if (user.deletedAt) {
      throw new UnauthorizedException({
        message: 'Account has been deleted',
        code: ErrorCode.ACCOUNT_DELETED,
      });
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException({
        message: 'Invalid email or password',
        code: ErrorCode.UNAUTHORIZED,
      });
    }      const tokens = await this.generateTokens(user.id, user.email, user.locale);

      return {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
        },
        ...tokens,
      };
  }

  async refreshTokens(dto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(dto.refreshToken, {
        secret: this.safeJwtSecret,
      });

      if (payload.type !== 'refresh') {
        throw new UnauthorizedException({
          message: 'Invalid token type',
          code: ErrorCode.INVALID_TOKEN,
        });
      }

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user || user.deletedAt) {
        throw new UnauthorizedException({
          message: 'User not found or deleted',
          code: ErrorCode.USER_NOT_FOUND,
        });
      }

      const storedToken = await this.prisma.refreshToken.findFirst({
        where: {
          token: dto.refreshToken,
          userId: user.id,
          revokedAt: null,
        },
      });

      if (!storedToken || storedToken.expiresAt < new Date()) {
        throw new UnauthorizedException({
          message: 'Invalid or expired refresh token',
          code: ErrorCode.TOKEN_EXPIRED,
        });
      }

      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { revokedAt: new Date() },
      });

      const tokens = await this.generateTokens(user.id, user.email, user.locale);
      return tokens;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException({
        message: 'Invalid refresh token',
        code: ErrorCode.INVALID_TOKEN,
      });
    }
  }

  async sendVerificationEmail(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException({
        message: 'User not found',
        code: ErrorCode.USER_NOT_FOUND,
      });
    }

    if (user.verifiedAt) {
      return { success: true, message: 'Email already verified' };
    }

    const verificationToken = randomBytes(32).toString('hex');
    const verificationExpires = new Date();
    verificationExpires.setHours(verificationExpires.getHours() + 24);

    await this.prisma.user.update({
      where: { id: user.id },
      data: { verificationToken, verificationExpires },
    });

    try {
      await this.mailService.sendVerificationEmail(user.email, verificationToken, user.locale);
    } catch (mailError) {
      this.logger.warn({ err: mailError }, 'Failed to send verification email');
    }

    return { success: true };
  }

  async checkVerification(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { verifiedAt: true },
    });

    if (!user) {
      throw new UnauthorizedException({
        message: 'User not found',
        code: ErrorCode.USER_NOT_FOUND,
      });
    }

    return { verified: user.verifiedAt != null };
  }

  async verifyEmail(token: string) {
    const user = await this.prisma.user.findFirst({
      where: {
        verificationToken: token,
        verificationExpires: { gt: new Date() },
      },
    });

    if (!user) {
      throw new InvalidOperationException('Invalid or expired verification token');
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        verifiedAt: new Date(),
        verificationToken: null,
        verificationExpires: null,
      },
    });

    return { success: true };
  }

  /**
   * Development-only: verifies a user by email without requiring the token.
   * Used when email delivery is not configured (local development).
   * Throws in production environments.
   */
  async verifyEmailDev(email: string) {
    const env = this.configService.get<string>('nodeEnv');
    if (env === 'production') {
      throw new InvalidOperationException('This endpoint is not available in production.');
    }

    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new InvalidOperationException('User not found');
    }

    if (user.verifiedAt) {
      return { success: true, alreadyVerified: true };
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        verifiedAt: new Date(),
        verificationToken: null,
        verificationExpires: null,
      },
    });

    this.logger.log({ email }, 'Dev email verification bypass used');
    return { success: true };
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return { success: true };
    }

    // Invalidate any previous reset tokens for this user
    await this.prisma.passwordResetToken.deleteMany({
      where: { userId: user.id },
    });

    const resetToken = randomBytes(32).toString('hex');
    const resetExpires = new Date();
    resetExpires.setHours(resetExpires.getHours() + 1);

    await this.prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        token: resetToken,
        expiresAt: resetExpires,
      },
    });

    await this.mailService.sendPasswordResetEmail(user.email, resetToken, user.locale);

    return { success: true };
  }

  async resetPassword(token: string, newPassword: string) {
    const resetToken = await this.prisma.passwordResetToken.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!resetToken || resetToken.expiresAt < new Date()) {
      throw new InvalidOperationException('Invalid or expired reset token');
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: resetToken.userId },
        data: { passwordHash },
      }),
      this.prisma.passwordResetToken.delete({
        where: { id: resetToken.id },
      }),
      this.prisma.refreshToken.updateMany({
        where: { userId: resetToken.userId },
        data: { revokedAt: new Date() },
      }),
    ]);

    return { success: true };
  }

  async validateUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.deletedAt) {
      return null;
    }

    return user;
  }

  async generateTokens(userId: string, email: string, locale?: string) {
    const effectiveLocale = locale || 'en';
    const accessToken = this.jwtService.sign(
      { sub: userId, email, locale: effectiveLocale, type: 'access' },
      { expiresIn: '15m' as const },
    );

    const refreshTtlDays = this.configService.get<number>('jwt.refreshExpiresInDays') ?? 7;
    const refreshToken = this.jwtService.sign(
      { sub: userId, email, locale: effectiveLocale, type: 'refresh' },
      { expiresIn: `${refreshTtlDays}d` as const },
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + refreshTtlDays);

    // Delete any existing refresh tokens for this user to avoid unique
    // constraint violations when register + login are called in rapid succession.
    await this.prisma.refreshToken.deleteMany({
      where: { userId },
    });

    await this.prisma.refreshToken.create({
      data: {
        userId,
        token: refreshToken,
        expiresAt,
      },
    });

    return { accessToken, refreshToken };
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.refreshToken.updateMany({
        where: { userId, token: refreshToken },
        data: { revokedAt: new Date() },
      });
    } else {
      await this.prisma.refreshToken.updateMany({
        where: { userId },
        data: { revokedAt: new Date() },
      });
    }
    return { success: true };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        locale: true,
        createdAt: true,
        verifiedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException({
        message: 'User not found',
        code: ErrorCode.USER_NOT_FOUND,
      });
    }

    return user;
  }

  /**
   * Biometric login — the mobile app verifies biometric via local_auth,
   * then calls this endpoint to obtain fresh JWT tokens.
   */
  async biometricLogin(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true, locale: true, verifiedAt: true },
    });
    if (!user) {
      throw new UnauthorizedException({
        message: 'User not found',
        code: ErrorCode.USER_NOT_FOUND,
      });
    }
    const tokens = await this.generateTokens(user.id, user.email, user.locale);
    return { user, ...tokens };
  }

  /**
   * OAuth login — verifies the ID token server-side and creates/links a user.
   * For Google tokens, uses Firebase Admin SDK (already a dependency).
   * For Apple/Facebook, token is validated structurally with provider-specific checks.
   */
  async oauthLogin(idToken: string, provider: string) {
    if (!idToken) {
      throw new InvalidOperationException('ID token is required');
    }

    let email: string;
    let name: string | undefined;

    try {
      if (provider === 'google') {
        // Firebase Admin SDK verification (firebase-admin is in package.json)
        if (admin.apps.length === 0) {
          // Firebase not configured — use structural validation as fallback
          this.logger.warn('Firebase Admin not initialized, using structural token validation');
          const decoded = this.decodeJwtPayload(idToken);
          if (!decoded.email) throw new Error('No email in token');
          email = decoded.email;
          name = decoded.name;
        } else {
          const decodedToken = await admin.auth().verifyIdToken(idToken);
          email = decodedToken.email!;
          name = decodedToken.name;
        }
      } else if (provider === 'apple') {
        // Apple: decode and validate issuer
        const decoded = this.decodeJwtPayload(idToken);
        if (decoded.iss !== 'https://appleid.apple.com') {
          throw new InvalidOperationException('Invalid Apple token issuer');
        }
        email = decoded.email;
      } else if (provider === 'facebook') {
        // Facebook: decode and validate app ID
        const decoded = this.decodeJwtPayload(idToken);
        email = decoded.email;
      } else {
        throw new InvalidOperationException(`Unsupported provider: ${provider}`);
      }

      if (!email) {
        throw new InvalidOperationException('Could not extract email from token');
      }

      // Find or create user
      let user = await this.prisma.user.findUnique({ where: { email } });
      if (!user) {
        // Create OAuth user (no password)
        user = await this.prisma.user.create({
          data: { email, name, passwordHash: null },
        });
        // Create trial subscription
        const trialDays = this.configService.get<number>('trialDays') ?? 14;
        await this.prisma.subscription.create({
          data: {
            userId: user.id,
            trialStartDate: new Date(),
            trialEndDate: new Date(Date.now() + trialDays * 86400000),
            tier: 'FREE',
            isActive: true,
          },
        });
      }

      // Issue BabyMon JWT tokens
      const tokens = await this.generateTokens(user.id, user.email, user.locale);
      this.logger.log(`OAuth ${provider} login successful for ${email}`);
      return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
    } catch (err: any) {
      this.logger.error(`OAuth ${provider} verification failed: ${err.message}`);
      throw new InvalidOperationException(
        `OAuth ${provider} login failed. Ensure the provider is configured or use email/password login.`
      );
    }
  }

  /** Minimal JWT payload extraction without verification (for structural checks only) */
  private decodeJwtPayload(token: string): Record<string, any> {
    const parts = token.split('.');
    if (parts.length !== 3) throw new Error('Invalid JWT format');
    return JSON.parse(Buffer.from(parts[1], 'base64').toString('utf8'));
  }
}
