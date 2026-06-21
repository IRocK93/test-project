import { IsString, IsEmail, IsOptional, IsEnum, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export const PARTNER_ROLES = ['PARENT', 'GUARDIAN', 'GRANDPARENT'] as const;
export type PartnerRole = (typeof PARTNER_ROLES)[number];

export const INVITATION_STATUSES = ['ACCEPTED', 'DECLINED'] as const;
export type InvitationStatus = (typeof INVITATION_STATUSES)[number];

export class InvitePartnerDto {
  @ApiProperty({ example: 'partner@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ enum: PARTNER_ROLES, default: 'PARENT', required: false })
  @IsOptional()
  @IsEnum(PARTNER_ROLES)
  role?: PartnerRole;
}

export class RespondToInvitationDto {
  @ApiProperty({ enum: INVITATION_STATUSES, example: 'ACCEPTED' })
  @IsIn(INVITATION_STATUSES)
  status: InvitationStatus;
}

export class LinkBabyMonDto {
  @ApiProperty({ example: 'uuid' })
  @IsString()
  babyMonId: string;

  @ApiProperty({ enum: ['READ', 'EDIT', 'ADMIN'], required: false })
  @IsOptional()
  @IsEnum(['READ', 'EDIT', 'ADMIN'])
  access?: 'READ' | 'EDIT' | 'ADMIN';
}
