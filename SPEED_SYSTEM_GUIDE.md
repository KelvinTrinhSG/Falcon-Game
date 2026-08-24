# Hệ Thống Wave Speed

## Các Mức Tốc Độ Hiện Tại

| Multiplier | Tên | Yêu Cầu |
|---|---|---|
| x1 | Bình thường | Miễn phí |
| x3 | Tăng tốc | Gamepass `1831192303` hoặc attribute `HasX3WavePass = true` (từ Spin Wheel) |

---

## Các File Liên Quan

| File | Vai trò |
|---|---|
| `src/ServerScriptService/Controllers/WaveController.lua` | Logic server — validate (button), apply multiplier |
| `src/ServerScriptService/Services/DebugService.lua` | Server — nhận lệnh từ chat, gọi `WaveController:SetWaveSpeed` |
| `src/StarterGui/GUI/HUD/Top/Buttons/SpeedButtonsHandler.client.lua` | UI client — nút bấm, hiển thị multiplier |
| `src/StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua` | Client — parse chat command `/wavespeed <n>` |

---

## Hai Đường Vào Hệ Thống Speed

| Đường | Client file | Server file | Validation |
|---|---|---|---|
| Nút bấm UI | `SpeedButtonsHandler.client.lua` | `WaveController` qua RemoteEvent `ChangeWaveSpeed` | Chỉ nhận `1`, `2`, `3` — x3 cần Gamepass |
| Chat command `/wavespeed <n>` | `DebugController.lua` | `DebugService` → `WaveController:SetWaveSpeed` | Không có — nhận bất kỳ số nào |

> Chat command `/wavespeed 2` hoạt động ngay mà không cần Gamepass hay validation.

---

## Cách Hoạt Động

### Server — [WaveController.lua:472-537](src/ServerScriptService/Controllers/WaveController.lua#L472-L537)

**Khi nhận event `ChangeWaveSpeed` từ client:**

1. Validate multiplier — chỉ chấp nhận `1` hoặc `3`:
   ```lua
   if multiplier ~= 1 and multiplier ~= 3 then return end
   ```

2. Nếu multiplier = `3`, kiểm tra quyền:
   ```lua
   MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_X3_SPEED)
   -- hoặc
   player:GetAttribute("HasX3WavePass") == true
   ```

3. Lưu multiplier vào `_playerSpeeds[player]` và attribute `WaveSpeedMultiplier`.

4. Set `WaveSpeed` attribute trên plot của player.

5. Cập nhật ngay WalkSpeed của **tất cả enemy đang sống** thuộc plot đó:
   ```lua
   hum.WalkSpeed = baseSpeed * multiplier
   ```

**Khi enemy mới spawn** (line 260-262):
```lua
local currentSpeed = _playerSpeeds[player] or 1
humanoid:SetAttribute("BaseWalkSpeed", humanoid.WalkSpeed)
humanoid.WalkSpeed = humanoid.WalkSpeed * currentSpeed
```

`BaseWalkSpeed` được lưu lại để tính đúng khi multiplier thay đổi sau đó.

---

### Client — [SpeedButtonsHandler.client.lua](src/StarterGui/GUI/HUD/Top/Buttons/SpeedButtonsHandler.client.lua)

- **Speed1** button → `FireServer(1)`
- **Speed3** button → `FireServer(3)` nếu có quyền, nếu không thì mở prompt mua Gamepass
- Text của Speed1 button hiển thị multiplier hiện tại (`x1`, `x3`, ...) theo attribute `WaveSpeedMultiplier`

---

## Chat Commands (Debug)

Gõ trong chat Roblox — chỉ hoạt động khi có quyền admin / debug:

```
/wavespeed 1   → x1 speed
/wavespeed 2   → x2 speed
/wavespeed 3   → x3 speed
/wavespeed 0.5 → slow motion (không có UI, nhưng chat vẫn nhận)
```

Flow: `DebugController` (client) → `DebugService:SetWaveSpeed` (server) → `WaveController:SetWaveSpeed` — **không qua validation**, không cần Gamepass.

---

## Cách Thêm Mức x2

### Bước 1 — Server: thêm `2` vào validation

Mở [WaveController.lua:507](src/ServerScriptService/Controllers/WaveController.lua#L507), sửa:

```lua
-- CŨ:
if multiplier ~= 1 and multiplier ~= 3 then return end

-- MỚI:
if multiplier ~= 1 and multiplier ~= 2 and multiplier ~= 3 then return end
```

### Bước 2 — Client: thêm nút Speed2 trong GUI

Trong [SpeedButtonsHandler.client.lua](src/StarterGui/GUI/HUD/Top/Buttons/SpeedButtonsHandler.client.lua):

```lua
local speed2Btn = buttonsFolder:WaitForChild("Speed2")

speed2Btn.MouseButton1Click:Connect(function()
    requestWaveSpeed(2)
end)
```

Và tạo thêm button `Speed2` trong Studio tương tự `Speed1` / `Speed3`.

---

## Hằng Số Quan Trọng

```lua
-- WaveController.lua
local GAMEPASS_X3_SPEED = 1831192303  -- ID Gamepass x3 Speed

-- SpeedButtonsHandler.client.lua
local GAMEPASS_X3_SPEED = 1831192303  -- phải khớp với server
```
