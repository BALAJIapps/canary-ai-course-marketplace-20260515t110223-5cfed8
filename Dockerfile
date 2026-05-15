
# Install dependencies, build, and start the Next.js app
FROM --platform=linux/amd64 node:20-alpine AS base

# Install pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Base image for production
FROM base AS builder

WORKDIR /app

# Install dependencies
COPY .pnpm-lock.yaml ./
COPY package.json ./
RUN pnpm install --frozen-lockfile

# Build the app
COPY . .
RUN pnpm build

# Production image
FROM base AS runner

WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nextjs
RUN adduser --system --uid 1001 nextjs
USER nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

ENV PORT 3000

CMD ["pnpm", "start", "-H", "0.0.0.0", "-p", "$PORT"]
