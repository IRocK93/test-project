import { IsString, IsEmail, IsOptional, MinLength, MaxLength } from 'class-validator';
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
}

export class DeleteAccountDto {
  @ApiProperty({ description: 'Current password for verification' })
  @IsString()
  @MinLength(1)
  password: string;
}
