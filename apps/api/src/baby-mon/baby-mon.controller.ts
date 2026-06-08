import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { BabyMonService } from './baby-mon.service';
import { CreateBabyMonDto, UpdateBabyMonDto } from './dto/baby-mon.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('baby-mons')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons')
export class BabyMonController {
  constructor(private babyMonService: BabyMonService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new BabyMon' })
  async create(@Request() req: any, @Body() dto: CreateBabyMonDto) {
    return this.babyMonService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all BabyMons for current user' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  async findAll(
    @Request() req: any,
    @Query() pagination: PaginationDto,
  ) {
    return this.babyMonService.findAll(
      req.user.id,
      pagination.skip || 0,
      pagination.take || 20,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a BabyMon by ID' })
  async findOne(@Request() req: any, @Param('id') id: string) {
    return this.babyMonService.findOne(id, req.user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a BabyMon' })
  async update(
    @Request() req: any,
    @Param('id') id: string,
    @Body() dto: UpdateBabyMonDto,
  ) {
    return this.babyMonService.update(id, req.user.id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a BabyMon' })
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.babyMonService.delete(id, req.user.id);
  }

  @Get(':id/stage')
  @ApiOperation({ summary: 'Get current stage for BabyMon' })
  async getStage(@Request() req: any, @Param('id') id: string) {
    return this.babyMonService.calculateCurrentStage(id);
  }
}
