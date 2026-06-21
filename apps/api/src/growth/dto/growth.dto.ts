import { IsString, IsOptional, IsNumber, IsDateString, IsIn } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { GrowthType } from '@prisma/client';

export class CreateGrowthRecordDto {
  @ApiProperty({ example: 'WEIGHT', description: 'Growth metric type', enum: ['HEIGHT', 'WEIGHT', 'HEAD_CIRCUMFERENCE'] })
  @IsString()
  @IsIn(['HEIGHT', 'WEIGHT', 'HEAD_CIRCUMFERENCE'])
  type: GrowthType;

  @ApiProperty({ example: 7.2, description: 'Measurement value' })
  @IsNumber()
  value: number;

  @ApiProperty({ example: 'kg', description: 'Unit of measurement' })
  @IsString()
  unit: string;

  @ApiProperty({ example: '2026-06-18T10:00:00Z', description: 'When the measurement was taken' })
  @IsDateString()
  measuredAt: string;

  @ApiPropertyOptional({ example: 'Measured at pediatrician visit', description: 'Additional notes' })
  @IsOptional()
  @IsString()
  notes?: string;
}
