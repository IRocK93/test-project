import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RegisterDeviceDto, SendTestNotificationDto } from './dto/notification.dto';

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
    @Body() dto: RegisterDeviceDto,
  ) {
    return this.notificationsService.registerDevice(userId, dto.deviceToken, dto.platform);
  }

  @Post('test')
  @ApiOperation({ summary: 'Send test push notification' })
  async sendTest(
    @CurrentUser('id') userId: string,
    @Body() dto: SendTestNotificationDto,
  ) {
    return this.notificationsService.sendPushNotification(userId, dto);
  }
}
