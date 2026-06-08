# BabyMon AWS Deployment Guide

## A Step-by-Step Guide for Non-Technical Founders

This guide walks you through deploying BabyMon to AWS and submitting to app stores. We'll take it one step at a time.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [AWS Account Setup](#2-aws-account-setup)
3. [RDS Database Setup](#3-rds-database-setup)
4. [S3 Storage Setup](#4-s3-storage-setup)
5. [EC2 Server Setup](#5-ec2-server-setup)
6. [Domain & SSL](#6-domain--ssl)
7. [Stripe Configuration](#7-stripe-configuration)
8. [Environment Variables](#8-environment-variables)
9. [Deploy Application](#9-deploy-application)
10. [App Store Submission](#10-app-store-submission)
11. [Google Play Store Submission](#11-google-play-store-submission)
12. [Post-Launch](#12-post-launch)

---

## 1. Prerequisites

Before we begin, you'll need:

- [ ] **AWS Account** - Sign up at [aws.amazon.com](https://aws.amazon.com)
- [ ] **Domain Name** - Buy from GoDaddy, Namecheap, or AWS (e.g., babymon.app)
- [ ] **Stripe Account** - Sign up at [stripe.com](https://stripe.com)
- [ ] **GitHub Account** - For CI/CD (optional but recommended)
- [ ] **Apple Developer Account** - $99/year at [developer.apple.com](https://developer.apple.com)
- [ ] **Google Play Developer Account** - $25 one-time at [play.google.com/console](https://play.google.com/console)

**Estimated Costs:**
- AWS (MVP): ~$30-50/month
- Apple Developer: $99/year
- Google Play: $25 one-time
- Domain: ~$10-20/year

---

## 2. AWS Account Setup

### Step 2.1: Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com) and click "Create an AWS Account"
2. Enter your email and choose "Personal" account type
3. Enter your name, address, and phone number
4. Add a valid credit card (required even for free tier)
5. Complete identity verification

### Step 2.2: Set Up Billing Alerts

1. Go to **AWS Console** → Search "Billing"
2. Click **Budgets** → **Create budget**
3. Choose "Cost budget"
4. Set monthly limit: **$50**
5. Add email alerts at 80% and 100%

### Step 2.3: Create IAM User (Important!)

Don't use your root account for daily operations:

1. Search **IAM** in AWS Console
2. Click **Users** → **Add users**
3. Username: `babymon-admin`
4. Select **AWS Management Console access**
5. Create a password (download the CSV!)
6. Attach policy: **AdministratorAccess** (for now)
7. Save the access key ID and secret access key

---

## 3. RDS Database Setup

### Step 3.1: Create Database

1. Search **RDS** in AWS Console
2. Click **Create database**
3. Choose:
   - **Engine**: PostgreSQL
   - **Version**: PostgreSQL 16 (or latest)
   - **Template**: Free tier
4. Settings:
   - DB instance identifier: `babymon-prod`
   - Master username: `babymon`
   - Master password: Create a strong password (save this!)
5. Instance configuration:
   - db.t3.micro (Free tier eligible)
6. Storage:
   - 20 GB (gp3)
   - Enable storage autoscaling (optional)
7. Connectivity:
   - **VPC**: Default VPC
   - **Public access**: No (we'll use private)
   - **Security group**: Create new
8. Click **Create database**

**Save these details:**
- Endpoint: `babymon-prod.xxxx.us-east-1.rds.amazonaws.com`
- Port: `5432`
- Username: `babymon`
- Password: [Your password]

### Step 3.2: Configure Security Group

1. Go to **EC2** → **Security Groups**
2. Find your RDS security group
3. Edit **Inbound rules**:
   - Type: PostgreSQL
   - Source: Your EC2 security group (we'll create this later)

---

## 4. S3 Storage Setup

### Step 4.1: Create Bucket

1. Search **S3** in AWS Console
2. Click **Create bucket**
3. Bucket name: `babymon-media-[yourname]` (must be unique globally)
4. Region: Same as your RDS (e.g., US East N. Virginia)
5. Uncheck "Block all public access" (we'll use signed URLs)
6. Enable versioning (recommended)
7. Click **Create bucket**

### Step 4.2: Configure CORS

1. Click your bucket → **Permissions** tab
2. Scroll to **Cross-origin resource sharing (CORS)**
3. Edit and paste:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
        "AllowedOrigins": ["https://yourdomain.com", "https://www.yourdomain.com"],
        "ExposeHeaders": []
    }
]
```

Replace `yourdomain.com` with your actual domain.

### Step 4.3: Create IAM Policy

1. Search **IAM** → **Policies** → **Create policy**
2. JSON tab:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::babymon-media-*/*"
        }
    ]
}
```

3. Policy name: `babymon-s3-policy`
4. Create

### Step 4.4: Attach Policy to User

1. Go to **IAM** → **Users** → `babymon-admin`
2. Click **Add permissions** → **Attach policies**
3. Select `babymon-s3-policy`

---

## 5. EC2 Server Setup

### Step 5.1: Create Key Pair

1. Search **EC2** → **Key Pairs** → **Create key pair**
2. Name: `babymon-prod`
3. Type: RSA
4. Format: `.pem` (for Mac/Linux) or `.ppk` (for Windows)
5. **Save this file securely!** You'll need it to connect.

### Step 5.2: Create Security Group

1. Search **EC2** → **Security Groups** → **Create security group**
2. Name: `babymon-sg`
3. Inbound rules:
   - SSH (Port 22): Your IP only
   - HTTP (Port 80): Anywhere
   - HTTPS (Port 443): Anywhere
   - Custom TCP (Port 3000): Anywhere (for API)

### Step 5.3: Launch Instance

1. Search **EC2** → **Instances** → **Launch instances**
2. Name: `babymon-server`
3. AMI: **Amazon Linux 2023** (Free tier eligible)
4. Instance type: **t3.medium** (2 vCPU, 4GB RAM - $25-30/month)
5. Key pair: Select `babymon-prod`
6. Network settings:
   - VPC: Default
   - Subnet: Public subnet
   - Auto-assign public IP: Enable
   - Security group: Select `babymon-sg`
7. Storage: 30 GB gp3
8. Click **Launch**

### Step 5.4: Connect to Server

**For Mac/Linux:**
```bash
ssh -i /path/to/babymon-prod.pem ec2-user@your-public-ip
```

**For Windows:**
- Download [PuTTY](https://www.putty.org/)
- Use PuTTYgen to convert .pem to .ppk
- Connect with PuTTY

### Step 5.5: Install Docker on EC2

Once connected, run:

```bash
# Update system
sudo yum update -y

# Install Docker
sudo amazon-linux-extras install docker

# Start Docker
sudo service docker start

# Add user to docker group
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Step 5.6: Configure Docker to Start on Boot

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

---

## 6. Domain & SSL

### Step 6.1: Register Domain

1. Go to [Route 53](https://console.aws.amazon.com/route53) in AWS Console
2. Click **Registered domains** → **Register domain**
3. Search for your desired domain (e.g., babymon.app)
4. Complete registration ($10-20/year)

### Step 6.2: Create Hosted Zone

1. In Route 53, click **Hosted zones** → **Create hosted zone**
2. Domain name: `yourdomain.com`
3. Create

### Step 6.3: Get SSL Certificate (Free!)

1. Search **ACM** (AWS Certificate Manager)
2. Click **Request certificate**
3. Domain name: `yourdomain.com`
4. Add another: `*.yourdomain.com` (wildcard)
5. Validation method: **DNS validation**
6. Request

### Step 6.4: Validate Certificate

1. Click your certificate → **Create record in Route 53**
2. Click **Create records** (usually takes 5-10 minutes to validate)

### Step 6.5: Set Up Load Balancer (Optional but Recommended)

For production, use an Application Load Balancer:

1. Search **EC2** → **Load Balancers** → **Create Load Balancer**
2. Type: **Application Load Balancer**
3. Scheme: **Internet-facing**
4. Security groups: Select `babymon-sg`
5. Listeners: HTTP (80) and HTTPS (443)
6. Target group: Create new, instance type
7. Register your EC2 instance
8. For HTTPS, select your ACM certificate

**Alternative (Simpler):** Use CloudFront with S3 for static files only.

---

## 7. Stripe Configuration

### Step 7.1: Create Stripe Account

1. Go to [stripe.com](https://stripe.com) and sign up
2. Complete business verification

### Step 7.2: Get API Keys

1. In Stripe Dashboard, click **Developers** → **API keys**
2. Copy:
   - Publishable key (starts with `pk_test_`)
   - Secret key (starts with `sk_test_`)

### Step 7.3: Create Products

1. Click **Products** → **Add product**
2. Create these products:

**Core Subscription:**
- Name: BabyMon Core
- Price: $7.99/month or $49.99/year
- ID: Save the price ID (starts with `price_`)

**AI Companion Subscription:**
- Name: BabyMon AI Companion
- Price: $12.99/month or $99.99/year
- ID: Save the price ID

### Step 7.4: Configure Webhooks

1. Click **Webhooks** → **Add endpoint**
2. URL: `https://api.yourdomain.com/api/subscriptions/webhook`
3. Events to listen:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_failed`
4. Click **Add endpoint**
5. Copy the **Signing secret** (starts with `whsec_`)

### Step 7.5: Get Webhook Signing Secret

You'll need:
- `STRIPE_SECRET_KEY`: From API keys
- `STRIPE_WEBHOOK_SECRET`: From webhook setup

---

## 8. Environment Variables

Create a `.env` file on your EC2 server:

```bash
# Database (from RDS)
DATABASE_URL="postgresql://babymon:YOUR_PASSWORD@babymon-prod.xxxx.us-east-1.rds.amazonaws.com:5432/babymon"

# JWT
JWT_SECRET="generate-a-long-random-string-here"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Stripe
STRIPE_SECRET_KEY="sk_test_xxx"
STRIPE_PUBLISHABLE_KEY="pk_test_xxx"
STRIPE_WEBHOOK_SECRET="whsec_xxx"
STRIPE_PRICE_CORE_MONTHLY="price_xxx"
STRIPE_PRICE_CORE_YEARLY="price_xxx"
STRIPE_PRICE_AI_MONTHLY="price_xxx"
STRIPE_PRICE_AI_YEARLY="price_xxx"

# AWS S3
AWS_REGION="us-east-1"
AWS_ACCESS_KEY_ID="AKIAxxx"
AWS_SECRET_ACCESS_KEY="xxx"
S3_BUCKET_NAME="babymon-media-yourname"

# App
PORT=3000
NODE_ENV="production"
API_URL="https://api.yourdomain.com"
FRONTEND_URL="https://yourdomain.com"

# Trial
TRIAL_DAYS=14
```

**Generate a secure JWT secret:**
```bash
openssl rand -hex 64
```

---

## 9. Deploy Application

### Option A: Direct Deployment (Recommended for MVP)

1. SSH into your EC2 instance
2. Clone your repository:

```bash
cd /home/ec2-user
git clone https://github.com/yourusername/babymon.git
cd babymon/apps/api
```

3. Create `.env` file with your environment variables

4. Install and run:

```bash
npm install
npm run build
npm run prisma:generate
npm run prisma:migrate:prod
npm run start:prod
```

### Option B: Docker Deployment

1. Create `Dockerfile` in your API directory:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npx prisma generate
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
```

2. Build and run:

```bash
docker build -t babymon/api .
docker run -d -p 3000:3000 --env-file .env babymon/api
```

### Option C: Use PM2 for Production

```bash
npm install -g pm2
pm2 start npm --name babymon -- run start:prod
pm2 startup
pm2 save
```

---

## 10. App Store Submission

### Step 10.1: Prepare App Icons

You need these sizes:
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro)
- 152x152 (iPad)
- 76x76 (iPad @2x)

Use [App Icon Generator](https://appiconmaker.co/) or hire a designer.

### Step 10.2: Create App Store Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - Platforms: iOS
   - Name: BabyMon
   - Primary Language: English
   - Bundle ID: com.babymon.app (create in Apple Developer)
   - SKU: babymon-001
4. Submit

### Step 10.3: Fill App Information

**App Information:**
- Category: Lifestyle, Medical (optional)
- Content Rights: No
- Age Rating: 4+

**Pricing and Availability:**
- Price Tier: Subscription
- Configure your subscriptions in App Store Connect

**App Information - Long Description:**
```
BabyMon - Smart Evolving Parenting Companion

Track your baby's development from conception through 24 months with gamified evolution mechanics.

Features:
- Milestone tracking with photos
- Feeding logs (breastmilk, formula, solid food)
- Health records (vaccinations, pediatric visits)
- XP and badge system
- Stage-based guidance
- Journey journal

14-day free trial. Subscribe for premium features.

Educational purposes only. Not medical advice.
```

### Step 10.4: Upload Build

1. In Xcode:
   - Open your Flutter project
   - Select **Product** → **Archive**
   - Click **Distribute App**
   - Upload to App Store Connect

2. Or use Transporter (Mac app from Apple)

### Step 10.5: Submit for Review

1. In App Store Connect, select your build
2. Fill out:
   - Contact email
   - Notes: "This is a parenting companion app that tracks milestones, feeding, and health records. It does NOT provide medical advice."
3. Submit

**Review Time:** 24-48 hours typically

---

## 11. Google Play Store Submission

### Step 11.1: Create App Bundle

1. Open Flutter project in terminal
2. Build release APK/AAB:

```bash
# For Android
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# or .aab for Play Store
```

### Step 11.2: Create Google Play Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill:
   - Name: BabyMon
   - Default language: English (US)
   - App type: App
4. Create

### Step 11.3: Fill Store Listing

**Title:** BabyMon
**Short Description:** Smart parenting companion for tracking baby's growth
**Full Description:** (similar to App Store)

**Graphics:**
- Screenshots: 4-8 screenshots (phone and tablet)
- Feature graphic: 1024x500
- App icon: 512x512

### Step 11.4: Complete Content Rating

1. Click **Content rating** → **Continue**
2. Answer questionnaire about:
   - Targeted age group
   - User-generated content
   - Violence, profanity, etc.
3. Submit

### Step 11.5: Configure Pricing

1. Click **Pricing and distribution**
2. Set as Free or Paid
3. Add subscription pricing

### Step 11.6: Data Safety

**This is critical!** Fill in the Data Safety form:

1. Click **Data Safety** → **Manage**
2. Answer:

| Question | Answer |
|----------|--------|
| Does your app collect user data? | Yes |
| Is data encrypted in transit? | Yes |
| Is data encrypted at rest? | Yes |
| Can users delete data? | Yes |
| Location data? | No |
| Financial info? | No |
| Health info? | Yes (stored locally) |
| Messages? | No |
| Photos/videos? | Yes (stored locally) |
| App activity? | Yes |
| Web browsing? | No |

3. Submit

### Step 11.7: Upload App Bundle

1. Click **Releases** → **Production**
2. Click **Create new release**
3. Upload your `.aab` file
4. Release name: v1.0.0
5. Click **Save** → **Review release**

### Step 11.8: Submit for Review

1. Click **Submit for review**
2. Confirm all sections are complete
3. Submit

**Review Time:** 1-7 days typically

---

## 12. Post-Launch

### Monitoring

1. Set up CloudWatch alerts for:
   - High CPU usage
   - High memory usage
   - Database connections

2. Use Sentry for error tracking (free tier available)

### Backups

1. RDS: Enable automated backups
   - Go to RDS → Your database → **Modify**
   - Backup: Enable
   - Retention: 7 days

2. Manual database snapshots weekly

### Updates

1. Make changes in your code
2. Test locally
3. Push to GitHub
4. SSH into server and pull:
   ```bash
   cd /home/ec2-user/babymon
   git pull
   npm run build
   pm2 restart babymon
   ```

---

## Quick Reference Checklist

### AWS Setup
- [ ] AWS account created
- [ ] IAM user created
- [ ] RDS PostgreSQL created
- [ ] S3 bucket created
- [ ] EC2 instance launched
- [ ] Security groups configured

### Domain & SSL
- [ ] Domain registered
- [ ] SSL certificate issued
- [ ] DNS configured

### Stripe
- [ ] Products created
- [ ] Webhooks configured

### App Stores
- [ ] App Store Connect: Build uploaded
- [ ] Google Play Console: App bundle uploaded
- [ ] Both: Submitted for review

---

## Need Help?

- **AWS Documentation:** https://docs.aws.amazon.com
- **Stripe Docs:** https://stripe.com/docs
- **Apple Developer:** https://developer.apple.com/help
- **Google Play:** https://developer.android.com/distribute

---

*Last updated: February 2026*
