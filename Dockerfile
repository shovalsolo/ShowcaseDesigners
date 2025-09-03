# ---------------------------
# 1. Base Image & Environment
# ---------------------------
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------
# 2. Install Chrome & System Dependencies
# ----------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       wget \
       curl \
       unzip \
       gnupg \
       ca-certificates \
       fonts-liberation \
       libnss3 \
       libxss1 \
       libasound2 \
       libatk-bridge2.0-0 \
       libgtk-3-0 \
       libx11-xcb1 \
       libxcomposite1 \
       libxdamage1 \
       libxrandr2 \
       libgbm1 \
       libxi6 \
       python3 \
       python3-pip \
       xdg-utils \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/google-chrome.gpg \
       https://dl.google.com/linux/linux_signing_key.pub \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] \
       http://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# 3. Fetch & Install ChromeDriver with HTTP-fail and Fallback Logic
# ---------------------------------------------------------------
RUN set -eux; \
    # 3.1 Extract full and major versions
    CHROME_FULL=$(google-chrome-stable --version | awk '{print $3}'); \
    CHROME_MAJOR=${CHROME_FULL%%.*}; \
    \
    # 3.2 Try exact match, then major-only, then latest
    DRIVER_VERSION=$( \
      curl -fsSL "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_FULL}" \
      || curl -fsSL "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR}" \
      || curl -fsSL "https://chromedriver.storage.googleapis.com/LATEST_RELEASE" \
    ); \
    echo "🔍 Chrome version: ${CHROME_FULL} → ChromeDriver: ${DRIVER_VERSION}"; \
    \
    # 3.3 Download & install
    wget -qO /tmp/chromedriver.zip \
      "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip"; \
    unzip -q /tmp/chromedriver.zip -d /usr/local/bin; \
    chmod +x /usr/local/bin/chromedriver; \
    rm /tmp/chromedriver.zip

# -----------------------
# 4. Python Dependencies
# -----------------------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------------
# 5. Test & Report
# ---------------
COPY . .
CMD ["pytest", "tests/", "--html=reports/report.html", "--self-contained-html", "-v"]
