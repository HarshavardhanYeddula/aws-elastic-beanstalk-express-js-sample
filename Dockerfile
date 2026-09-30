# =========================================================
# Dockerfile — AWS Elastic Beanstalk Express.js sample
# ISEC6000 Assessment 2 — Task 3
#
# Multi-stage build on supported Node 20 LTS (Alpine base),
# with apk upgrade so OS-level CVEs are patched at build time.
# A non-root runtime user provides defence-in-depth.
# =========================================================

# ---- Build stage: install dependencies -----------------
FROM node:20-alpine AS build
WORKDIR /app

# Patch OS packages to the latest security revision
RUN apk update && apk upgrade --no-cache

COPY package*.json ./
RUN npm install --production=false
COPY . .

# ---- Runtime stage: minimal, non-root ------------------
FROM node:20-alpine AS runtime
WORKDIR /app

# Patch OS packages in the runtime layer as well
RUN apk update && apk upgrade --no-cache

# Create non-root user for defence-in-depth
RUN addgroup -S app && adduser -S app -G app

# Copy only what is needed to run
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/app.js ./

# Drop privileges
USER app

EXPOSE 8080
CMD ["node", "app.js"]
