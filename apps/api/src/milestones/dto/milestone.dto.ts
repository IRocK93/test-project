import { IsString, IsOptional, IsArray, IsDateString, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateMilestoneDto {
  @ApiProperty({ example: 'First smile' })
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

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  isCustom?: boolean;
}

export class UpdateMilestoneDto {
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
