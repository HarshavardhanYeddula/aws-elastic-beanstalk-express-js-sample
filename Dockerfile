# ---------------------------------------------------------------
# ISEC6000 Assessment 2 — Node.js application image
# Multi-stage build: keep final image minimal
# ---------------------------------------------------------------
FROM node:16-alpine AS build
WORKDIR /app

# Install dependencies first (leverages Docker layer caching)
COPY package*.json ./
RUN npm install --production=false

# Copy application source
COPY . .

# ---------------------------------------------------------------
# Runtime stage
# ---------------------------------------------------------------
FROM node:16-alpine
WORKDIR /app

# Non-root user for security
RUN addgroup -S app && adduser -S app -G app

# Copy only what we need from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/app.js ./

# Switch to non-root
USER app

EXPOSE 8080
CMD ["node", "app.js"]
