import { Controller, Get, Post, Body, UseGuards, ForbiddenException } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { randomBytes } from 'crypto';

@ApiTags('admin/promo-codes')
@Controller('admin/promo-codes')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PromoCodesController {
  constructor(private prisma: PrismaService) {}

  private async requireAdmin(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId }, select: { role: true } });
    if (!user || user.role !== 'ADMIN') throw new ForbiddenException({ message: 'Admin access required', code: ErrorCode.ADMIN_UNAUTHORIZED });
  }

  @Get()
  @ApiOperation({ summary: 'List all promo codes with usage stats' })
  async listAll(@CurrentUser('id') userId: string) {
    await this.requireAdmin(userId);
    return this.prisma.promoCode.findMany({
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { redemptions: true } } },
    });
  }

  @Post('generate')
  @ApiOperation({ summary: 'Generate promo codes in batch' })
  async generate(
    @CurrentUser('id') userId: string,
    @Body() body: {
      prefix: string;
      count: number;
      type: 'TRIAL_EXTEND' | 'FULL_PREMIUM';
      valueDays: number;
      maxRedemptions?: number;
      expiresAt?: string;
      createdBy?: string;
    },
  ) {
    await this.requireAdmin(userId);

    const { prefix, count, type, valueDays, maxRedemptions, expiresAt, createdBy } = body;
    if (!prefix || count < 1 || count > 500) throw new ForbiddenException({ message: 'Invalid params: prefix required, count 1-500', code: ErrorCode.VALIDATION_ERROR });
    if (!['TRIAL_EXTEND', 'FULL_PREMIUM'].includes(type)) throw new ForbiddenException({ message: 'Invalid type', code: ErrorCode.VALIDATION_ERROR });
    if (valueDays < 1 || valueDays > 365) throw new ForbiddenException({ message: 'valueDays must be 1-365', code: ErrorCode.VALIDATION_ERROR });

    const generated: string[] = [];
    const existingCodes = new Set(
      (await this.prisma.promoCode.findMany({ select: { code: true } })).map(p => p.code),
    );

    for (let i = 0; i < count; i++) {
      let code: string;
      do {
        const suffix = randomBytes(4).toString('hex').toUpperCase().substring(0, 8);
        code = `${prefix.toUpperCase()}-${suffix.substring(0, 4)}-${suffix.substring(4, 8)}`;
      } while (existingCodes.has(code) || generated.includes(code));

      generated.push(code);
      existingCodes.add(code);

      await this.prisma.promoCode.create({
        data: {
          code,
          type: type as any,
          valueDays,
          maxRedemptions: maxRedemptions ?? null,
          expiresAt: expiresAt ? new Date(expiresAt) : null,
          createdBy: createdBy ?? null,
        },
      });
    }

    return { generated, count: generated.length, type, valueDays };
  }
}
