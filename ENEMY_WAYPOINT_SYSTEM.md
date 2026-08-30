# Enemy Waypoint Movement System

## Tổng quan

Enemy di chuyển theo Waypoints bằng `humanoid:MoveTo()` trực tiếp — **không dùng PathfindingService**. Logic chính nằm trong hàm `moveEnemyAlongWaypoints()` trong [WaveController.lua](src/ServerScriptService/Controllers/WaveController.lua).

---

## Cấu trúc Waypoints

```
Workspace
└── [PlotFolder]
    └── Path
        └── Waypoints
            ├── 1        (BasePart)
            ├── 2        (BasePart)
            ├── 3        (BasePart)
            └── End      (BasePart — waypoint cuối cùng)
```

- Waypoints là **BasePart objects**, được đặt tên bằng số (`"1"`, `"2"`, ...) hoặc `"End"`
- Thứ tự di chuyển: `1 → 2 → 3 → ... → End`

---

## Luồng hoạt động

### 1. Spawn Enemy

Trong hàm `startNextWave()` ([WaveController.lua ~L241](src/ServerScriptService/Controllers/WaveController.lua)):

1. Clone enemy từ `ReplicatedStorage.Enemies`
2. Gán vị trí spawn ngẫu nhiên tại `EnemySpawn`
3. Set hai ObjectValue trên enemy:
   - **Goal** → `Core1` (target ban đầu)
   - **OwnerPlot** → plot hiện tại
4. Đưa enemy vào `Workspace.ActiveEnemies`
5. Gọi `moveEnemyAlongWaypoints(enemy, plot, state)`

### 2. Sắp xếp Waypoints ([WaveController.lua ~L78–93](src/ServerScriptService/Controllers/WaveController.lua))

```lua
-- Thu thập tất cả BasePart trong waypointsFolder
-- Sắp xếp theo quy tắc:
--   "End" luôn đứng cuối
--   Numeric: sắp xếp tăng dần (1, 2, 3...)
--   Non-numeric: sắp xếp alphabetical
```

### 3. Di chuyển qua từng Waypoint ([WaveController.lua ~L95–178](src/ServerScriptService/Controllers/WaveController.lua))

```lua
for _, wp in ipairs(waypoints) do
    -- Cập nhật Goal của enemy = waypoint hiện tại
    goalValue.Value = wp

    -- Vòng lặp check khoảng cách (mỗi 0.1s)
    while not reached and humanoid.Health > 0 do
        -- Kiểm tra vật cản phía trước
        -- Nếu bị chặn: dừng lại, tấn công block
        -- Nếu không bị chặn: humanoid:MoveTo(wp.Position)

        -- Tính khoảng cách nằm ngang (bỏ qua Y)
        local dist = (Vector3.new(pos.X, 0, pos.Z)
                    - Vector3.new(wp.Position.X, 0, wp.Position.Z)).Magnitude

        if dist <= requiredDistance then
            reached = true
        end
    end
end
```

**Ngưỡng khoảng cách đến waypoint:**
| Waypoint | Ngưỡng |
|----------|--------|
| Thông thường (1, 2, 3...) | 1.5 studs |
| `"End"` | 5 studs |

> Tính khoảng cách chỉ trên trục **X, Z** (Y = 0), nên không bị ảnh hưởng bởi độ cao.

---

## Xử lý va chạm với Block

### Phát hiện vật cản ([WaveController.lua ~L118–173](src/ServerScriptService/Controllers/WaveController.lua))

- Dùng `Workspace:GetPartBoundsInBox()` với hitbox phía trước enemy:
  - Offset: `(0, 0, -1.5)` so với vị trí enemy
  - Kích thước: `1.5 × 4 × 2` studs
- Chỉ check các part trong phạm vi plot hiện tại

### Khi bị chặn

1. `humanoid:MoveTo(rootPart.Position)` — dừng tại chỗ
2. Kiểm tra block có attribute `IsPlacedItem` → xác định là block (không phải turret)
3. Tấn công block với damage = `enemyConfig.Damage`
4. Cooldown tấn công: `1 / waveSpeedMultiplier` giây
5. Block chết → enemy tiếp tục đi waypoint tiếp theo

---

## Khi đến Waypoint "End"

```lua
-- Core1 nhận 10 damage
local newHealth = math.max(0, currentHealth - 10)
coreBuilding:SetAttribute("Health", newHealth)

-- Enemy chết ngay lập tức (không cho cash reward)
humanoid.Health = 0
```

---

## Wave Speed Multiplier

Hàm `WaveController:SetWaveSpeed()` ([~L476](src/ServerScriptService/Controllers/WaveController.lua)) ảnh hưởng đến:

| Thuộc tính | Công thức |
|------------|-----------|
| Walk speed | `baseSpeed × multiplier` |
| Attack cooldown | `1 / waveSpeedMultiplier` |
| Delay giữa lần spawn | `baseDelay / currentWaitSpeed` |

---

## Sơ đồ luồng tổng quát

```
Enemy Spawn tại EnemySpawn
        │
        ▼
Goal = Core1, OwnerPlot = plot
        │
        ▼
moveEnemyAlongWaypoints()
        │
        ▼
Sắp xếp Waypoints: [1] → [2] → [3] → [End]
        │
        ▼
┌─── Mỗi Waypoint ───────────────────────────┐
│  Goal.Value = waypoint hiện tại            │
│         │                                  │
│  ┌─ Check vật cản phía trước ─┐           │
│  │  Bị chặn?                  │           │
│  │  Có → Dừng, tấn công block │           │
│  │  Không → humanoid:MoveTo() │           │
│  └────────────────────────────┘           │
│         │                                  │
│  dist (X,Z) ≤ threshold? → Đến nơi        │
└────────────────────────────────────────────┘
        │
        ▼
Đến "End" waypoint
        │
        ▼
Core1 mất 10 HP → Enemy chết
```

---

## Files liên quan

| File | Vai trò |
|------|---------|
| [WaveController.lua](src/ServerScriptService/Controllers/WaveController.lua) | Logic chính: spawn wave, di chuyển enemy |
| [EnemyConfigurations.lua](src/ReplicatedStorage/Modules/EnemyConfigurations.lua) | Stats enemy: HP, Damage, CashReward |
| [WaveConfigurations.lua](src/ReplicatedStorage/Modules/WaveConfigurations.lua) | Định nghĩa wave: loại enemy, số lượng, delay |
| [PlotController.lua](src/ServerScriptService/Controllers/PlotController.lua) | Setup plot, validate waypoint structure |
