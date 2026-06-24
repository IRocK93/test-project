import { Controller, Get, Post, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JournalService } from './journal.service';
import { JournalProposalsService } from './journal-proposals.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('journal')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId')
export class JournalController {
  constructor(
    private journalService: JournalService,
    private proposalsService: JournalProposalsService,
  ) {}

  @Get('journal')
  @ApiOperation({ summary: 'Get journey journal' })
  @ApiQuery({ name: 'type', required: false })
  async getJournal(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Query('type') type?: string,
    @Query() pagination?: PaginationDto,
  ): Promise<any> {
    return this.journalService.getJournal(babyMonId, req.user.id, type, pagination?.skip, pagination?.take);
  }

  @Get('journal/proposals')
  @ApiOperation({ summary: 'Get pending proposals' })
  async getProposals(@Request() req: any, @Param('babyMonId') babyMonId: string): Promise<any> {
    return this.proposalsService.getPendingProposals(babyMonId);
  }

  @Post('journal/proposals/:proposalId/approve')
  @ApiOperation({ summary: 'Approve a proposal' })
  async approveProposal(@Request() req: any, @Param('proposalId') proposalId: string): Promise<any> {
    return this.proposalsService.approveProposal(proposalId, req.user.id);
  }

  @Post('journal/proposals/:proposalId/reject')
  @ApiOperation({ summary: 'Reject a proposal' })
  async rejectProposal(@Request() req: any, @Param('proposalId') proposalId: string): Promise<any> {
    return this.proposalsService.rejectProposal(proposalId, req.user.id);
  }
}
