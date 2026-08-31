# ----- Build Stage -----
FROM node:lts-alpine AS builder
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.33.0 --activate

# Copy package and configuration
COPY package.json pnpm-lock.yaml tsconfig.json .npmrc ./

# Copy source code
COPY src ./src

# Install dependencies and build
RUN pnpm install --frozen-lockfile && pnpm run build

# ----- Production Stage -----
FROM node:lts-alpine
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.33.0 --activate

# Copy built artifacts
COPY --from=builder /app/build ./build

# Copy package.json and lockfile for production install
COPY package.json pnpm-lock.yaml .npmrc ./

# Install production dependencies, then remove package managers unused at runtime.
RUN pnpm install --prod --frozen-lockfile --ignore-scripts \
  && rm -rf /root/.cache/node/corepack /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
  && rm -f /usr/local/bin/corepack /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/pnpm /usr/local/bin/pnpx

# Expose port 3000 (internal container port)
EXPOSE 3000

# Add health check for HTTP mode
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD if [ "$MCP_TRANSPORT" = "http" ] || [ "$MCP_TRANSPORT" = "sse" ]; then \
        wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1; \
      else \
        exit 0; \
      fi

# Default command supports both stdio and HTTP modes
CMD ["node", "build/index.js"]
