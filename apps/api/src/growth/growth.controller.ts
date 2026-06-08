import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GrowthService } from './growth.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('growth')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId/growth')
export class GrowthController {
  constructor(private growthService: GrowthService) {}

  @Post()
  @ApiOperation({ summary: 'Add growth record (height, weight, head circumference)' })
  async add(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() body: { type: 'HEIGHT' | 'WEIGHT' | 'HEAD_CIRCUMFERENCE'; value: number; unit: string; measuredAt: string; notes?: string },
  ) {
    return this.growthService.addGrowthRecord(
      userId,
      babyMonId,
      body.type,
      body.value,
      body.unit,
      new Date(body.measuredAt),
      body.notes,
    );
  }

  @Get()
  @ApiOperation({ summary: 'Get growth records' })
  async getAll(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Query('type') type?: string,
  ) {
    return this.growthService.getGrowthRecords(babyMonId, userId, type);
  }

  @Get('analysis')
  @ApiOperation({ summary: 'Get growth analysis with percentile' })
  async analyze(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Query('type') type: string,
  ) {
    return this.growthService.getGrowthAnalysis(babyMonId, userId, type);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete growth record' })
  async delete(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.growthService.deleteGrowthRecord(id, userId);
  }
}
