import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  Logger,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { Prisma } from '@prisma/client';
import { ErrorCode } from '../enums/error-code.enum';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message: string = 'Internal server error';
    let code: string = ErrorCode.INTERNAL_ERROR;
    let details: Array<{ field: string; code: string }> | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
        // Derive a stable code from the HTTP status when the exception
        // only carries a string message (e.g., NotFoundException('User not found')).
        code = this.inferCodeFromStatus(status);
      } else {
        const resp = exceptionResponse as Record<string, unknown>;
        message = String(resp.message || exception.message);
        // Prefer an explicit code from the thrower; fall back to status inference.
        const explicitCode = resp.code ?? resp.error;
        code =
          typeof explicitCode === 'string' && explicitCode.length > 0
            ? explicitCode
            : this.inferCodeFromStatus(status);
        // Preserve field-level validation details if present
        if (Array.isArray(resp.details)) {
          details = resp.details as Array<{ field: string; code: string }>;
        }
      }
    } else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      status = this.mapPrismaError(exception);
      message = 'A database error occurred';
      code = ErrorCode.DATABASE_ERROR;
    } else if (exception instanceof Error) {
      message = exception.message;
      code = ErrorCode.INTERNAL_ERROR;
    }

    this.logger.error(
      { err: exception, path: request.url, status, code },
      message,
    );

    const body: Record<string, unknown> = {
      statusCode: status,
      message,
      code,
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    if (details) {
      body.details = details;
    }

    response.status(status).json(body);
  }

  private inferCodeFromStatus(status: number): string {
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return ErrorCode.VALIDATION_ERROR;
      case HttpStatus.UNAUTHORIZED:
        return ErrorCode.UNAUTHORIZED;
      case HttpStatus.FORBIDDEN:
        return ErrorCode.LIMIT_REACHED;
      case HttpStatus.NOT_FOUND:
        return ErrorCode.NOT_FOUND;
      case HttpStatus.CONFLICT:
        return ErrorCode.DUPLICATE_EMAIL;
      case HttpStatus.TOO_MANY_REQUESTS:
        return ErrorCode.RATE_LIMITED;
      default:
        return ErrorCode.INTERNAL_ERROR;
    }
  }

  private mapPrismaError(error: Prisma.PrismaClientKnownRequestError): number {
    switch (error.code) {
      case 'P2002':
        return 409;
      case 'P2025':
        return 404;
      case 'P2003':
        return 400;
      default:
        return 500;
    }
  }
}
