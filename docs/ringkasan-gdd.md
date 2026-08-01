# Ringkasan GDD — Coralsim: Eco-Loop Edition

> **Dokumen lengkap:** `docs/game-design-document.md`

---

## Overview

Game 2D eco-simulation tentang bersihin polusi laut. **Looping gameplay** + edukasi pilah sampah. Godot 4.7, target Web/Desktop.

---

## Narrative Flow

```
ACT 1: DARAT (Tutorial — Tina)
  Intro → Grace Period 60s → Quest Tina (kumpulin sampah)
    → Dapat koin → Beli material → Repair 1 karang rusak
    → ★ CUTSCENE: Marina muncul dari karang ★

ACT 2: LAUT (Core Game — Marina)
  Marina ajarin sorting 3 jenis sampah
    → Daily quest diving & sorting
    → Loop: Diving → Collect → Sort → Recycle → Upgrade
    → Bersihin 4 ocean zone → ENDING
```

### Karakter

| Karakter | Peran | Lokasi |
|----------|-------|--------|
| **Tina** | Mentor awal + shop keeper | Darat (surface) |
| **Marina** | Quest giver utama + guru sorting | Laut (coral reef) |

---

## Core Gameplay Loop

```
Surface → Pilih Ocean Zone → Diving (O₂ terbatas) → Collect sampah
    → Return ke Surface → Sorting Station (3 bin)
    → Recycling Facility → Upgrade Shop
    → Repeat (pollution turun, zone makin bersih)
```

---

## 3 Jenis Sampah

| Jenis | Warna | Contoh | Hasil Daur Ulang | Kegunaan |
|-------|-------|--------|------------------|----------|
| Plastik 🟡 | Kuning | Botol, kantong, jaring nilon | Recycled Plastic | Bag capacity, Flippers |
| Logam ⚪ | Abu-abu | Kaleng, besi, kabel | Scrap Metal | O₂ Tank (semua tier) |
| Organik 🟤 | Coklat | Sisa makanan, rumput laut | Compost | Coral Food |

Proporsi spawn: Plastik 50%, Logam 30%, Organik 20%.

---

## Pollution System (Antagonis Utama)

- **Naik otomatis:** +0.1%/10dtk (normal), +0.4%/10dtk (setelah tolak quest)
- **Tolak quest:** +0.5% instant
- **Grace Period:** 60 detik polusi frozen di awal game
- **Threshold:** 25% (ikan hilang) → 50% (O₂ boros) → 75% (zona terkunci) → 100% (GAME OVER)
- **Turun:** Collect (-0.5%), Sort benar (-1.0%), Quest selesai (-5.0%), Zone clean (-10.0%)
- **Darkening:** CanvasModulate 3 layer — overlay global + underwater fog + UI indicator

### Player Tolak Quest

```
Tolak → Pollution +0.5% + rate 4x lipat → Screen makin gelap
    → Tina dialogue progresif: "Baiklah" → "Polusi makin parah" → "Tolong!" → "MASIH MAU NOLAK?!"
    → Quest tetap tersedia kapan pun (tidak expired)
```

---

## Sorting System

3 bin 🟡⚪🟤. Drag & drop. Correct → +material +score. Wrong → -score +polusi naik.

---

## Upgrade Tree

| Tier | Upgrade | Material |
|------|---------|----------|
| T1 | O₂ Tank T1 (60→90s), Bag T1 (3→5) | Scrap Metal, Recycled Plastic |
| T2 | O₂ Tank T2 (90→150s), Bag T2 (5→8), Flippers (1.3x) | + Metal, Plastic, Compost |
| T3 | O₂ Tank T3 (150→240s), Bag T3 (8→12), Coral Food | + Metal, Plastic, Compost |
| T4 | O₂ Tank T4 (240→360s), Scanner | Metal, Plastic, Compost |

---

## 4 Ocean Zone

| Zone | Akses | O₂ Drain | Sampah Dominan |
|------|-------|----------|----------------|
| Beach/Shallow | Free | 1x | Plastik, Organik |
| Coral Reef | Beach 25% clean | 1.2x | Logam |
| Open Ocean | Coral Reef 100% | 1.5x | Plastik, Logam |
| Deep Sea/Abyss | Open Ocean 100% | 2x | Campuran |

---

## Overflow Trash (3 Phase)

- **Phase A:** Target quest capai → player bisa collect bonus dulu atau langsung balik
- **Phase B:** Quest diserahkan → reward + despawn bertahap (1 trash/3dtk)
- **Phase C:** Free mode → pollution naik pelan, quest baru di > 50%

---

## Dialogue Rules

1. **Non-skippable** — tiap baris klik untuk lanjut (edukasi)
2. **Tidak ikut gelap** — balloon pakai CanvasLayer terpisah dari pollution overlay

---

## Key Changes dari Game Existing

| Aspek | Existing | Baru |
|-------|----------|------|
| Quest | Wajib, 2x, selesai | Opsional, looping, daily |
| Timer | Buatan (3/5 menit) | Natural (O₂ + pollution) |
| Pollution | Trigger sekali | Dinamis, naik/turun terus |
| Inventory | 3 material | 3 trash + 3 recycled |
| Progression | Linear | Zone-based branching |
| Sorting | Tidak ada | 3 bin + drag & drop |
| Ending | Setelah 2 quest | Setelah semua zone bersih |

---

## Controls

| Key | Action |
|-----|--------|
| WASD/Arrows | Gerak |
| E | Interaksi (NPC, sorting, dll) |
| F/M1 | Collect trash |
| H | Masuk/keluar laut |
| Escape | Pause |

---

## Status GDD

**Versi:** 1.2 — 14 section, ~43 KB, 84 subsection.
