import { IsString, IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class DevOverrideTrialDto {
  @ApiProperty({ description: 'User ID to override trial for', example: 'uuid' })
  @IsString()
  userId: string;

  @ApiProperty({ description: 'Number of trial days to grant', example: 30, minimum: 0, maximum: 365 })
  @IsInt()
  @Min(0)
  @Max(365)
  @Type(() => Number)
  days: number;
}

export class PromoCodeDto {
  @ApiProperty({ description: 'Promo code to validate or redeem', example: 'LAUNCH-A3F7-K9M2' })
  @IsString()
  code: string;
}
