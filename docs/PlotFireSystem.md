# Plot Fire System — Plan

## Mô tả tính năng

Mỗi Plot của người chơi có thanh máu (Health). Khi máu giảm, các ngọn lửa (`Fire`) trong
`Workspace/Map/Fires/<PlotName>/` sẽ hiện dần và to lên theo tỉ lệ máu đã mất.

---

## Cấu trúc Workspace

```
Workspace/
└── Map/
    └── Fires/
        └── Plot1/        ← tên PHẢI khớp với Workspace.Plots (Plot1, Plot2...)
            ├── 1/
            │   └── Fire
            ├── 2/
            │   └── Fire
            ├── 3/
            │   └── Fire
            ├── 4/
            │   └── Fire
            └── 5/
                └── Fire
```

---

## Mapping Player ↔ Plot ↔ Fire folder

Hệ thống hiện tại đã có sẵn cơ chế:
- Player có attribute `PlotNumber` (số 1–20), set bởi `PlotController`.
- Plots nằm ở `Workspace.Plots/Plot1`, `Plot2`...

**Fire folder dùng chính `PlotNumber` để map:**

```lua
local plotNum    = player:GetAttribute("PlotNumber")  -- vd: 3
local fireFolder = Workspace.Map.Fires:FindFirstChild("Plot" .. plotNum)  -- "Plot3"
local plotModel  = Workspace.Plots:FindFirstChild("Plot" .. plotNum)
```

Không cần logic riêng — đặt tên Fire folder trùng với tên Plot là xong.

---

## Reset khi người chơi thoát

`PlotController.onPlayerRemoving()` hiện tại đã dọn placed items và reset `OwnerId`.
Ta cần thêm **1 dòng**: reset `PlotHealth` về `PlotMaxHealth`.

```lua
-- Thêm vào onPlayerRemoving() trong PlotController.lua
plot:SetAttribute("PlotHealth", plot:GetAttribute("PlotMaxHealth"))
```

**Tại sao đủ:** Client đang lắng nghe `GetAttributeChangedSignal("PlotHealth")`.
Khi health về max → `updateFires()` tính ra 0 lửa → tự tắt hết. Không cần code riêng cho fire reset.

---

## Logic Health → Fire

| Health còn lại | Số Fire hiện | Fire.Size |
|---|---|---|
| 100% | 0 | 0 |
| 80% | 1 | 10 |
| 60% | 2 | 20 |
| 40% | 3 | 30 |
| 20% | 4 | 40 |
| 0% | 5 | 50 |

**Công thức tổng quát** (healthPercent = 0..1):

```
damageFraction = 1 - healthPercent
firesVisible   = math.round(damageFraction * 5)   -- 0..5
fireSize       = damageFraction * 50              -- 0..50
```

Các Fire được chọn **ngẫu nhiên** (shuffle danh sách 5 part, lấy N cái đầu).

---

## Thiết kế hệ thống

### Lưu trữ Health
- Plot có **Attribute** `PlotHealth` (number, 0–100) và `PlotMaxHealth` (number).
- Server là nơi duy nhất ghi `PlotHealth`.
- Client đọc qua `GetAttributeChangedSignal("PlotHealth")` để cập nhật Fire.

### Server — PlotHealthController
**File:** `src/ServerScriptService/Controllers/PlotHealthController.lua`

Trách nhiệm:
- Khởi tạo `PlotHealth` / `PlotMaxHealth` cho mỗi Plot khi server start.
- Expose hàm `TakeDamage(plotModel, amount)` cho các hệ thống khác gọi.
- Khi health về 0 → trigger game over logic.

### Sửa PlotController — reset khi player thoát
**File:** `src/ServerScriptService/Controllers/PlotController.lua`  
**Vị trí:** hàm `onPlayerRemoving()` ~line 393

Thêm vào sau khi tìm được plot:
```lua
plot:SetAttribute("PlotHealth", plot:GetAttribute("PlotMaxHealth"))
```

### Client — PlotFireController
**File:** `src/StarterPlayer/StarterPlayerScripts/PlotFireController.client.lua`

Trách nhiệm:
- Dùng `PlotNumber` attribute của LocalPlayer để tìm đúng Fire folder.
- Lắng nghe `GetAttributeChangedSignal("PlotHealth")` trên Plot model.
- Gọi `updateFires()` mỗi khi health thay đổi.

---

## Chi tiết hàm updateFires

```lua
local function updateFires(fireParts: {BasePart}, healthPercent: number)
    local damageFraction = 1 - healthPercent
    local firesVisible   = math.round(damageFraction * #fireParts)
    local fireSize       = damageFraction * 50

    local shuffled = shuffleParts(fireParts)

    for i, part in ipairs(shuffled) do
        local fire = part:FindFirstChildOfClass("Fire")
        if not fire then continue end

        if i <= firesVisible then
            fire.Enabled = true
            fire.Size    = fireSize
        else
            fire.Enabled = false
            fire.Size    = 0
        end
    end
end
```

---

## Các bước thực hiện

- [ ] **1. Server** — Tạo `PlotHealthController.lua`: init attribute, hàm `TakeDamage`.
- [ ] **2. Server** — Sửa `PlotController.onPlayerRemoving()`: reset `PlotHealth` về max khi player thoát.
- [ ] **3. Client** — Tạo `PlotFireController.client.lua`: đọc attribute, gọi `updateFires`.
- [ ] **4. Mặc định** — Đảm bảo tất cả `Fire.Enabled = false` khi server start (health 100%).
- [ ] **5. Kết nối** — Gọi `TakeDamage` từ hệ thống enemy attack / damage hiện có.
- [ ] **6. Test** — Dùng lệnh debug `/plotdamage` và `/plotheal` để kiểm tra thủ công.

---

## Lệnh debug đề xuất

Thêm vào `DebugController`:

| Lệnh | Mô tả |
|---|---|
| `/plotdamage <amount>` | Gây damage trực tiếp lên plot của bản thân |
| `/plotheal` | Hồi full máu plot của bản thân |
