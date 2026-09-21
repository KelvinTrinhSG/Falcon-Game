# Duchess / Astro Toilet Event System

## Tổng quan

Event tự động kích hoạt mỗi 30 phút, kéo dài 240 giây (4 phút). AstroToilet liên tục spawn và di chuyển theo waypoints để tấn công TVManShield. Player phải tiêu diệt chúng để bảo vệ shield.

- **Win**: shield còn HP khi hết giờ
- **Lose**: shield HP về 0 trước khi hết giờ

---

## Các file liên quan

### Server

| File | Vai trò |
|------|---------|
| `ServerScriptService/DuchessEvent/EventClass.lua` | Generic FSM engine cho mọi event |
| `ServerScriptService/DuchessEvent/DuchessEventController.server.lua` | Config + logic riêng của Duchess Event |
| `ServerScriptService/DuchessEvent/AstroToiletSpawner.lua` | Spawn và điều hướng AstroToilet |
| `ServerScriptService/DuchessEvent/EventSwordManager.lua` | Quản lý sword tạm thời cho player join event |
| `ServerScriptService/Controllers/BlockHealthBarController.lua` | Cập nhật HealthBarBillboardGui cho TVManShield |

### Client

| File | Vai trò |
|------|---------|
| `StarterPlayer/StarterPlayerScripts/DuchessEvent/DuchessEventClient.client.lua` | Countdown GUI + hiện/ẩn EventTeleport button |
| `StarterPlayer/StarterPlayerScripts/TeleportController.client.lua` | Xử lý click EventTeleport, hide HUD, stop wave |
| `ReplicatedStorage/Modules/EventClientClass.lua` | Generic client OOP class cho mọi event |

---

## FSM (Finite State Machine)

```
IDLE → STARTING → ACTIVE → ENDING → IDLE
```

- **IDLE**: chờ scheduler hoặc admin trigger
- **STARTING**: chạy `onStart`, fire notification tới client, bắt đầu hard timer
- **ACTIVE**: chờ hard timer (240s) hoặc admin EndTrigger hoặc shield HP = 0
- **ENDING**: chạy `onEnd`, fire End remote tới client, sau 0.5s về IDLE

---

## RemoteEvents (trong `ReplicatedStorage/Events/`)

| Tên | Hướng | Mục đích |
|-----|-------|----------|
| `DuchessEventStart` | Server → Client | Thông báo event bắt đầu, gửi `startTime` + `totalDuration` |
| `DuchessEventEnd` | Server → Client | Thông báo event kết thúc |
| `DuchessEventTestTrigger` | Client → Server | Admin trigger event (UserId: 11115679011) |
| `DuchessEventEndTrigger` | Client → Server | Admin kết thúc event sớm |
| `DuchessEventJoin` | Client → Server | Player click EventTeleport → server cấp SovereignSplitter |

---

## Chuỗi sự kiện khi Event START

1. `onStart` chạy:
   - Reset `eventResult = "win"`
   - **Props** stash từ `Workspace/.../DuchessToiletEvent/Props` sang `ServerStorage/.../DuchessToiletEvent/`
   - Clone từ ServerStorage vào Workspace:
     - `Path` → `Workspace/.../DuchessToiletEvent/`
     - `TVManShield` → `Workspace/.../DuchessToiletEvent/` (Health=100, tag "Damageable")
     - `DuchessToiletFolder/DuchessToilet` → `Workspace/.../DuchessToiletEvent/DuchessToiletFolder/`
     - `Blast` → `Workspace/.../DuchessToiletEvent/` (chỉ khi DuchessToilet clone thành công)
   - Connect shield HP listener: khi HP ≤ 0 → `eventResult = "lose"` → `_forceEnd()`
   - Teleport `UpgradedTitanModels/UpgradedTitanTVMan` đến CFrame event `{-111.828, Y=180°}`
   - Tắt CanTouch cả 2: `TouchParts/UpgradedTitanTVMan` và `TouchParts/UpgradedTitanTVManFail`
   - Hạ `UpgradedTitanModels/Floor` xuống Y = -100 (lưu CFrame gốc để restore)
   - `Spawner.start()` bắt đầu spawn AstroToilet mỗi 5 giây

2. Notification `"⚔️ Astro Toilet is attacking! Defend the main base now!"` fire tới tất cả client
3. Client hiện countdown 4:00 (sau delay 5.6s)
4. `EventTeleport` button hiện + Onboarding hand pointer

---

## Chuỗi sự kiện khi Event END

1. `onEnd` chạy:
   - Disconnect shield HP listener
   - `EventSwordManager.restoreAll()` — trả sword cũ cho tất cả player đã join
   - `Spawner.stop()` — dừng spawn + destroy tất cả AstroToilet còn sống
   - Destroy từ Workspace: `Path`, `TVManShield`, `DuchessToilet`, `Blast`
   - Unstash Props về Workspace
   - Teleport TVMan về vị trí mặc định `{-114.671, Y=0°}`
   - Set CanTouch theo kết quả:
     - **Win**: `UpgradedTitanTVMan` bật, `UpgradedTitanTVManFail` tắt
     - **Lose**: `UpgradedTitanTVManFail` bật, `UpgradedTitanTVMan` tắt
   - Restore Floor về CFrame gốc

2. Client nhận `DuchessEventEnd`:
   - Countdown ẩn đi
   - `EventTeleport` button ẩn
   - `TeleportController` restore HUD Top + Bottom (`isInDuchessEvent = false`)

---

## AstroToilet Spawner

- **Source**: `ReplicatedStorage/EventFolder/DuchessToiletEvent/AstroToilets/` (4 models, cycle theo thứ tự)
- **Spawn interval**: 5 giây
- **Waypoints**: `Workspace/EventFolder/DuchessToiletEvent/Path/Waypoints/` (1, 2, ... 7, End)
- **Movement**: `Humanoid:MoveTo()` re-issue mỗi 0.1s (tránh Roblox 8s timeout)
- **Collision**: Group "AstroToilets" không collide với group "Players"
- **Goal marker**: mỗi clone được thêm `BoolValue` tên `"Goal"` để sword hitbox nhận diện được
- **Khi đến End**: `model:Destroy()` + `damageShield()` (trừ 1 HP TVManShield)
- **Khi bị kill giữa đường**: `reachedEnd = false` → không gọi `damageShield()`

---

## EventSwordManager

Khi player click `EventTeleport`:
1. Client fire `DuchessEventJoin` → server `EventSwordManager.give(player)`
2. Tất cả tool trong Character (equipped) được đánh dấu `WasEquipped = true`
3. Tất cả tool (Character + Backpack) được di chuyển vào `ServerStorage/EventSwordStash/[UserId]/`
4. Clone `ReplicatedStorage/Weapons/SovereignSplitter` → parent vào Character (auto-equip)

Khi event kết thúc (`restoreAll()`):
1. Destroy `SovereignSplitter` (có attribute `IsEventTemp = true`)
2. Tool có `WasEquipped = true` → parent vào Character (re-equip)
3. Tool còn lại → parent vào Backpack
4. Luôn chạy trong `pcall` + clear stash folder dù có lỗi

---

## Client: EventTeleport Button

**File**: `TeleportController.client.lua`

Khi click:
1. `isInDuchessEvent = true`
2. Nếu đang Fighting → `ToggleWaveStateEvent:FireServer()` dừng wave
3. `hudTop.Visible = false`, `hudBottom.Visible = false`
4. `DuchessEventJoin:FireServer()` → nhận SovereignSplitter
5. Teleport đến `Workspace/ShopTeleport` + notification `"Joined Event"`

Guard Bottom re-show:
- `HealthUIController` tự động set `Bottom.Visible = true` khi wave stop
- `WaveUIStateChanged` listener dùng `task.defer` override lại nếu `isInDuchessEvent = true`

Khi event kết thúc (`DuchessEventEnd`):
- `isInDuchessEvent = false`
- Restore `hudTop.Visible = true`, `hudBottom.Visible = true` (trong `pcall`)

---

## TVManShield Health Bar

- Shield dùng cùng pattern với block: `Attribute "Health"` + CollectionService tag `"Damageable"`
- `BlockHealthBarController` tự động detect và cập nhật `HealthBarBillboardGui`
- Shield là `UnionOperation` (BasePart) không phải Model → controller có guard `IsA("Model")` trước khi access `PrimaryPart`

---

## Workspace layout khi event đang chạy

```
Workspace/
└── EventFolder/
    └── DuchessToiletEvent/
        ├── Path/              ← clone từ SS khi start, destroy khi end
        │   └── Waypoints/
        │       ├── 1 … 7
        │       └── End
        ├── TVManShield        ← clone từ SS, Health=100, tag Damageable
        ├── DuchessToiletFolder/
        │   └── DuchessToilet  ← clone từ SS khi start, destroy khi end
        └── Blast              ← clone từ SS khi start, destroy khi end

UpgradedTitanModels/
├── UpgradedTitanTVMan         ← pivot đến CFrame event khi start
├── Floor                      ← hạ Y=-100 khi start, restore khi end
└── TouchParts/
    ├── UpgradedTitanTVMan     ← CanTouch theo win/lose
    └── UpgradedTitanTVManFail ← CanTouch theo win/lose
```

---

## Admin controls (UserId: 11115679011)

- **"▶ Trigger Astro Event"** button → fire `DuchessEventTestTrigger`
- **"⏹ End Astro Event"** button → fire `DuchessEventEndTrigger`

Cả 2 button chỉ hiện với player có UserId đúng, được tạo bởi `EventClientClass`.
