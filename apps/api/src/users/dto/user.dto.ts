import { IsString, IsEmail, IsOptional, MinLength, MaxLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateUserDto {
  @ApiProperty({ example: 'user@example.com', required: false })
  @IsOptional()
  @IsEmail({}, { message: 'Please enter a valid email address' })
  email?: string;

  @ApiProperty({ example: 'John Doe', required: false })
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(100, { message: 'Name must not exceed 100 characters' })
  name?: string;

  @ApiProperty({ example: '+1234567890', required: false })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ example: 'en', required: false, description: 'ISO 639-1 language code (e.g., en, es, fr)' })
  @IsOptional()
  @IsString()
  @Matches(/^[a-z]{2}(-[A-Z]{2})?$/, { message: 'Locale must be a valid ISO language code (e.g., en, en-US)' })
  locale?: string;
}

export class DeleteAccountDto {
  @ApiProperty({ description: 'Current password for verification' })
  @IsString()
  @MinLength(1)
  password: string;
}
