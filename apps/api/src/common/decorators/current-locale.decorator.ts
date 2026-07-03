import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { SUPPORTED_LOCALES } from '../constants/locales.constant';

function normalizeLocale(raw: unknown): string | undefined {
  if (!raw) return undefined;
  const str = typeof raw === 'string' ? raw : Array.isArray(raw) ? raw[0] : String(raw);
  if (!str) return undefined;
  const normalized = str.trim().split('-')[0].toLowerCase();
  return SUPPORTED_LOCALES.has(normalized) ? normalized : undefined;
}

/**
 * Resolves the effective locale for the current request.
 *
 * Resolution order:
 * 1. `?locale=` query parameter (if present and valid)
 * 2. `Accept-Language` header
 * 3. Authenticated user's stored `locale` preference
 * 4. Fallback: `'en'`
 *
 * The value is set by `LocaleInterceptor` on `request.resolvedLocale`.
 */
export const CurrentLocale = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest();
    // Priority 1: explicit query param overrides everything (validated)
    const queryLocale = normalizeLocale(request.query?.locale);
    if (queryLocale) {
      return queryLocale;
    }
    // Priority 2-4: resolved by LocaleInterceptor
    return request.resolvedLocale ?? 'en';
  },
);
