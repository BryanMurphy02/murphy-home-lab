# Hardware

Documentation of all physical hardware in the murphy-home-lab setup.

---

## Server — MurphyServer

| Component | Details |
|-----------|---------|
| **Device Name** | MurphyServer |
| **CPU** | Intel Core i7-6700 @ 3.40GHz (4 cores, 8 threads) |
| **RAM** | 8GB DDR4 2133MHz (2x 4GB DIMM) |
| **OS** | Windows 11 64-bit |
| **Storage (C:\\)** | 150GB SSD — OS and applications |
| **Storage (D:\\)** | Internal HDD — media library (`D:\Plex`) |
| **GPU** | No dedicated GPU |
| **Pen/Touch** | None |

---

## RAM Slots

| Slot | Installed | Details |
|------|-----------|---------|
| DIMM 1 | ✅ | 4GB DDR4 2133MHz |
| DIMM 2 | ✅ | 4GB DDR4 2133MHz |
| DIMM 3 | ❌ | Empty |
| DIMM 4 | ❌ | Empty |

**Max supported RAM:** 64GB DDR4  
**Supported speeds:** DDR4-1866 / DDR4-2133

---

---

## Resource Usage (Current Baseline)

| Resource | Usage |
|----------|-------|
| **RAM** | ~71% idle (with Docker + Plex running) |
| **RAM Free** | ~2.3GB |

> Note: High idle RAM usage is largely due to Windows 11 overhead (~4-5GB).
> Upgrading to 32GB will significantly improve headroom for additional services.

---

## Notes

- The i7-6700 supports DDR4 and DDR3L (1.35V low voltage only). Standard DDR3 at 1.5V is not supported.
- Media is stored on an internal HDD mounted at `D:\Plex` on Windows.
- No hardware transcoding currently configured (no compatible GPU).