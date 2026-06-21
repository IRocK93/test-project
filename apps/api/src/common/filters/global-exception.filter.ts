import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { Prisma } from '@prisma/client';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = 500;
    let message: string = 'Internal server error';
    let code: string = 'INTERNAL_ERROR';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      message =
        typeof exceptionResponse === 'string'
          ? exceptionResponse
          : String((exceptionResponse as Record<string, unknown>).message || exception.message);
      code =
        String((exceptionResponse as Record<string, unknown>).error || 'ERROR');
    } else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      status = this.mapPrismaError(exception);
      message = 'A database error occurred';
      code = 'DATABASE_ERROR';
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    this.logger.error(
      { err: exception, path: request.url, status },
      message,
    );

    response.status(status).json({
      statusCode: status,
      message,
      code,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
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
