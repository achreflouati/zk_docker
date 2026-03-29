#!/bin/bash
# ── ZK HRMS — Initialisation du site (lancer UNE SEULE FOIS) ─────────────────
# Usage: docker compose exec backend bash /workspace/init-site.sh

set -e

SITE="zkhrms.localhost"
ADMIN_PASS="admin"
DB_ROOT_PASS="admin"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ZK HRMS — Création du site Frappe"
echo " Site : $SITE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /home/frappe/frappe-bench

# Vérifie si le site existe déjà
if bench --site "$SITE" list-apps &>/dev/null; then
    echo "⚠️  Le site $SITE existe déjà. Abandon."
    echo "   Pour repartir à zéro: docker compose down -v"
    exit 0
fi

echo ""
echo "[1/5] Création du site..."
bench new-site "$SITE" \
    --db-root-password "$DB_ROOT_PASS" \
    --admin-password "$ADMIN_PASS" \
    --no-mariadb-socket

echo ""
echo "[2/5] Installation ERPNext..."
bench --site "$SITE" install-app erpnext

echo ""
echo "[3/5] Installation HRMS..."
bench --site "$SITE" install-app hrms

echo ""
echo "[4/5] Installation ZK HRMS..."
bench --site "$SITE" install-app zk_hrms

echo ""
echo "[5/5] Configuration finale..."
bench --site "$SITE" set-config allow_cors 1
bench use "$SITE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✅ Installation terminée !"
echo ""
echo " 🌐 Ouvrir : http://localhost"
echo " 👤 Login  : Administrator"
echo " 🔑 Mot de passe : $ADMIN_PASS"
echo " 📊 ZK Dashboard : http://localhost/app/zk-dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
