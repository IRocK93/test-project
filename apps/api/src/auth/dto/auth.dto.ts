import { IsEmail, IsString, MinLength, MaxLength, Matches, IsOptional, IsDateString, IsBoolean } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  @MaxLength(255)
  @Transform(({ value }) => typeof value === 'string' ? value.toLowerCase().trim() : value)
  email: string;

  @ApiProperty({ example: 'Password123' })
  @IsString()
  @MinLength(8)
  @MaxLength(72)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  password: string;

  @ApiProperty({ example: 'John Doe', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100)
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

  @ApiProperty({ example: 'en', required: false, description: 'Preferred locale (en, es, fr, de, ar, he, it, pt, zh)' })
  @IsOptional()
  @IsString()
  @Matches(/^[a-z]{2}$/)
  locale?: string;
}

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  @Transform(({ value }) => typeof value === 'string' ? value.toLowerCase().trim() : value)
  email: string;

  @ApiProperty({ example: 'Password123' })
  @IsString()
  @MinLength(1)
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
  @IsEmail()
  email: string;
}

export class ResetPasswordDto {
  @ApiProperty({ description: 'Password reset token' })
  @IsString()
  token: string;

  @ApiProperty({ example: 'NewPassword123' })
  @IsString()
  @MinLength(8)
  @MaxLength(72)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
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
