# Forge — Running Services

## Core
| Service | Purpose | Port |
|---|---|---|
| Docker | Container runtime | — |
| Git / Gitea | Self-hosted code repos | 3000 |
| Gitea Actions Runner | CI/CD pipeline executor | — |

## Web & Networking
| Service | Purpose | Port |
|---|---|---|
| Nginx | Web server + reverse proxy | 80 / 443 |
| Certbot | SSL certificates via Let's Encrypt | — |

## Monitoring & GUI
| Service | Purpose | Port |
|---|---|---|
| Portainer | Docker management GUI | 9000 |
| Prometheus | Metrics collection | 9090 |
| Grafana | Dashboards and visualization | 3001 |

## Game Servers
| Service | Purpose | Port |
|---|---|---|
| Minecraft Server | `itzg/minecraft-server` Docker image | 25565 |

## Future (when ready)
| Service | Purpose | Port |
|---|---|---|
| Pi-hole | DNS + network ad blocking | 53 / 8080 |
| WireGuard | VPN for remote access | 51820 |
| Vaultwarden | Self-hosted password manager | 8888 |
| HashiCorp Vault | Secrets management for pipelines | 8200 |
| k3s | Lightweight Kubernetes | — |
| Argo CD | GitOps delivery for Kubernetes | 8080 |
| Uptime Kuma | Service health monitoring | 3002 |