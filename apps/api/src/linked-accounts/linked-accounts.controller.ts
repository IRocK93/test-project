import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { LinkedAccountsService } from './linked-accounts.service';
import { InvitePartnerDto, RespondToInvitationDto, LinkBabyMonDto } from './dto/linked-accounts.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

/**
 * User-level co-parent routes (retained for admin / non-mobile callers and
 * the existing linkBabyMon endpoint).
 */
@ApiTags('linked-accounts')
@Controller('linked-accounts')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class LinkedAccountsController {
  constructor(private linkedAccountsService: LinkedAccountsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all linked accounts for current user' })
  async getLinkedAccounts(@CurrentUser('id') userId: string) {
    return this.linkedAccountsService.getLinkedAccounts(userId);
  }

  @Get('invitations')
  @ApiOperation({ summary: 'Get pending invitations for current user' })
  async getPendingInvitations(@CurrentUser('id') userId: string) {
    return this.linkedAccountsService.getPendingInvitations(userId);
  }

  @Post('baby-mons')
  @ApiOperation({ summary: 'Link a BabyMon to current user (co-parent access)' })
  async linkBabyMon(
    @CurrentUser('id') userId: string,
    @Body() dto: LinkBabyMonDto,
  ) {
    return this.linkedAccountsService.linkBabyMonToUser(userId, dto.babyMonId, dto.access);
  }
}

/**
 * BabyMon-nested partner routes — the surface the mobile client calls.
 *
 * "partners" is scoped to a specific BabyMon because that's how the mobile
 * UI models it: you invite a partner FOR a baby, and you manage the roster
 * baby by baby.
 *
 * NOTE: DELETE uses the nested path `/baby-mons/:babyMonId/partners/:partnerId`
 * rather than a flat `/baby-mons/:id` to avoid colliding with the BabyMon
 * CRUD DELETE route in BabyMonController.
 */
@ApiTags('partners')
@Controller('baby-mons')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class BabyMonPartnersController {
  constructor(private linkedAccountsService: LinkedAccountsService) {}

  @Get(':babyMonId/partners')
  @ApiOperation({ summary: 'Get partners for a BabyMon (linked + pending)' })
  async getPartners(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
  ) {
    return this.linkedAccountsService.getPartnersForBabyMon(userId, babyMonId);
  }

  @Post(':babyMonId/partners/invite')
  @ApiOperation({ summary: 'Invite a registered user to co-parent a BabyMon' })
  async invitePartner(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() dto: InvitePartnerDto,
  ) {
    return this.linkedAccountsService.invitePartner(userId, babyMonId, dto.email, dto.role);
  }

  @Patch(':partnerId/respond')
  @ApiOperation({ summary: 'Respond to a partner invitation (ACCEPTED / DECLINED)' })
  async respondToInvitation(
    @CurrentUser('id') userId: string,
    @Param('partnerId') partnerId: string,
    @Body() dto: RespondToInvitationDto,
  ) {
    return this.linkedAccountsService.respondToInvitation(userId, partnerId, dto.status);
  }

  @Delete(':babyMonId/partners/:partnerId')
  @ApiOperation({ summary: 'Remove a partner or cancel an invitation for a BabyMon' })
  async removePartner(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') _babyMonId: string,
    @Param('partnerId') partnerId: string,
  ) {
    return this.linkedAccountsService.removeLink(userId, partnerId);
  }
}
