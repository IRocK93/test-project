import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StageContentService } from './stage-content.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('stage-content')
@UseGuards(JwtAuthGuard)
@Controller('stage-content')
export class StageContentController {
  constructor(private stageContentService: StageContentService) {}

  @Get('baby-mon/:babyMonId')
  @ApiOperation({ summary: 'Get stage content for a BabyMon' })
  async getForBabyMon(@Param('babyMonId') babyMonId: string) {
    return this.stageContentService.getForBabyMon(babyMonId);
  }
}
