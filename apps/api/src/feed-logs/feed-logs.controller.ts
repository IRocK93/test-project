import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { FeedLogsService } from './feed-logs.service';
import { CreateFeedLogDto, UpdateFeedLogDto } from './dto/feed-log.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('feed-logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class FeedLogsController {
  constructor(private feedLogsService: FeedLogsService) {}

  @Post('baby-mons/:babyMonId/feed-logs')
  @ApiOperation({ summary: 'Create a feeding log' })
  async create(@Request() req: any, @Param('babyMonId') babyMonId: string, @Body() dto: CreateFeedLogDto) {
    return this.feedLogsService.create(babyMonId, req.user.id, dto);
  }

  @Get('baby-mons/:babyMonId/feed-logs')
  @ApiOperation({ summary: 'Get all feeding logs' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  async findAll(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.feedLogsService.findAll(
      babyMonId,
      req.user.id,
      pagination.skip || 0,
      pagination.take || 20,
    );
  }

  @Get('feed-logs/:id')
  @ApiOperation({ summary: 'Get a feeding log' })
  async findOne(@Request() req: any, @Param('id') id: string) {
    return this.feedLogsService.findOne(id, req.user.id);
  }

  @Patch('feed-logs/:id')
  @ApiOperation({ summary: 'Update a feeding log' })
  async update(@Request() req: any, @Param('id') id: string, @Body() dto: UpdateFeedLogDto) {
    return this.feedLogsService.update(id, req.user.id, dto);
  }

  @Delete('feed-logs/:id')
  @ApiOperation({ summary: 'Delete a feeding log' })
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.feedLogsService.delete(id, req.user.id);
  }
}
