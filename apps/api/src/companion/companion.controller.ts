import { Controller, Get, Post, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CompanionService } from './companion.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TierGuard } from './tier.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('companion')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, TierGuard)
@Controller('stage-content/:babyMonId')
export class CompanionController {
  constructor(private companionService: CompanionService) {}

  @Get('daily-brief')
  @ApiOperation({ summary: 'Get personalized daily brief for AI_COMPANION subscribers' })
  async getDailyBrief(@Param('babyMonId') babyMonId: string) {
    return this.companionService.getDailyBrief(babyMonId);
  }

  @Get('routine')
  @ApiOperation({ summary: 'Get adaptive daily routine' })
  async getRoutine(@Param('babyMonId') babyMonId: string) {
    return this.companionService.getRoutine(babyMonId);
  }

  @Post('routine/:stepLabel/complete')
  @ApiOperation({ summary: 'Mark a routine step as completed' })
  async completeStep(
    @Param('babyMonId') babyMonId: string,
    @Param('stepLabel') stepLabel: string,
  ) {
    return this.companionService.completeRoutineStep(babyMonId, stepLabel);
  }

  @Get('milestones/expected')
  @ApiOperation({ summary: 'Get developmental milestones for current stage' })
  async getMilestones(
    @Param('babyMonId') babyMonId: string,
    @Query('status') status?: string,
  ) {
    return this.companionService.getMilestones(babyMonId, status);
  }

  @Post('milestones/:expectationId/achieve')
  @ApiOperation({ summary: 'Mark a milestone as achieved' })
  async achieveMilestone(
    @Param('babyMonId') babyMonId: string,
    @Param('expectationId') expectationId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.companionService.achieveMilestone(babyMonId, expectationId, userId);
  }

  @Get('advice')
  @ApiOperation({ summary: 'Get advice cards for current stage' })
  async getAdvice(
    @Param('babyMonId') babyMonId: string,
    @Query('category') category?: string,
    @Query() pagination?: PaginationDto,
  ) {
    return this.companionService.getAdvice(babyMonId, category, pagination?.skip ?? 0, pagination?.take ?? 10);
  }

  @Post('advice/:adviceCardId/bookmark')
  @ApiOperation({ summary: 'Toggle bookmark on an advice card' })
  async toggleBookmark(
    @Param('babyMonId') babyMonId: string,
    @Param('adviceCardId') adviceCardId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.companionService.toggleBookmarkAdvice(userId, babyMonId, adviceCardId);
  }

  @Get('advice/bookmarked')
  @ApiOperation({ summary: 'Get IDs of bookmarked advice cards for the current user' })
  async getBookmarkedAdviceIds(@CurrentUser('id') userId: string) {
    return this.companionService.getBookmarkedAdviceIds(userId);
  }

  @Post('advice/:adviceCardId/rate')
  @ApiOperation({ summary: 'Rate an advice card as helpful or not helpful' })
  async rateAdvice(
    @Param('adviceCardId') adviceCardId: string,
    @CurrentUser('id') userId: string,
    @Body('helpful') helpful: boolean,
  ) {
    return this.companionService.rateAdvice(userId, adviceCardId, helpful);
  }
}
