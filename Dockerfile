FROM node:22-bookworm-slim

# Install system deps: FFmpeg, Chromium, fonts
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip ffmpeg chromium \
    libgbm1 libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
    libxdamage1 libxrandr2 libcups2 libasound2 libpangocairo-1.0-0 \
    libxshmfence1 libgtk-3-0 \
    fonts-liberation fonts-noto-color-emoji fonts-noto-cjk fonts-noto-core \
    fonts-noto-extra fonts-noto-ui-core fonts-freefont-ttf fonts-dejavu-core \
    fontconfig \
    && rm -rf /var/lib/apt/lists/* && apt-get clean && fc-cache -fv

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CONTAINER=true

# Install chrome-headless-shell for deterministic BeginFrame capture
RUN npx @puppeteer/browsers install chrome-headless-shell@stable --path /usr/local/chs \
    && ln -sf /usr/local/chs/chrome-headless-shell-linux-64/chrome-headless-shell /usr/local/bin/chrome-headless-shell

ENV PRODUCER_HEADLESS_SHELL_PATH=/usr/local/bin/chrome-headless-shell

# Install HyperFrames CLI from npm
RUN npm install -g hyperframes@0.8.36

# Create project directory
RUN mkdir -p /app/projects
WORKDIR /app/projects

# Create a default blank composition
RUN hyperframes init default --example blank

# CPU-only VPS optimizations
ENV PRODUCER_LOW_MEMORY_MODE=1
ENV PRODUCER_FORCE_SCREENSHOT=1
ENV PRODUCER_MAX_CONCURRENT_RENDERS=1
ENV HYPERFRAMES_NO_TELEMETRY=1
ENV HYPERFRAMES_NO_UPDATE_CHECK=1
ENV HYPERFRAMES_NO_AUTO_INSTALL=1
ENV HYPERFRAMES_PREVIEW_HOST=0.0.0.0

EXPOSE 3005

CMD ["hyperframes", "preview", "--port", "3005", "--no-open", "--background"]
