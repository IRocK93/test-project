import { Injectable, UnauthorizedException, ConflictException, InternalServerErrorException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto, RefreshTokenDto } from './dto/auth.dto';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { MailService } from '../mail/mail.service';
import { randomBytes } from 'crypto';

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
    const secret = this.configService.get<string>('JWT_SECRET');
    if (!secret && this.configService.get('NODE_ENV') === 'production') {
      throw new InternalServerErrorException('JWT_SECRET is required in production');
    }
    return secret || 'dev-only-secret';
  }

  async register(dto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new ConflictException({
        message: 'Email already registered',
        error: 'CONFLICT',
      });
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
            verificationToken,
            verificationExpires,
          },
        });

        const trialDays = parseInt(this.configService.get<string>('TRIAL_DAYS') || '14', 10);
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
        await this.mailService.sendVerificationEmail(user.email, verificationToken);
      } catch (mailError) {
        this.logger.warn({ err: mailError }, 'Failed to send verification email, but registration succeeded');
      }
      const tokens = await this.generateTokens(user.id, user.email);

      return {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          verified: false,
        },
        ...tokens,
        message: 'Registration successful. Please check your email to verify your account.',
      };
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      this.logger.error({ err: error }, 'Registration failed');
      throw new InternalServerErrorException({
        message: `Failed to create account: ${msg}`,
        error: 'INTERNAL_ERROR',
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
        error: 'UNAUTHORIZED',
      });
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException({
        message: 'Please use OAuth login',
        error: 'OAUTH_REQUIRED',
      });
    }

    if (user.deletedAt) {
      throw new UnauthorizedException({
        message: 'Account has been deleted',
        error: 'ACCOUNT_DELETED',
      });
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException({
        message: 'Invalid email or password',
        error: 'UNAUTHORIZED',
      });
    }

    const tokens = await this.generateTokens(user.id, user.email);

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
          error: 'INVALID_TOKEN',
        });
      }

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user || user.deletedAt) {
        throw new UnauthorizedException({
          message: 'User not found or deleted',
          error: 'USER_NOT_FOUND',
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
          error: 'TOKEN_EXPIRED',
        });
      }

      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { revokedAt: new Date() },
      });

      const tokens = await this.generateTokens(user.id, user.email);
      return tokens;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException({
        message: 'Invalid refresh token',
        error: 'INVALID_TOKEN',
      });
    }
  }

  async verifyEmail(token: string) {
    const user = await this.prisma.user.findFirst({
      where: {
        verificationToken: token,
        verificationExpires: { gt: new Date() },
      },
    });

    if (!user) {
      throw new BadRequestException('Invalid or expired verification token');
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        verifiedAt: new Date(),
        verificationToken: null,
        verificationExpires: null,
      },
    });

    return { message: 'Email verified successfully' };
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return { message: 'If the email exists, a reset link has been sent' };
    }

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

    await this.mailService.sendPasswordResetEmail(user.email, resetToken);

    return { message: 'If the email exists, a reset link has been sent' };
  }

  async resetPassword(token: string, newPassword: string) {
    const resetToken = await this.prisma.passwordResetToken.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!resetToken || resetToken.expiresAt < new Date()) {
      throw new BadRequestException('Invalid or expired reset token');
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

    return { message: 'Password reset successfully' };
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

  async generateTokens(userId: string, email: string) {
    const accessToken = this.jwtService.sign(
      { sub: userId, email, type: 'access' },
      { expiresIn: '15m' as const },
    );

    const refreshToken = this.jwtService.sign(
      { sub: userId, email, type: 'refresh' },
      { expiresIn: '7d' as const },
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

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
    return { message: 'Logged out successfully' };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        verifiedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }
}
