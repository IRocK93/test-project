import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
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

  constructor(private prisma: PrismaService) {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    const config = process.env.FIREBASE_CONFIG;
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
    return { message: 'Device registered successfully' };
  }

  async unregisterDevice(deviceToken: string) {
    await this.prisma.device.delete({
      where: { deviceToken },
    }).catch(() => {});

    return { message: 'Device unregistered' };
  }

  async sendPushNotification(userId: string, payload: PushNotificationPayload) {
    const devices = await this.prisma.device.findMany({
      where: { userId },
    });

    if (devices.length === 0) {
      this.logger.warn(`No devices found for user ${userId}`);
      return { message: 'No devices found' };
    }

    if (!this.initialized) {
      this.logger.warn(`Push notification not sent (disabled): ${payload.title}`);
      return { message: 'Push notifications not configured' };
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

  async notifyMilestoneAdded(babymonId: string, milestoneTitle: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: 'New Milestone Added!',
        body: `${babyMon.name}: ${milestoneTitle}`,
        data: { babymonId, type: 'milestone' },
      });
    }
  }

  async notifyBadgeUnlocked(babymonId: string, badgeName: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: 'Badge Unlocked!',
        body: `${babyMon.name} earned: ${badgeName}`,
        data: { babymonId, type: 'badge' },
      });
    }
  }

  async notifyGrowthRecorded(babymonId: string, type: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: 'Growth Recorded',
        body: `${type} measurement added for ${babyMon.name}`,
        data: { babymonId, type: 'growth' },
      });
    }
  }

  async notifyProposalReceived(babymonId: string, proposalType: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (babyMon?.ownerUserId) {
      await this.sendPushNotification(babyMon.ownerUserId, {
        title: 'New Proposal',
        body: `A new ${proposalType} proposal needs your attention`,
        data: { babymonId, type: 'proposal' },
      });
    }
  }
}
