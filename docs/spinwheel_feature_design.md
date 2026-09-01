# SpinWheel — Thiết kế tính năng

## Tổng quan

SpinWheel là tính năng vòng quay may mắn cho phép người chơi nhận phần thưởng ngẫu nhiên. Có hai loại lượt quay: **Free Spin** (miễn phí, hồi sau 30 phút) và **Robux Spin** (mua bằng Robux, có cơ chế Lucky Roll đặc biệt).

---

## Kiến trúc

```
Client (StarterGui/SpinWheel/WheelAnimation.client.lua)
  └── UI animation, cooldown timer, button input
       │
       ▼ RemoteEvent: SpinWheelEvent
Server (ServerScriptService/WheelServer.server.lua)
  └── Loot roll, DataStore, item distribution
       │
       ▼ RemoteEvent: WheelCooldownEvent
Client ← nhận kết quả và cập nhật UI
```

### Các thành phần chính

| Thành phần | Vị trí | Vai trò |
|---|---|---|
| `WheelAnimation.client.lua` | StarterGui/SpinWheel | UI, animation, proximity check |
| `WheelServer.server.lua` | ServerScriptService | Logic, DataStore, phần thưởng |
| `SpinWheelEvent` | ReplicatedStorage | Gửi yêu cầu quay từ client → server |
| `WheelCooldownEvent` | ReplicatedStorage | Server trả kết quả / cooldown về client |
| `workspace.SpinWheel` | Workspace | Model 3D bánh xe |
| `workspace.SpinPad` | Workspace | Vùng chạm để mở UI |

---

## Luồng hoạt động

### 1. Mở UI
1. Người chơi bước vào vùng `SpinPad` (hoặc chạm vào pad).
2. Client phát hiện proximity → hiển thị `ScreenGui` SpinWheel.
3. Nếu người chơi rời xa > 18 studs, UI tự động đóng.

### 2. Free Spin
1. Người chơi bấm **Spin** (khi có `FreeSpins > 0` hoặc cooldown đã hết).
2. Client gửi `SpinWheelEvent` với type `"Free"`.
3. Server kiểm tra cooldown (1800s = 30 phút) qua DataStore.
4. Server roll loot theo bảng trọng số → trả phần thưởng.
5. Server gửi `WheelCooldownEvent` về client kèm kết quả.
6. Client chạy animation quay (5s, 360×5 vòng) → dừng đúng ô phần thưởng.
7. Hiển thị notification thưởng.

### 3. Robux Spin
1. Người chơi chọn gói Robux (1 / 3 / 10 lượt quay).
2. Kích hoạt Roblox MarketplaceService purchase với ProductID tương ứng.
3. Sau khi thanh toán, `RobuxSpins` của người chơi tăng.
4. Người chơi bấm **Lucky Spin** → gửi `SpinWheelEvent` với type `"Robux"`.
5. Server áp dụng **Lucky Roll**: re-roll kết quả và ưu tiên item hiếm hơn.
6. Animation nhanh hơn (1.5s, 360×3 vòng).

---

## Bảng loot (8 ô)

| Ô | Phần thưởng | Tỉ lệ |
|---|---|---|
| Item1 | (phổ biến) | 40% |
| Item2 | (phổ biến) | 25% |
| Item3 | (thường) | 15% |
| Item6 | (thường) | 10% |
| Item8 | (hiếm) | 5% |
| Item7 | (hiếm) | 3% |
| Item5 | (rất hiếm) | 1.5% |
| Item4 | (siêu hiếm) | 0.5% |

Loại phần thưởng thực tế bao gồm: **Extra Spins**, **Cash**, **Crates**, **Weapon Items**, **X3WavePass**.

### Lucky Roll (Robux Spin)
- Roll lần đầu theo bảng trọng số chuẩn.
- Re-roll thêm 1 lần → lấy kết quả có item hiếm hơn trong 2 lần roll.
- Không đảm bảo item siêu hiếm, nhưng tăng đáng kể xác suất tier cao.

---

## Cooldown & DataStore

- **Free Spin cooldown:** 1800 giây (30 phút), lưu vào DataStore theo `Player.UserId`.
- **Anti-spam save:** Tối thiểu 8 giây giữa 2 lần ghi DataStore.
- **Forced save:** Lưu ngay khi người chơi thoát hoặc server đóng.
- Client hiển thị đồng hồ đếm ngược (`MM:SS`) trên nút Spin khi đang cooldown.

---

## UI / Animation

### ScreenGui
- Hiển thị khi người chơi đứng gần SpinPad.
- Có nút **Spin** (Free), **Lucky Spin** (Robux), và nút **Rates** để xem tỉ lệ.
- Hover effect: nút phóng to nhẹ khi rê chuột (Tween).
- Đồng hồ đếm ngược cooldown hiển thị trên nút Spin.

### SurfaceGui / BillboardGui
- Bánh xe 3D hiển thị ngay trên `workspace.SpinWheel`.
- Idle animation: quay chậm 12°/giây liên tục.
- Spin animation:
  - **Free Spin:** Tween 5 giây, xoay thêm 360×5 + offset ô thưởng.
  - **Robux Spin:** Tween 1.5 giây, xoay thêm 360×3 + offset ô thưởng.

### Rates Panel
- Toggle hiển thị/ẩn bảng tỉ lệ khi bấm nút **Rates**.

---

## Tích hợp hệ thống khác

| Hệ thống | Cách dùng |
|---|---|
| `PlayerController` | Trao vũ khí / item cho người chơi sau khi quay |
| `CrateController` | Mở crate nếu phần thưởng là Crate |
| `ShowNotification` (RemoteEvent) | Hiển thị popup thông báo phần thưởng |
| `MarketplaceService` | Xử lý mua Robux Spin |
| `DataStoreService` | Lưu trạng thái cooldown và số lượt quay |

---

## Các điểm cần chú ý khi phát triển tiếp

- **Bảo mật:** Toàn bộ logic roll và kiểm tra cooldown phải nằm trên server — client chỉ gửi request và nhận kết quả.
- **Exploit prevention:** Server phải validate lại `FreeSpins` / `RobuxSpins` trước khi cho quay, không tin tưởng giá trị từ client.
- **DataStore fail-safe:** Nếu DataStore bị lỗi khi load, không cho quay Free Spin để tránh mất dữ liệu cooldown.
- **Mở rộng loot table:** Thêm ô mới cần cập nhật cả bảng trọng số lẫn vị trí ô trên bánh xe 3D.
- **Mobile UX:** Kiểm tra kích thước nút và proximity trigger trên màn hình nhỏ.
