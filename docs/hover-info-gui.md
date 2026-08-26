# Hover & Click Info GUI — Block và Tower

## Tổng quan

Game hiện có hệ thống GUI thông tin hoạt động theo **2 bước**:
1. **Hover (rê chuột)** → hiện viền trắng bao quanh item
2. **Click** → mở panel thông tin chi tiết ở góc phải màn hình

Cả Block lẫn Tower đều được hỗ trợ bởi cùng một hệ thống.

---

## File chính

**[TurretClicker.client.lua](../src/StarterPlayer/StarterPlayerScripts/TurretClicker.client.lua)**
— LocalScript duy nhất xử lý toàn bộ hover + click info cho Block và Tower.

---

## Cơ chế Hover (rê chuột)

- Dùng event `mouse.Move` để detect target mỗi khi chuột di chuyển.
- Duyệt hierarchy từ `mouse.Target` lên trên, tìm `Model` có tag `PlacedItem` (CollectionService).
- Kiểm tra `plot:GetAttribute("OwnerId") == player.UserId` → chỉ highlight item của chính mình.
- Tạo `Highlight` object tên **"HoverOutline"**:
  - `FillTransparency = 1` (không tô màu bên trong)
  - `OutlineColor = Color3.fromRGB(255, 255, 255)` (viền trắng)
  - `OutlineTransparency = 0.6` (hơi mờ để phân biệt với trạng thái click)

**Không hiện hover khi:**
- Đang có wave active (`isWaveActive = true`)
- Đang ở Delete Mode
- Item đã được click chọn (đang hiển thị SelectionOutline)

---

## Cơ chế Click (mở info panel)

- Dùng event `mouse.Button1Down`.
- Logic tìm item giống hover (duyệt hierarchy + kiểm tra tag + OwnerId).
- Khi tìm được item → gọi `openMenu(turretModel)`.
- Tạo `Highlight` thứ hai tên **"SelectionOutline"**:
  - `OutlineTransparency = 0` (viền trắng đậm hơn, phân biệt với hover)
- Hover outline bị ẩn khi item đang được select.

---

## GUI Info Panel (TurretInfo)

GUI nằm tại `PlayerGui > TurretInfo`, mặc định `Enabled = false`.

### Cấu trúc

```
TurretInfo (ScreenGui)
└── Frame
    ├── UIScale          ← dùng để animate open/close
    ├── ItemName         ← tên Block/Tower
    ├── Design
    │   └── Image        ← icon của item
    ├── Stats
    │   ├── Damage       ← hiển thị HP (Block) hoặc Damage (Tower)
    │   │   ├── ItemIcon ← icon stat (đổi theo loại)
    │   │   └── Frame
    │   │       ├── Title  ← "HP OF BLOCK" hoặc "DAMAGE"
    │   │       └── Count  ← giá trị số
    │   └── Fast         ← Fire Rate (chỉ hiện với Tower)
    │       └── Frame
    │           └── Count
    └── Exit             ← nút đóng
```

### Nội dung theo loại item

| Loại | Title dòng 1 | Giá trị dòng 1 | Dòng 2 (Fast) |
|------|-------------|----------------|---------------|
| **Block** (`Type == "Blocks"`) | `HP OF BLOCK` | `config.Health` | Ẩn |
| **Tower** (còn lại) | `DAMAGE` | `config.Damage` | `config.Cooldown` / `config.FireRate` |

Icon stat:
- Block: `rbxassetid://86839486830710` (icon HP)
- Tower: icon mặc định từ `statIcon.Image`

---

## Animation

| Hành động | Duration | Easing |
|-----------|----------|--------|
| Mở | 0.35s | Back, Out |
| Đóng | 0.2s | Quad, In |

- Panel slide in từ phải: `UDim2.new(1, -20, 0.5, 0)`
- Trạng thái ẩn: `UDim2.new(1, -20, 0.6, 0)` + `UIScale.Scale = 0`
- Mobile scale: `0.6x` | Desktop scale: `1.0x`
- Nút Exit có hiệu ứng zoom `1.15x` khi hover.

---

## Điều kiện tự động đóng panel

1. Wave bắt đầu → `WaveUIStateChanged` event → `closeMenu()`
2. Delete Mode bật → detect qua `RunService.Heartbeat` → `closeMenu()`
3. RobuxStore mở → `robuxStore.Visible` thay đổi → `closeMenu()`
4. Người chơi bấm nút Exit

---

## Dữ liệu nguồn

File config: **[ItemConfigurations.lua](../src/ReplicatedStorage/Modules/ItemConfigurations.lua)**

Script load cả `ItemConfigurations` lẫn `LimitedItems` vào bảng `AllConfigs`.
Nếu không tìm thấy config theo `turretModel.Name`, hiển thị `"?"` cho các chỉ số.

---

## Health Bar riêng (Block)

**[BlockHealthBarController.lua](../src/ServerScriptService/Controllers/BlockHealthBarController.lua)**
— Server script riêng biệt, hiển thị `HealthBarBillboardGui` trực tiếp trên Block.
- Cập nhật real-time theo HP hiện tại.
- Format: `currentHealth / maxHealth`
- Chỉ hiện khi HP > 0.
- Dùng tag `Damageable` (CollectionService).

---

## Kết luận kiểm tra

| Tính năng | Block | Tower |
|-----------|-------|-------|
| Hover viền trắng | ✅ | ✅ |
| Click mở info panel | ✅ | ✅ |
| Hiển thị tên item | ✅ | ✅ |
| Hiển thị icon | ✅ | ✅ |
| Stat HP / Damage | ✅ HP | ✅ Damage |
| Stat Fire Rate | ✗ (ẩn) | ✅ |
| Health bar billboard | ✅ | ✗ |
| Chỉ hiện item của mình | ✅ | ✅ |
| Tắt trong wave | ✅ | ✅ |
| Tắt trong Delete Mode | ✅ | ✅ |
