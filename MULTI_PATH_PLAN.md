# Plan: Multi-Path Enemy System (Random WayPoints Folder)

## Mục tiêu

Thay vì chỉ có một tập waypoints, `Path/Waypoints` sẽ chứa nhiều thư mục con (`WayPoints1` … `WayPoints7`). Khi mỗi enemy spawn, nó **chọn ngẫu nhiên 1 thư mục** và di chuyển theo các part bên trong thư mục đó.

```
Path
└── Waypoints
    ├── WayPoints1 → 1, 2, 3, ... End
    ├── WayPoints2 → 1, 2, 3, ... End
    ├── WayPoints3 → 1, 2, 3, ... End
    ├── WayPoints4 → 1, 2, 3, ... End
    ├── WayPoints5 → 1, 2, 3, ... End
    ├── WayPoints6 → 1, 2, 3, ... End
    └── WayPoints7 → 1, 2, 3, ... End
```

---

## Thay đổi cần làm

### Chỉ 1 file cần sửa: [WaveController.lua](src/ServerScriptService/Controllers/WaveController.lua)

---

## Chi tiết từng thay đổi

### Thay đổi 1 — Hàm `moveEnemyAlongWaypoints` (dòng ~73–83)

**Hiện tại:** đọc thẳng `waypointsFolder:GetChildren()` để lấy các BasePart.

**Sau khi sửa:**
1. Lấy tất cả **Folder con** trong `waypointsFolder`
2. Nếu có Folder con → chọn random 1 Folder → đọc BasePart bên trong Folder đó
3. Nếu không có Folder con (backward-compatible) → đọc BasePart thẳng từ `waypointsFolder` như cũ

```lua
-- TRƯỚC (dòng 78–83)
local waypoints = {}
for _, wp in ipairs(waypointsFolder:GetChildren()) do
    if wp:IsA("BasePart") then
        table.insert(waypoints, wp)
    end
end

-- SAU
local waypoints = {}

-- Thu thập tất cả Folder con (WayPoints1, WayPoints2, ...)
local pathFolders = {}
for _, child in ipairs(waypointsFolder:GetChildren()) do
    if child:IsA("Folder") then
        table.insert(pathFolders, child)
    end
end

local sourceFolder: Folder | typeof(waypointsFolder)
if #pathFolders > 0 then
    -- Chọn random 1 trong các WayPoints folder
    sourceFolder = pathFolders[math.random(1, #pathFolders)]
else
    -- Backward-compatible: không có Folder con → dùng thẳng waypointsFolder
    sourceFolder = waypointsFolder
end

for _, wp in ipairs(sourceFolder:GetChildren()) do
    if wp:IsA("BasePart") then
        table.insert(waypoints, wp)
    end
end
```

> `sourceFolder` sau đó được dùng bình thường trong `table.sort` và vòng lặp di chuyển — không cần thêm thay đổi nào khác trong phần này.

---

### Thay đổi 2 — Hàm `onEnemyDeath` (dòng ~320–321)

**Vấn đề:** Hàm này tìm `End` waypoint trực tiếp trong `waypointsFolder` để check xem enemy có đến đích không. Sau khi đổi cấu trúc, `End` nằm trong Folder con, nên sẽ tìm không thấy → luôn cho cash dù enemy đã vào base.

**Sau khi sửa:** Tìm `End` trong tất cả Folder con, lấy cái nào gần enemy nhất.

```lua
-- TRƯỚC (dòng 320–321)
local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
local endPoint = waypointsFolder and waypointsFolder:FindFirstChild("End")

-- SAU
local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
local endPoint = nil

if waypointsFolder then
    -- Tìm End trong các Folder con
    for _, folder in ipairs(waypointsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            local ep = folder:FindFirstChild("End")
            if ep then
                -- Lấy End gần enemy nhất (enemy có thể đang ở path nào đó)
                if not endPoint or (rootPart and
                    (rootPart.Position - ep.Position).Magnitude <
                    (rootPart.Position - endPoint.Position).Magnitude)
                then
                    endPoint = ep
                end
            end
        end
    end
    -- Backward-compatible: End nằm thẳng trong waypointsFolder
    if not endPoint then
        endPoint = waypointsFolder:FindFirstChild("End")
    end
end
```

---

## Không cần thay đổi

| Phần code | Lý do |
|-----------|-------|
| Logic sort waypoints (dòng 85–93) | Vẫn sort theo tên, không đổi |
| Vòng lặp di chuyển (dòng 95–178) | Không thay đổi, chỉ `waypoints` table thay đổi nguồn |
| Block attack logic | Không liên quan đến path |
| `startNextWave()` | Không cần truyền thêm tham số |
| Roblox Studio (Waypoint parts) | Chỉ cần gom các part vào Folder con |

---

## Checklist thực hiện

- [ ] **Studio**: Tạo 7 Folder con trong `Path > Waypoints`: `WayPoints1` … `WayPoints7`
- [ ] **Studio**: Di chuyển (hoặc nhân bản) các part `1, 2, 3, ..., End` vào từng Folder theo path tương ứng
- [ ] **Code**: Sửa hàm `moveEnemyAlongWaypoints` — chọn random Folder con (Thay đổi 1)
- [ ] **Code**: Sửa hàm `onEnemyDeath` — tìm `End` trong Folder con (Thay đổi 2)
- [ ] **Test**: Spawn enemy nhiều lần, xác nhận mỗi lần chọn path khác nhau
- [ ] **Test**: Xác nhận cash reward vẫn bị trừ khi enemy vào base
- [ ] **Test**: Xác nhận Cash reward vẫn cho khi enemy bị kill trước End

---

## Lưu ý

- Mỗi Folder con **bắt buộc phải có** waypoint tên `"End"` — nếu thiếu, enemy sẽ đứng yên sau waypoint cuối và không damage base.
- Tên Folder con không quan trọng (không cần đúng `WayPoints1`) — code chỉ check `IsA("Folder")`.
- Backward-compatible: nếu `waypointsFolder` vẫn chứa BasePart trực tiếp (không có Folder con), hệ thống cũ vẫn hoạt động bình thường.
