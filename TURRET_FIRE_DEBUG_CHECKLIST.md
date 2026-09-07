# Debug: Turret chạy animation bắn mới nhưng không có tia (tracer) và quái không mất máu

## ✅ ĐÃ FIX

Đã áp dụng fix trong `src/ServerScriptService/Controllers/TurretController.lua`:
- Xoá `attackTrack:GetMarkerReachedSignal("Fire"):Connect(...)`.
- Tách toàn bộ logic raycast/damage/tracer cũ thành hàm `fireAtTarget(turretModel, data)`
  (khai báo ở đầu file, sau `setFX`).
- Gọi `fireAtTarget(turretModel, data)` trực tiếp trong `TurretController:Start()`, ngay sau
  chỗ `data.attackTrack:Play()` — không còn phụ thuộc vào marker animation nữa.

Cần vào Studio test lại theo "Quy trình test đề xuất" bên dưới để xác nhận tia + damage hoạt động.

---

## ✅ Nguyên nhân đã xác nhận

Animation bắn mới **chỉ còn 1 keyframe duy nhất** (không còn dùng Marker tên `"Fire"` nữa).

Toàn bộ logic raycast + gây damage + bắn tia (`TurretFiredFX`) trong
`TurretController.lua` đang được kích hoạt **hoàn toàn dựa vào** sự kiện
`attackTrack:GetMarkerReachedSignal("Fire")` (dòng 106). Animation chỉ có 1 keyframe thì
không có timeline để đặt Marker → sự kiện `"Fire"` **không bao giờ** bắn ra → cả khối code
raycast/damage/tracer bên trong callback đó **không bao giờ chạy**, dù animation vẫn phát
bình thường (vì `data.attackTrack:Play()` ở dòng 279 là lệnh riêng, độc lập với marker).

→ Đây chính là lý do turret "bắn" (animation chạy) nhưng không có tia và quái không mất máu.

---

## Hướng sửa: bỏ phụ thuộc vào Marker, gọi logic bắn trực tiếp

Vì animation giờ không còn (và không cần) Marker, cần refactor `TurretController.lua` để
tách khối logic bắn ra khỏi callback `GetMarkerReachedSignal`, biến nó thành một hàm gọi
**trực tiếp** ngay khi turret bắt đầu bắn (thay vì chờ marker báo hiệu).

### Việc cần làm trong `src/ServerScriptService/Controllers/TurretController.lua`

1. **Xoá** đoạn:
   ```lua
   attackTrack:GetMarkerReachedSignal("Fire"):Connect(function()
       ...
   end)
   ```
   (dòng 106-186)

2. **Tách phần thân bên trong callback đó** thành 1 hàm riêng, ví dụ:
   ```lua
   local function fireAtTarget(turretModel: Model, data)
       if not data.currentTarget then return end
       local targetRoot = data.currentTarget:FindFirstChild("HumanoidRootPart")
       if not targetRoot then return end
       -- ... (giữ nguyên toàn bộ nội dung raycast + damage + FX cũ)
   end
   ```

3. **Gọi hàm này trực tiếp** tại nơi hiện đang `data.attackTrack:Play()`, trong
   `TurretController:Start()` (khoảng dòng 276-281):
   ```lua
   if now - data.lockOnTime >= 0.1 then
       data.lastFireTime = now
       if data.idleTrack and data.idleTrack.IsPlaying then data.idleTrack:Stop() end
       if data.attackTrack and not data.attackTrack.IsPlaying then
           data.attackTrack:Play()
           data.attackTrack:AdjustSpeed(waveSpeedMultiplier)
       end
       if not data.fxEnabled then
           data.fxEnabled = true
           setFX(turretModel, true)
       end
       fireAtTarget(turretModel, data)   -- THÊM: gọi bắn ngay, không chờ marker nữa
   end
   ```

> Không cần `task.delay` để đồng bộ với animation nữa vì animation chỉ có 1 keyframe
> (gần như tức thời) — bắn ngay khi bắt đầu animation là hợp lý về mặt hình ảnh.
> Nếu sau này muốn có độ trễ nhỏ cho đẹp mắt (animation vươn nòng ra trước khi bắn), có thể
> bọc `fireAtTarget(turretModel, data)` trong `task.delay(0.05, function() ... end)` — nhưng
> cần cẩn thận trường hợp turret/target bị destroy trong lúc delay (check lại `turretModel.Parent`
> và `data.currentTarget` bên trong closure trước khi bắn).

4. Các biến `ownerId`, `ownerPlayer`, `raycastParams`, `ignoreList` hiện được khai báo bên
   trong callback marker (dòng 111-122) — khi tách thành hàm `fireAtTarget`, giữ nguyên logic này
   bên trong hàm mới, không cần thay đổi.

---

## Checklist phụ (nếu sau khi sửa marker vẫn còn lỗi)

Nếu áp dụng fix trên mà vẫn không có tia/damage, kiểm tra tiếp theo thứ tự:

### A. Thiếu Attachment `"FirePoint"` trong model turret
- Dòng 68-73: script tìm mọi Attachment tên `FirePoint` trong turret làm gốc raycast.
  Nếu model turret mới không có Attachment này (hoặc đặt sai tên) → `data.attachments` rỗng
  → vòng lặp raycast không chạy lần nào.
- **Kiểm tra:** Explorer → turret model → tìm Attachment tên đúng `FirePoint` (case-sensitive).

### B. Raycast trúng vật cản trước khi tới quái
- Nếu raycast bị chặn bởi vật thể không nằm trong `ignoreList` → `hitSomething = false`
  → vẫn có tia (bắn tới điểm trúng vật cản) nhưng không damage.

### C. `hitModel` không có child `"Goal"`
- Dòng 144: `if hitHumanoid and hitModel and hitModel:FindFirstChild("Goal") then`.
  Nếu enemy model bị đổi cấu trúc, mất child `Goal` → dù raycast trúng chính xác, khối
  damage + tia vẫn bị bỏ qua (rơi vào nhánh "miss" ở dòng 182-184).

### D. `TurretFiredFX` không tới client vì `ownerPlayer` nil
- Dòng 111-112: nếu `data.plot:GetAttribute("OwnerId")` sai hoặc player không còn trong game
  → `ownerPlayer` nil → `TurretFiredFX:FireClient` không được gọi → không có tia dù damage
  vẫn áp dụng bình thường ở server (log `[DamageHandler] TakeDamage` vẫn xuất hiện).

---

## Quy trình test đề xuất

1. Áp dụng fix ở phần "Hướng sửa" phía trên.
2. Vào chơi thử (Play Solo để xem cả Server + Client Output).
3. Đặt 1 turret, để 1 quái đứng yên trong tầm bắn, theo dõi Output:
   - `[TurretController] Fire → target: ... | damage: ... | HP before: ...` (dòng 147)
     → phải xuất hiện ngay khi turret bắt đầu animation bắn.
   - `[DamageHandler] TakeDamage → ... | -X | HP after: ...` (DamageHandler.lua dòng 22)
     → nếu dòng Fire xuất hiện nhưng dòng này không có → xem mục B, C ở trên.
   - Nếu cả 2 dòng trên đều có nhưng vẫn không thấy tia màu vàng trên màn hình → xem mục D,
     kiểm tra `ClientFXController.client.lua` dòng 277-290.

---

## File liên quan
- `src/ServerScriptService/Controllers/TurretController.lua` — toàn bộ logic target/animation/raycast/damage
- `src/ReplicatedStorage/Modules/DamageHandler.lua` — áp damage lên Humanoid/attribute Health
- `src/StarterPlayer/StarterPlayerScripts/ClientFXController.client.lua` (dòng 274-290) — vẽ tia tracer khi nhận `TurretFiredFX`
- `src/ReplicatedStorage/Modules/ItemConfigurations.lua` — config `Damage`, `Range`, `FireRate` theo turret
