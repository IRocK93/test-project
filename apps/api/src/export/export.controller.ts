import { Controller, Get, Param, Query, UseGuards, Request, Res } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ExportService } from './export.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('export')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId')
export class ExportController {
  constructor(private exportService: ExportService) {}

  @Get('export')
  @ApiOperation({ summary: 'Export BabyMon data as JSON or CSV' })
  async export(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query('format') format: string = 'json',
  ) {
    if (format === 'csv') {
      const csv = await this.exportService.exportCsv(babyMonId, req.user.id);
      return csv;
    }
    return this.exportService.exportJson(babyMonId, req.user.id);
  }
}
