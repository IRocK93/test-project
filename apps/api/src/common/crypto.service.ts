import { Injectable, Logger } from '@nestjs/common';
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

/**
 * AES-256-GCM encryption service for sensitive health data fields.
 *
 * Used to encrypt bloodGroup, allergy treatment notes, and other
 * special-category personal data at the application layer before
 * persisting to the database.
 *
 * Requires CRYPTO_KEY (64 hex chars = 32 bytes) and CRYPTO_IV (24 hex chars = 12 bytes)
 * to be set in environment. Falls back to a logged warning with no-encrypt passthrough
 * in dev if keys are not configured.
 */
@Injectable()
export class CryptoService {
  private readonly logger = new Logger(CryptoService.name);
  private readonly key: Buffer | null;
  private readonly ivLength = 12; // GCM recommended IV length

  constructor() {
    const keyHex = process.env.CRYPTO_KEY;
    if (keyHex && keyHex.length === 64) {
      this.key = Buffer.from(keyHex, 'hex');
    } else {
      this.key = null;
      if (process.env.NODE_ENV === 'production') {
        this.logger.error('CRYPTO_KEY not configured — field encryption disabled in PRODUCTION!');
      } else {
        this.logger.warn('CRYPTO_KEY not set — field encryption disabled (dev mode)');
      }
    }
  }

  /** Encrypt a plaintext value. Returns `enc:` prefix + hex IV + hex tag + hex ciphertext. */
  encrypt(plaintext: string | null | undefined): string | null {
    if (!plaintext) return null;
    if (!this.key) return plaintext; // no-encrypt passthrough

    try {
      const iv = randomBytes(this.ivLength);
      const cipher = createCipheriv('aes-256-gcm', this.key, iv);
      const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
      const tag = cipher.getAuthTag();
      return `enc:${iv.toString('hex')}:${tag.toString('hex')}:${encrypted.toString('hex')}`;
    } catch (err) {
      this.logger.error({ err }, 'Encryption failed — storing plaintext as fallback');
      return plaintext;
    }
  }

  /** Decrypt a value previously encrypted with {@link encrypt}. */
  decrypt(ciphertext: string | null | undefined): string | null {
    if (!ciphertext) return null;
    if (!this.key || !ciphertext.startsWith('enc:')) return ciphertext;

    try {
      const parts = ciphertext.slice(4).split(':');
      if (parts.length < 3) return ciphertext;
      const iv = Buffer.from(parts[0], 'hex');
      const tag = Buffer.from(parts[1], 'hex');
      const encrypted = Buffer.from(parts[2], 'hex');
      const decipher = createDecipheriv('aes-256-gcm', this.key, iv);
      decipher.setAuthTag(tag);
      return Buffer.concat([decipher.update(encrypted), decipher.final()]).toString('utf8');
    } catch (err) {
      this.logger.error({ err }, 'Decryption failed — returning ciphertext');
      return ciphertext;
    }
  }
}
