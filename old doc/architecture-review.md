# BabyMon Architecture Review

## 1. Backend (NestJS) Assessment

### 1.1 Authentication & JWT Flow
**Status: SOLID with minor gaps**

The JWT auth implementation in `auth.service.ts` is well-structured:
- Access token (15m) + Refresh token (7d) rotation with revocation on use
- Token type distinction (`type: 'access'` vs `type: 'refresh'`) prevents misuse
- Refresh token stored in DB with expiration check
- Proper `deletedAt` check for soft-deleted users

**Issues Found:**
1. **Security:** `safeJwtSecret` fallback in production is dangerous (line 14 in auth.service.ts). If `JWT_SECRET` env var is missing in production, the fallback is used silently instead of failing.

```typescript
// CURRENT (DANGEROUS):
const safeJwtSecret = jwtSecret || 'babymon-jwt-secret-do-not-use-in-production';

// SHOULD BE:
if (!jwtSecret && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET is required');
}
```

2. **Missing:** No token family tracking (rotated refresh tokens should be invalidated as a family to prevent token replay attacks). Current implementation only revokes the used token but not others from same family.

3. **Rate limiting:** Auth endpoints have throttle guards but refresh endpoint allows 10 req/min which could be used for token enumeration.

### 1.2 Subscription/Trial Guard
**Status: GOOD**

`SubscriptionWriteGuard` correctly gates write operations. Logic in `subscriptions.service.ts` properly checks:
- Active Stripe subscription
- Active trial period
- Returns appropriate error messages

**Issue:** The `devOverrideTrial` method uses a predictable ID (`dev-${userId}`) which could be exploited. Consider using a separate dev-only endpoint with additional verification.

### 1.3 Access Control (Co-parent Linking)
**Status: INCONSISTENT**

Access verification is duplicated across services:
- `milestones.service.ts` has `verifyAccess()` private method
- `baby-mon.service.ts` does ownership check only
- `evolution.service.ts` duplicates the linked account check

**Recommendation:** Create a shared `AccessControlService` or use a single `BabymonAccessGuard` that:
1. Checks owner first
2. Then checks linked accounts with `LINKED` status
3. Returns the access level (VIEW/EDIT)

### 1.4 Audit Logging
**Status: INCOMPLETE**

The `AuditInterceptor` only logs HTTP requests - it doesn't actually write to the `AuditLog` table. It's a request logger, not an audit logger.

**Issue:** Manual `auditLog.create()` calls exist in services but there's no standardized audit event types. Events are strings like `'BABYMON_CREATED'` - should be an enum.

### 1.5 Data Integrity Issues

**Issue 1: XP awarded is hardcoded in service layer**
```typescript
// milestones.service.ts line 33
xpAwarded: 10,
```
Should be configurable per milestone type or derive from badge definitions.

**Issue 2: Race condition in badge awarding**
`checkAndAwardBadges()` runs after milestone creation. If two entries are created simultaneously, badge could be awarded twice (though the unique constraint on `[babymonId, badgeType]` prevents double-storage, the business logic still runs twice).

**Issue 3: No transaction around badge XP update**
When a milestone is deleted within the 10-minute window, XP is decremented but badge state isn't re-evaluated.

### 1.6 Missing Patterns
1. **No input sanitization:** DTOs lack class-validator decorators in most places (e.g., baby-mon.dto.ts)
2. **No global error formatter:** Exceptions have inconsistent structure (`{message, error}` vs `{code, error}`)
3. **No health check endpoint:** Critical for container orchestration
4. **Growth module exists but no GrowthRecord service integration** - orphaned code

---

## 2. Prisma Schema Assessment

### 2.1 Data Model Issues

**Issue 1: `LinkedBabyMon` is misnamed and confusing**
The `LinkedBabyMon` table represents which BabyMons a user can access, not linking BabyMons together. Rename to `BabyMonAccess` or `UserBabyMon`.

**Issue 2: Missing indexes**
- `StageContent(babymonId, stageKey)` has unique constraint but `stageKey` alone should be indexed for content lookup
- `AuditLog(actorUserId)` not indexed - will be heavily queried

**Issue 3: Soft-delete inconsistency**
Most models have `deletedAt` but:
- `RefreshToken` doesn't (uses `revokedAt` instead - correct)
- `LinkedAccount` doesn't (uses status enum - acceptable)
- `Subscription` doesn't have soft-delete at all (acceptable for financial records)

**Issue 4: `entry_change_proposals` schema is incomplete**
- `originalPayloadJson` can be null but should always be populated for EDIT proposals
- No constraint ensures `responseReason` is required when `status` is `REJECTED`

**Issue 5: `PasswordResetToken` doesn't track if it was used**
Once used, the token should be invalidated (delete, not just expire check).

### 2.2 Recommended Schema Changes

```prisma
// Add index for audit log queries by actor
model AuditLog {
  ...
  @@index([actorUserId, createdAt]) // Composite index for user's audit history
}

// Rename LinkedBabyMon for clarity
model BabyMonAccess {
  id        String   @id @default(uuid())
  userId    String
  babymonId String
  access    String   @default("EDIT") // VIEW, EDIT
  createdAt DateTime @default(now())
  
  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  babyMon BabyMon @relation(fields: [babymonId], references: [id], onDelete: Cascade)
  
  @@unique([userId, babymonId])
  @@index([userId])
  @@index([babymonId])
}
```

---

## 3. Flutter Architecture Design

### 3.1 Current State
The mobile app is a bare scaffold with:
- `presentation/providers/auth_provider.dart` - basic Riverpod state
- `data/api_client.dart` and `data/services/api_service.dart` - duplicate Dio clients
- `data/local/local_database.dart` - placeholder only
- No domain layer, no repository pattern, no offline support

### 3.2 Recommended Clean Architecture Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── storage_keys.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── network_info.dart
│   │   └── dio_client.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
│
├── domain/                    # BUSINESS LOGIC LAYER (no Flutter imports)
│   ├── entities/
│   │   ├── user.dart
│   │   ├── baby_mon.dart
│   │   ├── milestone.dart
│   │   ├── feed_log.dart
│   │   ├── health_record.dart
│   │   └── badge.dart
│   ├── repositories/           # ABSTRACT contracts
│   │   ├── auth_repository.dart
│   │   ├── baby_mon_repository.dart
│   │   ├── milestone_repository.dart
│   │   ├── feed_log_repository.dart
│   │   ├── health_repository.dart
│   │   └── sync_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   └── refresh_token_usecase.dart
│       ├── baby_mon/
│       │   ├── get_baby_mons_usecase.dart
│       │   └── create_baby_mon_usecase.dart
│       └── milestones/
│           ├── get_milestones_usecase.dart
│           └── create_milestone_usecase.dart
│
├── data/                       # DATA LAYER
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── baby_mon_remote_datasource.dart
│   │   │   └── milestone_remote_datasource.dart
│   │   └── local/
│   │       ├── database.dart           # Drift database
│   │       ├── tables/
│   │       │   ├── milestone_table.dart
│   │       │   ├── feed_log_table.dart
│   │       │   └── health_record_table.dart
│   │       ├── daos/
│   │       │   ├── milestone_dao.dart
│   │       │   └── sync_dao.dart
│   │       └── local_datasource.dart    # Offline operations
│   ├── models/                 # Data transfer objects (JSON serializable)
│   │   ├── user_model.dart
│   │   ├── baby_mon_model.dart
│   │   ├── milestone_model.dart
│   │   └── feed_log_model.dart
│   └── repositories/           # CONCRETE implementations
│       ├── auth_repository_impl.dart
│       ├── baby_mon_repository_impl.dart
│       └── milestone_repository_impl.dart
│
└── presentation/               # UI LAYER
    ├── providers/              # Riverpod providers
    │   ├── auth/
    │   │   ├── auth_provider.dart
    │   │   └── auth_state.dart
    │   ├── baby_mon/
    │   │   └── baby_mon_provider.dart
    │   ├── milestones/
    │   │   └── milestone_provider.dart
    │   └── sync/
    │       └── sync_status_provider.dart
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── onboarding/
    │   │   └── create_baby_mon_screen.dart
    │   └── main/
    │       ├── dashboard/
    │       ├── milestones/
    │       ├── feeding/
    │       ├── health/
    │       └── journal/
    ├── widgets/
    │   ├── common/
    │   │   ├── loading_indicator.dart
    │   │   └── error_view.dart
    │   └── entry/
    │       ├── milestone_card.dart
    │       └── feed_log_tile.dart
    └── router/
        └── app_router.dart
```

### 3.3 Layer Responsibilities

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| **domain** | Business rules, entities, repository interfaces, use cases | None (pure Dart) |
| **data** | API calls, local DB operations, model serialization, repository implementations | domain, external packages |
| **presentation** | UI widgets, Riverpod providers, screen state | domain, data |

### 3.4 Data Flow (Offline-First)

```
USER ACTION
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                          │
│   - User taps "Save Milestone"                             │
│   - Provider calls CreateMilestoneUseCase                  │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER (UseCase)                                     │
│   - Validates input                                         │
│   - Contains business logic                                │
│   - Returns Either<Failure, Milestone>                     │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ DATA LAYER (RepositoryImpl)                               │
│   1. Check network status                                   │
│   2. If ONLINE:                                            │
│      - Call remote datasource                               │
│      - On success: save to local DB, return result          │
│      - On failure: save to local DB with PENDING status    │
│   3. If OFFLINE:                                           │
│      - Save to local DB with PENDING_SYNC status          │
│      - Return success (optimistic UI)                      │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ LOCAL DB (Drift)                                           │
│   Tables: pending_sync_queue                               │
│   - id (UUID, primary key)                                │
│   - entity_type (milestone/feed_log/health)                │
│   - entity_id (local UUID)                                 │
│   - payload (JSON)                                         │
│   - status (PENDING/IN_PROGRESS/FAILED)                   │
│   - created_at                                             │
│   - retry_count                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Offline Sync Strategy

### 4.1 Drift Database Schema

```dart
// tables/pending_sync_table.dart
class PendingSyncEntries extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entityType => text()(); // 'milestone', 'feed_log', etc.
  TextColumn get entityId => text()(); // Local UUID of the entry
  TextColumn get payload => text()(); // JSON serialized data
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentTimestamp)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// Entity tables mirror API structure + sync status
class MilestoneEntries extends Table {
  TextColumn get id => text()(); // Server ID or local UUID
  TextColumn get babymonId => text()();
  TextColumn get title => text()();
  DateTimeColumn get happenedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentTimestamp)();
}
```

### 4.2 Sync Algorithm

```dart
class SyncService {
  Future<void> syncPendingEntries() async {
    final pendingEntries = await db.pendingSyncQueries.getPending();
    
    for (final entry in pendingEntries) {
      try {
        await db.pendingSyncQueries.updateStatus(entry.id, 'IN_PROGRESS');
        
        switch (entry.entityType) {
          case 'milestone':
            await _syncMilestone(entry);
          case 'feed_log':
            await _syncFeedLog(entry);
          case 'health_record':
            await _syncHealthRecord(entry);
        }
        
        await db.pendingSyncQueries.markSynced(entry.id);
      } catch (e) {
        await db.pendingSyncQueries.incrementRetry(entry.id);
        if (entry.retryCount >= 3) {
          await db.pendingSyncQueries.markFailed(entry.id);
          // Notify user of persistent failure
        }
      }
    }
  }
  
  Future<void> _syncMilestone(PendingSyncEntry entry) async {
    // Check if this is create (no server ID) or update (has server ID)
    final milestone = jsonDecode(entry.payload);
    if (milestone['serverId'] == null) {
      // CREATE
      final response = await api.createMilestone(entry.babymonId, milestone);
      // Update local entry with server ID
      await db.milestonesDao.updateServerId(entry.entityId, response['id']);
    } else {
      // UPDATE
      await api.updateMilestone(milestone['serverId'], milestone);
    }
  }
}
```

### 4.3 Conflict Resolution Strategy

1. **Last-write-wins for MVP**: Server timestamp is authoritative
2. **Soft-delete wins**: If server has deleted, local pending updates are discarded
3. **Queue management**:
   - Max 100 pending entries per BabyMon
   - Entries older than 30 days auto-expire
   - User can manually discard pending changes

### 4.4 Sync Triggers

| Trigger | Action |
|---------|--------|
| App foreground | Sync pending entries |
| Network available | Sync pending entries |
| Manual pull-to-refresh | Full sync |
| Entry created offline | Add to queue, attempt immediate sync |
| App background | No action (let OS handle) |

---

## 5. API Client Design (Dio + Repository Pattern)

### 5.1 Current Issues

1. **Duplicate clients**: `ApiService` and `ApiClient` both do similar things
2. **No interceptors for retry logic**: Token refresh creates new Dio instance in `_refreshToken()` (line 55)
3. **No circuit breaker pattern**: Failed requests fail immediately

### 5.2 Recommended Dio Client Setup

```dart
// core/network/dio_client.dart
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(_storage, _refreshToken),
      ConnectivityInterceptor(),
      RetryInterceptor(),
      LogInterceptor(),
    ]);
  }
  
  Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Future<bool> Function() refreshToken;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${await storage.read(key: StorageKeys.accessToken)}';
        final resp = await DioClient().fetch(opts);
        return handler.resolve(resp);
      }
    }
    handler.next(err);
  }
}
```

### 5.3 Repository Pattern Implementation

```dart
// domain/repositories/milestone_repository.dart
abstract class MilestoneRepository {
  Future<Either<Failure, List<Milestone>>> getMilestones(String babyMonId);
  Future<Either<Failure, Milestone>> createMilestone(String babyMonId, CreateMilestoneParams params);
  Future<Either<Failure, Milestone>> updateMilestone(String id, UpdateMilestoneParams params);
  Future<Either<Failure, void>> deleteMilestone(String id);
  Future<Either<Failure, List<Milestone>>> getLocalMilestones();
}

// data/repositories/milestone_repository_impl.dart
class MilestoneRepositoryImpl implements MilestoneRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, Milestone>> createMilestone(
    String babyMonId, 
    CreateMilestoneParams params
  ) async {
    // Always save locally first (optimistic)
    final localId = await local.saveMilestone(params);
    
    if (await networkInfo.isConnected) {
      try {
        final response = await remote.createMilestone(babyMonId, params);
        await local.updateServerId(localId, response.id);
        return Right(response.toEntity());
      } catch (e) {
        // Mark as pending sync
        await local.markPendingSync(localId);
        // Return success with local data
        final localData = await local.getMilestone(localId);
        return Right(localData.toEntity());
      }
    } else {
      await local.markPendingSync(localId);
      return Right(Milestone(id: localId, syncStatus: SyncStatus.pending));
    }
  }
}
```

### 5.4 Error Handling

```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? code;
  const ServerFailure(super.message, {this.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class CacheFailure extends Failure {
  const CacheFailure() : super('Local storage error');
}

// Mapping API errors to Failures
class FailureMapper {
  static Failure fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return ServerFailure(
          e.response?.data?['message'] ?? 'Server error',
          code: e.response?.statusCode,
        );
      default:
        return ServerFailure('Unexpected error');
    }
  }
}
```

---

## 6. Summary of Recommendations

### High Priority
1. **Backend**: Fix JWT secret fallback in `auth.service.ts` - must fail in production if missing
2. **Backend**: Add missing `class-validator` DTO validation decorators
3. **Flutter**: Consolidate to single Dio client (remove duplicate `api_client.dart` vs `api_service.dart`)
4. **Flutter**: Implement proper Drift database with sync queue table

### Medium Priority
1. **Backend**: Extract access control to shared `AccessControlService`
2. **Backend**: Add enum for audit event types
3. **Backend**: Add health check endpoint
4. **Flutter**: Implement full Clean Architecture with domain layer
5. **Flutter**: Add retry logic with exponential backoff for sync

### Low Priority
1. **Prisma**: Rename `LinkedBabyMon` to `BabyMonAccess`
2. **Prisma**: Add composite index on `AuditLog(actorUserId, createdAt)`
3. **Backend**: Add token family tracking for enhanced refresh token security
4. **Flutter**: Add circuit breaker pattern for API calls

---

*Document generated by BabyMon Architecture Review - ARCHITECT subagent*