# 🚀 BabyMon — Production Deployment Checklist

> **Last Updated:** June 4, 2026  
> **Environment:** Production deployment to Railway + Google Play

---

## 1. Backend — Railway

```bash
npm i -g @railway/cli
railway login
railway init
```

**Railway configuration (`railway.json` at repo root):**
```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "apps/api/Dockerfile"
  },
  "deploy": {
    "startCommand": "node dist/src/main",
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 30
  }
}
```

**Deploy:**
```bash
railway link          # Link to Railway project
railway up            # Deploy
railway domain        # Get production URL
curl https://<domain>/api/health  # Verify
railway run npx prisma migrate deploy
```

---

## 2. Database — Neon.tech

Create a Neon project, get the connection string, set as `DATABASE_URL` in Railway:
```
DATABASE_URL=postgresql://user:pass@ep-xxx.us-east-1.aws.neon.tech/db?sslmode=require
```

---

## 3. API URL Update

**File:** `apps/mobile/lib/core/constants/api_constants.dart`

```dart
// Change:
static const String baseUrl = 'http://10.0.2.2:3000';
// To:
static const String baseUrl = 'https://your-app.railway.app';
```

---

## 4. Firebase Config

**Files needed:**
- `apps/mobile/android/app/google-services.json` — download from Firebase Console
- `apps/mobile/lib/firebase_options.dart` — from `flutterfire configure`

```bash
flutterfire configure --project=your-firebase-project
```

---

## 5. Google Play Submission

```bash
cd apps/mobile
flutter build appbundle      # Release AAB
# Upload: Google Play Console → Testing → Internal Testing → Create Release → Upload AAB
```

**Store listing requirements:**
- Short description (80 chars)
- Full description (4000 chars)
- Screenshots (min 2, 1080px+)
- Feature graphic (1024x500px)
- Privacy policy URL

---

## 6. Environment Variables

| Variable | Value | Source |
|----------|-------|--------|
| `DATABASE_URL` | PostgreSQL connection string | Neon.tech dashboard |
| `JWT_SECRET` | Random 64-char hex string | `openssl rand -hex 32` |
| `JWT_EXPIRES_IN` | `15m` | — |
| `JWT_REFRESH_EXPIRES_IN` | `7d` | — |
| `PORT` | `3000` | Railway default |
| `NODE_ENV` | `production` | Railway |
| `TRIAL_DAYS` | `14` | — |
| `SENDGRID_API_KEY` | SendGrid API key | SendGrid dashboard (email) |
| `AWS_ACCESS_KEY_ID` | AWS access key | AWS IAM (S3 uploads) |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | AWS IAM |
| `AWS_S3_BUCKET` | S3 bucket name | AWS S3 |
| `STRIPE_SECRET_KEY` | Stripe secret key | Stripe dashboard |
| `FIREBASE_CONFIG` | Firebase service account JSON | Firebase Console |
| `FRONTEND_URL` | App URL | Your domain |

---

## 7. Budget Breakdown

| Service | Plan | Monthly Cost | Purpose |
|---------|------|--------------|---------|
| Railway | Hobby | $5/month | Backend API hosting |
| Neon.tech | Free | $0 (3GB) | PostgreSQL database |
| Cloudinary | Free | $0 (25GB) | Image/file uploads |
| Resend (Email) | Free | $0 (100/day) | Email verification |
| Stripe | Pay-per-txn | 2.9% + 30¢ | Subscriptions |
| Google Play | One-time | $25 | App store registration |
| **Total** | | **~$5/month** | + $25 one-time |

---

*Last Updated: June 4, 2026*