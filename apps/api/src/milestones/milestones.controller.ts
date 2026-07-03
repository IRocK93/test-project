import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { MilestonesService } from './milestones.service';
import { CreateMilestoneDto, UpdateMilestoneDto } from './dto/milestone.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('milestones')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class MilestonesController {
  constructor(private milestonesService: MilestonesService) {}

  @Post('baby-mons/:babyMonId/milestones')
  @ApiOperation({ summary: 'Create a milestone' })
  async create(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Body() dto: CreateMilestoneDto,
  ) {
    return this.milestonesService.create(babyMonId, req.user.id, dto);
  }

  @Get('baby-mons/:babyMonId/milestones')
  @ApiOperation({ summary: 'Get all milestones for a BabyMon' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  async findAll(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.milestonesService.findAll(
      babyMonId,
      req.user.id,
      pagination.skip || 0,
      pagination.take || 20,
    );
  }

  @Get('milestones/:id')
  @ApiOperation({ summary: 'Get a milestone by ID' })
  async findOne(@Request() req: any, @Param('id') id: string) {
    return this.milestonesService.findOne(id, req.user.id);
  }

  @Patch('milestones/:id')
  @ApiOperation({ summary: 'Update a milestone' })
  async update(
    @Request() req: any,
    @Param('id') id: string,
    @Body() dto: UpdateMilestoneDto,
  ) {
    return this.milestonesService.update(id, req.user.id, dto);
  }

  @Delete('milestones/:id')
  @ApiOperation({ summary: 'Delete a milestone' })
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.milestonesService.delete(id, req.user.id);
  }
}
