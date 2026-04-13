# AnyGo Security Analysis

> **AI-Assisted Reverse Engineering of a Commercial GPS Spoofing Tool**  
> Author: [@TorranceTech](https://github.com/TorranceTech)  
> Date: April 2026  
> Tools: Claude + Ollama (thinkllama) + Frida + strings + keytool

---

## Overview

This is a security research analysis of **AnyGo by iToolab** — a commercial iOS GPS spoofing application marketed for location privacy and games like Pokémon GO.

The entire analysis was conducted using an **AI-assisted workflow**: Claude (cloud) orchestrating a locally-running Ollama model (`thinkllama` — Qwen3.5 35B) as an autonomous agent via Claude Code. No manual scripting was required — the AI agent ran all commands, interpreted outputs, and surfaced findings autonomously.

---

## Findings Summary

| # | Finding | Severity |
|---|---------|----------|
| 1 | Undocumented Android APK distributed via hidden JSON endpoint | 🔴 High |
| 2 | APK signed by unknown third party (JumgenAlex), not Niantic | 🔴 High |
| 3 | Anti-cheat bypass strings found in DEX bytecode | 🔴 High |
| 4 | Binary requests SIP disable on macOS host | 🟡 Medium |
| 5 | No hardcoded API keys in main binary | 🟢 Low |
| 6 | SIP confirmed enabled on test machine (not exploited) | 🟢 Info |

---

## Methodology

### Tools Used
- **Claude + Claude Code** — AI orchestration layer
- **thinkllama** — Local Ollama model (Qwen3.5:35b) as autonomous agent
- **Frida 17.2.12** — Dynamic instrumentation
- **strings** — Static binary analysis
- **keytool** — Certificate inspection
- **curl / unzip** — Network and archive analysis
- **macOS** — Analysis host (Mac Studio M2, 64GB)
- **iPad (dummy device)** — Target device

### Workflow
```
1. Binary analysis of AnyGo.app (Mach-O x86_64)
2. Endpoint discovery via strings grep
3. JSON endpoint enumeration
4. APK discovery and download
5. MD5 verification
6. DEX bytecode analysis
7. Certificate inspection
8. SIP status verification
```

---

## Detailed Findings

### Finding 1 — Undocumented Android APK

AnyGo is marketed exclusively as an **iOS tool**. However, a hidden JSON endpoint discovered inside the Mac binary reveals an undocumented Android APK:

**Endpoint:** `https://download.itoolab.com/resources/anygo/pokmgo.json`

```json
{
  "generalChannel": {
    "version": "0.405.1.0",
    "url": "https://download.onvideoeditor.com/resources/anygo/pokemongo/pokemongo_0.405.1.0.apk",
    "md5": "b0b646ed40bb1d0b3784d0e175047f73",
    "size": 152249206,
    "signatures": "442334ab"
  },
  "PKG_ACTIVITY_NAME": "com.nianticproject.holoholo.libholoholo.unity.UnityMainActivity"
}
```

This APK (220MB actual size vs 152MB declared) is not listed anywhere on iToolab's website or marketing materials.

---

### Finding 2 — Third-Party APK Signing Certificate

MD5 verification confirmed the APK integrity matches the declared hash. Certificate inspection revealed:

```
Signer: JumgenAlex
Organization: JumgenSoftware / JumgenProduct
Valid until: December 30, 2047
```

**This is not Niantic's certificate.** The APK has been recompiled and re-signed by an unknown third party. This constitutes unauthorized redistribution of a modified version of Pokémon GO.

---

### Finding 3 — Anti-Cheat Bypass in DEX Bytecode

Analysis of `classes.dex` revealed strings consistent with anti-detection patching:

```
Violation(s) detected in the following constraint(s):
ROOT management app detected!
binary detected!
EXTRA_IS_MOCK
FAKE_KEY_NAME
mockLocation
ro.allow.mock.location
```

These strings indicate the modified APK contains code to intercept and neutralize Niantic's integrity checks — specifically mock location detection, root detection, and binary tampering detection.

---

### Finding 4 — SIP Disable Requirement

The AnyGo Mac binary contains references to macOS System Integrity Protection:

```
SIPGuideURL
isEnableSIP
DisableSIPURL
/usr/bin/csrutil
"To use this feature you need to disable SIP, please check the guide."
```

SIP is macOS's last line of defense against kernel-level code injection. Requesting users to disable it is a significant security concern for the host machine.

**Test machine status:** `System Integrity Protection status: enabled` ✅  
SIP was never disabled — AnyGo's core GPS spoofing functioned without it via Developer Mode only.

---

### Finding 5 — Infrastructure

| URL | Purpose |
|-----|---------|
| `https://download.itoolab.com/updateinfo/anygo_update_mac.json` | App updates |
| `https://download.itoolab.com/resources/anygo/pokmgo.json` | Hidden Pokémon GO resources |
| `https://download.onvideoeditor.com/resources/anygo/pokemongo/*.apk` | APK distribution |
| `https://iwherego.com/pogo-genius/` | Pokémon GO integration feature |
| `https://discord.gg/bqmhSSVFsQ` | Community |

Note: APK is served from `onvideoeditor.com` — a domain unrelated to iToolab's main brand, suggesting intentional obscuration.

---

### Finding 6 — Native Libraries in APK

```
lib/arm64-v8a/libAdaptivePerformanceHint.so
lib/arm64-v8a/libAdaptivePerformanceThermalHeadroom.so
lib/arm64-v8a/libadventuresync.so
[+23 additional .so files]
```

The `libadventuresync.so` is particularly notable — Adventure Sync is Pokémon GO's background activity tracking feature, suggesting deep integration beyond simple GPS injection.

---

## How GPS Spoofing Works (Technical)

```
Mac (AnyGo) ──USB──► iPad (Developer Mode enabled)
     │                        │
     │   location simulation  │
     └──────────────────────► iOS Location API
                              │
                              ▼
                    Pokémon GO sees fake GPS
                              │
                    VPN syncs IP to match location
                              │
                    Niantic anti-cheat: bypassed
```

The Mac app uses Apple's official `simulated location` API — the same one Xcode uses for testing. Developer Mode must be enabled on the target device. No jailbreak required for basic functionality.

---

## AI-Assisted Workflow

This entire analysis was performed using the following stack:

```
Claude (claude.ai) 
    └── Claude Code v2.1.92
            └── thinkllama:latest (Qwen3.5:35b via Ollama)
                    └── Bash, Read, Grep, Fetch tools
```

The AI agent autonomously:
- Discovered hidden endpoints via binary string analysis
- Fetched and parsed JSON configs
- Downloaded and verified the APK
- Extracted and analyzed DEX bytecode
- Inspected signing certificates
- Correlated findings across multiple sources

**Time to complete full analysis: ~2 hours** (including model setup and tool configuration)

---

## Disclaimer

This research was conducted on software legally purchased by the researcher. Analysis was performed for educational and security research purposes only. No proprietary code is redistributed here. This falls under legitimate security research and reverse engineering for interoperability purposes.

---

## References

- [iToolab AnyGo](https://itoolab.com/gps-changer/)
- [Frida Documentation](https://frida.re/docs/home/)
- [Apple Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- [Niantic Fair Play Policy](https://nianticlabs.com/en/about/trust-and-safety)
