import {
  HttpException,
  ArgumentsHost,
  HttpStatus,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { GlobalExceptionFilter } from './global-exception.filter';

describe('GlobalExceptionFilter', () => {
  let filter: GlobalExceptionFilter;

  beforeEach(() => {
    filter = new GlobalExceptionFilter();
  });

  function createMockHost() {
    const json = jest.fn();
    const status = jest.fn().mockReturnValue({ json });
    const response = { status };
    const request = { url: '/api/v1/test', method: 'GET' };

    const host = {
      switchToHttp: () => ({
        getResponse: () => response,
        getRequest: () => request,
      }),
    } as ArgumentsHost;

    return { host, response, request, status, json };
  }

  it('should be defined', () => {
    expect(filter).toBeDefined();
  });

  it('should return 500 for unknown errors', () => {
    const { host, status, json } = createMockHost();
    const error = new Error('Something broke');

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: 500,
        message: 'Something broke',
        code: 'INTERNAL_ERROR',
      }),
    );
  });

  it('should return the HttpException status and message', () => {
    const { host, status, json } = createMockHost();
    const error = new HttpException('Not Found', HttpStatus.NOT_FOUND);

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(404);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: 404,
        message: 'Not Found',
        code: 'ERROR',
      }),
    );
  });

  it('should extract error code from HttpException response body', () => {
    const { host, status, json } = createMockHost();
    const error = new HttpException(
      { message: 'Validation failed', error: 'VALIDATION_ERROR' },
      HttpStatus.BAD_REQUEST,
    );

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(400);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: 400,
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
      }),
    );
  });

  it('should return 409 for Prisma unique constraint violations (P2002)', () => {
    const { host, status, json } = createMockHost();
    const error = new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
      code: 'P2002',
      clientVersion: '5.0.0',
    });

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(409);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: 409,
        message: 'A database error occurred',
        code: 'DATABASE_ERROR',
      }),
    );
  });

  it('should return 404 for Prisma not-found errors (P2025)', () => {
    const { host, status, json } = createMockHost();
    const error = new Prisma.PrismaClientKnownRequestError('Record not found', {
      code: 'P2025',
      clientVersion: '5.0.0',
    });

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(404);
  });

  it('should return 400 for Prisma foreign key errors (P2003)', () => {
    const { host, status } = createMockHost();
    const error = new Prisma.PrismaClientKnownRequestError('Foreign key failed', {
      code: 'P2003',
      clientVersion: '5.0.0',
    });

    filter.catch(error, host);

    expect(status).toHaveBeenCalledWith(400);
  });

  it('should include the request path in the response', () => {
    const { host, json } = createMockHost();
    const error = new Error('Test');

    filter.catch(error, host);

    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        path: '/api/v1/test',
      }),
    );
  });

  it('should include timestamp in the response', () => {
    const { host, json } = createMockHost();
    const error = new Error('Test');

    filter.catch(error, host);

    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        timestamp: expect.any(String),
      }),
    );
  });

  it('should handle null/undefined exceptions gracefully', () => {
    const { host, status, json } = createMockHost();

    // Should not throw
    expect(() => filter.catch(null, host)).not.toThrow();
    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 500 }),
    );
  });
});
