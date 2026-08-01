# AGENTS.md — Coralsim

> **⚠️ KRITIKAL**: Setiap AI agent WAJIB membaca `docs/gdd-coralism.txt` secara utuh
> sebelum membuat perubahan APAPUN pada project ini. GDD adalah fondasi absolut.
> Jangan membuat asumsi sendiri — jika ragu, tanya user.

## Project Identity

| Aspek | Detail |
|-------|--------|
| **Nama** | Coralsim (folder: agate-game) |
| **Engine** | Godot 4.7 — GL Compatibility |
| **Language** | GDScript (seluruh kode) |
| **Platform** | Web (HTML5) primary, Desktop (Windows) secondary |
| **Genre** | Eco-simulation, Action-Adventure, Educational |
| **Target Usia** | 13+ |
| **High Concept** | *"Bersihkan laut, pilah sampah, selamatkan terumbu karang. Semakin lama kamu diam, semakin gelap lautmu."* |

## Core Philosophy (dari GDD)

1. **Looping gameplay** dengan progression nyata — bukan game linear selesai 10 menit
2. **Pollution sebagai antagonis utama** — layar makin gelap jika pemain abai
3. **3 jenis sampah**: Plastik 🟡, Logam ⚪, Organik 🟤
4. **Narrative 2 Act** — Act 1 (Tina di darat) → transisi Marina → Act 2 (laut)
5. **Player agency** — quest opsional, konsekuensi natural

## Game Loop Inti (GDD Bab 3.A)

```
Surface World → Pilih Ocean Zone → Diving (O₂ terbatas)
→ Collect 3 jenis sampah → Return ke Surface
→ Sorting Station (3 bin) → Recycling Facility
→ Upgrade Shop → Repeat (pollution turun, zone makin bersih)
```

## Rules Wajib untuk AI Agent

1. **Baca GDD dulu** — selalu rujuk `docs/gdd-coralism.txt` sebelum menulis kode
2. **Jangan melenceng dari GDD** — jika ada konflik antara code existing dan GDD, ikuti GDD. Tanyakan ke user jika perlu klarifikasi.
3. **GDScript + Godot 4.7** — semua kode dalam GDScript, renderer GL Compatibility
4. **Bahasa Indonesia** — kode, komentar, dan dokumentasi dalam Bahasa Indonesia
5. **Emit signals** — komunikasi antar node via signal, jangan direct reference kecuali autoload
6. **Pollution is king** — pollution system adalah mekanik inti yang mengatur tempo game
7. **Dialog non-skippable** — tiap baris klik untuk lanjut, CanvasLayer terpisah dari pollution overlay

## Key File References

| File | Fungsi |
|------|--------|
| `docs/gdd-coralism.txt` | **GAME DESIGN DOCUMENT — Wajib baca** |
| `project.godot` | Engine config, autoloads, input map |
| `gamemanager.gd` | Game state sentral (quest, coin, inventory) |
| `air_quality.gd` | Pollution system + overlay + thresholds |
| `player.gd` | Player controller darat (top-down, state machine) |
| `player_swim.gd` | Player controller laut (360° swim, O₂) |
| `dunia.tscn` | Main world scene (Surface) |
| `bawah_laut.tscn` | Underwater scene (Ocean Zones) |
| `tina.gd` | Quest giver + shop keeper NPC |
| `shop_manager.gd` | Shop UI + item purchasing |
| `audio_manager.gd` | Audio pool (5 SFX players + 1 BGM) |

## Autoloads (Global Singletons)

| Autoload | Tipe | Fungsi |
|----------|------|--------|
| `GameManager` | Node | State sentral: quest, coin, inventory, ending |
| `AudioManager` | Node | BGM + SFX playback dengan pooling |
| `AirQuality` | CanvasLayer | Pollution overlay + threshold system |
| `DialogueManager` | Node (addon) | Branching dialogue runtime |

## Controls (dari GDD Bab 4.A)

| Input | Aksi |
|-------|------|
| WASD / Arrow Keys | Gerak (darat & laut) |
| E | Interaksi (NPC, Sorting Station) |
| F / M1 | Collect / ambil sampah |
| H | Masuk / keluar laut |
| Escape | Pause menu |
| B | Buka shop (near shop area) |
| T | Buka inventory / debug |

## 4 Ocean Zones (GDD Bab 6)

| Zone | Unlock | O₂ Drain | Musuh |
|------|--------|----------|-------|
| Beach/Shallow | Free (start) | 1x | Tidak ada |
| Coral Reef | Beach 25% clean | 1.2x | Tidak ada |
| Open Ocean | Coral Reef 100% clean | 1.5x | Hiu, Swordfish |
| Deep Sea/Abyss | Open Ocean 100% clean | 2x | Gelap, predator |

## Prioritas Fitur (dari GDD Bab 9)

**P1 (Wajib):** Pollution system + grace period, O₂ system, diving + collect, sorting 3 bin, upgrade shop
**P2:** 4 ocean zone unlock, Marina character + cutscene, daily quest system, recycling mini-game
**P3:** Ocean encyclopedia, musuh, ending poem, visual polish

## Structured Query Instructions

Jika kamu menggunakan agent yang mendukung structured queries atau MCP, gunakan format berikut untuk operasi file:

- `/read` — untuk membaca file
- `/edit` — untuk mengedit file (selalu baca GDD dulu)
- `/search` — untuk mencari pattern dalam codebase
- `/glob` — untuk mencari files berdasarkan pattern
- `/web_fetch` — untuk referensi eksternal (Godot docs, dll)
