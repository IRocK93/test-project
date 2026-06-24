import { IsEnum, IsString, IsOptional, IsArray, IsDateString, ArrayMaxSize, ValidateIf } from 'class-validator';
import { ApiProperty, PartialType } from '@nestjs/swagger';

export enum StageType {
  IDEA = 'PLAN',
  CONCEIVED = 'INCUBATING',
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
  @ValidateIf(o => o.stageStartType === 'INCUBATING')
  @IsDateString()
  conceptionDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'INCUBATING')
  @IsDateString()
  lmpDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'BORN')
  @IsDateString()
  birthDate?: string;

  @ApiProperty({ required: false })
  @ValidateIf(o => o.stageStartType === 'PLAN')
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

export class UpdateBabyMonDto extends PartialType(CreateBabyMonDto) {}

