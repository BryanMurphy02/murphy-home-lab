# Hardware: MINISFORUM UM760 Slim

> **Role:** Home Server
> **Hostname:** nexus
> **OS:** Ubuntu Server (headless)

---

## System Overview

| Field        | Details                        |
|--------------|-------------------------------|
| Manufacturer | MINISFORUM                    |
| Model        | UM760 Slim                    |
| Form Factor  | Mini PC (MFF)                 |
| Released     | 2024                          |

---

## CPU

| Field         | Details                                      |
|---------------|----------------------------------------------|
| Model         | AMD Ryzen 5 7640HS                           |
| Architecture  | Zen 4                                        |
| Cores/Threads | 6C / 12T                                     |
| Base Clock    | 4.3 GHz                                      |
| Boost Clock   | Up to 5.0 GHz                                |
| Cache         | 16 MB L3                                     |
| TDP           | 35–54 W (configured at 60 W in this unit)    |
| Node          | 4 nm (TSMC)                                  |

---

## Memory (RAM)

| Field         | Details                                      |
|---------------|----------------------------------------------|
| Capacity      | 32 GB                                        |
| Type          | DDR5 SO-DIMM                                 |
| Speed         | 4800 MHz (upgradeable to 5600 MHz)           |
| Channels      | Dual-channel                                 |
| Slots         | 2× SO-DIMM                                   |
| Max Supported | 96 GB                                        |

---

## Storage

| Field         | Details                                      |
|---------------|----------------------------------------------|
| Primary SSD   | 1 TB M.2 2280 PCIe 4.0 NVMe                  |
| Max Speed     | Up to 7,000 MB/s                             |
| M.2 Slots     | 2× M.2 2280 PCIe 4.0 (second slot empty)     |
| Max Per Slot  | 4 TB                                         |
| RAID Support  | RAID 0 / RAID 1 (across both M.2 slots)      |

> **Note:** Second M.2 slot available for expansion.

---

## Integrated Graphics

| Field         | Details                                      |
|---------------|----------------------------------------------|
| GPU           | AMD Radeon 760M                              |
| Architecture  | RDNA 3                                       |
| Compute Units | 8 CU                                         |
| Max Frequency | 2600 MHz                                     |

> **Note:** iGPU not actively used on Ubuntu Server (headless).

---

## Networking

| Field             | Details                          |
|-------------------|----------------------------------|
| Ethernet          | 1× 2.5G RJ45 (2.5GbE)           |
| Wi-Fi             | Wi-Fi 6E                         |
| Bluetooth         | Bluetooth 5.3                    |

---

## Ports & I/O

| Port                    | Count | Details                                  |
|-------------------------|-------|------------------------------------------|
| USB 3.2 Gen 2 Type-A    | 2     | 10 Gbps                                  |
| USB 2.0 Type-A          | 2     |                                          |
| USB4 Type-C             | 1     | 40 Gbps, supports Alt DP + PD charging   |
| HDMI                    | 1     | HDMI 2.1, up to 8K @ 60 Hz              |
| DisplayPort             | 1     | DP 1.4, up to 4K @ 144 Hz               |
| 3.5 mm Audio Jack       | 1     |                                          |
| Clear CMOS Button       | 1     |                                          |

---

## Display Output (for reference)

| Output         | Max Resolution / Refresh      |
|----------------|-------------------------------|
| HDMI 2.1       | 8K @ 60 Hz                    |
| DisplayPort 1.4| 4K @ 144 Hz                   |
| USB4           | 8K @ 60 Hz                    |
| Multi-monitor  | Up to 3 independent displays  |

---

## Cooling

| Field         | Details                                                              |
|---------------|----------------------------------------------------------------------|
| Type          | Active — phase-change thermal material + large silent fan            |
| Heat Pipes    | 3× copper heat pipes                                                 |
| TDP Supported | Stable 60 W sustained                                               |
| Notes         | Phase-change material reduces CPU temps ~25% vs. passive heat sinks  |

---

## Power

| Field          | Details                    |
|----------------|----------------------------|
| Power Adapter  | Included (US plug)         |
| Auto Power On  | Supported (BIOS setting)   |

---

## Software / OS

| Field           | Details                        |
|-----------------|--------------------------------|
| Installed OS    | Ubuntu Server (headless)       |
| Original OS     | Windows 11 Pro (factory)       |
| Boot Mode       | <!-- UEFI / Legacy -->         |

---


*Last updated: 3/16/26*