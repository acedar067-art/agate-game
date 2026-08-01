# Game Design Document — Coralsim: Eco-Loop Edition

> **Versi:** 1.2
> **Engine:** Godot 4.7 (GL Compatibility)
> **Bahasa:** GDScript
> **Target Platform:** Web (HTML5), Desktop

---

## 0. Current Game Flow (Before Overhaul)

### 0.1. Existing Workflow

```
[Main Menu] → Start
    ↓
[Intro Narration] — muncul sekali, otomatis
    ↓
[Dunia/Surface] — player spawn di dunia
    ↓
[Tina NPC] — satu-satunya NPC quest giver
    │
    ├── [Quest Wajib 1: Kumpulin 10 sampah, 3 menit]
    │       ↓
    │   [Collect trash] — spawn 25-30 trash di housing/forest
    │       ↓
    │   [Return ke Tina] — quest selesai → 100 koin
    │       ↓
    │   [Pollution Overlay] — CanvasModulate 75% gelap → bersih (tween 3s)
    │
    ├── [Quest Wajib 2: Kumpulin 20 sampah, 5 menit]
    │       ↓
    │   [Shop/Material] — beli besi, pasir, cable_ties
    │       ↓
    │   [Underwater] — swim, cari karang rusak
    │       ↓
    │   [Coral Repair] — pakai 3 material → coral pulih
    │       ↓
    │   [Ending] — poem "Surat Cinta Dari Bumi" → save .txt → quit
    │
    └── [TIDAK ADA JALUR LAIN]
```

### 0.2. Masalah dalam Existing Design

| Masalah | Dampak |
|---------|--------|
| **Linear** — 2 quest, selesai, game over | Replay value = 0 |
| **Timer buatan** — 3/5 menit | Stres, bukan eksplorasi |
| **Quest wajib** — tidak bisa tolak | No player agency |
| **Pollution sekali** — trigger quest selesai | Bukan mekanik, cuma cutscene |
| **Inventory 3 item** — besi, pasir, cable_ties | Tidak ada variasi |
| **Underwater minim** — cari coral, repair, selesai | Potensi laut tidak terpakai |
| **Tina bossy** — "Kerjakan quest ini" | Mentor, bukan taskmaster |

### 0.3. Yang Dipertahankan

- Asset lingkungan (tileset, underwater, coral)
- Sprite player (SteamMan, Diver 1)
- Marine life (ikan, hiu, ubur-ubur, dll)
- Audio (BGM lofi, SFX)
- Dialogue Manager plugin
- CanvasModulate pollution (di-expand)
- Sistem scene transition (dunia ↔ bawah_laut)
- Konsep coral repair (di-expand jadi coral gardening)

### 0.4. Yang Diganti

| Aspek | Existing | Baru |
|-------|----------|------|
| Quest | Wajib, 2x, selesai | Opsional, looping, daily |
| Timer | Buatan (3/5 menit) | Natural (O₂ + pollution) |
| Pollution | Trigger sekali | Dinamis, terus naik/turun |
| Inventory | 3 material | 3 trash + 3 recycled material |
| Progression | Linear | Branching, zone-based |
| Ending | Setelah 2 quest | Setelah semua zone bersih |
| Konsekuensi | Quest gagal → ulang | Polusi naik → layar gelap → game over |

---

## 1. Game Overview

### 1.1. Deskripsi

Coralsim adalah game 2D action-adventure / eco-simulation tentang membersihkan polusi laut. Pemain menyelam, mengumpulkan sampah, memilahnya ke tempat yang benar, mendaur ulang menjadi material berguna, dan gradually membersihkan ekosistem laut. Game ini menggabungkan **gameplay looping** dengan **edukasi pengelolaan sampah** dalam setting laut yang interaktif.

### 1.2. Genre & Platform

- **Genre:** Eco-simulation, Action-Adventure, Educational
- **Platform:** Web (HTML5) — unggulan, Desktop (Windows)
- **Target Audience:** Umum (13+), pelajar, pecinta lingkungan

### 1.3. Target Audience

- Pemain kasual yang suka game santai dengan tujuan jelas
- Pelajar/siswa sebagai media edukasi lingkungan
- Pemain yang tertarik dengan tema ekologi dan kelautan

### 1.4. Unique Selling Points

- **Looping gameplay** dengan progression nyata — bukan game linear 10 menit
- **3 jenis sampah** (Plastik, Logam, Organik) — mudah diingat, fokus edukasi
- **Pollution sebagai antagonis** — layar makin gelap jika pemain abai
- **Player agency** — quest opsional, bukan paksaan
- **Narrative ringan** — Tina sebagai mentor, bukan bossy taskmaster

---

## 2. Core Gameplay Loop

### 2.1. High-Level Loop

```
Surface World
    │
    ├── Pilih Ocean Zone
    │       │
    │       ▼
    │   Diving (O₂ terbatas)
    │       │
    │       ├── Kumpulin sampah
    │       └── O₂ habis → Return ke Surface
    │
    ├── Sorting Station
    │       │
    │       ├── Drag & drop sampah ke bin benar
    │       ├── ✅ Correct → Material + Points
    │       └── ❌ Wrong → Penalty
    │
    ├── Recycling Facility
    │       │
    │       └── Process material → Finished products
    │
    ├── Upgrade Shop
    │       │
    │       └── Beli upgrade (O₂, bag, speed, dll)
    │
    └── Tina's Bulletin Board (opsional)
            │
            └── Daily quest → bonus reward
```

### 2.2. Daily Session Flow

```
1. [Surface] Cek Bulletin Board — ambil quest opsional
2. [Surface] Pilih ocean zone (semakin dalam semakin sulit)
3. [Diving] Kumpulin sampah secepat mungkin (O₂ terbatas)
4. [Return] Naik ke surface — manual atau O₂ habis
5. [Sorting] Buka Sorting Station → pilah semua sampah
6. [Recycle] Proses material mentah → finished product
7. [Upgrade] Beli upgrade dari hasil recycle
8. [Repeat] — pollution turun, zone makin bersih
```

### 2.3. Player Agency: Quest Opsional + Pollution Consequence

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  SAAT TINA MENAWARKAN QUEST:                            │
│                                                          │
│  ┌──────────────────────────────────────┐               │
│  │ Tina: "Laut butuh bantuanmu.         │               │
│  │        Kumpulin 10 sampah plastik    │               │
│  │        untuk hari ini?"              │               │
│  │                                      │               │
│  │  [❤️ Terima]  [✖️ Nanti Aja]        │               │
│  └──────────────────────────────────────┘               │
│                                                          │
│  ┌─────────────┐          ┌──────────────────────────┐  │
│  │ ❤️ TERIMA   │          │ ✖️ TOLAK / NANTI         │  │
│  ├─────────────┤          ├──────────────────────────┤  │
│  │ FAST TRACK  │          │ SLOW TRACK               │  │
│  │             │          │                          │  │
│  │ ✅ Bonus    │          │ ❌ No bonus koin         │  │
│  │   koin      │          │ ❌ No bonus material     │  │
│  │ ✅ Bonus    │          │ ⚠️ Pollution TETAP NAIK  │  │
│  │   material  │          │ ⚡ Lebih cepat dari       │  │
│  │ ✅ Target   │          │    biasanya (+0.2%/10s)  │  │
│  │   jelas     │          │ 🌊 Screen mulai gelap    │  │
│  │ ✅ Pollution│          │    perlahan              │  │
│  │   turun -5% │          │                          │  │
│  └─────────────┘          └──────────────────────────┘  │
│                                                          │
│  Quest TERSEDIA KAPAN PUN — tidak pernah expired        │
│  Balik ke Tina kapan saja → quest masih bisa diambil    │
│                                                          │
│  SETIAP KALI TOLAK:                                      │
│  - Tina sedih, tapi tidak maksa                         │
│  - Pollution +0.5% instant (akumulasi penolakan)        │
│  - Screen visible lebih gelap                           │
│  - Dialogue Tina berubah (cemas → panik)                │
│                                                          │
│  POLLUTION = ANTAGONIS UTAMA                             │
│  Bukan Tina. Tina cuma pengingat.                       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### 2.4. Overflow Trash — Quest Complete Tapi Sampah Masih Banyak

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  MASALAH:                                               │
│  Quest target 10/10 tercapai tapi masih banyak sampah.  │
│  Setelah quest selesai, sampah sisa tidak bisa hilang.  │
│                                                          │
│  SOLUSI: Quest System 3 Phase                           │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  PHASE A — Target Tercapai (10/10)                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  QUEST PROGRESS: 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦 10/10    │   │
│  │  [Kembali ke Tina]  [Collect dulu...]            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Target quest terpenuhi. Player punya 2 pilihan:        │
│                                                          │
│  Pilihan 1: Kembali ke Tina SEKARANG                     │
│  - Quest selesai, dapat reward                          │
│  - Sampah yang sudah dikumpulkan tetap di sortir        │
│                                                          │
│  Pilihan 2: Collect dulu untuk BONUS                    │
│  - Setiap kelebihan > 10: +2 XP + material random       │
│  - O₂ tetap berjalan (diving masih terbatas)            │
│  - Pollution tetap naik                                 │
│  - Bisa balik ke Tina KAPAN PUN                         │
│    (quest tidak expired)                                │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  PHASE B — Quest Diserahkan ke Tina                     │
│                                                          │
│  Saat player kembali ke Tina dan serahkan quest:        │
│                                                          │
│  1. Reward diberikan (koin + material)                   │
│  2. Pollution -5%                                        │
│  3. Sisa sampah di dunia di-despawn BERTAHAP             │
│     → 1 trash / 3 detik                                  │
│     → Visual: trash berkedip → kabut asap → hilang       │
│     → Player MASIH BISA collect selama despawn           │
│     → Kalau diambil: masuk inventory, tidak di-despawn   │
│  4. Tina: "Sampah yang tersisa akan terurai...           │
│            Laut mulai bernafas lagi."                    │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  PHASE C — Free Mode (Setelah Quest)                    │
│                                                          │
│  Setelah quest selesai + despawn selesai:                │
│                                                          │
│  - Pollution tetap berjalan (naik perlahan)             │
│  - Sampah masih spawn — lebih sedikit (3-5 visible)     │
│  - Player bisa diving, collect, sort, recycle            │
│    TANPA quest active                                   │
│  - Sampai pollution > 50% → Tina offer quest lagi       │
│    (bulletin board / dialogue trigger)                   │
│  - Atau player bisa inisiatif ambil quest sendiri        │
│                                                          │
│  FREE MODE ACTIVITIES:                                   │
│  ✅ Diving bebas (explore, collect, foto ikan)          │
│  ✅ Sorting station (pilah sampah sisa)                  │
│  ✅ Recycle material                                     │
│  ✅ Upgrade equipment                                    │
│  ✅ Menunggu pollution naik untuk quest berikutnya       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

#### Flowchart Penolakan Quest

```
[Tina Offer Quest]
    |
    ├── [Terima]  → Quest active → reward on complete → pollution -5%
    │
    └── [Tolak]   → Pollution +0.5% (instant)
                    → Pollution rate meningkat (+0.2%/10s default → +0.4%/10s)
                    → Screen gelap bertahap (CanvasModulate update)
                    → Tina dialogue berubah:
                        - Pertama: "Baiklah, kalau butuh aku di sini."
                        - Kedua: "Polusinya makin parah..."
                        - Ketiga: "Tolong... laut kita sekarat."
                        - Keempat: "MASIH MAU NOLAK?!" (pollution > 75%)
                    → Quest tetap tersedia (Tidak pernah lock)
```

---

## 3. World & Zones

### 3.1. Surface World (Dunia)

Lokasi utama di atas laut. Berisi:

#### 3.1.1. Sorting Station

Area untuk memilah sampah. 3 bin 🟡⚪🟤, drag & drop mechanic.

#### 3.1.2. Recycling Facility

Area untuk memproses material mentah jadi finished product. Satu mesin generik dengan variasi per jenis sampah.

#### 3.1.3. Upgrade Shop

Tempat membeli upgrade equipment menggunakan hasil recycle.

#### 3.1.4. Tina's Bulletin Board

Papan quest harian dari Tina. Opsional, reward bonus.

#### 3.1.5. Ocean Encyclopedia

Katalog edukasi: info setiap jenis sampah, fakta dekomposisi, dampak ke biota laut.

### 3.2. Ocean Zones

4 zona laut dengan tingkat kesulitan berbeda:

| Zone | Akses | O₂ Drain | Ancaman | Sampah Dominan |
|------|-------|----------|---------|----------------|
| Beach/Shallow | Free | 1x | Tidak ada | Plastik, Organik, Kertas |
| Coral Reef | Free* | 1.2x | Arus ringan | Logam, Kaca, Tekstil |
| Open Ocean | 🔒 O₂ Tier 2 | 1.5x | Arus kuat, predator | Elektronik, Tekstil |
| Deep Sea/Abyss | 🔒 O₂ Tier 4 | 2x | Gelap, tekanan | B3, semua jenis |

> *Coral Reef free setelah Beach/Shallow mencapai 25% bersih.

### 3.3. Zone Unlock Progression

```
1. Beach/Shallow → 100% clean → unlock Coral Reef
2. Coral Reef → 100% clean → unlock Open Ocean
3. Open Ocean → 100% clean → unlock Deep Sea
4. Deep Sea → 100% clean → ENDING
```

---

## 4. Trash System

### 4.1. 3 Jenis Sampah

Rule of three: mudah diingat, cepat disortir, fokus edukasi laut.

| # | Jenis | Contoh | Warna Bin | Asset Existing |
|---|-------|--------|-----------|----------------|
| 1 | **Plastik** 🟡 | Botol, kantong, sedotan, jaring nilon | Kuning | ✅ `water bottle *.png`, `alcohol *.png`, `garbage bag *.png` |
| 2 | **Logam** ⚪ | Kaleng, besi, jangkar, kabel | Abu-abu | ✅ `rusty sheet metal *.png` |
| 3 | **Organik** 🟤 | Sisa makanan, rumput laut, kayu | Coklat | ✅ `rotting food *.png` |

### 4.2. Spawning Logic (Dynamic Respawn)

```
Pollution Level → Trash Spawn Rate:
  0-25%  →  2-4 trash visible per jenis
  25-50% →  4-7 trash visible per jenis
  50-75% →  7-10 trash visible per jenis
  75-100% → 10-15+ trash visible per jenis (penuh layar)

Proporsi spawn (berdasarkan pollution):
  Plastik: 50%  (paling banyak di laut)
  Logam:   30%
  Organik: 20%

Respawn Timer:
  - Trash yang diambil akan respawn setelah timer
  - Makin tinggi pollution → makin cepat respawn
```

### 4.3. Trash Asset Mapping

Mapping dari asset existing ke 3 jenis sampah:

| Asset File | Jenis | Notes |
|-----------|-------|-------|
| `water bottle *.png` (6 var) | Plastik | Clean/crumpled/dirty — jadi 3 jenis underwater |
| `alcohol *.png` (4 var) | Plastik | Botol alkohol — variasi bentuk |
| `garbage bag *.png` (5 var) | Plastik | Kantong sampah — variasi ukuran |
| `rotting food *.png` (2 var) | Organik | Sisa makanan — langsung reuse |
| `rusty sheet metal *.png` (6 var) | Logam | Lembaran besi berkarat — 6 variasi |
| `box *.png`, `crumpled paper *.png` | **Organik** | Bisa jadi kayu lapuk / kertas basah |
| `computer *.png`, `dryer.png`, dll | **Logam** | Elektronik tua → kategori logam (ada besi/kabel) |
| `recycling *.png` (2 var) | **Decorative** | Simbol daur ulang (bukan trash) |

---

## 5. Sorting System

### 5.1. Drag & Drop Mechanic

```
Input: Array of unsorted trash dari bag (player inventory)

Layout:
  ┌────────────────────────────────────┐
  │  SORTING STATION                   │
  │                                    │
  │  ┌── Trash Inventory ────────┐    │
  │  │ 🧴 Plastik 🔩 Logam 🍌   │    │
  │  │    Organik                │    │
  │  └───────────────────────────┘    │
  │                                    │
  │  ┌── 3 Sorting Bins ─────────┐    │
  │  │  🟡 PLASTIK               │    │
  │  │  ⚪ LOGAM                  │    │
  │  │  🟤 ORGANIK                │    │
  │  └───────────────────────────┘    │
  │                                    │
  │  Score: 150  Streak: 5x 🔥        │
  └────────────────────────────────────┘

Mechanic:
  1. Player drag trash dari panel kiri
  2. Drop ke salah satu dari 3 bin di panel kanan
  3. Correct: trash hilang, +material, +score, streak++
  4. Wrong: trash hancur, -score, streak reset
```

### 5.2. Correct/Wrong Feedback

| Action | Feedback Visual | Audio | Reward/Penalty |
|--------|----------------|-------|----------------|
| ✅ Correct | Particle sparkle, checkmark | `succes.wav` | +1 material, +10 pts, +5 XP |
| ❌ Wrong | Screen shake, X mark, trash destroyed | `error.wav` | -5 pts, -2 koin, trash lost |

### 5.3. Streak & Bonus System

```
Streak 5x  → "Good!"    → 1.5x XP multiplier
Streak 10x → "Great!"   → 2x XP multiplier + bonus 10 koin
Streak 15x → "Amazing!" → 3x XP multiplier + bonus 25 koin + rare drop
```

### 5.4. Sorting Station UI Wireframe

> Implementasi menggunakan Godot Control nodes (Container, TextureRect, Label, Button) — tanpa external sprite untuk panel utama. Hanya 3 bin icon yang perlu external asset.

---

## 6. Recycling System

### 6.1. 8 Mini-Game Variations

| Jenis | Mini-Game | Mekanik | Durasi |
|-------|-----------|---------|--------|
| Plastik 🟡 | Press & Melt | Tekan tombol timing-bar | 3 detik |
| Logam ⚪ | Smelt & Forge | Klik di titik panas | 4 detik |
| Organik 🟤 | Compost | **Timer passif** (5-10 detik real) — tunggu alami | 5-10 detik |

> Semua mini-game menggunakan **1 mesin generik** yang sama, hanya variasi warna per jenis.

### 6.2. Resource Output Table

| Input (Raw) | Output (Finished) | Kegunaan |
|-------------|-------------------|----------|
| Plastik 🟡 | Recycled Plastic | Bag capacity, Flippers |
| Logam ⚪ | Scrap Metal | O₂ Tank (semua tier) |
| Organik 🟤 | Compost | Coral Food — attract fish & grow coral |

### 6.3. Processing Time Balance

```
Recycle Duration:
  Plastik 🟡  → 2 detik (melt cepat)
  Logam ⚪    → 4 detik (forge lebih lama)
  Organik 🟤  → 8 detik (compost alami — bisa di-queue, jalan di background)

  ⚠️ Player bisa queue multiple items → proses berjalan sequential
```

---

## 7. Upgrade System

### 7.1. Upgrade Tree

#### Tier 1 (Start — Beach/Shallow)

| Upgrade | Effect | Cost |
|---------|--------|------|
| O₂ Tank T1 | 60s → 90s dive time | 5 Scrap Metal |
| Bag T1 | 3 → 5 slots | 5 Recycled Plastic |

#### Tier 2 (Setelah Beach 100% — Coral Reef)

| Upgrade | Effect | Cost |
|---------|--------|------|
| O₂ Tank T2 | 90s → 150s | 10 Scrap Metal + 5 Recycled Plastic |
| Bag T2 | 5 → 8 slots | 10 Recycled Plastic + 3 Compost |
| Flippers T1 | 1.0x → 1.3x swim speed | 8 Recycled Plastic |

#### Tier 3 (Setelah Coral Reef 100% — Open Ocean)

| Upgrade | Effect | Cost |
|---------|--------|------|
| O₂ Tank T3 | 150s → 240s | 20 Scrap Metal + 10 Recycled Plastic |
| Bag T3 | 8 → 12 slots | 15 Recycled Plastic + 5 Compost |
| Coral Food | Grow coral 2x faster | 15 Compost + 5 Scrap Metal |

#### Tier 4 (Setelah Open Ocean 100% — Deep Sea)

| Upgrade | Effect | Cost |
|---------|--------|------|
| O₂ Tank T4 | 240s → 360s | 30 Scrap Metal + 15 Recycled Plastic |
| Scanner | ID trash type underwater | 15 Scrap Metal + 10 Compost |

---

## 8. Pollution System

### 8.1. Global Pollution Meter

Pollution adalah **mekanik inti** yang menggantikan timer artifisial.

```
Pollution Level:  0% ───────────────────────────── 100%
                  (Bersih)                     (Blackout)
```

### 8.2. Rate of Change

```
NAIK (otomatis & aksi pemain):
  Natural increase default:          +0.1% / 10 detik
  Natural setelah tolak quest:       +0.4% / 10 detik (4x lipat)
  Tolak quest (instant):             +0.5% / kali tolak
  Sortir salah:                      +1.0% / item
  Zone diabaikan:                    +0.2% / 30 detik
  Quest gagal:                       +5.0%

TURUN (aksi pemain):
  Collect trash:                     -0.5% / item
  Sortir benar:                      -1.0% / item
  Quest Tina selesai:                -5.0% / quest
  Zone 100% clean:                   -10.0% (sekali)
```

### 8.3. Threshold Effects

| Threshold | Visual | Gameplay Effect | Narrative |
|-----------|--------|-----------------|-----------|
| 0-25% | Cerah, jernih | Normal | "Laut mulai pulih" |
| 25-50% | Agak gelap (#909090) | Ikan mulai hilang | Tina khawatir |
| 50-75% | Gelap (#505050) | O₂ 20% lebih cepat habis, beberapa zona terkunci | Tina cemas |
| 75-99% | Sangat gelap (#202020) | O₂ 40% lebih cepat habis, visibilitas rendah | Tina panik |
| 100% | Blackout total (#000000) | **GAME OVER** | "Bumi sudah terlalu sakit..." |

### 8.4. Visual Overlay

Implementasi menggunakan `CanvasModulate` yang sudah ada di `dunia.gd`, di-expand:

```
func get_overlay_color(pollution: float) -> Color:
    if pollution < 10:   return Color.WHITE       # #FFFFFF
    if pollution < 25:   return Color("#D0D0D0")   # Cerah
    if pollution < 50:   return Color("#909090")   # Agak gelap
    if pollution < 75:   return Color("#505050")   # Gelap
    if pollution < 90:   return Color("#202020")   # Sangat gelap
    if pollution < 100:  return Color("#050505")   # Hampir hitam
    return Color.BLACK                              # Blackout
```

### 8.5. Game Over Condition

```
Saat pollution = 100%:
  1. CanvasModulate instant hitam
  2. Semua input di-lock
  3. Tampilkan "GAME OVER — Laut telah mati"
  4. Opsi: [Main Menu] [Restart]
  5. Tidak ada save — restart dari awal
```

### 8.6. Quest sebagai Fast Track

```
Tanpa Quest:     Pollution turun 1.5% per diving trip (rata-rata)
Dengan Quest:    Pollution turun 6.5%+ per trip (quest bonus 5%)
```

### 8.7. Screen Darkening on Quest Rejection

Mekanik inti: **Setiap penolakan quest mempercepat kegelapan layar.**

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  SAAT PLAYER TOLAK QUEST:                                 │
│                                                            │
│  1. Pollution +0.5% INSTANT (umpan balik langsung)         │
│  2. Natural rate naik: +0.1%/10s → +0.4%/10s (4x lipat)   │
│  3. CanvasModulate color berubah di frame berikutnya       │
│  4. Tina dialogue berubah (cemas → sedih → panik)          │
│                                                            │
│  LAPISAN POLUSI:                                           │
│                                                            │
│  Bukan cuma global overlay. Ada 3 layer effect:            │
│                                                            │
│  Layer 1: CanvasModulate (warna global)                    │
│    - 0-25%:  Cerah, warna asli                            │
│    - 25-50%:  Agak gelap (#909090)                        │
│    - 50-75%:  Gelap (#505050)                             │
│    - 75-99%:  Sangat gelap (#202020)                      │
│    - 100%:    Blackout (#000000)                          │
│                                                            │
│  Layer 2: Underwater visibility                            │
│    - Makin tinggi polusi → underwater makin buram          │
│    - Efek: ColorTint + fog-like overlay di bawah laut      │
│                                                            │
│  Layer 3: UI indicator                                     │
│    - Pollution bar di HUD (merah jika > 50%)              │
│    - Peringatan threshold: flash border saat 50%, 75%, 90%│
│    - Tina dialogue: muncul otomatis di threshold tertentu  │
│                                                            │
│  TRANISI (TWEEN):                                          │
│                                                            │
│  Tidak instant — biar natural:                             │
│  - Perubahan pollution 0-10%:  tween 5 detik              │
│  - Perubahan pollution 10-25%: tween 3 detik              │
│  - Perubahan pollution 25%+:   tween 1 detik (tegas)      │
│                                                            │
│  RESET:                                                    │
│  - Pollution tidak pernah turun otomatis                   │
│  - Hanya turun kalau player AKSI (collect, sort, quest)   │
│  - Kalau player diem aja → pollution terus naik → GAME OVER│
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 8.8. Grace Period — Polusi Delay di Awal Game

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  MASALAH:                                               │
│  Pas testing, polusi langsung naik detik pertama        │
│  → Player bingung, tidak sempat eksplorasi/tutorial     │
│                                                         │
│  SOLUSI: Grace Period 60 DETIK                         │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │  GRACE PERIOD ACTIVE: 60s                      │    │
│  │  Pollution = 0% (frozen)                       │    │
│  │  Timer visible di HUD: "Waktu tenggang: 45s"   │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  Selama Grace Period:                                  │
│  - Pollution tetap 0%, tidak naik                      │
│  - Timer countdown visible di pojok HUD                │
│  - Tina kasih tutorial singkat (dialogue):             │
│      "Selamat datang! Selama 1 menit ke depan          │
│       laut masih tenang. Gunakan waktu ini             │
│       untuk belajar mengelompokkan sampah."            │
│  - Player bisa gerak, interaksi, diving — bebas        │
│  - Pollution system pause (tidak add pollution)        │
│                                                         │
│  Setelah Grace Period habis:                           │
│  - Pollution mulai naik normal (0.1%/10s)              │
│  - Timer hilang dari HUD                               │
│  - Tina: "Waktu tenggang selesai. Laut mulai           │
│           memanggilmu..."                              │
│                                                         │
│  ⚠️ Grace Period hanya SEKALI — tidak reset           │
│  ⚠️ Tidak bisa diperpanjang                            │
│  ⚠️ Kalau player tolak quest di grace period → tetap   │
│     pollution naik setelah grace berakhir              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Contoh Skenario: Player Tolak Quest Terus

```
[Mulai game] Pollution: 0%   → Cerah
    ↓
[Tolak quest #1] Pollution: +0.5% → rate naik 4x
    ↓  (diam 2 menit, pollution naik 4.8%)
[Tolak quest #2] Pollution: +5.8% → +0.5% lagi = 6.3%
    ↓  (diam 3 menit, pollution naik 7.2%)
[Tolak quest #3] Pollution: ~14% → makin gelap
    ↓
[Polusi 25%] → Threshold: ikan mulai hilang, Tina khawatir
    ↓
[Polusi 50%] → Threshold: O₂ lebih cepat habis, Tina cemas
    ↓
[Polusi 75%] → Threshold: zona terkunci, Tina panik
    ↓
[Polusi 100%] → GAME OVER — "Laut telah mati"
```

---

## 9. Narrative & Characters

### 9.1. Tina (Mentor)

- **Peran:** Penjaga pantai, mentor, quest giver
- **Kepribadian:** Peduli, sabar, sedikit cemas kalau polusi tinggi
- **Dialogue:** Branching berdasarkan pollution level & zone progress

### 9.2. Player (Penyelamat)

- **Peran:** Pemain — penyelamat laut
- **Agency:** Bebas memilih quest atau tidak

### 9.3. Story Beat Progression

```
Game Start → Intro narration
                ↓
First visit dunia → Tina menjelaskan polusi & sorting
                ↓
Beach/Shallow 100% → Tina: "Kamu baru mulai..."
                ↓
Coral Reef 100% → Tina: "Karang hidup lagi!"
                ↓
Open Ocean 100% → Tina: "Laut lepas pulih..."
                ↓
Deep Sea 100% → ENDING — Poem "Surat Cinta Dari Bumi"
```

### 9.4. Ending: "Surat Cinta Dari Bumi"

Poem dari perspektif Bumi & Tina. Sama seperti existing — disimpan ke file .txt di Documents (desktop) atau download (web).

### 9.5. Lore Unlock per Zone Clean

Setiap zona 100% bersih → unlock entry di Ocean Encyclopedia:
- Fakta tentang ekosistem zona tersebut
- Info species ikan yang tinggal di sana
- Data dampak polusi pada zona

---

## 10. Game Systems

### 10.1. State Machine (Player)

```
Above ground: Idle → Jalan → Serang
Underwater:   Idle → Swim → Collect (expand dengan O₂ state)
```

### 10.2. Dialogue Manager

Menggunakan plugin `dialogue_manager` yang sudah ada. Tina's dialogue branching by:
- Pollution level
- Zone progress
- Quest status

### 10.2.1. Dialogue Display Rules

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  RULE 1: NON-SKIPPABLE                                      │
│                                                             │
│  Setiap baris dialogue WAJIB dibaca sampai selesai.         │
│  Player klik → lanjut ke baris berikutnya.                  │
│  Tidak ada skip all / fast forward.                         │
│                                                             │
│  Alasan: Game edukasi — teks adalah konten utama.           │
│          Edukasi hilang kalau dilewati.                     │
│                                                             │
│  Implementasi di Godot:                                     │
│  - dialogue_manager plugin sudah punya mode "click to       │
│    continue" secara default                                 │
│  - Pastikan auto_advance = false di resource dialogue       │
│  - Pastikan tidak ada tombol skip di custom balloon         │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  RULE 2: DIALOGUE TIDAK IKUT GELAP (Pollution)              │
│                                                             │
│  Pollution overlay (CanvasModulate) hanya cover dunia game. │
│  Dialogue balloon tetap terang & terbaca.                   │
│                                                             │
│  Implementasi di Godot:                                     │
│  - Dialogue balloon pakai CanvasLayer terpisah              │
│    → Set canvas_layer untuk balloon UI                      │
│  - Atau: balloon sebagai child dari root CanvasLayer        │
│    yang tidak kena modulate                                 │
│  - Teks warna: putih (#FFFFFF) dengan shadow tipis          │
│    agar kontras tinggi di semua kondisi                     │
│                                                             │
│  Hasil:                                                     │
│  - Dunia di belakang balloon boleh gelap                    │
│  - Balloon tetap putih, teks jelas                          │
│  - Player bisa fokus baca dialogue tanpa gangguan visual   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 10.3. Audio Manager

Existing `audio_manager.gd` — perlu tambahan SFX:
- Sorting correct/error
- Recycling process
- Pollution threshold warning
- Zone unlock fanfare

### 10.4. Save/Load

```
Web:   JavaScriptBridge localStorage
Desktop:  FileAccess user://

Save data:
  - Pollution level
  - Zone progress (per zone %)
  - Upgrade tier
  - Inventory (materials)
  - Coins
  - Quest status
```

### 10.5. Input Mapping

| Key | Action |
|-----|--------|
| WASD / Arrows | Gerak (above + underwater) |
| E | Interaksi (NPC, Sorting Station, dll) |
| F / M1 | Collect trash |
| T | Toggle inventory |
| B | Buka shop |
| H | Masuk/keluar laut |
| Space / M1 | Serang (above ground) |
| Escape | Pause menu |

---

## 11. Controls

### 11.1. Keyboard

Sama seperti input mapping di atas.

### 11.2. Mouse (Sorting Station)

- **Drag & Drop:** Klik & tahan trash → seret ke bin → lepas
- **Hover:** Highlight trash/bin
- **Right-click:** Cancel drag

---

## 12. Technical Architecture

### 12.1. Autoloads

| Autoload | File | Purpose |
|----------|------|---------|
| DialogueManager | `addons/dialogue_manager/dialogue_manager.gd` | Dialogue system |
| GameManager | `gamemanager.gd` | Game state, quest, inventory, coins |
| AudioManager | `audio_manager.gd` | BGM & SFX |
| PollutionManager | **NEW** `pollution_manager.gd` | Pollution level, thresholds, effects |

### 12.2. Scene Tree Structure

```
Main (root)
├── StartMenu (start_menu.tscn)
├── Dunia (dunia.tscn) ← Surface World
│   ├── Player
│   ├── Tina + NPCs
│   ├── SortingStation (NEW)
│   ├── RecyclingFacility (NEW)
│   ├── UpgradeShop (expand shop.tscn)
│   ├── BulletinBoard (NEW)
│   └── Encyclopedia (NEW)
├── BawahLaut (bawah_laut.tscn) ← Underwater
│   ├── PlayerSwim
│   ├── TrashSpawner (expand)
│   ├── Ikan / MarineLife
│   └── Entrance/Exit
├── PauseMenu
├── GameOver (NEW)
└── EndingScene
```

### 12.3. Signal Flow Diagram

```
PollutionManager
    ├── signal pollution_changed(level) → dunia.gd (update overlay)
    ├── signal threshold_reached(level) → dunia.gd (trigger event)
    └── signal game_over → GameOver scene

TrashSpawner
    ├── signal trash_collected(type) → PlayerBag
    └── listen PollutionManager.pollution_changed → adjust spawn rate

SortingStation
    ├── signal sort_correct(type) → GameManager (add material)
    └── signal sort_wrong(type) → PollutionManager (add pollution)

GameManager
    ├── signal quest_completed → PollutionManager (reduce pollution)
    └── signal zone_clean(zone) → unlock next zone
```

### 12.4. File Structure (New Files)

```
docs/
  game-design-document.md          ← GDD ini

NEW FILES:
  pollution_manager.gd             ← Global pollution system
  sorting_station.gd + .tscn       ← Sorting UI
  recycling_minigame.gd + .tscn    ← Recycling system
  bulletin_board.gd + .tscn        ← Daily quest board
  ocean_map.gd + .tscn             ← Zone selection
  encyclopedia.gd + .tscn          ← Ocean facts

MODIFIED FILES:
  gamemanager.gd                   ← Expand state tracking
  dunia.gd + .tscn                 ← New surface features
  trash_spawner.gd                 ← 8 types + dynamic respawn
  trash_box.gd                     ← trash_type property
  player_swim.gd                   ← O₂ system
  shop_manager.gd + .tscn          ← Upgrade shop
  inventory_ui.gd                  ← 3 trash display
```

---

## 13. Asset List

### 13.1. Existing Assets (Reusable)

| Kategori | Files | Status |
|----------|-------|--------|
| Player sprites | SteamMan (12), Diver 1 | ✅ Siap |
| Trash sprites | 58 file di addons/trash assets/ | ✅ Mapping ke 3 jenis |
| Environment | 51 tileset files, underwater backgrounds | ✅ Siap |
| Marine life | 6 ikan, hiu, swordfish, angler, jelly, squid | ✅ Siap |
| Audio | 1 BGM lofi, 7 SFX + 2 voice | ✅ Cukup |
| UI | Buttons, shop, coin, inventory slot | ✅ Dasar |
| Coral | Corals.png, underwater corals | ✅ Siap |
| Particles | dust_particles_01.png | ✅ Minimal |

### 13.2. New Assets Required

| Prioritas | Asset | Qty | Source Plan |
|-----------|-------|-----|-------------|
| **P1** | Bin icons (3 warna) | 3 icon 16-32px 🟡⚪🟤 | itch.io / OpenGameArt — cari "trash bin icons" |
| **P1** | Recycling machine (1 generic) | 1 sprite 32-64px | Recolor/fork dari existing object atau cari "machine sprite" gratis |
| **P2** | Ocean zone map background | 1 gambar | AI generate (Gemini/Leonardo) |
| **P2** | Upgrade icons (tank, bag, flippers, scanner, hazmat) | 5-6 icon | OpenGameArt — cari "RPG icon pack" |
| **P3** | Tekstil trash sprite | 2-3 varian | Reuse garbage bag + recolor, atau cari "fabric sprite" |
| **P3** | B3 barrel/drum sprite | 1-2 varian | Cari "toxic barrel 16px" gratis |

### 13.3. Asset Sourcing Plan

1. **Prioritas gratis** — OpenGameArt, itch.io (free), Kenney.nl
2. **AI generate** — Gemini untuk background/ environmental yang custom
3. **Reuse & recolor** — Asset existing di-recolor untuk variasi baru
4. **Code-only** — UI panel, progress bar, score display — Godot built-in nodes

---

## 14. Development Roadmap

### Phase 1: Core Game Loop (Priority)

```
Files:
  NEW:  pollution_manager.gd
  MOD:  gamemanager.gd
  MOD:  dunia.gd
  MOD:  trash_spawner.gd
  MOD:  trash_box.gd
  MOD:  player_swim.gd

Goal:  Pollution system + diving loop functional
Test:  Pollution naik/turun, threshold effects, game over
```

### Phase 2: Sorting & Recycling

```
Files:
  NEW:  sorting_station.gd + .tscn
  NEW:  recycling_minigame.gd + .tscn
  MOD:  inventory_ui.gd

Goal:  Full sorting + recycling gameplay
Test:  All 3 trash types, correct/wrong feedback, material output
```

### Phase 3: Progression & Polish

```
Files:
  NEW:  bulletin_board.gd + .tscn
  NEW:  ocean_map.gd + .tscn
  MOD:  shop_manager.gd + .tscn

Goal:  Zone unlock, upgrade tree, daily quests
Test:  Full progression from Beach to Deep Sea
```

### Phase 4: Narrative & Final

```
Files:
  NEW:  encyclopedia.gd + .tscn
  MOD:  (npc/dialogue files)
  MOD:  dunia.tscn (final layout)

Goal:  Encyclopedia, narrative polish, ending
Test:  Full game from start to ending
```

---

> **Dokumen ini terakhir diperbarui:** Juli 2026
