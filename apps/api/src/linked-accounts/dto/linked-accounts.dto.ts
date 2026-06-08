import { IsString, IsEmail, IsOptional, IsBoolean, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class InvitePartnerDto {
  @ApiProperty({ example: 'partner@example.com' })
  @IsEmail()
  partnerEmail: string;
}

export class RespondToInvitationDto {
  @ApiProperty({ example: true })
  @IsBoolean()
  accept: boolean;
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
