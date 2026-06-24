import { ApiProperty } from '@nestjs/swagger';

/** Response DTO for BabyMon — prevents accidental exposure of internal fields. */
export class BabyMonResponseDto {
  @ApiProperty() id: string;
  @ApiProperty() name: string;
  @ApiProperty({ required: false }) middleName?: string;
  @ApiProperty({ required: false }) lastName?: string;
  @ApiProperty({ enum: ['PLAN', 'INCUBATING', 'BORN'] }) stageStartType: string;
  @ApiProperty({ required: false }) conceptionDate?: Date;
  @ApiProperty({ required: false }) birthDate?: Date;
  @ApiProperty({ enum: ['MONIOUS', 'MONIESE', 'MO'] }) gender: string;
  @ApiProperty({ type: [String], required: false }) traits?: string[];
  @ApiProperty({ required: false }) specialMove?: string;
  @ApiProperty({ required: false }) biologicalMother?: string;
  @ApiProperty({ required: false }) biologicalFather?: string;
  @ApiProperty({ required: false }) bloodGroup?: string;
  @ApiProperty({ required: false }) eyeColor?: string;
  @ApiProperty() currentXp: number;
  @ApiProperty() currentLevel: number;
  @ApiProperty() ownerUserId: string;
  @ApiProperty() isOwner: boolean;
  @ApiProperty() createdAt: Date;
  @ApiProperty() updatedAt: Date;
}
