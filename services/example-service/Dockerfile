# Example multi-stage Dockerfile (small, fast dev image)
FROM node:18-alpine AS build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build || true

FROM node:18-alpine
WORKDIR /usr/src/app
COPY --from=build /usr/src/app .
ENV NODE_ENV=development
EXPOSE 3000
CMD ["npm", "run", "start:dev"]
