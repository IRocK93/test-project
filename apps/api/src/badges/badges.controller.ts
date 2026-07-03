import { Controller, Get, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { BadgesService } from './badges.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('badges')
@Controller('badges')
export class BadgesController {
  constructor(private badgesService: BadgesService) {}

  @Get('definitions')
  @ApiOperation({ summary: 'Get all badge definitions with icon URLs' })
  async getDefinitions(@Request() req: any) {
    return this.badgesService.getBadgeDefinitions(req.resolvedLocale);
  }
}

@ApiTags('baby-mons')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId')
export class BabyMonBadgesController {
  constructor(private badgesService: BadgesService) {}

  @Get('badges')
  @ApiOperation({ summary: 'Get all badges' })
  async findAll(@Request() req: any, @Param('babyMonId') babyMonId: string) {
    return this.badgesService.findAll(babyMonId, req.user.id);
  }
}
