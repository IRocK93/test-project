import { IsEnum, IsString, IsOptional, IsArray, IsDateString, ArrayMaxSize, MaxLength, ValidateIf } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum StageType {
  IDEA = 'IDEA',
  CONCEIVED = 'CONCEIVED',
  BORN = 'BORN',
}

export enum Gender {
  MONIOUS = 'MONIOUS',
  MONIESE = 'MONIESE',
  MO = 'MO',
}

export class CreateBabyMonDto {
  @ApiProperty({ example: 'Emma' })
  @IsString()
  name: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  middleName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({ enum: StageType })
  @IsEnum(StageType)
  stageStartType: StageType;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'CONCEIVED')
  @IsDateString()
  conceptionDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'CONCEIVED')
  @IsDateString()
  lmpDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'BORN')
  @IsDateString()
  birthDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'IDEA')
  @IsDateString()
  ideaDate?: string;

  @ApiProperty({ enum: Gender })
  @IsEnum(Gender)
  gender: Gender;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(3)
  traits?: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  specialMove?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  biologicalMother?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  biologicalFather?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bloodGroup?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  eyeColor?: string;
}

export class UpdateBabyMonDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  middleName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({ required: false, enum: Gender })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  traits?: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  specialMove?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  biologicalMother?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  biologicalFather?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bloodGroup?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  eyeColor?: string;
}
