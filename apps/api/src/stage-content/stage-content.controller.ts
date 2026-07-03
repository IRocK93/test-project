import { Controller, Get, Param, Query, UseGuards, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { StageContentService } from './stage-content.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentLocale } from '../common/decorators/current-locale.decorator';

@ApiTags('stage-content')
@UseGuards(JwtAuthGuard)
@Controller('stage-content')
export class StageContentController {
  private readonly logger = new Logger(StageContentController.name);

  constructor(
    private stageContentService: StageContentService,
    private prisma: PrismaService,
  ) {}

  @Get('baby-mon/:babyMonId')
  @ApiOperation({ summary: 'Get stage content for a BabyMon' })
  async getForBabyMon(
    @Param('babyMonId') babyMonId: string,
    @Query('locale') locale?: string,
    @CurrentLocale() resolvedLocale?: string,
  ) {
    const effectiveLocale = locale || resolvedLocale || 'en';
    return this.stageContentService.getForBabyMon(babyMonId, effectiveLocale);
  }

  @Get(':stageKey')
  async getByStageKey(
    @Param('stageKey') stageKey: string,
    @Query('locale') locale?: string,
    @CurrentLocale() resolvedLocale?: string,
  ) {
    try {
      const effectiveLocale = locale || resolvedLocale || 'en';
      this.logger.log(`getByStageKey called with stageKey="${stageKey}" locale="${effectiveLocale}"`);
      const result = await this.stageContentService.getByStageKey(stageKey, null, effectiveLocale);
      this.logger.log(`getByStageKey returning: ${JSON.stringify(result).substring(0, 200)}`);
      return result;
    } catch (err) {
      this.logger.error(`getByStageKey FAILED: ${err.message}`, err.stack);
      throw err;
    }
  }

}
