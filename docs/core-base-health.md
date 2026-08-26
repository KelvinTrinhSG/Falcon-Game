# Core1 (Base) — Hệ thống máu

## Cơ chế hiện tại

| Sự kiện | Thay đổi HP |
|---------|-------------|
| Wave bắt đầu | HP = **50** |
| Mỗi enemy chạm đến Base | HP **-10** |
| HP về 0 | Game Over |
| Giữa các wave | HP reset = **100** |

## Không có hệ thống nâng cấp

- Không có RemoteEvent/Function nào tên `UpgradeCore`, `UpgradeBase`, v.v.
- Không có Shop UI nào cho phép mua nâng cấp máu Base
- Không có config nào trong `ItemConfigurations.lua` cho Core

## Hệ thống dang dở (EquipModel)

Trong [PlotController.lua](../src/ServerScriptService/Controllers/PlotController.lua) có hàm `EquipModel()` — cho phép gắn model bảo vệ lên plot với HP riêng:

```lua
plotHealthPart:SetAttribute("Health", modelConfig.Health)
```

Nhưng **không có Shop UI nào expose chức năng này** ra cho người chơi. Code tồn tại nhưng bị bỏ dở.

## Kết luận

Base hiện tại chỉ có đúng **50 HP cố định** mỗi wave, không thể nâng cấp.

**File liên quan:**
- [WaveController.lua](../src/ServerScriptService/Controllers/WaveController.lua) — set HP khi wave bắt đầu/kết thúc
- [PlotController.lua](../src/ServerScriptService/Controllers/PlotController.lua) — EquipModel (dang dở)
- [HealthUIController.client.lua](../src/StarterPlayer/StarterPlayerScripts/HealthUIController.client.lua) — hiển thị HP Base trên UI
