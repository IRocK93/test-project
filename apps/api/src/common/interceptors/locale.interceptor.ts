import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { SUPPORTED_LOCALES } from '../constants/locales.constant';

/**
 * Resolves the effective locale for every incoming request and attaches it
 * to `request.resolvedLocale`.
 *
 * Resolution order:
 * 1. `Accept-Language` HTTP header
 * 2. Authenticated user's stored `locale` preference (from JWT payload, set by JwtStrategy)
 * 3. Fallback: `'en'`
 *
 * The resolved value is validated against the supported locale whitelist
 * and can be read via `@CurrentLocale()` decorator in controllers.
 */
@Injectable()
export class LocaleInterceptor implements NestInterceptor {
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<any> {
    const request = context.switchToHttp().getRequest();

    let resolved: string | undefined;

    // Priority 1: Accept-Language header
    const headerLocale = request.headers['accept-language'];
    if (headerLocale && typeof headerLocale === 'string') {
      // Normalize: take first segment, strip region if present
      resolved = headerLocale.split(',')[0].trim().split('-')[0].toLowerCase();
    }

    // Priority 2: Authenticated user's stored locale (from JWT payload — no DB lookup)
    if (!resolved && request.user?.locale) {
      resolved = request.user.locale;
    }

    // Validate against whitelist, fallback to 'en' if unsupported
    const effective = resolved && SUPPORTED_LOCALES.has(resolved) ? resolved : 'en';
    request.resolvedLocale = effective;
    return next.handle();
  }
}
