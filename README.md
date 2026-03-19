# NemoClaw

Installationsskript för NVIDIA NemoClaw — ett agentramverk med OpenShell sandbox och inferens-routing.

## Krav

| Krav | Minimum | Rekommenderat |
|------|---------|---------------|
| OS | Ubuntu 22.04 / macOS | Ubuntu 22.04+ |
| RAM | 8 GB | 16 GB |
| Disk | 20 GB ledigt | 40 GB ledigt |
| Node.js | — | 20+ |
| Docker | Krävs | Senaste |

En [NVIDIA API-nyckel](https://build.nvidia.com) krävs.

## Snabbstart

```bash
# Alternativ 1: Kör direkt
bash setup-nemoclaw.sh

# Alternativ 2: Med API-nyckel i miljön
NVIDIA_API_KEY=nvapi-xxxx bash setup-nemoclaw.sh
```

## Efter installation

```bash
nemoclaw onboard          # Onboarding-guide
nemoclaw <agent> connect  # Anslut till sandbox
openclaw tui              # Chatta via TUI
```

## Resurser

- Dokumentation: https://docs.nvidia.com/nemoclaw/latest/
- GitHub (NVIDIA): https://github.com/NVIDIA/NemoClaw
- API-nycklar: https://build.nvidia.com
