import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { getNotificationStrings } from '../common/localized-strings';
import * as admin from 'firebase-admin';

export interface PushNotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private initialized = false;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    const config = this.configService.get('firebase.configJson') as string | undefined;
    if (config) {
      try {
        const serviceAccount = JSON.parse(config);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        this.initialized = true;
        this.logger.log('Firebase Admin initialized');
      } catch (error) {
        this.logger.error('Failed to initialize Firebase:', error.message);
      }
    } else {
      this.logger.warn('FIREBASE_CONFIG not set - push notifications disabled');
    }
  }

  async registerDevice(userId: string, deviceToken: string, platform: 'ios' | 'android' | 'web') {
    // Check if device already exists
    const existing = await this.prisma.device.findUnique({
      where: { deviceToken },
    });

    if (existing) {
      // Update existing device
      await this.prisma.device.update({
        where: { deviceToken },
        data: {
          userId,
          platform,
          lastActiveAt: new Date(),
        },
      });
    } else {
      // Create new device
      await this.prisma.device.create({
        data: {
          userId,
          deviceToken,
          platform,
        },
      });
    }

    this.logger.log(`Device registered for user ${userId}: ${platform}`);
    return { success: true };
  }

  async unregisterDevice(deviceToken: string) {
    await this.prisma.device.delete({
      where: { deviceToken },
    }).catch((err) => this.logger.warn({ err }, 'Device unregister failed (non-critical)'));

    return { success: true };
  }

  async sendPushNotification(userId: string, payload: PushNotificationPayload) {
    const devices = await this.prisma.device.findMany({
      where: { userId },
    });

    if (devices.length === 0) {
      this.logger.warn(`No devices found for user ${userId}`);
      return { sent: 0, failed: 0 };
    }

    if (!this.initialized) {
      this.logger.warn(`Push notification not sent (disabled): ${payload.title}`);
      return { sent: 0, failed: 0 };
    }

    const results = await Promise.allSettled(
      devices.map(device =>
        admin.messaging().send({
          token: device.deviceToken,
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: payload.data,
          android: {
            priority: 'high' as const,
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
              },
            },
          },
        })
      )
    );

    const successful = results.filter(r => r.status === 'fulfilled').length;
    this.logger.log(`Push notification sent to ${successful}/${devices.length} devices`);

    return { sent: successful, failed: devices.length - successful };
  }

  async notifyMilestoneAdded(babymonId: string, milestoneTitle: string, locale?: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      const strings = getNotificationStrings(locale || 'en');
      const ns = strings.milestoneAdded;
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: ns.title,
        body: ns.body(babyMon.name, milestoneTitle),
        data: { babymonId, type: 'milestone' },
      });
    }
  }

  async notifyBadgeUnlocked(babymonId: string, badgeName: string, locale?: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      const strings = getNotificationStrings(locale || 'en');
      const ns = strings.badgeUnlocked;
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: ns.title,
        body: ns.body(babyMon.name, badgeName),
        data: { babymonId, type: 'badge' },
      });
    }
  }

  async notifyGrowthRecorded(babymonId: string, type: string, locale?: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      const strings = getNotificationStrings(locale || 'en');
      const ns = strings.growthRecorded;
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: ns.title,
        body: ns.body(babyMon.name, type),
        data: { babymonId, type: 'growth' },
      });
    }
  }

  async notifyProposalReceived(babymonId: string, proposalType: string, locale?: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      const strings = getNotificationStrings(locale || 'en');
      const ns = strings.proposalReceived;
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: ns.title,
        body: ns.body(proposalType),
        data: { babymonId, type: 'proposal' },
      });
    }
  }

  async notifyPaymentFailed(userId: string, attemptCount: number, locale?: string) {
    const strings = getNotificationStrings(locale || 'en');
    const ns = strings.paymentFailed;
    await this.sendPushNotification(userId, {
      title: ns.title,
      body: attemptCount >= 3 ? ns.bodyMultiple : ns.bodySingle,
      data: { type: 'payment_failed', attemptCount: attemptCount.toString() },
    });
  }
}
