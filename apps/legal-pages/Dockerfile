# apps/legal-pages/Dockerfile
# Self-contained build context. Railway runs `railway up` from this directory,
# so files referenced by COPY must live INSIDE apps/legal-pages/.
# The legal HTMLs are committed here (updated by `npm run sync` from the canonical
# source at apps/mobile/tool/*). See README.md for the sync workflow.

FROM node:20-alpine

# Create non-root user for runtime safety.
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

# Copy package files first for layer-cache friendliness.
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev \
 && npm cache clean --force \
 && rm -rf /tmp/* /root/.npm

# Copy the rest of the service (server, HTML files, .dockerignore respects size).
COPY --chown=app:app . /app

# Switch to non-root user.
USER app

# Railway surfaces our process on PORT. EXPOSE is documentation only.
EXPOSE 3000

# Liveness probe for Railway's platform-level restart heuristics. Uses node's
# built-in fetch (Node 18+) so we don't depend on busybox `wget --spider` quirks
# across alpine variants. Exits 0 if /health returns 200, else 1.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.status===200?0:1)).catch(()=>process.exit(1))"

CMD ["node", "index.js"]
