import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MedicalTeamService } from './medical-team.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('medical-team')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class MedicalTeamController {
  constructor(private svc: MedicalTeamService) {}

  @Get('baby-mons/:babyMonId/medical-team')
  async findAll(@Param('babyMonId') id: string) { return this.svc.findAll(id); }

  @Post('baby-mons/:babyMonId/medical-team')
  async create(@Param('babyMonId') id: string, @Request() r: any, @Body() b: any) { return this.svc.create(id, r.user.id, b); }

  @Delete('baby-mons/:babyMonId/medical-team/:mId')
  async remove(@Param('mId') mId: string) { return this.svc.remove(mId); }
}