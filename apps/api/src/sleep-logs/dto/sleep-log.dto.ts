import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsDateString, IsNumber, Min, Max, IsEnum } from 'class-validator';
import { Transform } from 'class-transformer';

export enum SleepType {
  NAP = 'NAP',
  NIGHT = 'NIGHT',
}

export class CreateSleepLogDto {
  @ApiProperty({ enum: SleepType, example: SleepType.NAP })
  @IsEnum(SleepType)
  type: SleepType;

  @ApiProperty({ example: '2024-01-01T10:00:00.000Z' })
  @IsDateString()
  startTime: string;

  @ApiProperty({ example: '2024-01-01T11:30:00.000Z' })
  @IsDateString()
  endTime: string;

  @ApiPropertyOptional({ example: 'Baby slept well' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ example: 4, description: 'Sleep quality rating 1-5' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  quality?: number;
}

export class UpdateSleepLogDto {
  @ApiPropertyOptional({ enum: SleepType })
  @IsOptional()
  @IsEnum(SleepType)
  type?: SleepType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  startTime?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  endTime?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Sleep quality rating 1-5' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  quality?: number;
}