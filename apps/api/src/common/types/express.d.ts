declare global {
  namespace Express {
    interface Request {
      /** Effective locale resolved by LocaleInterceptor for the current request. */
      resolvedLocale?: string;
    }
  }
}

export {};
