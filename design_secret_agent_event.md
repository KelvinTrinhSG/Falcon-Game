# Secret Agent Event — Plan

## Roblox Events system có dùng được không?

**Một phần.** Roblox Events system chỉ là công cụ **marketing/notification**:
- Notify player khi event bắt đầu
- Drive player vào game qua push notification
- Detect player join từ event qua `GameJoinContext.EventId`

Nó **không** tự spawn NPC, không tự trigger logic trong game.

Phần gameplay (spawn Secret Agent, collect, reward) phải tự code hoàn toàn.

### Cách kết hợp hợp lý:
| Việc | Dùng gì |
|------|---------|
| Thông báo event đến player | Roblox Events system (Creator Dashboard) |
| Detect player join từ event notification | `GameJoinContext.EventId` |
| Spawn Secret Agent, collect, reward | In-game scripting tự viết |

---

## Tổng quan gameplay

Trong khoảng thời gian event diễn ra:
- Server spawn **2 Secret Agent** tại **2 vị trí ngẫu nhiên** trong map
- Player chạm vào Secret Agent → **collect** → nhận **1 turret ngẫu nhiên** làm reward
- Secret Agent biến mất sau khi bị collect
- Sau một khoảng thời gian (ví dụ 5 phút), **2 Secret Agent mới** spawn lại

---

## Thông tin đã xác định

| Câu hỏi | Trả lời |
|---------|---------|
| Event active khi nào? | Tự động theo giờ |
| Vị trí spawn | Preset positions (đặt sẵn trong Studio) |
| Turret reward | Turret mới tên `SecretAgent` |

## Thông tin đầy đủ

| Câu hỏi | Trả lời |
|---------|---------|
| Event active khi nào? | Mỗi 1 giờ 1 lần, kéo dài 5 phút |
| Vị trí spawn | Preset positions đặt sẵn trong Studio |
| Số lượng spawn | 2 Secret Agent, chọn random từ preset pool |
| Collect limit | Mỗi player collect được 1 lần per event |
| Turret reward | Turret `SecretAgent` → vào `BlockInventory` |
| Model | Đã có sẵn trong Studio |
| Despawn | Xóa toàn bộ khi event kết thúc |

---

## Lịch event

- Dùng `os.time() % 3600` để xác định vị trí trong chu kỳ 1 giờ
- Event **active** khi `os.time() % 3600 < 300` (5 phút đầu mỗi giờ)
- Server check mỗi giây để bắt đầu/kết thúc event đúng lúc

```
Mỗi giờ:
  :00 → event BẮT ĐẦU — spawn 2 Secret Agent
  :05 → event KẾT THÚC — despawn tất cả, reset collected list
```

## Preset spawn positions

- Path: `Workspace/EventPlaces/SecretAgentEvent/PlaceHolders`
- **14 Part** trong folder, server đọc toàn bộ rồi **shuffle → lấy 2 đầu tiên**

## Per-player collect tracking

- Lưu trong **server-side table** (không cần vào ProfileService vì reset mỗi event):
```lua
local collectedThisEvent = {} -- { [player] = true }
```
- Reset khi event kết thúc

## Flow chi tiết

```
Server start
    │
    ▼
Loop mỗi giây — kiểm tra os.time() % 3600
    │
    ├─ == 0 (đầu giờ) → EVENT BẮT ĐẦU
    │       │
    │       ▼
    │   Chọn 2 spawn point random từ SecretAgentSpawnPoints
    │   Clone model SecretAgent, đặt tại 2 vị trí
    │   Fire client: hiện thông báo event bắt đầu
    │
    ├─ < 300 (trong 5 phút) → event đang chạy
    │       │
    │       └─ Player chạm vào Secret Agent
    │               │
    │               ├─ Player đã collect rồi → bỏ qua
    │               └─ Chưa collect
    │                       │
    │                       ▼
    │                   Despawn Secret Agent đó
    │                   collectedThisEvent[player] = true
    │                   Thêm "SecretAgent" vào BlockInventory
    │                   Fire BlockInventoryUpdated
    │                   Fire notification cho player
    │
    └─ == 300 (hết 5 phút) → EVENT KẾT THÚC
            │
            ▼
        Despawn tất cả Secret Agent còn lại
        Reset collectedThisEvent = {}
        Fire client: hiện thông báo event kết thúc
```

---

## Files cần tạo

| File | Việc |
|------|------|
| `ServerScriptService/SecretAgentEvent.server.lua` | Scheduler, spawn/despawn, touch, reward |
| `StarterPlayer/StarterPlayerScripts/SecretAgentClient.client.lua` | Nhận event notification, hiện thông báo bắt đầu/kết thúc |

## Cần làm trong Studio trước khi code

- `Workspace/EventPlaces/SecretAgentEvent/PlaceHolders` — đã có 14 Part ✓
- Xác nhận model `SecretAgent` nằm ở đâu (ReplicatedStorage hay ServerStorage?) để clone

## Thứ tự implement

1. Setup Studio: tạo `SecretAgentSpawnPoints`, xác nhận vị trí model `SecretAgent`
2. Viết `SecretAgentEvent.server.lua` — scheduler + spawn/despawn + touch + reward
3. Viết `SecretAgentClient.client.lua` — nhận notification từ server, hiện thông báo
4. Test: chỉnh `os.time() % 60` (mỗi phút) thay vì `% 3600` để test nhanh
5. Sau khi ổn, đổi lại `% 3600`
