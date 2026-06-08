import { IsEnum, IsString, IsOptional, IsArray, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum HealthCategory {
  VACCINATION = 'VACCINATION',
  VISIT = 'VISIT',
  OTHER = 'OTHER',
  WEIGHT = 'WEIGHT',
  HEIGHT = 'HEIGHT',
  HEAD_CIRCUMFERENCE = 'HEAD_CIRCUMFERENCE',
  TEMPERATURE = 'TEMPERATURE',
  HOSPITAL = 'HOSPITAL',
  CLINIC = 'CLINIC',
  INJURY = 'INJURY',
  BOWEL_MOVEMENT = 'BOWEL_MOVEMENT',
  MEDICAL_TEAM = 'MEDICAL_TEAM',
  ALLERGY = 'ALLERGY',
}

export class CreateHealthRecordDto {
  @ApiProperty({ enum: HealthCategory })
  @IsEnum(HealthCategory)
  category: HealthCategory;

  @ApiProperty({ example: 'First vaccine' })
  @IsString()
  title: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty()
  @IsDateString()
  happenedAt: string;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  localMediaRefs?: string[];
}

export class UpdateHealthRecordDto {
  @ApiProperty({ required: false, enum: HealthCategory })
  @IsOptional()
  @IsEnum(HealthCategory)
  category?: HealthCategory;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  happenedAt?: string;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  localMediaRefs?: string[];
}
