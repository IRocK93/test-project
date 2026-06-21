import { IsBoolean, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '../../common/prisma-enums';

export class UpdateUserStatusDto {
  @ApiProperty({ example: true, description: 'Set user active/inactive' })
  @IsBoolean()
  isActive: boolean;
}

export class UpdateUserRoleDto {
  @ApiProperty({ example: 'ADMIN', description: 'User role', enum: ['USER', 'ADMIN'] })
  @IsIn(['USER', 'ADMIN'])
  role: UserRole;
}
