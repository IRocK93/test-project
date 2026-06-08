import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Post('register-device')
  @ApiOperation({ summary: 'Register device for push notifications' })
  async registerDevice(
    @CurrentUser('id') userId: string,
    @Body() body: { deviceToken: string; platform: 'ios' | 'android' | 'web' },
  ) {
    return this.notificationsService.registerDevice(userId, body.deviceToken, body.platform);
  }

  @Post('test')
  @ApiOperation({ summary: 'Send test push notification' })
  async sendTest(
    @CurrentUser('id') userId: string,
    @Body() body: { title: string; body: string },
  ) {
    return this.notificationsService.sendPushNotification(userId, body);
  }
}
