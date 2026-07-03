import {
  IsString,
  IsOptional,
  IsInt,
  IsBoolean,
  IsIn,
  IsArray,
  Min,
  Max,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ─── Expert Advice Card ───

export class UpsertAdviceCardDto {
  @ApiProperty({ example: 'born_week_0', description: 'Stage key' })
  @IsString()
  stageKey: string;

  @ApiProperty({
    example: 'GROWTH_HEALTH',
    description: 'Advice category',
    enum: ['GROWTH_HEALTH', 'DEVELOPMENT', 'NUTRITION_FEEDING', 'SLEEP', 'PLAY_ACTIVITIES', 'PARENT_WELLBEING'],
  })
  @IsIn(['GROWTH_HEALTH', 'DEVELOPMENT', 'NUTRITION_FEEDING', 'SLEEP', 'PLAY_ACTIVITIES', 'PARENT_WELLBEING'])
  category: string;

  @ApiPropertyOptional({ example: 50, description: 'Priority (higher = more important)' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  priority?: number;

  @ApiProperty({ example: 'Your Newborn: First Hours After Birth' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'What to expect in the golden hour...' })
  @IsString()
  summary: string;

  @ApiProperty({ example: 'The first hour after birth is called...' })
  @IsString()
  content: string;

  @ApiPropertyOptional({
    example: 'CLINICAL',
    description: 'Content source',
    enum: ['CLINICAL', 'DEVELOPMENT', 'EXPERT', 'PARENT_COMMUNITY', 'GENERAL'],
  })
  @IsOptional()
  @IsIn(['CLINICAL', 'DEVELOPMENT', 'EXPERT', 'PARENT_COMMUNITY', 'GENERAL'])
  source?: string;

  @ApiPropertyOptional({ example: ['newborn', 'sleep'], description: 'Tags' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiProperty({ example: 'he', description: 'Locale code' })
  @IsString()
  locale: string;
}

// ─── Routine Template ───

class ScheduleItemDto {
  @ApiProperty({ example: '6:30-7:00 AM' })
  @IsString()
  time: string;

  @ApiProperty({ example: 'Wake, feed' })
  @IsString()
  activity: string;

  @ApiPropertyOptional({ example: 30 })
  @IsOptional()
  @IsInt()
  durationMins?: number;
}

export class UpsertRoutineTemplateDto {
  @ApiProperty({ example: 'born_week_0' })
  @IsString()
  stageKey: string;

  @ApiProperty({ example: 'Newborn Rhythm (Weeks 0-4)' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ example: 'There is no rigid schedule...' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 45 })
  @IsOptional()
  @IsInt()
  wakeWindowMins?: number;

  @ApiPropertyOptional({ example: 6 })
  @IsOptional()
  @IsInt()
  napCount?: number;

  @ApiPropertyOptional({ example: 8 })
  @IsOptional()
  @IsInt()
  totalNapHours?: number;

  @ApiPropertyOptional({ example: 9 })
  @IsOptional()
  @IsInt()
  nightSleepHours?: number;

  @ApiPropertyOptional({ example: 'Every 2-3 hours' })
  @IsOptional()
  @IsString()
  feedFrequency?: string;

  @ApiPropertyOptional({ type: [ScheduleItemDto], description: 'Sample schedule items' })
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ScheduleItemDto)
  sampleSchedule?: ScheduleItemDto[];

  @ApiPropertyOptional({ example: ['Feed', 'Swaddle', 'White noise'], description: 'Bedtime ritual steps' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  bedtimeRitual?: string[];

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  flexible?: boolean;

  @ApiProperty({ example: 'he' })
  @IsString()
  locale: string;
}

// ─── Milestone Expectation ───

export class UpsertMilestoneExpectationDto {
  @ApiProperty({ example: 'born_week_0' })
  @IsString()
  stageKey: string;

  @ApiProperty({
    example: 'GROSS_MOTOR',
    enum: ['MOTOR', 'GROSS_MOTOR', 'FINE_MOTOR', 'COGNITIVE', 'LANGUAGE', 'LANGUAGE_COMMUNICATION', 'SOCIAL_EMOTIONAL', 'SELF_HELP'],
  })
  @IsIn(['MOTOR', 'GROSS_MOTOR', 'FINE_MOTOR', 'COGNITIVE', 'LANGUAGE', 'LANGUAGE_COMMUNICATION', 'SOCIAL_EMOTIONAL', 'SELF_HELP'])
  domain: string;

  @ApiProperty({ example: 'Lifts head briefly when on tummy' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'Your newborn can briefly lift their head...' })
  @IsString()
  description: string;

  @ApiPropertyOptional({
    example: 'EXPECTED',
    enum: ['EXPECTED', 'EMERGING', 'ADVANCED', 'RED_FLAG'],
  })
  @IsOptional()
  @IsIn(['EXPECTED', 'EMERGING', 'ADVANCED', 'RED_FLAG'])
  status?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  ageRangeMinDays?: number;

  @ApiPropertyOptional({ example: 14 })
  @IsOptional()
  @IsInt()
  ageRangeMaxDays?: number;

  @ApiPropertyOptional({ example: 'Talk to your pediatrician if...' })
  @IsOptional()
  @IsString()
  redFlagText?: string;

  @ApiPropertyOptional({ example: 'Place baby chest-to-chest...' })
  @IsOptional()
  @IsString()
  activityPrompt?: string;

  @ApiPropertyOptional({ example: 10 })
  @IsOptional()
  @IsInt()
  xpReward?: number;

  @ApiProperty({ example: 'he' })
  @IsString()
  locale: string;
}

// ─── Stage Content ───

export class UpsertStageContentDto {
  @ApiPropertyOptional({ example: '00000000-0000-0000-0000-000000000000', description: 'BabyMon ID for personalized content; omit for system default' })
  @IsOptional()
  @IsString()
  babymonId?: string;

  @ApiProperty({ example: 'born_week_0' })
  @IsString()
  stageKey: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  weekNumber?: number;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  monthNumber?: number;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isPostBirth?: boolean;

  @ApiProperty({ example: 'Your BabyMon is growing! Track feedings...' })
  @IsString()
  summaryText: string;

  @ApiProperty({ example: 'Keep tracking feedings, sleep, and milestones.' })
  @IsString()
  nurturingText: string;

  @ApiProperty({ example: "You're doing great!" })
  @IsString()
  encouragementText: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  xpThreshold?: number;

  @ApiProperty({ example: 'he' })
  @IsString()
  locale: string;
}

// ─── List / Query DTOs ───

export class ListContentQueryDto {
  @ApiPropertyOptional({ example: 'advice-card', description: 'Content type', enum: ['advice-card', 'routine-template', 'milestone-expectation', 'stage-content'] })
  @IsOptional()
  @IsIn(['advice-card', 'routine-template', 'milestone-expectation', 'stage-content'])
  type?: string;

  @ApiPropertyOptional({ example: 'born_week_0' })
  @IsOptional()
  @IsString()
  stageKey?: string;

  @ApiPropertyOptional({ example: 'he' })
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
