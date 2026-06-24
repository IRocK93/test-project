import { Controller, Get, UseGuards, HttpException, HttpStatus, Res, Req } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TierGuard } from './tier.guard';
import { Response, Request } from 'express';
import * as https from 'https';
import * as http from 'http';

const OLD_STUB_URL = 'https://cdn.babymon.app/models/gemma4-e2b-v1-q4km.gguf';

@ApiTags('companion')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, TierGuard)
@Controller('models/companion-llm')
export class ModelManifestController {
  constructor(private config: ConfigService) {}

  @Get('manifest')
  @ApiOperation({ summary: 'Get the current LLM model manifest for on-device download' })
  getManifest() {
    const modelUrl = this.config.get<string>('companion.modelUrl');
    const modelSha256 = this.config.get<string>('companion.modelSha256') || null;

    if (!modelUrl || modelUrl === OLD_STUB_URL) {
      throw new HttpException(
        { statusCode: HttpStatus.SERVICE_UNAVAILABLE, message: 'AI model is not configured.', error: 'Model Not Configured' },
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    return {
      latest: {
        version: 'smollm2-360m-v2',
        name: 'Quick Start',
        sizeBytes: 271000000,
        sha256: modelSha256,
        url: modelUrl,
        minRamGB: 1,
        changelog: 'SmolLM2 360M — Lightweight on-device model, instant download.',
      },
      minimumRequired: null,
      rollbackAdvised: null,
    };
  }

  /// Proxies the model download through the backend so the mobile app only
  /// needs to reach the API server (no direct HuggingFace access required).
  @Get('download')
  @ApiOperation({ summary: 'Download the LLM model file (backend proxy)' })
  downloadModel(@Req() req: Request, @Res() res: Response) {
    const modelUrl = this.config.get<string>('companion.modelUrl');
    if (!modelUrl || modelUrl === OLD_STUB_URL) {
      throw new HttpException(
        { statusCode: HttpStatus.SERVICE_UNAVAILABLE, message: 'AI model is not configured.' },
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    const parsed = new URL(modelUrl);
    const client = parsed.protocol === 'https:' ? https : http;
    const rangeHeader = req.headers['range'] as string | undefined;

    const options: https.RequestOptions = {
      hostname: parsed.hostname,
      port: parsed.port || (parsed.protocol === 'https:' ? 443 : 80),
      path: parsed.pathname + parsed.search,
      method: 'GET',
      headers: {
        'User-Agent': 'BabyMon/1.0',
        ...(rangeHeader ? { 'Range': rangeHeader } : {}),
      },
    };

    const proxyReq = client.request(options, (proxyRes) => {
      // Follow redirect once (HuggingFace → CDN)
      if (proxyRes.statusCode === 302 || proxyRes.statusCode === 301) {
        const redirectUrl = proxyRes.headers['location'];
        if (redirectUrl) {
          const redirectParsed = new URL(redirectUrl);
          const redirectClient = redirectParsed.protocol === 'https:' ? https : http;
          const redirectOptions: https.RequestOptions = {
            hostname: redirectParsed.hostname,
            port: redirectParsed.port || (redirectParsed.protocol === 'https:' ? 443 : 80),
            path: redirectParsed.pathname + redirectParsed.search,
            method: 'GET',
            headers: {
              'User-Agent': 'BabyMon/1.0',
              ...(rangeHeader ? { 'Range': rangeHeader } : {}),
            },
          };

          const redirectReq = redirectClient.request(redirectOptions, (finalRes) => {
            res.status(finalRes.statusCode || 200);
            const contentLength = finalRes.headers['content-length'];
            if (contentLength) res.setHeader('Content-Length', contentLength);
            res.setHeader('Accept-Ranges', 'bytes');
            finalRes.pipe(res);
          });

          redirectReq.on('error', (err) => {
            if (!res.headersSent) res.status(502).json({ message: 'Upstream CDN unreachable.' });
          });
          redirectReq.end();
          return;
        }
      }

      // Direct response (no redirect)
      res.status(proxyRes.statusCode || 200);
      const contentLength = proxyRes.headers['content-length'];
      if (contentLength) res.setHeader('Content-Length', contentLength);
      res.setHeader('Accept-Ranges', 'bytes');
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
      if (!res.headersSent) res.status(502).json({ message: 'Model server unreachable.' });
    });

    proxyReq.end();
  }
}
