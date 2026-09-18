# Titan TV Man Support System — Plan

## Tổng quan

Khi player chạm vào TouchPart của Titan TV Man, hệ thống sẽ:
1. Kiểm tra cooldown của player (10 phút, lưu trong data)
2. Mở DialogueFrame với Titan TV Man
3. Nếu còn cooldown → dialogue hiện tin nhắn "Come back in X:XX minutes." (không cấp thưởng)
4. Nếu sẵn sàng → dialogue hiện tin nhắn kết quả thưởng, trao thưởng, bắt đầu đếm ngược

---

## Cấu trúc wave tier

| Tier | Wave |
|------|------|
| Low  | < 20 |
| Mid  | 20 – 39 |
| High | 40 – 60 |

---

## Bảng phần thưởng

### 1. Cash — 50%

| Tier | Range |
|------|-------|
| Low  | 200 – 400 |
| Mid  | 10,000 – 15,000 |
| High | 80,000 – 120,000 |

### 2. Turret — 15%

| Tier | Turrets |
|------|---------|
| Low  | CameraGuy, TvGuy, EngineerCameraGuy |
| Mid  | LaserCameramanCar, LargeTvGuy, LargeScientistCameraman |
| High | TitanCameraGuy, TitanTVMan |

### 3. Block — 25%

| Tier | Blocks |
|------|--------|
| Low  | Rock Block, Concrete Block, Ice Block |
| Mid  | Lava Block, Toxic Block, Gold Block |
| High | Plasma Block, Gold Block |

### 4. Weapon — 10%

Trao ngay cho player, không cần đặt thêm.

| Tier | Weapons |
|------|---------|
| Low  | Upgraded Plunger, Spike Plunger |
| Mid  | Blue Sword, Red Sword |
| High | Red Cross Sword, Eviscerator Axe |

---

## Cooldown

- Thời gian: **10 phút (600 giây)** per player
- Lưu trong **ProfileService** — thêm key `TitanTVManLastSupport = 0` (Unix timestamp) vào `ProfileTemplate` trong `PlayerController.lua`
- Mỗi player tính độc lập, không ảnh hưởng lẫn nhau
- Reset sau 10 phút tính từ lần dùng, **không** reset khi rejoin

---

## TimerLabel

Path: `Workspace/UpgradedTitanModels/Floor/RestockGUI/TimerLabel`

| Trạng thái | Nội dung |
|-----------|----------|
| Sẵn sàng | `"Ready for Support"` |
| Đang cooldown | `"MM:SS"` đếm ngược còn lại |

- Mỗi player thấy timer **của riêng mình** → render bằng **LocalScript**
- Client poll mỗi giây, tính từ timestamp lưu trong data

---

## Cơ chế trao thưởng (dựa theo SpinWheel)

| Loại | Cơ chế |
|------|--------|
| **Cash** | `leaderstats.Cash.Value += amount` |
| **Turret** | `profile.Data.BlockInventory[turretId] += 1` → fire `BlockInventoryUpdated` |
| **Block** | `profile.Data.BlockInventory[blockId] += 1` → fire `BlockInventoryUpdated` |
| **Weapon** | `table.insert(profile.Data.WeaponInventory, weaponId)` → fire `WeaponInventoryUpdated` |

> Turret và Block đều dùng chung `BlockInventory` — đúng theo cách SpinWheel đang làm.

## Wave của player

Đọc từ `profile.Data.HighestWave` (ProfileService) — wave cao nhất đạt được.

---

## Files cần tạo / sửa

### Server

| File | Việc cần làm |
|------|-------------|
| `ServerScriptService/Controllers/PlayerController.lua` | Thêm `TitanTVManLastSupport = 0` vào `ProfileTemplate` |
| `ServerScriptService/DialogueServer.server.lua` | Thêm RemoteEvent/Function, logic roll thưởng, kiểm tra/lưu cooldown, trao thưởng, fire dialogue |

### Client

| File | Việc cần làm |
|------|-------------|
| `StarterPlayer/StarterPlayerScripts/TitanTVManTimer.client.lua` | Script mới — poll cooldown từ server mỗi giây, cập nhật TimerLabel |

### Remotes cần thêm (trong DialogueServer)

| Remote | Loại | Chiều | Dùng để |
|--------|------|-------|---------|
| `tvManSupportResult` | RemoteEvent | Server → Client | Fire dialogue text sau khi xử lý (cooldown hoặc reward) |
| `getTVManCooldown` | RemoteFunction | Client → Server | Client hỏi số giây cooldown còn lại khi join/respawn |

---

## Flow chi tiết

```
Player touch TouchPart
    │
    ▼
Server kiểm tra TitanTVManLastSupport trong data
    │
    ├─ Còn cooldown
    │       │
    │       ▼
    │   Fire setDialogueImageEvent + createDialogueEvent
    │   Dialogue: 1 trong 5 câu cooldown (random), thay {time} = MM:SS còn lại
    │
    └─ Hết cooldown
            │
            ▼
        Roll reward (math.random 1–100)
            ├─ 1–50   → Cash
            ├─ 51–75  → Block
            ├─ 76–90  → Turret
            └─ 91–100 → Weapon (trao ngay)
            │
            ▼
        Trao thưởng cho player
        Lưu timestamp = os.time() vào data
        Fire setDialogueImageEvent + createDialogueEvent
        Dialogue: 1 trong 3 câu ready (random), thay {item} = tên phần thưởng
            │
            ▼
Client TitanTVManTimer bắt đầu đếm ngược TimerLabel
```

---

## Dialogue lines

### Cooldown (5 câu random, `{time}` = MM:SS còn lại)

1. `"Hold on, brother! I'm preparing your support package. Please wait {time} more."`
2. `"I'm working on it, comrade! Your supply drop will be ready in {time}. Stay strong!"`
3. `"Easy there! I'm gathering resources for you. Come back in {time}, I'll have it ready."`
4. `"Support is being loaded, soldier! Return in {time} and I'll hook you up."`
5. `"Not just yet, friend. I need {time} more to get your package ready. Don't go too far!"`

### Ready (3 câu random, `{item}` = tên phần thưởng)

1. `"Support is ready, brother! I've got {item} for you. Go make them pay!"`
2. `"Your supply drop has arrived! Here's {item} — use it well, comrade!"`
3. `"Finally ready! Take this {item} and show those enemies what we're made of!"`

---

## Thứ tự implement

1. Thêm `TitanTVManLastSupport` vào data schema (PlayerController)
2. Tạo RemoteEvent `tvManSupportResult` + RemoteFunction `getTVManCooldown` trong DialogueServer
3. Viết logic roll + trao thưởng trong DialogueServer (tách hàm riêng cho cash/turret/block/weapon)
4. Tạo `TitanTVManTimer.client.lua` — poll cooldown, cập nhật TimerLabel
5. Cập nhật DialogueController — nhận `tvManSupportResult`, hiện dialogue tương ứng
6. Test từng reward type riêng bằng cách hardcode roll result
