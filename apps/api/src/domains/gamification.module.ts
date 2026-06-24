/**
 * Gamification domain barrel module.
 *
 * Aggregates XP, badges, evolution, and stage-content modules.
 */
import { Module } from '@nestjs/common';
import { XpModule } from '../xp/xp.module';
import { BadgesModule } from '../badges/badges.module';
import { EvolutionModule } from '../evolution/evolution.module';
import { StageContentModule } from '../stage-content/stage-content.module';

@Module({
  imports: [XpModule, BadgesModule, EvolutionModule, StageContentModule],
  exports: [XpModule, BadgesModule, EvolutionModule, StageContentModule],
})
export class GamificationModule {}
