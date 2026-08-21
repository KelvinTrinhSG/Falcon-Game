# Hệ thống Crate

## Tổng quan

- **4 loại Crate:** WoodCrate, MetalCrate, EarthCrate, GodCrate
- **Tối đa 3 slot** crate mỗi player
- **Config trung tâm:** `WeaponConfigurations.Crates`
- **Models:** `ReplicatedStorage/Crates/`

---

## Loại Crate (WeaponConfigurations.lua)

| Key | DisplayName | Giá (Cash) | UnlockTime | Loot |
|---|---|---|---|---|
| `WoodCrate` | Wood Crate | 600 | 60s | StoneSword, ClassicSword, WhiteSword |
| `MetalCrate` | Metal Crate | 4,000 | 300s (5 phút) | BlueSword, IceSword, AzureSword, PinkSword |
| `EarthCrate` | Earth Crate | 15,000 | 900s (15 phút) | EasterSword, GemSword, PotOSword, EarthSword |
| `GodCrate` | GodCrate | Robux only | 0s (instant) | PrismFang, SovereignSplitter, Crownbreaker, LightSword |

**ProductID (Robux):** WoodCrate `3493295534`, MetalCrate `3493297826`, EarthCrate `3493298349`, GodCrate `3493293425`

**SkipTimerProductID:** WoodCrate `3590910161`, MetalCrate `3493295140`, EarthCrate `3590910686`

---

## Cấu trúc Data Player

Lưu trong `profile.Data.Crates` (array):
```lua
{
    Type = "WoodCrate",
    SpawnIndex = 1,
    UnlockTimestamp = os.time() + unlockTime
}
```

---

## Luồng hoạt động

```
Player mua crate (Cash hoặc Robux)
        ↓
WeaponsShopController:PurchaseCrate() / CrateController:PurchaseCrate()
        ↓
CrateController:SpawnCrateModel()  →  Model xuất hiện trên plot
        ↓
ClientCrateHandler  →  Hiển thị countdown timer trên crate
        ↓
Player chạm vào crate khi hết giờ
        ↓
CrateController:onOpenCrate()  →  Roll loot từ bảng WeaponConfigurations
        ↓
Weapon được thêm vào inventory, crate bị xóa
```

---

## Các file liên quan

### Server

| File | Vai trò |
|---|---|
| `ServerScriptService/Controllers/CrateController.lua` | Controller chính: mua, spawn, unlock, mở crate |
| `ServerScriptService/Controllers/WeaponsShopController.lua` | Xử lý mua bằng Robux, skip timer, restock shop |
| `ServerScriptService/Controllers/PlotController.lua` | Spawn PromotionalGodCrate lên plot khi player join |
| `ServerScriptService/Controllers/PlayerController.lua` | Khởi tạo `profile.Data.Crates = {}`, fire `CrateDataUpdated` khi login |
| `ServerScriptService/PromoCodesHandler.server.lua` | Code `WELCOME` tặng MetalCrate qua `CrateController:PurchaseCrate()` |
| `ServerScriptService/WheelServer.server.lua` | Vòng quay: GodCrate (1.5%) — instant open lấy weapon luôn |
| `ReplicatedStorage/Modules/WeaponConfigurations.lua` | Config toàn bộ crate: giá, unlock time, loot table, ProductID |

### Client

| File | Vai trò |
|---|---|
| `StarterPlayer/StarterPlayerScripts/ClientCrateHandler.client.lua` | Countdown timer GUI trên crate model, đổi màu khi sẵn sàng |
| `StarterPlayer/StarterPlayerScripts/PromotionalCrateHandler.client.lua` | ProximityPrompt + Touched cho GodCrate cố định trên plot |
| `StarterGui/GUI/Frames/WeaponsShop/WeaponsShopHandler.client.lua` | UI shop: list crate, nút Robux, đếm slot còn lại |

---

## Chi tiết từng file

### CrateController.lua
- `PurchaseCrate(player, crateType, isFree)` — kiểm tra slot (max 3), tạo data, gọi SpawnCrateModel, fire `CrateDataUpdated`
- `SpawnCrateModel(player, crateData)` — clone model từ `ReplicatedStorage/Crates`, set attribute `OwnerId / UnlockTimestamp / SpawnIndex / CrateType`, setup Touched với debounce + kiểm tra thời gian
- `onOpenCrate(player, spawnIndex)` — tìm crate trong data, roll random từ `config.Loot`, thêm weapon vào inventory, xóa crate
- `LoadPlayerCrates(player)` — gọi khi player join, spawn lại tất cả crate đã lưu

### WeaponsShopController.lua
- `processReceipt()` — xử lý Robux purchase:
  - GodCrate ProductID → instant open, cho weapon thẳng
  - Crate khác → gọi `CrateController:PurchaseCrate()`
  - SkipTimerProductID → set `UnlockTimestamp = 0` để mở ngay
- `RequestSkipTimer(player, crateModel)` — đọc `CrateType` từ attribute, lấy SkipTimerProductID, fire prompt Robux về client
- `Restock()` — tạo stock ngẫu nhiên cho WeaponsShop dựa vào `Chance` và `StockAmount` trong config

### ClientCrateHandler.client.lua
- Chờ folder `Crate` trong plot của player
- Mỗi crate được gắn countdown GUI clone từ `CrateGUITemplate`
- Heartbeat loop cập nhật giây còn lại, đổi `StrokeColor` sang vàng khi `UnlockTimestamp ≤ os.time()`

### PlotController.lua
- `spawnPromotionalCrate()` — tìm `RobuxCrateSpawn` part trên plot, clone GodCrate model, đặt tên `PromotionalGodCrate`

### PromotionalCrateHandler.client.lua
- Chờ `PromotionalGodCrate` xuất hiện trên plot
- Tạo ProximityPrompt với DisplayName và ProductID từ config
- Backup: Touched event với debounce 3 giây

---

## Events

| Event | Hướng | Mô tả |
|---|---|---|
| `CrateDataUpdated` | Server → Client | Fire khi crate array thay đổi (mua, mở, login) |
| `RequestSkipTimer` | Server → Client | Gửi ProductID để client prompt Robux |

---

## Lưu ý kỹ thuật

- GodCrate trên Wheel **không** tạo crate model — mở thẳng và cho weapon ngay
- GodCrate Promotional trên plot **chỉ** mua bằng Robux (không có cash price)
- Slot crate bị giới hạn **3** — được check ở cả `CrateController`, `WeaponsShopController` và UI client
- Model crate phải có attribute `UnlockTimestamp` trước khi client ClientCrateHandler đọc (có `WaitForChild` logic)
