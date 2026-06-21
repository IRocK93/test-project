import { IsString, IsIn } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({ example: 'fcm-token-abc123', description: 'FCM device token' })
  @IsString()
  deviceToken: string;

  @ApiProperty({ example: 'android', description: 'Device platform', enum: ['ios', 'android', 'web'] })
  @IsString()
  @IsIn(['ios', 'android', 'web'])
  platform: 'ios' | 'android' | 'web';
}

export class SendTestNotificationDto {
  @ApiProperty({ example: 'Milestone achieved!', description: 'Notification title' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'Your baby just reached a new milestone!', description: 'Notification body' })
  @IsString()
  body: string;
}
