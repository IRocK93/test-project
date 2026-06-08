export enum AccessLevel {
  VIEW = 'VIEW',
  EDIT = 'EDIT',
}

export interface AccessCheckResult {
  hasAccess: boolean;
  level: AccessLevel | null;
  babyMonId: string;
  userId: string;
}