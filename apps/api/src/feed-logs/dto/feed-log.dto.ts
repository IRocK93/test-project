import { IsEnum, IsString, IsOptional, IsArray, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum FeedingType {
  BREASTMILK = 'BREASTMILK',
  FORMULA = 'FORMULA',
  SOLID = 'SOLID',
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

  @ApiProperty()
  @IsDateString()
  happenedAt: string;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  localMediaRefs?: string[];
}

export class UpdateFeedLogDto {
  @ApiProperty({ required: false, enum: FeedingType })
  @IsOptional()
  @IsEnum(FeedingType)
  type?: FeedingType;

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

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  localMediaRefs?: string[];
}
