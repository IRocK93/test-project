import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { LinkedAccountsService } from './linked-accounts.service';
import { InvitePartnerDto, RespondToInvitationDto, LinkBabyMonDto } from './dto/linked-accounts.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('linked-accounts')
@Controller('linked-accounts')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class LinkedAccountsController {
  constructor(private linkedAccountsService: LinkedAccountsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all linked accounts' })
  async getLinkedAccounts(@CurrentUser('id') userId: string) {
    return this.linkedAccountsService.getLinkedAccounts(userId);
  }

  @Get('invitations')
  @ApiOperation({ summary: 'Get pending invitations' })
  async getPendingInvitations(@CurrentUser('id') userId: string) {
    return this.linkedAccountsService.getPendingInvitations(userId);
  }

  @Post('invite')
  @ApiOperation({ summary: 'Invite a partner by email' })
  async invitePartner(
    @CurrentUser('id') userId: string,
    @Body() dto: InvitePartnerDto,
  ) {
    return this.linkedAccountsService.invitePartner(userId, dto.partnerEmail);
  }

  @Post('invitations/:id/respond')
  @ApiOperation({ summary: 'Respond to an invitation' })
  async respondToInvitation(
    @CurrentUser('id') userId: string,
    @Param('id') invitationId: string,
    @Body() dto: RespondToInvitationDto,
  ) {
    return this.linkedAccountsService.respondToInvitation(userId, invitationId, dto.accept);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remove a linked account' })
  async removeLink(
    @CurrentUser('id') userId: string,
    @Param('id') linkId: string,
  ) {
    return this.linkedAccountsService.removeLink(userId, linkId);
  }

  @Post('baby-mon')
  @ApiOperation({ summary: 'Link a BabyMon to current user (co-parent access)' })
  async linkBabyMon(
    @CurrentUser('id') userId: string,
    @Body() dto: LinkBabyMonDto,
  ) {
    return this.linkedAccountsService.linkBabyMonToUser(userId, dto.babyMonId, dto.access);
  }
}

@ApiTags('partners')
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class BabyMonPartnersController {
  constructor(private linkedAccountsService: LinkedAccountsService) {}

  @Get('baby-mons/:babyMonId/partners')
  @ApiOperation({ summary: 'Get partners for a BabyMon' })
  async getPartners(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
  ) {
    return this.linkedAccountsService.getPartnersForBabyMon(userId, babyMonId);
  }
}
