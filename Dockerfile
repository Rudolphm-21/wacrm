# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# wacrm — Next.js 16 app, built for Easypanel (project `evapi`, service `wacrm`).
#
# Multi-stage build producing a `next build` standalone output (see
# `output: "standalone"` in next.config.ts) so the final image only ships
# the traced node_modules subset instead of the whole dependency tree.
#
# NEXT_PUBLIC_* variables are inlined into the JS bundle at build time, so
# they must be supplied as Docker BUILD ARGS in Easypanel (App > Build),
# not just as runtime environment variables. Secrets like
# SUPABASE_SERVICE_ROLE_KEY, ENCRYPTION_KEY and META_APP_SECRET are read at
# runtime only — set those as regular (runtime) environment variables.
# ---------------------------------------------------------------------------

FROM node:22-alpine AS base

# ---- Dependencies ----------------------------------------------------------
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ---- Build ------------------------------------------------------------------
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Public (browser-exposed) config needed at build time.
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG NEXT_PUBLIC_SITE_URL
ARG NEXT_PUBLIC_APP_LOCALE
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL \
    NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY \
    NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL \
    NEXT_PUBLIC_APP_LOCALE=$NEXT_PUBLIC_APP_LOCALE \
    NEXT_TELEMETRY_DISABLED=1

RUN npm run build

# ---- Runtime ------------------------------------------------------------------
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3100 \
    HOSTNAME=0.0.0.0

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3100

CMD ["node", "server.js"]
