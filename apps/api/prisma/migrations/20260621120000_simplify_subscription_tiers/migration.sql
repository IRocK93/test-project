-- Simplify SubscriptionTier enum from 4 values to 2: FREE and PREMIUM
-- Map CORE → FREE and AI_COMPANION → PREMIUM

-- Update existing subscriptions
UPDATE "Subscription" SET "tier" = 'FREE' WHERE "tier" = 'CORE';
UPDATE "Subscription" SET "tier" = 'PREMIUM' WHERE "tier" = 'AI_COMPANION';
