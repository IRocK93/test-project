import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Base exception for all business-logic errors.
 * Requires a machine-readable `code` for client-side error handling.
 */
export class BusinessException extends HttpException {
  constructor(message: string, status: HttpStatus, code: string) {
    super({ statusCode: status, message, code }, status);
  }
}

// Common business exceptions
export class LimitReachedException extends BusinessException {
  constructor(message: string) {
    super(message, HttpStatus.FORBIDDEN, 'LIMIT_REACHED');
  }
}

export class TrialExpiredException extends BusinessException {
  constructor() {
    super('Your free trial has expired. Please upgrade to continue.', HttpStatus.FORBIDDEN, 'TRIAL_EXPIRED');
  }
}

export class DuplicateException extends BusinessException {
  constructor(message: string) {
    super(message, HttpStatus.CONFLICT, 'DUPLICATE');
  }
}

export class InvalidOperationException extends BusinessException {
  constructor(message: string) {
    super(message, HttpStatus.BAD_REQUEST, 'INVALID_OPERATION');
  }
}
