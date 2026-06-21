import { Controller, Get, UseGuards } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TierGuard } from './tier.guard';

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

    return {
      latest: {
        version: 'gemma4-e2b-v1',
        name: 'Gemma 4 E2B',
        sizeBytes: 1288490188,
        sha256: modelSha256,
        url: modelUrl,
        minRamGB: 4,
        changelog: 'Initial release. Evidence-based parenting guidance from clinical and development frameworks.',
      },
      minimumRequired: 'gemma4-e2b-v1',
      rollbackAdvised: null,
    };
  }
}
