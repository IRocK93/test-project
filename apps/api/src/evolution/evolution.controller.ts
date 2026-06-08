import { Controller, Get, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { EvolutionService } from './evolution.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('evolution')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId')
export class EvolutionController {
  constructor(private evolutionService: EvolutionService) {}

  @Get('evolution')
  @ApiOperation({ summary: 'Get evolution data' })
  async getEvolution(@Request() req: any, @Param('babyMonId') babyMonId: string) {
    return this.evolutionService.getEvolution(babyMonId, req.user.id);
  }

  @Get('evolution/summary')
  @ApiOperation({ summary: 'Get evolution summary' })
  async getSummary(@Request() req: any, @Param('babyMonId') babyMonId: string) {
    return this.evolutionService.getEvolutionSummary(babyMonId, req.user.id);
  }
}
