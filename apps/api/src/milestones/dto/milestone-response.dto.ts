import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * Safe response DTO — excludes deletedAt and internal sync fields from API responses.
 */
export class MilestoneResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  babymonId: string;

  @ApiProperty()
  authorUserId: string;

  @ApiProperty()
  title: string;

  @ApiPropertyOptional()
  notes?: string;

  @ApiProperty()
  happenedAt: Date;

  @ApiProperty({ type: [String] })
  localMediaRefs: string[];

  @ApiProperty()
  isCustom: boolean;

  @ApiProperty()
  xpAwarded: number;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
