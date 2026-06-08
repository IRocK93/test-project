import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
  PutObjectCommandInput,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class S3Service {
  private readonly logger = new Logger(S3Service.name);
  private s3Client: S3Client | null = null;
  private bucketName: string;

  constructor() {
    const accessKeyId = process.env.AWS_ACCESS_KEY_ID;
    const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;
    const region = process.env.AWS_REGION || 'us-east-1';
    this.bucketName = process.env.S3_BUCKET_NAME || 'babymon-media';

    if (accessKeyId && secretAccessKey) {
      this.s3Client = new S3Client({
        region,
        credentials: {
          accessKeyId,
          secretAccessKey,
        },
      });
      this.logger.log('S3 client initialized');
    } else {
      this.logger.warn('AWS credentials not configured - S3 features disabled');
    }
  }

  isConfigured(): boolean {
    return !!this.s3Client;
  }

  async uploadFile(
    userId: string,
    babyMonId: string,
    fileName: string,
    fileBuffer: Buffer,
    contentType: string,
  ): Promise<string> {
    if (!this.s3Client) {
      throw new BadRequestException('S3 is not configured');
    }

    // Generate unique key
    const key = `users/${userId}/babymons/${babyMonId}/${Date.now()}-${fileName}`;

    const params: PutObjectCommandInput = {
      Bucket: this.bucketName,
      Key: key,
      Body: fileBuffer,
      ContentType: contentType,
      Metadata: {
        userId,
        babyMonId,
        originalName: fileName,
      },
    };

    await this.s3Client.send(new PutObjectCommand(params));

    // Return the S3 URL
    return `https://${this.bucketName}.s3.${process.env.AWS_REGION || 'us-east-1'}.amazonaws.com/${key}`;
  }

  async getSignedUploadUrl(
    userId: string,
    babyMonId: string,
    fileName: string,
    contentType: string,
  ): Promise<string> {
    if (!this.s3Client) {
      throw new BadRequestException('S3 is not configured');
    }

    const key = `users/${userId}/babymons/${babyMonId}/${Date.now()}-${fileName}`;

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: key,
      ContentType: contentType,
    });

    // URL valid for 5 minutes
    const signedUrl = await getSignedUrl(this.s3Client, command, { expiresIn: 300 });

    return signedUrl;
  }

  async getSignedDownloadUrl(key: string): Promise<string> {
    if (!this.s3Client) {
      throw new BadRequestException('S3 is not configured');
    }

    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    // URL valid for 1 hour
    const signedUrl = await getSignedUrl(this.s3Client, command, { expiresIn: 3600 });

    return signedUrl;
  }

  async deleteFile(key: string): Promise<void> {
    if (!this.s3Client) {
      throw new BadRequestException('S3 is not configured');
    }

    await this.s3Client.send(
      new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      }),
    );
  }

  extractKeyFromUrl(url: string): string {
    // Extract key from S3 URL
    const urlParts = url.split('.s3.');
    if (urlParts.length > 1) {
      return urlParts[1].substring(urlParts[1].indexOf('/') + 1);
    }
    return url;
  }
}
