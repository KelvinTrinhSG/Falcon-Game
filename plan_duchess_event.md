# Plan: The Duchess Event System

## Tổng quan

Event "The Duchess" xảy ra định kỳ mỗi 30 phút (tại giờ cố định: 5:00, 5:30, 6:00, …), kéo dài đúng 4 phút, có notification toàn server và countdown GUI. Toàn bộ code nằm trong thư mục riêng biệt.

---

## Cấu trúc thư mục

```
src/
├── ServerScriptService/
│   └── DuchessEvent/                          ← NEW folder (Server)
│       ├── DuchessEventController.server.lua  ← FSM chính, scheduler, logic
│       └── DuchessEventTestButton.server.lua  ← Test button handler
│
├── StarterPlayer/
│   └── StarterPlayerScripts/
│       └── DuchessEvent/                      ← NEW folder (Client)
│           └── DuchessEventClient.client.lua  ← Countdown GUI handler
│
└── StarterGui/
    └── GUI/
        └── Frames/
            └── DuchessEvent/                  ← NEW folder (GUI)
                └── DuchessCountdownFrame      ← GUI instance (ScreenGui)
                    └── CountdownLabel         ← TextLabel hiển thị 4:00 → 0:00
```

> **Remote Events** (thêm vào `ReplicatedStorage/Events/`):
> - `DuchessEventStart`  — FireAllClients khi event bắt đầu
> - `DuchessEventEnd`    — FireAllClients khi event kết thúc

---

## FSM (Finite State Machine)

```
┌────────────────────────────────────────────────────────┐
│                        STATES                          │
├──────────┬──────────────┬──────────────┬───────────────┤
│  IDLE    │  STARTING    │   ACTIVE     │   ENDING      │
└──────────┴──────────────┴──────────────┴───────────────┘

Transitions:
  IDLE     → STARTING  : Scheduler trigger (mỗi 30 phút) HOẶC test button
  STARTING → ACTIVE    : Notification đã gửi + Remote đã fired
  ACTIVE   → ENDING    : os.clock() - startTime >= 240s (4 phút)
  ENDING   → IDLE      : Cleanup hoàn tất (GUI xóa, remote fired)

Guard conditions (chống lỗi):
  - IDLE     → STARTING : chỉ khi currentState == IDLE (không cho trigger kép)
  - STARTING → ACTIVE   : chỉ khi currentState == STARTING
  - ACTIVE   → ENDING   : Timer forceful bằng task.delay(240, forceEnd) — bất kể gì xảy ra
  - ENDING   → IDLE     : chỉ khi currentState == ENDING
```

---

## Chi tiết từng file

### 1. `DuchessEventController.server.lua` (Server FSM chính)

**Responsibilities:**
- Quản lý `currentState` với các hàm `transitionTo(newState)`
- Scheduler: dùng `os.time()` tính giây đến mốc 30 phút kế tiếp rồi `task.delay`
- Khi `STARTING`:
  - `FireAllClients(DuchessEventStart, startTime)` để client biết bắt đầu
  - Gửi notification toàn server qua `ShowNotification` event: *"⚔️ Astro Toilet is attacking! Defend the main base now!"* (type = "Warning")
  - `task.delay(240, forceEnd)` — hard timer, không cancel được
- Khi `ENDING`:
  - `FireAllClients(DuchessEventEnd)`
  - Reset state về `IDLE`
  - Tính và schedule trigger kế tiếp

**FSM logic:**
```lua
local STATE = { IDLE="IDLE", STARTING="STARTING", ACTIVE="ACTIVE", ENDING="ENDING" }
local currentState = STATE.IDLE

local function transitionTo(newState)
    -- guard: validate transition is legal
    currentState = newState
    -- dispatch handlers
end
```

**Scheduler logic:**
```lua
local function getSecondsToNextTrigger()
    local now = os.time()
    -- tính giây đến mốc :00 hoặc :30 tiếp theo
    local minutes = math.floor(now / 60) % 60
    local secondsIntoMinute = now % 60
    local minutesToNext = (minutes % 30 == 0 and secondsIntoMinute == 0)
        and 30
        or (30 - (minutes % 30))
    return minutesToNext * 60 - secondsIntoMinute
end
```

---

### 2. `DuchessEventTestButton.server.lua` (Test trigger)

- Tạo một `TextButton` trong `StarterGui` chỉ visible với player có `UserId == 11115679011`
- Khi click → gọi `RemoteEvent` → Server nhận → gọi `triggerEvent()` nếu state == IDLE
- Button chỉ hoạt động khi `currentState == IDLE` (tránh spam)

> **Lưu ý:** Button test này là một RemoteEvent riêng `DuchessTestTrigger` chỉ server xử lý khi UserId khớp — client không thể fake trigger vì server kiểm tra UserId.

---

### 3. `DuchessEventClient.client.lua` (Client countdown GUI)

**Responsibilities:**
- Lắng nghe `DuchessEventStart` → hiện countdown GUI + bắt đầu đếm ngược
- Lắng nghe `DuchessEventEnd` → ẩn/xóa countdown GUI ngay lập tức
- Countdown loop: cập nhật label mỗi giây (4:00, 3:59, …, 0:01, 0:00)
- Khi đếm về 0 tự cleanup (double protection)

---

### 4. GUI: `DuchessCountdownFrame`

**Design** (clone style từ Notification hiện tại):
```
┌─────────────────────────────────────┐
│  ⚔️  ASTRO TOILET EVENT              │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│          ⏱  3:47                    │
│    Defend the main base now!        │
└─────────────────────────────────────┘
```
- Màu sắc: gradient đỏ/tím (Warning style, giống notification Warning)
- Vị trí: góc trên phải màn hình (dưới notification thường)
- Font: đậm, dễ đọc
- Tween fade-in khi xuất hiện, fade-out khi kết thúc

---

## Luồng hoàn chỉnh

```
[Server Scheduler / Test Button]
        │
        ▼
  currentState == IDLE?
        │ YES
        ▼
  transitionTo(STARTING)
  → FireAllClients(DuchessEventStart, os.time())
  → ShowNotification toàn server: "⚔️ Astro Toilet is attacking! Defend the main base now!"
  → task.delay(240, forceEnd)   ← HARD LOCK 4 phút
        │
        ▼
  transitionTo(ACTIVE)
        │
  [Client nhận DuchessEventStart]
  → Hiện CountdownFrame
  → Bắt đầu vòng lặp đếm ngược
        │
  [Sau đúng 240 giây]
        ▼
  forceEnd() được gọi (dù bất kỳ chuyện gì)
  transitionTo(ENDING)
  → FireAllClients(DuchessEventEnd)
        │
  [Client nhận DuchessEventEnd]
  → Xóa CountdownFrame ngay lập tức
        │
        ▼
  transitionTo(IDLE)
  → Schedule trigger kế tiếp
```

---

## Remote Events cần tạo

| Tên | Hướng | Payload |
|-----|-------|---------|
| `DuchessEventStart` | Server → AllClients | `startTime: number` (os.time) |
| `DuchessEventEnd` | Server → AllClients | (không có) |
| `DuchessTestTrigger` | Client → Server | (không có) |

---

## Checklist implementation

- [ ] Tạo RemoteEvents trong ReplicatedStorage/Events
- [ ] Tạo thư mục `ServerScriptService/DuchessEvent/`
- [ ] Viết `DuchessEventController.server.lua` (FSM + Scheduler)
- [ ] Viết `DuchessEventTestButton.server.lua` (Test button)
- [ ] Tạo thư mục `StarterPlayer/StarterPlayerScripts/DuchessEvent/`
- [ ] Viết `DuchessEventClient.client.lua` (GUI handler)
- [ ] Tạo GUI `DuchessCountdownFrame` trong `StarterGui/GUI/Frames/DuchessEvent/`
- [ ] Test: Aplayer3210 click button → event chạy 4 phút → tự kết thúc
- [ ] Test: double-trigger bị block (guard condition)
- [ ] Test: sau 4 phút GUI tự mất dù không có DuchessEventEnd
