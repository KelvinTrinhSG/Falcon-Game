# Block Health Bar Implementation

## Tổng quan

Mỗi Block đã có sẵn `HealthBarBillboardGui` trong model với cấu trúc:

```
HealthBarBillboardGui
├── BackGround (Frame)
├── Bar (Frame)
│   └── UIGradient
└── Hp (TextLabel)
    └── UIStroke
```

Khác với Enemy (dùng `Humanoid.HealthChanged`), Block lưu máu qua **Attribute** `Health` trên model. Ta cần một script lắng nghe `GetAttributeChangedSignal("Health")` để cập nhật UI.

---

## Cơ chế hoạt động hiện tại

| Thành phần | File | Vai trò |
|---|---|---|
| Gán Health ban đầu | `PlacementController.lua` | `newItem:SetAttribute("Health", config.Health)` |
| Trừ máu | `DamageHandler.lua` | `target:SetAttribute("Health", newHealth)` |
| Xoá block | `DamageHandler.lua` | `target:Destroy()` khi Health ≤ 0 |
| Config máu tối đa | `ItemConfigurations.lua` | Trường `Health` của từng block |

---

## Script cần tạo

### Vị trí đặt script

Trong **mỗi Block model** (RockBlock, ConcreteBlock, v.v.), thêm script tại:

```
Blocks/RockBlock/HealthBarBillboardGui/HealthUpdater (Script, RunContext: Server)
```

> Đặt cùng vị trí với `HealthUpdater` của Enemy để nhất quán cấu trúc.

---

### Nội dung script

```lua
-- HealthBarBillboardGui/HealthUpdater
-- Cập nhật thanh máu block dựa trên Attribute "Health"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations)

local billboard = script.Parent
local bar = billboard:WaitForChild("Bar")
local hpText = billboard:WaitForChild("Hp")

local block = billboard.Parent
local barOriginalSize = bar.Size

-- Lấy maxHealth từ config theo tên block
local config = ItemConfigurations.ItemConfigurations[block.Name]
local maxHealth = (config and config.Health) or 100

-- Gán Adornee về PrimaryPart (hoặc phần BasePart đầu tiên)
local adornee = block.PrimaryPart or block:FindFirstChildWhichIsA("BasePart")
billboard.Adornee = adornee

local function updateHealthBar()
    local currentHealth = math.max(0, block:GetAttribute("Health") or maxHealth)
    local healthPercent = currentHealth / maxHealth

    bar.Size = UDim2.new(
        barOriginalSize.X.Scale * healthPercent,
        barOriginalSize.X.Offset * healthPercent,
        barOriginalSize.Y.Scale,
        barOriginalSize.Y.Offset
    )

    hpText.Text = math.floor(currentHealth) .. " / " .. math.floor(maxHealth)

    -- Ẩn khi còn đầy máu, hiện khi bị đánh
    billboard.Enabled = healthPercent < 1
end

-- Chạy lần đầu
task.defer(updateHealthBar)

-- Lắng nghe thay đổi Health attribute
block:GetAttributeChangedSignal("Health"):Connect(updateHealthBar)
```

---

## Cài đặt BillboardGui Properties

Mở `HealthBarBillboardGui` trong mỗi block và đảm bảo các thuộc tính sau:

| Property | Giá trị gợi ý |
|---|---|
| `Size` | `{0, 4}, {0, 0.5}` (hoặc tương tự enemy) |
| `StudsOffset` | `{0, 2.5, 0}` (hiện phía trên block) |
| `AlwaysOnTop` | `false` |
| `Enabled` | `false` (script sẽ bật khi cần) |
| `Adornee` | *(để trống — script gán lúc runtime)* |

---

## Cách nhân rộng ra tất cả Block

Tất cả 10 block đều cần script này. Thay vì copy thủ công, dùng một trong hai cách:

### Cách 1 – Dùng `CollectionService` (Script chung tại ServerScriptService)

Tạo một script duy nhất tại `ServerScriptService` xử lý toàn bộ block có tag `"Damageable"`:

```lua
-- ServerScriptService/Controllers/BlockHealthBarController.lua

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations)

local function setupHealthBar(block: Model)
    local billboard = block:FindFirstChild("HealthBarBillboardGui", true)
    if not billboard then return end

    local bar = billboard:FindFirstChild("Bar")
    local hpText = billboard:FindFirstChild("Hp")
    if not bar or not hpText then return end

    local config = ItemConfigurations.ItemConfigurations[block.Name]
    local maxHealth = (config and config.Health) or 100
    local barOriginalSize = bar.Size

    local adornee = block.PrimaryPart or block:FindFirstChildWhichIsA("BasePart")
    billboard.Adornee = adornee

    local function update()
        local currentHealth = math.max(0, block:GetAttribute("Health") or maxHealth)
        local pct = currentHealth / maxHealth

        bar.Size = UDim2.new(
            barOriginalSize.X.Scale * pct,
            barOriginalSize.X.Offset * pct,
            barOriginalSize.Y.Scale,
            barOriginalSize.Y.Offset
        )
        hpText.Text = math.floor(currentHealth) .. " / " .. math.floor(maxHealth)
        billboard.Enabled = pct < 1
    end

    task.defer(update)
    block:GetAttributeChangedSignal("Health"):Connect(update)
end

-- Xử lý block đã tồn tại và block mới được đặt
CollectionService:GetInstanceAddedSignal("Damageable"):Connect(setupHealthBar)
for _, block in CollectionService:GetTagged("Damageable") do
    task.spawn(setupHealthBar, block)
end
```

> **Ưu điểm**: Một file duy nhất, không cần sửa từng block model.  
> **Điều kiện**: `PlacementController.lua` đã gán tag `"Damageable"` cho tất cả block khi đặt — điều này đã đúng.

### Cách 2 – Script riêng trong từng Block model

Copy script `HealthUpdater` vào từng `HealthBarBillboardGui` của 10 block. Phù hợp nếu muốn giữ cấu trúc giống Enemy.

---

## Luồng dữ liệu hoàn chỉnh

```
Đặt block
    └── PlacementController.lua
            └── SetAttribute("Health", config.Health)   ← maxHealth
                    └── Tag "Damageable" được gán

Enemy tấn công block
    └── DamageHandler.lua
            └── SetAttribute("Health", newHealth)
                    └── GetAttributeChangedSignal("Health") kích hoạt
                            └── HealthUpdater cập nhật Bar.Size & Hp.Text

Health ≤ 0
    └── DamageHandler.lua → block:Destroy()
```

---

## Kiểm tra

1. Đặt một block vào plot
2. Để enemy đánh block
3. Kiểm tra thanh máu hiện ra và thu nhỏ dần
4. Block bị phá → thanh máu biến mất cùng block
5. Block mới đặt → thanh máu ẩn (đầy máu), chỉ hiện khi bị đánh
