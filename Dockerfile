# =========================================================
# Dockerfile — AWS Elastic Beanstalk Express.js sample
# ISEC6000 Assessment 2 — Task 3
# Multi-stage build; runtime based on supported Node 20 LTS
# to satisfy the Trivy HIGH/CRITICAL security gate.
# =========================================================

# ---- Build stage: install dependencies -----------------
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --production=false
COPY . .

# ---- Runtime stage: minimal, non-root ------------------
FROM node:20-alpine AS runtime
WORKDIR /app

# Create non-root user for defence-in-depth
RUN addgroup -S app && adduser -S app -G app

# Copy only what's needed to run
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/app.js ./

# Drop privileges
USER app

EXPOSE 8080
CMD ["node", "app.js"]
