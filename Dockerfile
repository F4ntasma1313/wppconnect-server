# FROM node:22.22.2-alpine AS base
# WORKDIR /usr/src/wpp-server
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# # Install build dependencies and runtime libraries for sharp
# RUN apk update && \
#     apk add --no-cache \
#     vips \
#     vips-dev \
#     fftw-dev \
#     gcc \
#     g++ \
#     make \
#     libc6-compat \
#     pkgconfig \
#     python3 \
#     && rm -rf /var/cache/apk/*

# # To make sure yarn 4 uses node-modules linker
# COPY .yarnrc.yml ./

# # Copy only package.json to leverage Docker cache
# COPY package.json ./
# COPY yarn.lock ./

# # Enable corepack and prepare yarn 4.12.0
# RUN corepack enable && \
#     corepack prepare yarn@4.12.0 --activate

# # Install dependencies with immutable lockfile
# RUN yarn install

# FROM base AS build
# WORKDIR /usr/src/wpp-server
# COPY . .
# RUN yarn install
# RUN yarn build

# FROM build AS runtime
# WORKDIR /usr/src/wpp-server/

# # Install runtime dependencies (chromium and vips libraries)
# RUN apk add --no-cache \
#     chromium \
#     vips \
#     fftw

# EXPOSE 21465
# ENTRYPOINT ["node", "dist/server.js"]


FROM node:22-bookworm

WORKDIR /usr/src/wpp-server

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN apt-get update && apt-get install -y \
    chromium \
    dumb-init \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    xdg-utils \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm install --legacy-peer-deps

COPY . .

RUN npm run build

EXPOSE 21465

ENTRYPOINT ["dumb-init", "node", "--max-old-space-size=4096", "dist/server.js"]