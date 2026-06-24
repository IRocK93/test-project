import { IsEmail, IsString, MinLength, MaxLength, Matches, IsOptional, IsDateString, IsBoolean } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Please enter a valid email address' })
  @MaxLength(255, { message: 'Email must not exceed 255 characters' })
  @Transform(({ value }) => typeof value === 'string' ? value.toLowerCase().trim() : value)
  email: string;

  @ApiProperty({ example: 'Password123' })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @MaxLength(72, { message: 'Password must not exceed 72 characters' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
  })
  password: string;

  @ApiProperty({ example: 'John Doe', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'Name must not exceed 100 characters' })
  name?: string;

  @ApiProperty({ example: '1995-01-01', required: false })
  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  tosAccepted?: boolean;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  privacyAccepted?: boolean;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  consentToDataProcessing?: boolean;
}

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Please enter a valid email address' })
  @Transform(({ value }) => typeof value === 'string' ? value.toLowerCase().trim() : value)
  email: string;

  @ApiProperty({ example: 'Password123' })
  @IsString()
  @MinLength(1, { message: 'Password is required' })
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty({ description: 'The refresh token' })
  @IsString()
  refreshToken: string;
}

export class LogoutDto {
  @ApiProperty({ required: false, description: 'Specific refresh token to revoke' })
  @IsOptional()
  @IsString()
  refreshToken?: string;
}

export class ForgotPasswordDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Please enter a valid email address' })
  email: string;
}

export class ResetPasswordDto {
  @ApiProperty({ description: 'Password reset token' })
  @IsString()
  token: string;

  @ApiProperty({ example: 'NewPassword123' })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @MaxLength(72, { message: 'Password must not exceed 72 characters' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
  })
  password: string;
}

export class OAuthLoginDto {
  @ApiProperty({ example: 'eyJhbGciOi...', description: 'OAuth ID token from Google/Apple/Facebook' })
  @IsString()
  idToken: string;

  @ApiProperty({ example: 'google', description: 'Provider name (google, apple, facebook)' })
  @IsString()
  provider: string;
}
