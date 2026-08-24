# Hướng Dẫn Đổi Tên Turret → Model Mới

## Bảng Mapping

| Tên Turret Cũ | Key Code Cũ | Model Mới (PascalCase) | DisplayName Mới |
|---|---|---|---|
| Old Turret | `OldTurret` | `CameraGuy` | Camera Guy |
| Modern Turret | `ModernTurret` | `EngineerCameraGuy` | Engineer Camera Guy |
| Laser Turret | `LaserTurret` | `LargeScientistCameraman` | Large Scientist Cameraman |
| Extreme Turret | `ExtremeTurret` | `LargeSpeakerGuy` | Large Speaker Guy |
| Toxic Turret | `ToxicTurret` | `LargeTvGuy` | Large TV Guy |
| Bunker Turret | `BunkerTurret` | `LaserCameramanCar` | Laser Cameraman Car |
| Stars Turret | `StarsTurret` | `NinjaCameraGuy` | Ninja Camera Guy |
| Pirate Turret | `PirateTurret` | `SpeakerGuy` | Speaker Guy |
| Viking Turret | `VikingTurret` | `TvGuy` | TV Guy |
| Lava Turret | `LavaTurret` | `TitanCameraGuy` | Titan Camera Guy |

---

## Thông Số Đầy Đủ Các Turret

### Regular Turrets (ItemConfigurations.lua → ItemConfigurations)

| Key Mới | DisplayName Mới | Price | Damage | Range | FireRate | Chance | Stock | ProductID |
|---|---|---|---|---|---|---|---|---|
| `CameraGuy` | Camera Guy | 200 | 50 | 10 | 1 | 100 | 1–5 | 3495738970 |
| `EngineerCameraGuy` | Engineer Camera Guy | 500 | 100 | 12 | 0.5 | 90 | 1–5 | 3495739477 |
| `LargeScientistCameraman` | Large Scientist Cameraman | 1000 | 175 | 18 | 2 | 80 | 1–5 | 3495739902 |
| `LargeSpeakerGuy` | Large Speaker Guy | 2500 | 250 | 20 | 2 | 70 | 1–5 | 3590647772 |
| `LargeTvGuy` | Large TV Guy | 4000 | 400 | 16 | 2 | 60 | 1–5 | 3590648594 |
| `LaserCameramanCar` | Laser Cameraman Car | 7000 | 700 | 24 | 1 | 50 | 1–5 | 3590649081 |
| `NinjaCameraGuy` | Ninja Camera Guy | 15000 | 1000 | 28 | 2 | 40 | 1–5 | 3590649517 |
| `SpeakerGuy` | Speaker Guy | 30000 | 1500 | 30 | 1 | 30 | 1–5 | 3595356576 |
| `TvGuy` | TV Guy | 60000 | 3000 | 35 | 1 | 20 | 1–5 | 3595356717 |

### Limited Turret (ItemConfigurations.lua → LimitedItems)

| Key Mới | DisplayName Mới | Damage | Range | FireRate | ProductID |
|---|---|---|---|---|---|
| `TitanCameraGuy` | Titan Camera Guy | 2500 | 40 | 2 | 3589846329 |

### Image IDs (giữ nguyên, không đổi)

| Key Mới | ImageId |
|---|---|
| `CameraGuy` | `rbxassetid://79863737566861` |
| `EngineerCameraGuy` | `rbxassetid://134127163464424` |
| `LargeScientistCameraman` | `rbxassetid://138810171314082` |
| `LargeSpeakerGuy` | `rbxassetid://120922630413741` |
| `LargeTvGuy` | `rbxassetid://79148208455816` |
| `LaserCameramanCar` | `rbxassetid://110368994158233` |
| `NinjaCameraGuy` | `rbxassetid://90506924551302` |
| `SpeakerGuy` | `rbxassetid://104918083676404` |
| `TvGuy` | `rbxassetid://107433289761116` |
| `TitanCameraGuy` | `rbxassetid://131940710641018` |

### Tham Chiếu Đặc Biệt Cần Đổi Thêm

| File | Vị trí | Giá trị cũ | Giá trị mới |
|---|---|---|---|
| `WeaponConfigurations.lua` | `StarterPack.BeginnerPack.TurretId` | `"ModernTurret"` | `"EngineerCameraGuy"` |
| `WheelServer.server.lua` | `Items` – Item3 `name` và `itemId` | `"Modern Turret"` / `"ModernTurret"` | `"Engineer Camera Guy"` / `"EngineerCameraGuy"` |

---

## Các File Cần Chỉnh Sửa

| File | Loại thay đổi |
|---|---|
| `src/ReplicatedStorage/Modules/ItemConfigurations.lua` | Đổi 10 key và DisplayName |
| `src/ReplicatedStorage/Modules/WeaponConfigurations.lua` | Đổi key tham chiếu turret |
| `src/ServerScriptService/WheelServer.server.lua` | Đổi `itemId` |
| `src/ServerScriptService/Controllers/WeaponsShopController.lua` | Đổi tên tham chiếu |
| `src/ServerScriptService/Controllers/PlayerController.lua` | Đổi tên tham chiếu |
| `src/ServerScriptService/Controllers/PlacementController.lua` | Đổi tên tham chiếu |
| `src/ServerScriptService/Controllers/BlocksShopController.lua` | Đổi tên tham chiếu |
| `src/ServerScriptService/Controllers/LimitedTurretController.lua` | Đổi `LavaTurret` |
| `src/StarterPlayer/StarterPlayerScripts/OnboardingHandler.client.lua` | Đổi tên tham chiếu |
| `src/StarterGui/GUI/Frames/Inventory/InventoryHandler.client.lua` | Đổi tên tham chiếu |
| `src/StarterGui/GUI/Frames/BlocksShop/BlocksShopHandler.client.lua` | Đổi tên tham chiếu |
| `src/StarterGui/GUI/Frames/LimitedTurret/LimitedTurretHandler.client.lua` | Đổi `LavaTurret` |
| Roblox Studio – Model trong Workspace/ReplicatedStorage | Đổi tên model 3D |

---

## Bước 1 – Đổi Key và DisplayName trong ItemConfigurations.lua

Mở [src/ReplicatedStorage/Modules/ItemConfigurations.lua](src/ReplicatedStorage/Modules/ItemConfigurations.lua).

Đổi tên từng key và `DisplayName` tương ứng:

```lua
-- CŨ                          -- MỚI
OldTurret              →  CameraGuy
ModernTurret           →  EngineerCameraGuy
LaserTurret            →  LargeScientistCameraman
ExtremeTurret          →  LargeSpeakerGuy
ToxicTurret            →  LargeTvGuy
BunkerTurret           →  LaserCameramanCar
StarsTurret            →  NinjaCameraGuy
PirateTurret           →  SpeakerGuy
VikingTurret           →  TvGuy
LavaTurret             →  TitanCameraGuy  -- nằm trong LimitedItems
```

Mỗi entry cũng cần đổi field `DisplayName`:

```lua
-- Ví dụ:
CameraGuy = {
    DisplayName = "Camera Guy",  -- đổi từ "Old Turret"
    ...
}
```

---

## Bước 2 – Cập Nhật WeaponConfigurations.lua

Mở [src/ReplicatedStorage/Modules/WeaponConfigurations.lua](src/ReplicatedStorage/Modules/WeaponConfigurations.lua).

Dùng **Find & Replace** (Ctrl+H) trong VS Code, bật **Match Case**, thay lần lượt:

```
OldTurret              →  CameraGuy
ModernTurret           →  EngineerCameraGuy
LaserTurret            →  LargeScientistCameraman
ExtremeTurret          →  LargeSpeakerGuy
ToxicTurret            →  LargeTvGuy
BunkerTurret           →  LaserCameramanCar
StarsTurret            →  NinjaCameraGuy
PirateTurret           →  SpeakerGuy
VikingTurret           →  TvGuy
LavaTurret             →  TitanCameraGuy
```

> Thay từ **dài đến ngắn** để tránh partial match (ví dụ thay `LargeScientistCameraman` trước `Cameraman`).

---

## Bước 3 – Cập Nhật WheelServer.server.lua

Mở [src/ServerScriptService/WheelServer.server.lua](src/ServerScriptService/WheelServer.server.lua).

Tìm các entry có `itemId` và đổi theo bảng:

```lua
-- CŨ
{id="Item3", name="Modern Turret", ..., itemId="ModernTurret"},

-- MỚI
{id="Item3", name="Engineer Camera Guy", ..., itemId="EngineerCameraGuy"},
```

Áp dụng cho tất cả 10 turret có trong file này.

---

## Bước 4 – Cập Nhật Các File Controller và Handler

Dùng **Find & Replace** trong VS Code để thay đồng loạt trong từng file sau. Bật **Match Case**.

### Files cần thay:
- [src/ServerScriptService/Controllers/WeaponsShopController.lua](src/ServerScriptService/Controllers/WeaponsShopController.lua)
- [src/ServerScriptService/Controllers/PlayerController.lua](src/ServerScriptService/Controllers/PlayerController.lua)
- [src/ServerScriptService/Controllers/PlacementController.lua](src/ServerScriptService/Controllers/PlacementController.lua)
- [src/ServerScriptService/Controllers/BlocksShopController.lua](src/ServerScriptService/Controllers/BlocksShopController.lua)
- [src/ServerScriptService/Controllers/LimitedTurretController.lua](src/ServerScriptService/Controllers/LimitedTurretController.lua)
- [src/StarterPlayer/StarterPlayerScripts/OnboardingHandler.client.lua](src/StarterPlayer/StarterPlayerScripts/OnboardingHandler.client.lua)
- [src/StarterGui/GUI/Frames/Inventory/InventoryHandler.client.lua](src/StarterGui/GUI/Frames/Inventory/InventoryHandler.client.lua)
- [src/StarterGui/GUI/Frames/BlocksShop/BlocksShopHandler.client.lua](src/StarterGui/GUI/Frames/BlocksShop/BlocksShopHandler.client.lua)
- [src/StarterGui/GUI/Frames/LimitedTurret/LimitedTurretHandler.client.lua](src/StarterGui/GUI/Frames/LimitedTurret/LimitedTurretHandler.client.lua)

Trong mỗi file, thay tất cả 10 chuỗi theo bảng ở Bước 2.

---

## Bước 5 – Đổi Tên Model 3D trong Roblox Studio

Trong **Roblox Studio**, mở file `.rbxl`:

1. Vào **Explorer** → tìm thư mục chứa các model Turret (thường trong `ReplicatedStorage` hoặc `Workspace`)
2. Đổi tên từng Model theo bảng:

| Model Cũ (trong Studio) | Model Mới |
|---|---|
| Old Turret | CameraGuy |
| Modern Turret | EngineerCameraGuy |
| Laser Turret | LargeScientistCameraman |
| Extreme Turret | LargeSpeakerGuy |
| Toxic Turret | LargeTvGuy |
| Bunker Turret | LaserCameramanCar |
| Stars Turret | NinjaCameraGuy |
| Pirate Turret | SpeakerGuy |
| Viking Turret | TvGuy |
| Lava Turret | TitanCameraGuy |

3. Click chuột phải vào Model → **Rename** → nhập tên mới (không có khoảng trắng, đúng chữ hoa/thường)

> Nếu dùng **Rojo**, sau khi sync source code thì Studio sẽ tự cập nhật — chỉ cần đổi tên thủ công các Model 3D chưa được quản lý bởi Rojo.

---

## Bước 6 – Kiểm Tra Sau Khi Đổi Tên

### Checklist

- [ ] `ItemConfigurations.lua`: 10 key và 10 DisplayName đã đổi đúng
- [ ] `WeaponConfigurations.lua`: không còn key nào chứa tên Turret cũ
- [ ] `WheelServer.server.lua`: tất cả `itemId` đã khớp tên mới
- [ ] Các file controller/handler: không còn reference nào đến tên Turret cũ
- [ ] `LimitedTurretController.lua` và `LimitedTurretHandler.client.lua`: `LavaTurret` → `TitanCameraGuy`
- [ ] Roblox Studio: tên Model khớp chính xác với key trong `ItemConfigurations.lua`

### Script kiểm tra nhanh trong Studio (Command Bar)

```lua
-- Kiểm tra tên model có trong ItemConfigurations
local RE = game:GetService("ReplicatedStorage")
local configs = require(RE.Modules.ItemConfigurations).ItemConfigurations
local newNames = {
    "CameraGuy", "EngineerCameraGuy", "LargeScientistCameraman",
    "LargeSpeakerGuy", "LargeTvGuy", "LaserCameramanCar",
    "NinjaCameraGuy", "SpeakerGuy", "TvGuy", "TitanCameraGuy"
}
for _, name in ipairs(newNames) do
    if configs[name] then
        print("OK: " .. name)
    else
        warn("MISSING: " .. name)
    end
end
```

### Tìm tên cũ còn sót trong source code (PowerShell)

```powershell
$oldNames = @("OldTurret","ModernTurret","LaserTurret","ExtremeTurret","ToxicTurret",
              "BunkerTurret","StarsTurret","PirateTurret","VikingTurret","LavaTurret")
foreach ($name in $oldNames) {
    $results = Select-String -Path "src\**\*.lua" -Pattern $name -Recurse
    if ($results) {
        Write-Warning "Still found '$name' in:"
        $results | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber)" }
    }
}
```

---

## Tóm Tắt Thứ Tự Thực Hiện

```
1. Đổi key + DisplayName trong ItemConfigurations.lua      (Bước 1)
2. Đổi tên trong WeaponConfigurations.lua                  (Bước 2)
3. Đổi itemId trong WheelServer.server.lua                 (Bước 3)
4. Find & Replace trong 9 file controller/handler          (Bước 4)
5. Đổi tên Model 3D trong Roblox Studio                    (Bước 5)
6. Kiểm tra và test trong game                             (Bước 6)
```
