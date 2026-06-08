import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AllergiesService } from './allergies.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@ApiTags('allergies')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class AllergiesController {
  constructor(private allergiesService: AllergiesService) {}

  @Get('baby-mons/:babyMonId/allergies')
  @ApiOperation({ summary: 'Get all allergies with events for a BabyMon' })
  async findAll(@Param('babyMonId') babyMonId: string, @Request() req: any) {
    return this.allergiesService.findAll(babyMonId, req.user.id);
  }

  @Post('baby-mons/:babyMonId/allergies')
  @ApiOperation({ summary: 'Add a new allergy (or reactivate + record event if exists)' })
  async create(@Param('babyMonId') babyMonId: string, @Request() req: any, @Body() body: any) {
    return this.allergiesService.create(babyMonId, req.user.id, body);
  }

  @Post('baby-mons/:babyMonId/allergies/:allergyId/events')
  @ApiOperation({ summary: 'Record a new allergy event for an existing allergy' })
  async addEvent(@Param('babyMonId') babyMonId: string, @Param('allergyId') allergyId: string, @Request() req: any, @Body() body: any) {
    return this.allergiesService.addEvent(babyMonId, req.user.id, allergyId, body);
  }

  @Delete('baby-mons/:babyMonId/allergies/events/:eventId')
  @ApiOperation({ summary: 'Delete a single allergy event' })
  async deleteEvent(@Param('babyMonId') babyMonId: string, @Param('eventId') eventId: string) {
    return this.allergiesService.deleteEvent(babyMonId, eventId);
  }

  @Post('baby-mons/:babyMonId/allergies/:allergyId/cure')
  @ApiOperation({ summary: 'Mark an allergy as cured' })
  async cure(@Param('babyMonId') babyMonId: string, @Param('allergyId') allergyId: string) {
    return this.allergiesService.cure(babyMonId, allergyId);
  }

  @Post('baby-mons/:babyMonId/allergies/:allergyId/reactivate')
  @ApiOperation({ summary: 'Reactivate a cured allergy' })
  async reactivate(@Param('babyMonId') babyMonId: string, @Param('allergyId') allergyId: string) {
    return this.allergiesService.reactivate(babyMonId, allergyId);
  }

  @Delete('baby-mons/:babyMonId/allergies/:allergyId')
  @ApiOperation({ summary: 'Permanently delete an allergy and all its events' })
  async remove(@Param('babyMonId') babyMonId: string, @Param('allergyId') allergyId: string) {
    return this.allergiesService.remove(babyMonId, allergyId);
  }

  @Post('baby-mons/:babyMonId/allergies/clear-all')
  @ApiOperation({ summary: 'Delete all allergies and events for a BabyMon' })
  async clearAll(@Param('babyMonId') babyMonId: string) {
    return this.allergiesService.clearAll(babyMonId);
  }

  @Post('baby-mons/:babyMonId/allergies/events/clear-all')
  @ApiOperation({ summary: 'Delete all allergy events for a BabyMon (keep allergy profiles)' })
  async clearAllEvents(@Param('babyMonId') babyMonId: string) {
    return this.allergiesService.clearAllEvents(babyMonId);
  }
}