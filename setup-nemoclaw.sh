#!/usr/bin/env bash
# NemoClaw Setup Script
# Sätter upp NVIDIA NemoClaw med OpenShell sandbox och inferens-routing

set -euo pipefail

# --- Färger ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║     NVIDIA NemoClaw Setup Script     ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ─── 1. Krav-kontroll ─────────────────────────────────────────────────────────
info "Kontrollerar systemkrav..."

OS=$(uname -s)
case "$OS" in
  Linux)
    if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
      warn "Testad på Ubuntu 22.04+. Andra distros kan fungera men är inte officiellt stödda."
    fi
    ;;
  Darwin)
    warn "macOS detekterat. Docker Desktop eller Colima krävs som container-runtime."
    ;;
  *)
    error "Operativsystem $OS stöds inte."
    ;;
esac

# RAM-kontroll
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)
TOTAL_RAM_GB=$(( TOTAL_RAM_KB / 1024 / 1024 ))
if [ "$TOTAL_RAM_GB" -lt 8 ]; then
  warn "Minne: ${TOTAL_RAM_GB}GB detekterat. Minst 8GB rekommenderas (16GB optimalt)."
else
  success "Minne: ${TOTAL_RAM_GB}GB — OK"
fi

# Diskutrymme
FREE_DISK_GB=$(df -BG / | awk 'NR==2 {gsub("G",""); print $4}')
if [ "$FREE_DISK_GB" -lt 20 ]; then
  warn "Ledigt diskutrymme: ${FREE_DISK_GB}GB. Minst 20GB rekommenderas (40GB optimalt)."
else
  success "Diskutrymme: ${FREE_DISK_GB}GB ledigt — OK"
fi

# Node.js
if command -v node &>/dev/null; then
  NODE_VER=$(node --version | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 20 ]; then
    success "Node.js $NODE_VER — OK"
  else
    warn "Node.js $NODE_VER hittad. Version 20+ rekommenderas."
  fi
else
  warn "Node.js ej hittad. Installera Node.js 20+ om det behövs av dina agenter."
fi

# Docker / container-runtime
if command -v docker &>/dev/null; then
  if docker info &>/dev/null 2>&1; then
    success "Docker körs — OK"
  else
    error "Docker finns men körs inte. Starta Docker-daemonen och försök igen."
  fi
else
  error "Docker hittades inte. Installera Docker: https://docs.docker.com/get-docker/"
fi

# ─── 2. NVIDIA API-nyckel ─────────────────────────────────────────────────────
echo ""
if [ -z "${NVIDIA_API_KEY:-}" ]; then
  echo -e "${YELLOW}En NVIDIA API-nyckel krävs för NemoClaw.${NC}"
  echo "  Hämta din nyckel på: https://build.nvidia.com"
  echo ""
  read -rsp "  Klistra in din NVIDIA API-nyckel: " NVIDIA_API_KEY
  echo ""
  if [ -z "$NVIDIA_API_KEY" ]; then
    error "Ingen API-nyckel angiven. Avbryter."
  fi
else
  info "NVIDIA_API_KEY hittad i miljön."
fi

# ─── 3. Installera NemoClaw ───────────────────────────────────────────────────
echo ""
info "Hämtar och kör NemoClaw-installationsskriptet från NVIDIA..."
echo ""
warn "OBS: Tidigt skede — gränssnitt och API kan ändras utan varsel."
echo ""

export NVIDIA_API_KEY
curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash

# ─── 4. Verifiera installation ────────────────────────────────────────────────
echo ""
if command -v nemoclaw &>/dev/null; then
  success "nemoclaw CLI installerad: $(nemoclaw --version 2>/dev/null || echo 'version okänd')"
else
  warn "nemoclaw CLI ej hittad i PATH. Källar om shell-konfigurationen..."
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc" 2>/dev/null || source "${HOME}/.zshrc" 2>/dev/null || true
  if command -v nemoclaw &>/dev/null; then
    success "nemoclaw CLI tillgänglig efter shell-reload."
  else
    warn "Kan inte hitta nemoclaw i PATH. Öppna ett nytt terminalfönster och försök igen."
  fi
fi

# ─── 5. Onboarding ────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Installation klar!${NC}"
echo ""
echo "  Nästa steg:"
echo "  1. Kör onboarding-guiden:   nemoclaw onboard"
echo "  2. Anslut till din sandbox:  nemoclaw <agent-namn> connect"
echo "  3. Chatta via TUI:           openclaw tui"
echo ""
echo "  Dokumentation: https://docs.nvidia.com/nemoclaw/latest/"
echo "  GitHub:        https://github.com/NVIDIA/NemoClaw"
echo ""
