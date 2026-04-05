#!/bin/bash
# ── ZK HRMS — Script de démarrage ────────────────────────────────────────────
# Usage: bash start.sh
#
# - Première installation : crée le site automatiquement avec le mot de passe choisi
# - Redémarrage suivant : ignore la création (site déjà existant)
# - Chaque service fait "git pull" au démarrage → reçoit les dernières mises à jour

set -e

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║           ZK HRMS — Démarrage                       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── Détecter si le site existe déjà ────────────────────────────────────────────
SITE_EXISTS=false
if docker compose run --rm --no-deps --quiet-pull backend \
     bash -c 'test -f /home/frappe/frappe-bench/sites/zkhrms.localhost/site_config.json' \
     2>/dev/null; then
  SITE_EXISTS=true
fi

# ── Choisir le mot de passe admin ──────────────────────────────────────────────
if [ "$SITE_EXISTS" = "true" ]; then
  echo "✅  Site détecté — redémarrage normal (aucune installation requise)"
  echo ""
  ADMIN_PASSWORD="admin"   # valeur non utilisée pour ce démarrage
else
  echo "🆕  Première installation détectée"
  echo ""
  echo -n "🔑  Mot de passe Administrator [défaut: admin, validation auto dans 10s]: "

  ADMIN_PASSWORD=""
  if read -t 10 ADMIN_PASSWORD 2>/dev/null; then
    echo   # retour à la ligne après la saisie
  else
    echo   # retour à la ligne après le timeout
    echo "⏱   Timeout — mot de passe par défaut utilisé : admin"
  fi

  ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin}"
  echo ""
  echo "   Mot de passe retenu : $ADMIN_PASSWORD"
  echo ""
fi

# ── Lancer la stack ────────────────────────────────────────────────────────────
echo "🚀  Démarrage des services..."
echo ""
ADMIN_PASSWORD="$ADMIN_PASSWORD" docker compose up -d

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$SITE_EXISTS" = "false" ]; then
  echo ""
  echo " ⏳  Première installation en cours — suivre la progression :"
  echo "    docker compose logs -f create-site"
  echo ""
  echo " Une fois terminé, le site sera accessible sur :"
  echo "    🌐  http://localhost"
  echo "    👤  Administrator / $ADMIN_PASSWORD"
  echo "    📊  http://localhost/app/zk-dashboard"
else
  echo ""
  echo " 🌐  http://localhost"
  echo " 📊  http://localhost/app/zk-dashboard"
fi

echo ""
echo " 🔍  Statut : docker compose ps"
echo " 📋  Logs   : docker compose logs -f backend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
