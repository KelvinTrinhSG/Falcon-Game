# Hệ thống Base Shop — Tài liệu đầy đủ

## 1. Tổng quan

Player mua và trang bị Base (Core) để bảo vệ plot. Base cao tier → máu nhiều hơn → chịu được nhiều enemy hơn. Khi mua xong, Base mới tự động được trang bị và model trong Workspace được swap ngay.

---

## 2. Config — `BaseConfigurations`

**File:** `src/ReplicatedStorage/Modules/ItemConfigurations.lua` (cuối file, trước `return`)

```lua
local BaseConfigurations = {
    Core1 = { DisplayName = "Core 1", Price = 0,     Health = 100 },
    Core2 = { DisplayName = "Core 2", Price = 2000,  Health = 150 },
    Core3 = { DisplayName = "Core 3", Price = 10000, Health = 250 },
    Core4 = { DisplayName = "Core 4", Price = 25000, Health = 400 },
    Core5 = { DisplayName = "Core 5", Price = 60000, Health = 600 },
}
```

Export qua: `ItemConfigsModule.BaseConfigurations`

### Bảng giá & máu

| Tier | Model | Price ($) | MaxHealth | Chịu được (10 dmg/enemy) |
|------|-------|-----------|-----------|--------------------------|
| 1    | Core1 | 0 (Free)  | 100       | 10 con                   |
| 2    | Core2 | 2,000     | 150       | 15 con                   |
| 3    | Core3 | 10,000    | 250       | 25 con                   |
| 4    | Core4 | 25,000    | 400       | 40 con                   |
| 5    | Core5 | 60,000    | 600       | 60 con                   |

> Giá phân bố theo đường parabol với anchor: Core2 = 2,000 và Core5 = 60,000.

---

## 3. Player Data

**File:** `src/ServerScriptService/Controllers/PlayerController.lua` — `ProfileTemplate`

```lua
OwnedBases  = {"Core1"},   -- list baseId đã sở hữu. Core1 mặc định luôn có.
EquippedBase = "Core1",    -- baseId đang trang bị
```

---

## 4. Damage hệ thống

- Mỗi enemy chạm đến Base (đi hết waypoint đến `"End"`) → trừ **10 HP** vào `Core1:GetAttribute("Health")`
- Damage không phải qua Touched, chỉ check khoảng cách ≤ 5 studs với waypoint `"End"`
- WaveController reset health về `MaxHealth` attribute mỗi khi bắt đầu fight mới

---

## 5. Cấu trúc Workspace

```
Workspace/
  Plots/
    PlotX/
      Core1       ← Model Base đang trang bị (tên luôn là "Core1")
                    Attribute: Health    (current HP)
                    Attribute: MaxHealth (max HP từ config)
```

> Khi equip base mới: `Core1` hiện tại bị Destroy, clone từ `ReplicatedStorage/Bases/CoreX` được đặt vào, đặt tên lại thành `"Core1"`, set `Health` và `MaxHealth`.

---

## 6. Cấu trúc ReplicatedStorage

```
ReplicatedStorage/
  Bases/
    Core1   ← Model Base mặc định (bắt buộc có để swap về)
    Core2
    Core3
    Core4
    Core5
  Templates/
    BasesTemplate   ← Template card cho GUI (xem mục 9)
  Events/
    PurchaseBase    ← RemoteEvent (tự tạo bởi BaseShopController)
    EquipBase       ← RemoteEvent (tự tạo bởi BaseShopController)
    BaseDataUpdated ← RemoteEvent (tự tạo bởi BaseShopController)
  Functions/
    GetBaseData     ← RemoteFunction (tự tạo bởi BaseShopController)
```

---

## 7. Server — BaseShopController

**File:** `src/ServerScriptService/Controllers/BaseShopController.lua`

### Hàm chính

#### `BaseShopController:EquipBase(player, baseId, forceEquip?)`
- Tìm `Core1` trong plot → lưu CFrame → Destroy
- Clone model từ `ReplicatedStorage/Bases/baseId` → đặt tên `"Core1"` → set `MaxHealth` + `Health`
- Lưu `profile.Data.EquippedBase = baseId`
- Nếu đang fight → sync `WaveStateChanged` với health mới
- Fire `BaseDataUpdated` → client cập nhật GUI
- Nếu `forceEquip = true` → không hiện notification

#### Events được lắng nghe

| Event | Xử lý |
|-------|-------|
| `PurchaseBase` (OnServerEvent) | Kiểm tra owned, kiểm tra cash, trừ tiền, thêm vào OwnedBases, gọi EquipBase |
| `EquipBase` (OnServerEvent) | Kiểm tra owned, gọi EquipBase |
| `GetBaseData` (OnServerInvoke) | Trả về `(OwnedBases, EquippedBase)` |

### Init & dependencies

```lua
function BaseShopController:Init(controllers)
    PlayerController = controllers.PlayerController
    WaveController   = controllers.WaveController
end
```

PlotController cũng inject `BaseShopController` và gọi `EquipBase` khi player join (load đúng model + health).

---

## 8. Client — BasesShopHandler

**File:** `src/StarterGui/GUI/Frames/BasesShop/BasesShopHandler.client.lua`

### Logic hiển thị mỗi card

| Trạng thái | BuyButton | EquipButton | EquippedLabel |
|-----------|-----------|-------------|---------------|
| Đang trang bị | Hidden | Hidden | **Visible** |
| Đã sở hữu, chưa trang bị | Hidden | **Visible** | Hidden |
| Chưa sở hữu | **Visible** | Hidden | Hidden |

### Events lắng nghe

- `BaseDataUpdated.OnClientEvent(newOwned, newEquipped)` → repopulate GUI
- `shopFrame:GetPropertyChangedSignal("Visible")` → populate khi frame mở

### Khởi tạo

- `GetBaseData:InvokeServer()` → lấy `(OwnedBases, EquippedBase)` khi script chạy lần đầu

---

## 9. Studio — BasesTemplate (cần tạo)

Template card cho mỗi Base trong ScrollingFrame. Tạo tại `ReplicatedStorage/Templates/BasesTemplate`.

### Children bắt buộc (dùng `FindFirstChild` trong code)

| Tên | Loại | Nội dung |
|-----|------|---------|
| `ItemName` | TextLabel | Tên base (vd: "Core 3") |
| `ItemHealth` | TextLabel | `"HP: 250"` |
| `ItemPrice` | TextLabel | `"$10,000"` hoặc `"Free"` |
| `BuyButton` | TextButton | Hiện khi chưa sở hữu |
| `EquipButton` | TextButton | Hiện khi đã sở hữu nhưng chưa trang bị |
| `EquippedLabel` | TextLabel | Hiện khi đang trang bị |

> Tất cả children đều optional trong code (dùng FindFirstChild), thiếu child nào thì chỉ bỏ qua.

---

## 10. GUI Frame — BasesShop

**Location:** `StarterGui/GUI/Frames/BasesShop`

### Children bắt buộc

| Tên | Loại | Mô tả |
|-----|------|-------|
| `ScrollingFrame` | ScrollingFrame | Chứa các card base |

> Không có timer hay restock vì Base mua vĩnh viễn, không có stock.

### Mở frame

- Player chạm `Workspace/BasesShop/Touch` → ShopController fire `OpenShopFrame("BasesShop")` → FrameManager mở frame

---

## 11. Debug Commands (chat)

| Lệnh | Tác dụng |
|------|----------|
| `/baseme` | Cấp toàn bộ Core2–5 cho bản thân |
| `/baseid <UserId>` | Cấp toàn bộ base cho player theo UserId |
| `/baseall` | Cấp toàn bộ base cho tất cả player |
| `/equipbase Core3` | Trang bị base cụ thể (tự thêm vào owned nếu chưa có) |

**Files liên quan:**
- `src/StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua` — client chat handler
- `src/ServerScriptService/Services/DebugService.lua` — server logic

---

## 12. Files đã implement

| File | Trạng thái | Ghi chú |
|------|-----------|---------|
| `ReplicatedStorage/Modules/ItemConfigurations.lua` | ✅ Done | Thêm `BaseConfigurations` |
| `ServerScriptService/Controllers/PlayerController.lua` | ✅ Done | Thêm `OwnedBases`, `EquippedBase` vào ProfileTemplate |
| `ServerScriptService/Controllers/BaseShopController.lua` | ✅ Done | Controller mới |
| `ServerScriptService/Controllers/PlotController.lua` | ✅ Done | Gọi EquipBase khi join |
| `ServerScriptService/Controllers/WaveController.lua` | ✅ Done | Đọc `MaxHealth` attribute thay vì hardcode |
| `StarterGui/GUI/Frames/BasesShop/BasesShopHandler.client.lua` | ✅ Done | Rewrite hoàn toàn |
| `StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua` | ✅ Done | Thêm lệnh /base* |
| `ServerScriptService/Services/DebugService.lua` | ✅ Done | Thêm GiveBase*, EquipBase |

## 13. Còn cần làm trong Studio

| Việc | Mô tả |
|------|-------|
| `ReplicatedStorage/Bases/Core1` | Thêm model Core1 (copy từ plot) để có thể swap về |
| `ReplicatedStorage/Bases/Core2–5` | Thêm các model Base mới |
| `ReplicatedStorage/Templates/BasesTemplate` | Tạo card template theo mục 9 |
| `StarterGui/GUI/Frames/BasesShop` | Thiết kế GUI frame với `ScrollingFrame` bên trong |
| `Workspace/BasesShop/Touch` | Đã có trong ShopController, cần đảm bảo model tồn tại trong Workspace |
