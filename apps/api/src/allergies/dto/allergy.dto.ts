import { IsString, IsOptional, IsDateString, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum AllergySeverity {
  MILD = 'mild',
  MODERATE = 'moderate',
  SEVERE = 'severe',
  LIFE_THREATENING = 'lifeThreatening',
}

export class CreateAllergyDto {
  @ApiProperty({ example: 'Peanut', description: 'Allergy name' })
  @IsString()
  name: string;

  @ApiProperty({ enum: AllergySeverity, example: AllergySeverity.MILD, description: 'Severity level (API key)' })
  @IsEnum(AllergySeverity)
  severity: AllergySeverity;

  @ApiPropertyOptional({ example: 'Peanuts, tree nuts', description: 'Comma-separated triggers' })
  @IsOptional()
  @IsString()
  triggers?: string;

  @ApiPropertyOptional({ example: 'Hives, swelling', description: 'Reaction symptoms' })
  @IsOptional()
  @IsString()
  symptoms?: string;

  @ApiPropertyOptional({ example: 'EpiPen', description: 'Treatment plan' })
  @IsOptional()
  @IsString()
  treatment?: string;
}

export class CreateAllergyEventDto {
  @ApiPropertyOptional({ example: 'Reaction at daycare', description: 'Event notes' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ example: '2026-06-18T14:00:00Z', description: 'When the event occurred' })
  @IsOptional()
  @IsDateString()
  happenedAt?: string;
}
