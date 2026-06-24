import { IsString, IsOptional, IsArray, IsDateString } from 'class-validator';
import { ApiProperty, PartialType } from '@nestjs/swagger';

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

export class UpdateMilestoneDto extends PartialType(CreateMilestoneDto) {}
