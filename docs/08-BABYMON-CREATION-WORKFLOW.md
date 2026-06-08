# BabyMon Creation Workflow — Full Trace

This documents the complete Create BabyMon flow from Flutter UI → HTTP → NestJS backend → database, so future developers can maintain and debug it.

---

## 1. Flow Overview

```
Flutter App (CreateBabyMonScreen)
  │
  ├── User fills form: name, stage, date, gender, traits, specialMove
  │
  └── Tap "Create BabyMon"
        │
        ▼
  POST http://10.0.2.2:3000/api/baby-mons
  Headers:
    Content-Type: application/json
    Authorization: Bearer <JWT accessToken>
  Body:
    {
      "name": "Emma",
      "stageStartType": "BORN",
      "birthDate": "2024-06-01",
      "gender": "MONIOUS",
      "traits": ["Curious", "Playful"],
      "specialMove": "GiggleAttack"
    }
        │
        ▼
  NestJS Backend (port 3000)
        │
        ├── 1. main.ts: setGlobalPrefix('api') → path resolved to /api/baby-mons
        │
        ├── 2. Global ThrottlerGuard → rate limit check (DEFAULT: 100/min)
        │
        ├── 3. BabyMonController (class-level @UseGuards(JwtAuthGuard))
        │     │
        │     └── JwtAuthGuard extends AuthGuard('jwt')
        │           ├── Check @Public() decorator → no → continue
        │           ├── super.canActivate() → triggers Passport JWT strategy
        │           │     └── JwtStrategy.validate(payload)
        │           │           ├── Extract token from Authorization: Bearer <...>
        │           │           ├── Verify signature with JWT_SECRET
        │           │           ├── Check expiry (auto-rejected if expired)
        │           │           └── Lookup user in DB → return {id, email, role}
        │           └── Attach user to request (req.user)
        │
        ├── 4. ValidationPipe (global)
        │     ├── transform: true (auto-type convert query params)
        │     ├── whitelist: true (strip unknown fields)
        │     ├── forbidNonWhitelisted: true (reject unknown fields)
        │     └── Validate CreateBabyMonDto:
        │           name: @IsString() ✓
        │           stageStartType: @IsEnum(StageType: IDEA|CONCEIVED|BORN) ✓
        │           gender: @IsEnum(Gender: MONIOUS|MONIESE|MO) ✓
        │           birthDate: @ValidateIf(stage=BORN) @IsDateString() ✓
        │           conceptionDate: @ValidateIf(stage=CONCEIVED) @IsDateString()
        │           ideaDate: @ValidateIf(stage=IDEA) @IsDateString()
        │           traits: @IsArray() @IsString({each:true}) @ArrayMaxSize(3) ✓
        │           specialMove: @IsOptional() @IsString()
        │           middleName/lastName: @IsOptional() @IsString()
        │
        ├── 5. BabyMonService.create(req.user.id, dto)
        │     ├── Creates BabyMon record in PostgreSQL via Prisma
        │     ├── Creates initial Evolution record (level 1, 0 XP)
        │     └── Returns BabyMon + Evolution data
        │
        └── 6. Response → 201 Created
              {
                "id": "uuid",
                "name": "Emma",
                "stageStartType": "BORN",
                "birthDate": "2024-06-01T00:00:00.000Z",
                "gender": "MONIOUS",
                "traits": ["Curious", "Playful"],
                "specialMove": "GiggleAttack",
                "evolution": { "currentLevel": 1, "xp": 0, "currentStage": "BORN" }
              }
        │
        ▼
  Flutter App receives response
        │
        ├── Extract response.data['id'] → setSelectedBabyMonId(id)
        │     └── Stores ID in FlutterSecureStorage (key: "selected_baby_mon_id")
        │
        └── Navigate to /home → MainScreen → DashboardScreen
              │
              └── DashboardScreen._loadData()
                    ├── Read selectedBabyMonId from secure storage → found
                    ├── GET /api/baby-mons/{id} (verify exists)
                    ├── GET /api/baby-mons/{id}/evolution
                    ├── GET /api/baby-mons/{id}/badges
                    ├── GET /stage-content/{stageKey}
                    └── GET /api/baby-mons/{id}/growth?type=WEIGHT
```

---

## 2. Key Files

| File | Role |
|---|---|
| `apps/mobile/lib/presentation/screens/onboarding/create_baby_mon_screen.dart` | UI form, validation, API call, navigation |
| `apps/mobile/lib/data/api_client.dart` | HTTP client with Dio, token interceptor, refresh logic |
| `apps/mobile/lib/core/constants/api_constants.dart` | baseUrl, endpoint path constants, storage keys |
| `apps/mobile/lib/core/providers.dart` | Single `apiClientProvider` definition |
| `apps/mobile/lib/features/auth/data/datasources/auth_remote_datasource.dart` | Login/register: saves tokens to BOTH SharedPreferences AND FlutterSecureStorage |
| `apps/api/src/baby-mon/baby-mon.controller.ts` | Route handler + JWT guard |
| `apps/api/src/baby-mon/baby-mon.service.ts` | Business logic + Prisma queries |
| `apps/api/src/baby-mon/dto/baby-mon.dto.ts` | Request validation (class-validator) |
| `apps/api/src/common/guards/jwt-auth.guard.ts` | JWT authentication guard (extends AuthGuard('jwt')) |
| `apps/api/src/auth/strategies/jwt.strategy.ts` | Passport JWT strategy (decode + verify token) |

---

## 3. Data Flow Diagram (Simplified)

```
┌─────────────────┐     ┌──────────────┐     ┌───────────────┐     ┌──────────┐
│  Flutter Form    │────▶│  Dio Client   │────▶│  NestJS API    │────▶│  Prisma   │
│  (UI State)      │     │  (Http + JWT) │     │  (Routes+Guard)│     │  (DB)     │
└─────────────────┘     └──────────────┘     └───────────────┘     └──────────┘
         │                      │                     │                    │
         │  _selectedTraits     │  interceptor adds   │  JwtAuthGuard      │  INSERT INTO
         │  _stageType          │  Bearer token       │  validates token   │  "BabyMon"
         │  _gender             │  from               │                     │  + "Evolution"
         │  _birthDate          │  FlutterSecureStg   │  ValidationPipe     │
         │  _nameController     │                     │  checks DTO         │
         │                     │                     │                     │
         │  ◄── response ────── │ ◄── 201 ─────────── │ ◄──── created ───── │
```

---

## 4. Token Storage Architecture

Tokens are stored in **two** places (by design):

| Storage | Key | Used By |
|---|---|---|
| `flutter_secure_storage` | `access_token` | Dio interceptor (auto-attaches to all requests) |
| `flutter_secure_storage` | `refresh_token` | 401 interceptor (auto-refreshes expired tokens) |
| `flutter_secure_storage` | `selected_baby_mon_id` | Dashboard (determines which BabyMon to show) |
| `shared_preferences` | `accessToken` | AuthRemoteDatasource (login state check, logout) |
| `shared_preferences` | `userId` | AuthRemoteDatasource (current user lookup) |

**Critical**: Both `accessToken` AND `refreshToken` must be saved when logging in or registering. The `saveTokens()` call in `AuthRemoteDatasource` passes BOTH tokens to `ApiClient.saveTokens()` which writes both to `FlutterSecureStorage`. The refresh token was previously being discarded (passed as empty string `''`), which caused 401 errors after token expiry.

---

## 5. Common Issues & Debugging

### 5.1 401 Unauthorized — Token rejected
1. Check backend logs: is the token appearing in the `authorization` header?
2. Verify `JwtAuthGuard` extends `AuthGuard('jwt')` (not implements `CanActivate`)
3. Verify `JwtStrategy.validate()` is being called (add console.log if needed)
4. Check token format: `Bearer eyJhbGciOiJIUzI1NiIs...`

### 5.2 400 Bad Request — Validation failed
1. Backend returns structured error in `message` array
2. Common validators that reject:
   - `@IsDateString()` expects `YYYY-MM-DD` format (not ISO 8601 with time)
   - `@ArrayMaxSize(3)` limits array length, NOT string length
   - `@IsEnum(StageType)` rejects unknown values
3. Check the request body in backend logs (enable pinoHttp if needed)

### 5.3 404 Not Found
1. Verify `app.setGlobalPrefix('api')` in main.ts
2. Typed methods in ApiClient need `/api` prefix: `'/api${ApiConstants.babyMons}'`
3. Generic methods (`post()/get()`) auto-prepend `/api` to paths starting with `/`
4. Check if route is registered in controller decorator: `@Controller('baby-mons')`

### 5.4 Dashboard not showing after creation
1. Check `setSelectedBabyMonId()` was called with the response ID
2. Verify babyMonId is stored in FlutterSecureStorage
3. Dashboard `_loadData()` reads the ID and calls `getBabyMon(id)` to verify it exists
4. If BabyMon was deleted, clear the saved ID: `setSelectedBabyMonId('')`
5. Need a fresh login after token expires (fixed by saving refresh token)

### 5.5 Can't create new BabyMon after deleting old one
1. After deletion, use `setSelectedBabyMonId('')` to clear the stored ID
2. Navigate to `/create-baby-mon` or the dashboard will show "Create BabyMon" button
3. Dashboard now verifies the BabyMon exists before loading its data (safety check)
4. If the old ID persists in storage, the app will try to load deleted BabyMon → error

---

## 6. Environment Variables (Backend)

| Variable | Default | Purpose |
|---|---|---|
| `JWT_SECRET` | `babymon-jwt-secret-do-not-use-in-production` | JWT signing key |
| `JWT_EXPIRES_IN` | `15m` | Access token lifetime |
| `DATABASE_URL` | (required) | PostgreSQL connection string |
| `PORT` | `3000` | Server port |

---

## 7. Running Locally

```bash
# Terminal 1: Backend
cd apps/api
npm run start:dev   # Hot-reload on file changes

# Terminal 2: Flutter (Android emulator)
cd apps/mobile
flutter run -d emulator-5554  # 10.0.2.2:3000 auto-maps to host localhost
```

---

## 8. Evolution of This Workflow

### Original bugs fixed (chronological order):
1. **JwtAuthGuard not extending AuthGuard** → 401 on all protected routes (fixed: extends AuthGuard('jwt'))
2. **Refresh token not saved** → 401 after 15min token expiry (fixed: capture refreshToken from response)
3. **Traits @MaxLength(3) vs @ArrayMaxSize(3)** → "traits must be shorter than 3 characters" (fixed: changed validator)
4. **Date format mismatch** → ISO 8601 with time rejected by @IsDateString() (fixed: use yyyy-MM-dd)
5. **Dashboard not reloading** → stale state after create/delete (fixed: added WidgetsBindingObserver + existence check)
6. **Can't create after delete** → stale babyMonId in storage (fixed: clear ID on delete, validate existence)