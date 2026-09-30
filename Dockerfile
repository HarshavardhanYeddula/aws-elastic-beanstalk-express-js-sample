FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --production=false
COPY . .

FROM node:16-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/app.js ./
USER app
EXPOSE 8080
CMD ["node", "app.js"]
