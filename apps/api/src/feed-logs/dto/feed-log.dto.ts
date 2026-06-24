import { IsEnum, IsString, IsOptional, IsArray, IsDateString } from 'class-validator';
import { ApiProperty, PartialType } from '@nestjs/swagger';

export enum FeedingType {
  BREASTMILK = 'BREASTMILK',
  FORMULA = 'FORMULA',
  SOLID = 'SOLID',
  SOLIDS = 'SOLIDS',
  BOTTLE = 'BOTTLE',
  SNACK = 'SNACK',
  WATER = 'WATER',
  OTHER = 'OTHER',
}

export class CreateFeedLogDto {
  @ApiProperty({ enum: FeedingType })
  @IsEnum(FeedingType)
  type: FeedingType;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  amount?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  happenedAt?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  loggedAt?: string;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  localMediaRefs?: string[];
}

export class UpdateFeedLogDto extends PartialType(CreateFeedLogDto) {}

