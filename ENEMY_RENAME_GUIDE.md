# Hướng Dẫn Đổi Tên Enemy: Slime → Toilet

## Bảng Mapping Đầy Đủ

| Model Cũ | Cycle / Wave | Model Mới |
|---|---|---|
| SlimeEnemy | Cycle 1 – Wave 1-10 | SmallYellowToilet |
| SlimeFastEnemy | Cycle 1 – Wave 1-10 | SmallRedToilet |
| SlimeBombonEnemy | Cycle 1 – Wave 1-10 | LargeToilet |
| SlimeYellowEnemy | Cycle 2 – Wave 11-20 | AssassinYellowToilet |
| SlimeRedEnemy | Cycle 2 – Wave 11-20 | AssassinRedToilet |
| SlimeBlueEnemy | Cycle 2 – Wave 11-20 | PoliceToilet |
| SlimePinkMiniBobEnemy | Cycle 3 – Wave 21-30 | GlassesYellowToilet |
| SlimePinkBobEnemy | Cycle 3 – Wave 21-30 | GlassesRedToilet |
| SlimeCandleEnemy | Cycle 3 – Wave 21-30 | GlitchToilet |
| SlimeCatEnemy | Cycle 4 – Wave 31-40 | DJYellowToilet |
| SlimeMonkeyEnemy | Cycle 4 – Wave 31-40 | DJRedToilet |
| SlimeTurtleEnemy | Cycle 4 – Wave 31-40 | DualBladeToilet |
| SlimePlantEnemy | Cycle 5 – Wave 41-50 | VacuumYellowToilet |
| SlimeTreeEnemy | Cycle 5 – Wave 41-50 | VacuumRedToilet |
| SlimeCactusEnemy | Cycle 5 – Wave 41-50 | FlyingBuzzsawToilet |
| SlimeBullEnemy | Cycle 6 – Wave 51-60 | DualBladeYellowToilet |
| SlimeReindeerEnemy | Cycle 6 – Wave 51-60 | DualBladeRedToilet |
| SlimeDuckEnemy | Cycle 6 – Wave 51-60 | FlyingRocketLauncherToilet |
| SlimeSharkEnemy | Cycle 7 – Wave 61-70 | HelicopterParasiteYellowToilet |
| SlimeOrcaEnemy | Cycle 7 – Wave 61-70 | HelicopterParasiteRedToilet |
| SlimeAxolotlEnemy | Cycle 7 – Wave 61-70 | LargePoliceToilet |
| SlimeTomatoEnemy | Cycle 8 – Wave 71-80 | LargeFlyingBuzzsawYellowToilet |
| SlimePumpkinEnemy | Cycle 8 – Wave 71-80 | LargeFlyingBuzzsawRedToilet |
| SlimeWatermelonEnemy | Cycle 8 – Wave 71-80 | GiantDualBladeToilet |
| SlimeWaterLilyEnemy | Cycle 9 – Wave 81-100 | GiantGlassesYellowToilet |
| SlimeGreenEnemy | Cycle 9 – Wave 81-100 | GiantGlassesRedToilet |
| SlimePlantEnemy *(Cycle 9)* | Cycle 9 – Wave 81-100 | SpiderToilet |
| SlimeCactusEnemy *(Cycle 9)* | Cycle 9 – Wave 81-100 | InfectedTitanSpeakerman |
| SlimePlaneteGreenEnemy | Cycle 10 – Wave 101-120 | QuadBladeStriderToilet |
| SlimePlaneteYellowEnemy | Cycle 10 – Wave 101-120 | UFOToilet |
| SlimePlaneteBlackEnemy | Cycle 10 – Wave 101-120 | RocketToilet |
| SlimeGalaxyEnemy | Cycle 10 – Wave 101-120 | StriderRocketToilet |
| SlimeBoss1 | Boss | BossToilet |
| SlimeBoss2 | Boss | BossToilet2 |

> ⚠️ **Lưu ý quan trọng:** `SlimePlantEnemy` và `SlimeCactusEnemy` xuất hiện 2 lần trong bảng — Cycle 5 và Cycle 9 với tên mới **khác nhau**. Vì vậy Cycle 9 cần tạo **2 folder mới riêng biệt** (`SpiderToilet` và `InfectedTitanSpeakerman`) thay vì dùng chung folder Cycle 5.

---

## Các File Cần Chỉnh Sửa

| File | Loại thay đổi |
|---|---|
| `src/ReplicatedStorage/Enemies/` | Đổi tên 32 folder |
| `src/ReplicatedStorage/Modules/EnemyConfigurations.lua` | Đổi tên 34 key |
| `src/ReplicatedStorage/Modules/WaveConfigurations.lua` | Đổi tên trong field `Enemy` |
| `src/ServerScriptService/Controllers/WaveController.lua` | Đổi tên boss check |
| Roblox Studio – Model trong Workspace/ReplicatedStorage | Đổi tên model 3D |

---

## Bước 1 – Giải Quyết Conflict Cycle 9 Trước

Cycle 9 dùng lại `SlimePlantEnemy` và `SlimeCactusEnemy` với tên mới khác Cycle 5, nên phải tách thành folder riêng **trước** khi đổi tên bất kỳ thứ gì.

### 1a. Tạo folder mới cho Cycle 9

Trong `src/ReplicatedStorage/Enemies/`, tạo 2 folder mới:
- `SpiderToilet/` — copy toàn bộ nội dung từ `SlimePlantEnemy/`
- `InfectedTitanSpeakerman/` — copy toàn bộ nội dung từ `SlimeCactusEnemy/`

Mỗi folder phải có đủ:
```
SpiderToilet/
├── init.meta.json
├── SlimeAnimator.server.lua
├── ZombieAI.server.lua
└── Humanoid/
```

### 1b. Thêm config cho 2 enemy mới vào EnemyConfigurations.lua

Mở [src/ReplicatedStorage/Modules/EnemyConfigurations.lua](src/ReplicatedStorage/Modules/EnemyConfigurations.lua) và thêm 2 entry mới (copy stats từ Cycle 9 tương ứng):

```lua
["SpiderToilet"] = {
    CashReward = ...,
    MaxHealth = ...,
    Damage = ...,
},
["InfectedTitanSpeakerman"] = {
    CashReward = ...,
    MaxHealth = ...,
    Damage = ...,
},
```

---

## Bước 2 – Đổi Tên 32 Folder trong ReplicatedStorage/Enemies/

Đổi tên theo bảng sau (dùng File Explorer hoặc lệnh PowerShell bên dưới):

| Folder cũ | Folder mới |
|---|---|
| `SlimeEnemy` | `SmallYellowToilet` |
| `SlimeFastEnemy` | `SmallRedToilet` |
| `SlimeBombonEnemy` | `LargeToilet` |
| `SlimeYellowEnemy` | `AssassinYellowToilet` |
| `SlimeRedEnemy` | `AssassinRedToilet` |
| `SlimeBlueEnemy` | `PoliceToilet` |
| `SlimePinkMiniBobEnemy` | `GlassesYellowToilet` |
| `SlimePinkBobEnemy` | `GlassesRedToilet` |
| `SlimeCandleEnemy` | `GlitchToilet` |
| `SlimeCatEnemy` | `DJYellowToilet` |
| `SlimeMonkeyEnemy` | `DJRedToilet` |
| `SlimeTurtleEnemy` | `DualBladeToilet` |
| `SlimePlantEnemy` | `VacuumYellowToilet` |
| `SlimeTreeEnemy` | `VacuumRedToilet` |
| `SlimeCactusEnemy` | `FlyingBuzzsawToilet` |
| `SlimeBullEnemy` | `DualBladeYellowToilet` |
| `SlimeReindeerEnemy` | `DualBladeRedToilet` |
| `SlimeDuckEnemy` | `FlyingRocketLauncherToilet` |
| `SlimeSharkEnemy` | `HelicopterParasiteYellowToilet` |
| `SlimeOrcaEnemy` | `HelicopterParasiteRedToilet` |
| `SlimeAxolotlEnemy` | `LargePoliceToilet` |
| `SlimeTomatoEnemy` | `LargeFlyingBuzzsawYellowToilet` |
| `SlimePumpkinEnemy` | `LargeFlyingBuzzsawRedToilet` |
| `SlimeWatermelonEnemy` | `GiantDualBladeToilet` |
| `SlimeWaterLilyEnemy` | `GiantGlassesYellowToilet` |
| `SlimeGreenEnemy` | `GiantGlassesRedToilet` |
| `SlimePlaneteGreenEnemy` | `QuadBladeStriderToilet` |
| `SlimePlaneteYellowEnemy` | `UFOToilet` |
| `SlimePlaneteBlackEnemy` | `RocketToilet` |
| `SlimeGalaxyEnemy` | `StriderRocketToilet` |
| `SlimeBoss1` | `BossToilet` |
| `SlimeBoss2` | `BossToilet2` |

> Các folder `SpiderToilet` và `InfectedTitanSpeakerman` đã tạo ở Bước 1, không cần đổi tên thêm.

### Script PowerShell hỗ trợ (chạy từ thư mục Falcon/)

```powershell
$enemiesPath = "src\ReplicatedStorage\Enemies"
$renames = @{
    "SlimeEnemy"            = "SmallYellowToilet"
    "SlimeFastEnemy"        = "SmallRedToilet"
    "SlimeBombonEnemy"      = "LargeToilet"
    "SlimeYellowEnemy"      = "AssassinYellowToilet"
    "SlimeRedEnemy"         = "AssassinRedToilet"
    "SlimeBlueEnemy"        = "PoliceToilet"
    "SlimePinkMiniBobEnemy" = "GlassesYellowToilet"
    "SlimePinkBobEnemy"     = "GlassesRedToilet"
    "SlimeCandleEnemy"      = "GlitchToilet"
    "SlimeCatEnemy"         = "DJYellowToilet"
    "SlimeMonkeyEnemy"      = "DJRedToilet"
    "SlimeTurtleEnemy"      = "DualBladeToilet"
    "SlimePlantEnemy"       = "VacuumYellowToilet"
    "SlimeTreeEnemy"        = "VacuumRedToilet"
    "SlimeCactusEnemy"      = "FlyingBuzzsawToilet"
    "SlimeBullEnemy"        = "DualBladeYellowToilet"
    "SlimeReindeerEnemy"    = "DualBladeRedToilet"
    "SlimeDuckEnemy"        = "FlyingRocketLauncherToilet"
    "SlimeSharkEnemy"       = "HelicopterParasiteYellowToilet"
    "SlimeOrcaEnemy"        = "HelicopterParasiteRedToilet"
    "SlimeAxolotlEnemy"     = "LargePoliceToilet"
    "SlimeTomatoEnemy"      = "LargeFlyingBuzzsawYellowToilet"
    "SlimePumpkinEnemy"     = "LargeFlyingBuzzsawRedToilet"
    "SlimeWatermelonEnemy"  = "GiantDualBladeToilet"
    "SlimeWaterLilyEnemy"   = "GiantGlassesYellowToilet"
    "SlimeGreenEnemy"       = "GiantGlassesRedToilet"
    "SlimePlaneteGreenEnemy"  = "QuadBladeStriderToilet"
    "SlimePlaneteYellowEnemy" = "UFOToilet"
    "SlimePlaneteBlackEnemy"  = "RocketToilet"
    "SlimeGalaxyEnemy"      = "StriderRocketToilet"
    "SlimeBoss1"            = "BossToilet"
    "SlimeBoss2"            = "BossToilet2"
}

foreach ($old in $renames.Keys) {
    $oldPath = Join-Path $enemiesPath $old
    $newPath = Join-Path $enemiesPath $renames[$old]
    if (Test-Path $oldPath) {
        Rename-Item -Path $oldPath -NewName $renames[$old]
        Write-Host "Renamed: $old -> $($renames[$old])"
    } else {
        Write-Warning "Not found: $oldPath"
    }
}
```

---

## Bước 3 – Cập Nhật EnemyConfigurations.lua

Mở [src/ReplicatedStorage/Modules/EnemyConfigurations.lua](src/ReplicatedStorage/Modules/EnemyConfigurations.lua) và đổi tên tất cả các key theo bảng mapping. Các entry trùng lặp (`SlimePlantEnemy` và `SlimeCactusEnemy` cho Cycle 9) cần đổi thành tên mới riêng:

```lua
-- CŨ                              -- MỚI
["SlimeEnemy"]              →  ["SmallYellowToilet"]
["SlimeFastEnemy"]          →  ["SmallRedToilet"]
["SlimeBombonEnemy"]        →  ["LargeToilet"]
["SlimeYellowEnemy"]        →  ["AssassinYellowToilet"]
["SlimeRedEnemy"]           →  ["AssassinRedToilet"]
["SlimeBlueEnemy"]          →  ["PoliceToilet"]
["SlimePinkMiniBobEnemy"]   →  ["GlassesYellowToilet"]
["SlimePinkBobEnemy"]       →  ["GlassesRedToilet"]
["SlimeCandleEnemy"]        →  ["GlitchToilet"]
["SlimeCatEnemy"]           →  ["DJYellowToilet"]
["SlimeMonkeyEnemy"]        →  ["DJRedToilet"]
["SlimeTurtleEnemy"]        →  ["DualBladeToilet"]
["SlimePlantEnemy"]  (C5)   →  ["VacuumYellowToilet"]
["SlimeTreeEnemy"]          →  ["VacuumRedToilet"]
["SlimeCactusEnemy"] (C5)   →  ["FlyingBuzzsawToilet"]
["SlimeBullEnemy"]          →  ["DualBladeYellowToilet"]
["SlimeReindeerEnemy"]      →  ["DualBladeRedToilet"]
["SlimeDuckEnemy"]          →  ["FlyingRocketLauncherToilet"]
["SlimeSharkEnemy"]         →  ["HelicopterParasiteYellowToilet"]
["SlimeOrcaEnemy"]          →  ["HelicopterParasiteRedToilet"]
["SlimeAxolotlEnemy"]       →  ["LargePoliceToilet"]
["SlimeTomatoEnemy"]        →  ["LargeFlyingBuzzsawYellowToilet"]
["SlimePumpkinEnemy"]       →  ["LargeFlyingBuzzsawRedToilet"]
["SlimeWatermelonEnemy"]    →  ["GiantDualBladeToilet"]
["SlimeWaterLilyEnemy"]     →  ["GiantGlassesYellowToilet"]
["SlimeGreenEnemy"]         →  ["GiantGlassesRedToilet"]
["SlimePlantEnemy"]  (C9)   →  ["SpiderToilet"]              ← entry thứ 2 (đổi thành tên mới)
["SlimeCactusEnemy"] (C9)   →  ["InfectedTitanSpeakerman"]   ← entry thứ 2
["SlimePlaneteGreenEnemy"]  →  ["QuadBladeStriderToilet"]
["SlimePlaneteYellowEnemy"] →  ["UFOToilet"]
["SlimePlaneteBlackEnemy"]  →  ["RocketToilet"]
["SlimeGalaxyEnemy"]        →  ["StriderRocketToilet"]
["SlimeBoss1"]              →  ["BossToilet"]
["SlimeBoss2"]              →  ["BossToilet2"]
```

---

## Bước 4 – Cập Nhật WaveConfigurations.lua

Mở [src/ReplicatedStorage/Modules/WaveConfigurations.lua](src/ReplicatedStorage/Modules/WaveConfigurations.lua) và thay tất cả giá trị trong field `Enemy`:

```lua
-- Tìm và thay từng chuỗi:
Enemy = "SlimeEnemy"              →  Enemy = "SmallYellowToilet"
Enemy = "SlimeFastEnemy"          →  Enemy = "SmallRedToilet"
Enemy = "SlimeBombonEnemy"        →  Enemy = "LargeToilet"
-- ... (theo bảng mapping đầy đủ ở trên)

-- Đặc biệt cho Wave 81-100 (Cycle 9):
-- Các wave dùng SlimePlantEnemy  →  "SpiderToilet"
-- Các wave dùng SlimeCactusEnemy →  "InfectedTitanSpeakerman"
```

> Dùng Find & Replace trong VS Code với **Match Case** bật để tránh thay nhầm. Thay từng chuỗi một theo thứ tự từ dài đến ngắn (tránh partial match).

---

## Bước 5 – Cập Nhật WaveController.lua (Boss Detection)

Mở [src/ServerScriptService/Controllers/WaveController.lua](src/ServerScriptService/Controllers/WaveController.lua), tìm đến **dòng 287-290** (boss wave detection):

```lua
-- CŨ:
if group.Enemy == "SlimeBoss1" or group.Enemy == "SlimeBoss2" then

-- MỚI:
if group.Enemy == "BossToilet" or group.Enemy == "BossToilet2" then
```

---

## Bước 6 – Cập Nhật Model 3D trong Roblox Studio

Trong **Roblox Studio**, mở file `.rbxl`:

1. Vào **Explorer** → `ReplicatedStorage` → `Enemies`
2. Đổi tên từng Model con theo bảng mapping (click chuột phải → Rename)
3. Đảm bảo tên Model khớp chính xác với tên folder trong source code (phân biệt chữ hoa/thường, không có khoảng trắng)

> Nếu dùng **Rojo** để sync, các folder đã đổi tên ở Bước 2 sẽ tự động sync vào Studio khi chạy `rojo serve`.

---

## Bước 7 – Kiểm Tra Sau Khi Đổi Tên

### Checklist

- [ ] Tất cả 34 folder trong `src/ReplicatedStorage/Enemies/` đã đổi tên đúng (32 cũ + 2 mới tạo)
- [ ] `EnemyConfigurations.lua` không còn key nào bắt đầu bằng `Slime`
- [ ] `WaveConfigurations.lua` không còn giá trị `Enemy` nào bắt đầu bằng `Slime`
- [ ] `WaveController.lua` không còn reference `SlimeBoss1` / `SlimeBoss2`
- [ ] Trong Roblox Studio, tên Model khớp với tên folder/key trong code
- [ ] Test thử Wave 1, Wave 41, Wave 81, Wave 101 để kiểm tra enemy spawn đúng
- [ ] Test Boss wave (Wave có SlimeBoss1/SlimeBoss2 cũ) để xác nhận boss detection hoạt động

### Test nhanh trong Studio (Command Bar)

```lua
-- Kiểm tra tất cả enemy có trong ReplicatedStorage khớp với EnemyConfigurations
local RE = game:GetService("ReplicatedStorage")
local configs = require(RE.Modules.EnemyConfigurations)
for _, folder in ipairs(RE.Enemies:GetChildren()) do
    if not configs[folder.Name] then
        warn("MISSING CONFIG: " .. folder.Name)
    end
end
print("Check complete")
```

---

## Tóm Tắt Thứ Tự Thực Hiện

```
1. Tạo folder SpiderToilet + InfectedTitanSpeakerman (Bước 1)
2. Đổi tên 32 folder trong Enemies/ (Bước 2)
3. Cập nhật EnemyConfigurations.lua (Bước 3)
4. Cập nhật WaveConfigurations.lua (Bước 4)
5. Cập nhật WaveController.lua boss check (Bước 5)
6. Sync/đổi tên trong Roblox Studio (Bước 6)
7. Test và verify (Bước 7)
```
