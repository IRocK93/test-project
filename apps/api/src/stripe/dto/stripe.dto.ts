import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCheckoutSessionDto {
  @ApiProperty({ example: 'price_xxx', description: 'Stripe price ID for the desired tier' })
  @IsString()
  priceId: string;
}
