import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { SleepLogsService } from './sleep-logs.service';
import { CreateSleepLogDto, UpdateSleepLogDto } from './dto/sleep-log.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('sleep-logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class SleepLogsController {
  constructor(private sleepLogsService: SleepLogsService) {}

  @Post('baby-mons/:babyMonId/sleep-logs')
  @ApiOperation({ summary: 'Create sleep log' })
  async create(@Request() req: any, @Param('babyMonId') babyMonId: string, @Body() dto: CreateSleepLogDto) {
    return this.sleepLogsService.create(babyMonId, req.user.id, dto);
  }

  @Get('baby-mons/:babyMonId/sleep-logs')
  @ApiOperation({ summary: 'Get all sleep logs' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  async findAll(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.sleepLogsService.findAll(
      babyMonId,
      req.user.id,
      pagination.skip || 0,
      pagination.take || 20,
    );
  }

  @Get('sleep-logs/:id')
  @ApiOperation({ summary: 'Get sleep log' })
  async findOne(@Request() req: any, @Param('id') id: string) {
    return this.sleepLogsService.findOne(id, req.user.id);
  }

  @Patch('sleep-logs/:id')
  @ApiOperation({ summary: 'Update sleep log' })
  async update(@Request() req: any, @Param('id') id: string, @Body() dto: UpdateSleepLogDto) {
    return this.sleepLogsService.update(id, req.user.id, dto);
  }

  @Delete('sleep-logs/:id')
  @ApiOperation({ summary: 'Delete sleep log' })
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.sleepLogsService.delete(id, req.user.id);
  }
}