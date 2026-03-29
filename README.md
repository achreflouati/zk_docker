# ZK HRMS — Docker Local (Windows)

Frappe v15 + ERPNext v15 + HRMS + zk_hrms sur Docker Desktop Windows.

---

## Prérequis

1. **Docker Desktop** → https://www.docker.com/products/docker-desktop/
   - Installer, activer WSL2 quand demandé, redémarrer Windows
2. **Ton compte Docker Hub** : `achreflouati`

---

## Étape 1 — Télécharger ce dossier sur Windows

Copie les fichiers depuis le serveur via WinSCP/FileZilla ou SCP :
```
/home/frappesys/zk-docker/ → C:\Users\TonNom\zk-docker\
```

---

## Étape 2 — Builder l'image (une seule fois, ~20 min)

Ouvre **PowerShell** dans le dossier `zk-docker` :

```powershell
# Builder l'image localement
.\build.ps1

# OU builder ET pousser sur Docker Hub (pour réutiliser plus tard)
.\build.ps1 -Push
```

> La prochaine fois tu feras juste `docker pull achreflouati/zk-hrms:v15`

---

## Étape 3 — Démarrer les services

```powershell
docker compose up -d
```

Attends ~20 secondes que MariaDB démarre.

---

## Étape 4 — Créer le site (une seule fois)

```powershell
docker compose exec backend bash /workspace/init-site.sh
```

Durée : 5-10 minutes.

---

## Étape 5 — Ouvrir dans le navigateur

```
http://localhost
Login    : Administrator
Password : admin

ZK Dashboard : http://localhost/app/zk-dashboard
```

---

## Usage quotidien

```powershell
docker compose up -d        # démarrer
docker compose down         # arrêter (données conservées)
docker compose logs -f backend   # voir les logs
```

## Reset complet (tout supprimer)

```powershell
docker compose down -v
# puis relancer Étape 3 et 4
```

---

## Connexion à la vraie pointeuse ZKTeco

La pointeuse doit être sur le même réseau WiFi/LAN que ton PC Windows.

Dans ZK Dashboard → créer un nouveau ZK Device :
- **IP Address** : l'IP de ta pointeuse (ex: `192.168.1.100`)
- **Port** : `4370`
- **use_simulator** : décoché ✗

Docker Desktop sur Windows peut atteindre les appareils du réseau local directement.
