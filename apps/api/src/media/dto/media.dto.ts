import { IsString, IsOptional, IsInt, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UploadMediaDto {
  @ApiProperty({ example: 'baby-photo.jpg', description: 'Original file name' })
  @IsString()
  fileName: string;

  @ApiProperty({ example: 'image/jpeg', description: 'MIME type' })
  @IsString()
  fileType: string;

  @ApiPropertyOptional({ example: 102400, description: 'File size in bytes' })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(52428800) // 50 MB max
  fileSize?: number;

  @ApiProperty({ example: '/9j/4AAQSkZ...', description: 'Base64-encoded file data' })
  @IsString()
  fileData: string;
}

export class PresignedUrlDto {
  @ApiProperty({ example: 'baby-photo.jpg', description: 'Original file name' })
  @IsString()
  fileName: string;

  @ApiProperty({ example: 'image/jpeg', description: 'MIME type for upload' })
  @IsString()
  contentType: string;
}
