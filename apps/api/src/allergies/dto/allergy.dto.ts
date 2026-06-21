import { IsString, IsOptional, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAllergyDto {
  @ApiProperty({ example: 'Peanut', description: 'Allergy name' })
  @IsString()
  name: string;

  @ApiProperty({ example: 'Mild', description: 'Severity level' })
  @IsString()
  severity: string;

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
