# Stage 1: Build
FROM node:20-bookworm AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy prisma schema and generate client
COPY prisma ./prisma/
RUN npx prisma generate

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-bookworm AS production

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy prisma schema and generate client for this platform
COPY prisma ./prisma/
RUN npx prisma generate

# Copy built artifacts from builder
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN groupadd --gid 1001 nodejs && useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home nestjs

USER nestjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health/live', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); })"

CMD ["node", "dist/src/main"]
