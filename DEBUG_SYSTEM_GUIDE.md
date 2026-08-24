# Hệ Thống Debug (Chat Commands)

## Các File Liên Quan

| File | Vai trò |
|---|---|
| [src/StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua](src/StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua) | Client — lắng nghe chat, parse command, gọi DebugService |
| [src/ServerScriptService/Services/DebugService.lua](src/ServerScriptService/Services/DebugService.lua) | Server — thực thi lệnh (cấp cash, sword, speed) |

---

## Danh Sách Lệnh Chat

### Cash

| Lệnh | Mô tả | Số tiền |
|---|---|---|
| `/giveme` | Cấp cash cho bản thân | 1,000,000 |
| `/giveid <UserId>` | Cấp cash cho player theo UserId | 1,000,000 |
| `/giveall` | Cấp cash cho tất cả player trong server | 1,000,000 mỗi người |

### Sword (Vũ Khí)

| Lệnh | Mô tả |
|---|---|
| `/sword <SwordName>` | Cấp sword cho bản thân |
| `/swordid <UserId> <SwordName>` | Cấp sword cho player theo UserId |
| `/swordall <SwordName>` | Cấp sword cho tất cả player |

> `<SwordName>` phải khớp chính xác với key trong `WeaponConfigurations.Weapons`.

### Wave Speed

| Lệnh | Mô tả |
|---|---|
| `/wavespeed <number>` | Đặt tốc độ wave (vd: `/wavespeed 2`) |

> Không có validation — nhận bất kỳ số nào, kể cả `0.5` (slow motion).

---

## Flow Hoạt Động

```
Player gõ lệnh trong chat
        ↓
DebugController (client) — Players.LocalPlayer.Chatted
        ↓  parse command + args
DebugService (server, qua Knit RPC)
        ↓
  ┌─────────────────────────────────────────┐
  │ GiveSelf / GiveById / GiveAll           │ → cộng vào leaderstats.Cash
  │ GiveSwordSelf / GiveSwordById / ...     │ → thêm vào WeaponInventory + EquipWeapon
  │ SetWaveSpeed                            │ → WaveController:SetWaveSpeed
  └─────────────────────────────────────────┘
```

---

## Chi Tiết Từng Nhóm Lệnh

### Cash — `giveCash(player, amount)`

```lua
local REWARD = 1_000_000  -- DebugService.lua line 11

local function giveCash(player, amount)
    local cash = player.leaderstats.Cash
    cash.Value += amount
end
```

- Cộng thẳng vào `leaderstats.Cash` — **không lưu vào DataStore** (chỉ runtime).
- Nếu player disconnect thì mất (trừ khi DataStore auto-save bắt được trước).

### Sword — `giveSword(player, swordName)`

```lua
-- Kiểm tra sword tồn tại trong WeaponConfigurations
if not WeaponConfigurations.Weapons[swordName] then return false end

-- Thêm vào inventory nếu chưa có
if not table.find(profile.Data.WeaponInventory, swordName) then
    table.insert(profile.Data.WeaponInventory, swordName)
end

-- Set equipped + fire client update
profile.Data.LastEquippedWeapon = swordName
WeaponController:EquipWeapon(player, swordName)
ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)
```

- Lưu vào `profile.Data` (ProfileService) → **persist qua session**.
- Tự động equip ngay sau khi cấp.

### Wave Speed — `WaveController:SetWaveSpeed(player, multiplier)`

- Xem chi tiết tại [SPEED_SYSTEM_GUIDE.md](SPEED_SYSTEM_GUIDE.md).

---

## ⚠️ Cảnh Báo Bảo Mật

**Hiện tại không có kiểm tra quyền admin.** Bất kỳ player nào cũng có thể gõ:

```
/giveall      → cấp 1M cash cho toàn server
/swordall X   → cấp sword cho toàn server
/wavespeed 0  → đóng băng tất cả enemy
```

### Cách Thêm Whitelist Admin

Mở [DebugController.lua:24](src/StarterPlayer/StarterPlayerScripts/Controllers/DebugController.lua#L24), thêm kiểm tra trước khi xử lý lệnh:

```lua
local ADMIN_IDS = {
    123456789,  -- UserId của admin 1
    987654321,  -- UserId của admin 2
}

Players.LocalPlayer.Chatted:Connect(function(message: string)
    -- Chặn nếu không phải admin
    local userId = Players.LocalPlayer.UserId
    if not table.find(ADMIN_IDS, userId) then return end

    -- ... parse command như bình thường
end)
```

> Whitelist phải đặt ở **cả client lẫn server** (DebugService) để an toàn thực sự, vì client-side check có thể bị bypass.
