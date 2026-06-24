import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { MedicalTeamService } from './medical-team.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateMedicalTeamMemberDto } from './dto/medical-team.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('medical-team')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class MedicalTeamController {
  constructor(private svc: MedicalTeamService) {}

  @Get('baby-mons/:babyMonId/medical-team')
  async findAll(@Param('babyMonId') id: string, @Query() pagination?: PaginationDto) { return this.svc.findAll(id, pagination?.skip, pagination?.take); }

  @Post('baby-mons/:babyMonId/medical-team')
  async create(@Param('babyMonId') id: string, @Request() r: any, @Body() dto: CreateMedicalTeamMemberDto) { return this.svc.create(id, r.user.id, dto); }

  @Delete('baby-mons/:babyMonId/medical-team/:mId')
  async remove(@Param('mId') mId: string) { return this.svc.remove(mId); }
}