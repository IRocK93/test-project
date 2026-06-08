import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { HealthRecordsService } from './health-records.service';
import { CreateHealthRecordDto, UpdateHealthRecordDto } from './dto/health-record.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('health-records')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class HealthRecordsController {
  constructor(private healthRecordsService: HealthRecordsService) {}

  @Post('baby-mons/:babyMonId/health-records')
  @ApiOperation({ summary: 'Create health record' })
  async create(@Request() req: any, @Param('babyMonId') babyMonId: string, @Body() dto: CreateHealthRecordDto) {
    return this.healthRecordsService.create(babyMonId, req.user.id, dto);
  }

  @Get('baby-mons/:babyMonId/health-records')
  @ApiOperation({ summary: 'Get all health records' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  async findAll(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.healthRecordsService.findAll(
      babyMonId,
      req.user.id,
      pagination.skip || 0,
      pagination.take || 20,
    );
  }

  @Get('health-records/:id')
  @ApiOperation({ summary: 'Get health record' })
  async findOne(@Request() req: any, @Param('id') id: string) {
    return this.healthRecordsService.findOne(id, req.user.id);
  }

  @Patch('health-records/:id')
  @ApiOperation({ summary: 'Update health record' })
  async update(@Request() req: any, @Param('id') id: string, @Body() dto: UpdateHealthRecordDto) {
    return this.healthRecordsService.update(id, req.user.id, dto);
  }

  @Delete('health-records/:id')
  @ApiOperation({ summary: 'Delete health record' })
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.healthRecordsService.delete(id, req.user.id);
  }
}
