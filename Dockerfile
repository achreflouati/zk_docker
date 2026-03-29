# ZK HRMS — Custom Frappe v15 image
# Installe chaque app séparément pour que Docker cache chaque étape.
# Si une étape échoue, le rebuild repart seulement depuis cette étape.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# ── Dépendances système ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    python3.11 python3.11-dev python3.11-venv python3-pip \
    git curl wget sudo \
    libpango-1.0-0 libpangoft2-1.0-0 libharfbuzz0b libfribidi0 \
    libffi-dev libssl-dev libjpeg-dev libxslt1-dev \
    mariadb-client redis-tools \
    xfonts-75dpi xfonts-base fontconfig \
    && rm -rf /var/lib/apt/lists/*

# ── Node.js 18 + Yarn ─────────────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

# ── wkhtmltopdf ───────────────────────────────────────────────────────────────
RUN curl -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb \
    -o /tmp/wkhtmltox.deb \
    && dpkg -i /tmp/wkhtmltox.deb || apt-get install -f -y \
    && rm /tmp/wkhtmltox.deb

# ── Utilisateur frappe ────────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash frappe \
    && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER frappe
WORKDIR /home/frappe

# ── Bench CLI ────────────────────────────────────────────────────────────────
RUN pip3 install --user frappe-bench
ENV PATH="/home/frappe/.local/bin:$PATH"

# ── bench init (frappe seulement) ────────────────────────────────────────────
RUN bench init \
    --frappe-branch version-15 \
    --skip-redis-config-generation \
    --no-procfile \
    --no-backups \
    frappe-bench

WORKDIR /home/frappe/frappe-bench

# ── Apps (chaque RUN = couche Docker cachée séparément) ───────────────────────
RUN bench get-app --skip-assets payments \
    https://github.com/frappe/payments --branch version-15

RUN bench get-app --skip-assets erpnext \
    https://github.com/frappe/erpnext --branch version-15

RUN bench get-app --skip-assets hrms \
    https://github.com/frappe/hrms --branch version-15

RUN bench get-app --skip-assets zk_hrms \
    https://github.com/achreflouati/ZKHRMS --branch develop

# ── Dépendances Python de zk_hrms (pyzk) ────────────────────────────────────
RUN ./env/bin/pip install --no-cache-dir pyzk

# ── Build assets JS/CSS ────────────────────────────────────────────────────────
RUN bench build --production

# ── Config de base ────────────────────────────────────────────────────────────
RUN echo "{}" > sites/common_site_config.json \
    && ls apps > sites/apps.txt

EXPOSE 8000
CMD ["bench", "serve", "--port", "8000"]
