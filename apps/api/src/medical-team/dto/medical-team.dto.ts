import { IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMedicalTeamMemberDto {
  @ApiProperty({ example: 'Dr. Smith', description: 'Provider name' })
  @IsString()
  name: string;

  @ApiProperty({ example: 'Pediatrician', description: 'Medical specialty' })
  @IsString()
  specialty: string;

  @ApiPropertyOptional({ example: 'Children\'s Hospital', description: 'Facility or practice name' })
  @IsOptional()
  @IsString()
  facility?: string;

  @ApiPropertyOptional({ example: '+1-555-1234', description: 'Contact phone number' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: 'dr.smith@hospital.com', description: 'Contact email' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: 'Prefers morning appointments', description: 'Additional notes' })
  @IsOptional()
  @IsString()
  notes?: string;
}
