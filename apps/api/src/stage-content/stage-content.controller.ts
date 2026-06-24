import { Controller, Get, Param, Query, UseGuards, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StageContentService } from './stage-content.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

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
  async getForBabyMon(@Param('babyMonId') babyMonId: string) {
    return this.stageContentService.getForBabyMon(babyMonId);
  }

  @Get(':stageKey')
  async getByStageKey(@Param('stageKey') stageKey: string) {
    try {
      this.logger.log(`getByStageKey called with stageKey="${stageKey}"`);
      const result = await this.stageContentService.getByStageKey(stageKey, null);
      this.logger.log(`getByStageKey returning: ${JSON.stringify(result).substring(0, 200)}`);
      return result;
    } catch (err) {
      this.logger.error(`getByStageKey FAILED: ${err.message}`, err.stack);
      throw err;
    }
  }

}
