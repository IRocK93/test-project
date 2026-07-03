import { Controller, Get, Post, Patch, Param, Query, UseGuards, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UpdateUserStatusDto, UpdateUserRoleDto } from './dto/admin.dto';
import {
  UpsertAdviceCardDto,
  UpsertRoutineTemplateDto,
  UpsertMilestoneExpectationDto,
  UpsertStageContentDto,
  ListContentQueryDto,
} from './dto/content-admin.dto';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Roles('ADMIN')
  @Get('users')
  @ApiOperation({ summary: 'Get all users (admin only)' })
  async getUsers(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('role') role?: string,
  ) {
    return this.adminService.getAllUsers(page || 1, limit || 20, role);
  }

  @Roles('ADMIN')
  @Get('users/:id')
  @ApiOperation({ summary: 'Get user by ID (admin only)' })
  async getUser(@Param('id') id: string) {
    return this.adminService.getUserById(id);
  }

  @Roles('ADMIN')
  @Patch('users/:id/status')
  @ApiOperation({ summary: 'Update user active status (admin only)' })
  async updateUserStatus(
    @Param('id') id: string,
    @Body() dto: UpdateUserStatusDto,
  ) {
    return this.adminService.updateUserStatus(id, dto.isActive);
  }

  @Roles('ADMIN')
  @Patch('users/:id/role')
  @ApiOperation({ summary: 'Update user role (admin only)' })
  async updateUserRole(
    @Param('id') id: string,
    @Body() dto: UpdateUserRoleDto,
  ) {
    return this.adminService.updateUserRole(id, dto.role);
  }

  @Roles('ADMIN')
  @Get('audit-logs')
  @ApiOperation({ summary: 'Get audit logs (admin only)' })
  async getAuditLogs(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('userId') userId?: string,
    @Query('babymonId') babymonId?: string,
  ) {
    return this.adminService.getAuditLogs(page || 1, limit || 50, userId, babymonId);
  }

  @Roles('ADMIN')
  @Get('stats')
  @ApiOperation({ summary: 'Get system statistics (admin only)' })
  async getStats() {
    return this.adminService.getSystemStats();
  }

  // ─── Content Management ───

  @Roles('ADMIN')
  @Post('content/advice-cards')
  @ApiOperation({ summary: 'Create or update an expert advice card (admin only)' })
  async upsertAdviceCard(@Body() dto: UpsertAdviceCardDto) {
    return this.adminService.upsertAdviceCard(dto);
  }

  @Roles('ADMIN')
  @Post('content/routine-templates')
  @ApiOperation({ summary: 'Create or update a routine template (admin only)' })
  async upsertRoutineTemplate(@Body() dto: UpsertRoutineTemplateDto) {
    return this.adminService.upsertRoutineTemplate(dto);
  }

  @Roles('ADMIN')
  @Post('content/milestone-expectations')
  @ApiOperation({ summary: 'Create or update a milestone expectation (admin only)' })
  async upsertMilestoneExpectation(@Body() dto: UpsertMilestoneExpectationDto) {
    return this.adminService.upsertMilestoneExpectation(dto);
  }

  @Roles('ADMIN')
  @Post('content/stage-content')
  @ApiOperation({ summary: 'Create or update stage content (admin only)' })
  async upsertStageContent(@Body() dto: UpsertStageContentDto) {
    return this.adminService.upsertStageContent(dto);
  }

  @Roles('ADMIN')
  @Get('content')
  @ApiOperation({ summary: 'List content by type, stageKey, and locale (admin only)' })
  async listContent(@Query() query: ListContentQueryDto) {
    return this.adminService.listContent(
      query.type,
      query.stageKey,
      query.locale,
      query.page,
      query.limit,
    );
  }
}
